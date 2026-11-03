--!strict
-- Server-owned per-player progression (session only, no persistence).
-- Only server code may call AddEnergy. Clients never send energy values.
-- Energy and stage are mirrored to Player attributes ("Energy", "GrowthStage")
-- so future UI can read them without a RemoteEvent.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config") :: ModuleScript)
local Growth = require(Shared:WaitForChild("Growth") :: ModuleScript)

local PlayerDataService = {}

local energyByPlayer: { [Player]: number } = {}
local progressChanged = Instance.new("BindableEvent")

-- Fires (player: Player, energy: number, stageIndex: number) on the server only.
PlayerDataService.ProgressChanged = progressChanged.Event

local function publish(player: Player, energy: number)
    local stage = Growth.GetStageIndex(energy, Config.GrowthStages)
    player:SetAttribute("Energy", energy)
    player:SetAttribute("GrowthStage", stage)
    progressChanged:Fire(player, energy, stage)
end

local function onPlayerAdded(player: Player)
    if energyByPlayer[player] ~= nil then
        return
    end
    energyByPlayer[player] = 0
    publish(player, 0)
end

function PlayerDataService.Init()
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(function(player)
        energyByPlayer[player] = nil
    end)
    for _, player in Players:GetPlayers() do
        onPlayerAdded(player)
    end
end

function PlayerDataService.GetEnergy(player: Player): number?
    return energyByPlayer[player]
end

function PlayerDataService.GetStageIndex(player: Player): number
    local energy = energyByPlayer[player] or 0
    return Growth.GetStageIndex(energy, Config.GrowthStages)
end

-- True if the player has a record and has not reached the energy cap.
function PlayerDataService.CanGainEnergy(player: Player): boolean
    local energy = energyByPlayer[player]
    return energy ~= nil and energy < Config.EvolutionEnergyRequired
end

-- Adds energy (clamped to the cap). Returns the amount actually added.
function PlayerDataService.AddEnergy(player: Player, amount: number): number
    local current = energyByPlayer[player]
    if current == nil or amount ~= amount or amount <= 0 then
        return 0
    end
    local updated = Growth.ClampEnergy(current + amount, Config.EvolutionEnergyRequired)
    local gained = updated - current
    if gained <= 0 then
        return 0
    end
    energyByPlayer[player] = updated
    publish(player, updated)
    return gained
end

return PlayerDataService
