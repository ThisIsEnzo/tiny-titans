--!strict
-- Server-owned evolution state (session only, no persistence).
-- Each player starts as Config.BaseForm. When energy reaches the threshold the server
-- marks evolution available; the client may then request one branch via the
-- RequestEvolution RemoteEvent. The server validates every request and records the
-- choice exactly once. Clients only ever send a branch name, never state.
-- Attributes replicated to all clients: "EvolutionForm" (string), "EvolutionAvailable" (bool).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config") :: ModuleScript)
local Evolution = require(Shared:WaitForChild("Evolution") :: ModuleScript)

local EvolutionService = {}

local formByPlayer: { [Player]: string } = {}
local playerData: any = nil

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

-- Rejected requests change nothing; the client learns the outcome from attributes only.
local function onRequestEvolution(player: Player, form: any)
    local currentForm = formByPlayer[player]
    local energy = playerData.GetEnergy(player)
    if currentForm == nil or energy == nil or not isAlive(player) then
        return
    end
    local ok = Evolution.Validate(
        form,
        energy,
        Config.EvolutionEnergyRequired,
        currentForm,
        Config.BaseForm,
        Config.EvolutionForms
    )
    if not ok then
        return
    end
    formByPlayer[player] = form :: string
    refresh(player)
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

    playerDataService.ProgressChanged:Connect(function(player: Player)
        refresh(player)
    end)
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(function(player)
        formByPlayer[player] = nil
    end)
    for _, player in Players:GetPlayers() do
        onPlayerAdded(player)
    end
end

return EvolutionService
