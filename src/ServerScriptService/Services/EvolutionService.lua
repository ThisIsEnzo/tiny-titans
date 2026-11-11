--!strict
-- Server-owned evolution state (session only, no persistence).
-- Each player starts as the starter form from CreatureDefinitions. The server marks evolution
-- available when at least one evolved form requirement is met; the client may request one branch via the
-- RequestEvolution RemoteEvent. The server validates every request and records the
-- choice exactly once. Clients only ever send a branch name, never state.
-- Requests are also rate limited per player on the server (Config.EvolutionRequestCooldown).
-- Attributes replicated to all clients: "EvolutionForm" (string), "EvolutionAvailable" (bool).
-- Attributes are the source of truth for the UI. After each processed request the
-- requesting player (only) also receives EvolutionResult(reason: string) so the UI can
-- explain a rejection; requests dropped by the rate limit get no reply.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config") :: ModuleScript)
local Evolution = require(Shared:WaitForChild("Evolution") :: ModuleScript)
local CreatureDefinitions = require(Shared:WaitForChild("CreatureDefinitions") :: ModuleScript)

local EvolutionService = {}

local formChanged = Instance.new("BindableEvent")

-- Fires (player: Player, form: string) on the server only, after a valid evolution selection
-- (not on the reset back to the base form). RespawnService uses it for the life recap.
EvolutionService.FormChanged = formChanged.Event

local formByPlayer: { [Player]: string } = {}
local lastRequestAt: { [Player]: number } = {}
local playerData: any = nil
local resultEvent: RemoteEvent? = nil

local function refresh(player: Player)
    local form = formByPlayer[player]
    if form == nil then
        return
    end
    local biomass = playerData.GetBiomass(player) or 0
    player:SetAttribute("EvolutionForm", form)
    player:SetAttribute(
        "EvolutionAvailable",
        Evolution.IsAvailable(biomass, form, CreatureDefinitions)
    )
end

local function isAlive(player: Player): boolean
    local character = player.Character
    if character == nil then
        return false
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid ~= nil and humanoid.Health > 0
end

local function onPlayerAdded(player: Player)
    if formByPlayer[player] ~= nil then
        return
    end
    formByPlayer[player] = CreatureDefinitions.StarterFormId
    refresh(player)
end

local function reply(player: Player, reason: string)
    if resultEvent ~= nil and player.Parent == Players then
        resultEvent:FireClient(player, reason)
    end
end

-- Rejected requests change nothing; the requester gets the reason, everyone else sees nothing.
-- The rate limit runs first, so invalid and repeated requests count against it too.
local function onRequestEvolution(player: Player, form: any)
    local now = os.clock()
    if Evolution.IsRateLimited(lastRequestAt[player], now, Config.EvolutionRequestCooldown) then
        return -- dropped without touching state (and without extending the cooldown)
    end
    if player.Parent ~= Players then
        return -- player already left; do not re-create their rate-limit entry
    end
    lastRequestAt[player] = now

    local currentForm = formByPlayer[player]
    local biomass = playerData.GetBiomass(player)
    if currentForm == nil or biomass == nil then
        return
    end
    if not isAlive(player) then
        reply(player, "NoLivingCharacter")
        return
    end
    local newForm, reason = Evolution.Select(form, biomass, currentForm, CreatureDefinitions)
    if reason == "Ok" then
        formByPlayer[player] = newForm
        refresh(player)
        formChanged:Fire(player, newForm)
    end
    reply(player, reason)
end

function EvolutionService.GetForm(player: Player): string?
    return formByPlayer[player]
end

-- Puts the player back in the base form for a new life (called by ResetService when a life
-- ends). Returns false if the player has no record. Rate-limit timestamps are not life state
-- and are kept.
function EvolutionService.ResetForm(player: Player): boolean
    if formByPlayer[player] == nil then
        return false
    end
    formByPlayer[player] = Config.BaseForm
    refresh(player)
    return true
end

-- playerDataService must already be initialised.
function EvolutionService.Init(playerDataService: any)
    playerData = playerDataService

    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes == nil then
        remotes = Instance.new("Folder")
        remotes.Name = "Remotes"
        remotes.Parent = ReplicatedStorage
    end
    local request = Instance.new("RemoteEvent")
    request.Name = "RequestEvolution"
    request.Parent = remotes
    request.OnServerEvent:Connect(onRequestEvolution)
    local result = Instance.new("RemoteEvent")
    result.Name = "EvolutionResult"
    result.Parent = remotes
    resultEvent = result

    playerDataService.ProgressChanged:Connect(function(player: Player)
        refresh(player)
    end)
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(function(player)
        formByPlayer[player] = nil
        lastRequestAt[player] = nil
    end)
    for _, player in Players:GetPlayers() do
        onPlayerAdded(player)
    end
end

return EvolutionService
