--!strict
-- Server-owned evolution state (session only, no persistence).
-- Each player starts as Config.BaseForm. When energy reaches the threshold the server
-- marks evolution available; the client may then request one branch via the
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

local EvolutionService = {}

local formByPlayer: { [Player]: string } = {}
local lastRequestAt: { [Player]: number } = {}
local playerData: any = nil
local resultEvent: RemoteEvent? = nil

local function refresh(player: Player)
    local form = formByPlayer[player]
    if form == nil then
        return
    end
    local energy = playerData.GetEnergy(player) or 0
    player:SetAttribute("EvolutionForm", form)
    player:SetAttribute(
        "EvolutionAvailable",
        Evolution.IsAvailable(energy, Config.EvolutionEnergyRequired, form, Config.BaseForm)
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
    formByPlayer[player] = Config.BaseForm
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
    local energy = playerData.GetEnergy(player)
    if currentForm == nil or energy == nil then
        return
    end
    if not isAlive(player) then
        reply(player, "NoLivingCharacter")
        return
    end
    local newForm, reason = Evolution.Select(
        form,
        energy,
        Config.EvolutionEnergyRequired,
        currentForm,
        Config.BaseForm,
        Config.EvolutionForms
    )
    if reason == "Ok" then
        formByPlayer[player] = newForm
        refresh(player)
    end
    reply(player, reason)
end

function EvolutionService.GetForm(player: Player): string?
    return formByPlayer[player]
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
