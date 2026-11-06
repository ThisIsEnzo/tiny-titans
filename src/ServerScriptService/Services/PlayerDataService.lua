--!strict
-- Server-owned per-player progression (session only, no persistence).
-- Only server code may call AddBiomass. Clients never send biomass values.
-- Biomass and stage are mirrored to Player attributes ("Biomass", "GrowthStage")
-- so future UI can read them without a RemoteEvent.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config") :: ModuleScript)
local Growth = require(Shared:WaitForChild("Growth") :: ModuleScript)
local LifeReset = require(Shared:WaitForChild("LifeReset") :: ModuleScript)

local PlayerDataService = {}

local biomassByPlayer: { [Player]: number } = {}
local progressChanged = Instance.new("BindableEvent")

-- Fires (player: Player, biomass: number, stageIndex: number) on the server only.
PlayerDataService.ProgressChanged = progressChanged.Event

local function publish(player: Player, biomass: number)
    local stage = Growth.GetStageIndex(biomass, Config.GrowthStages)
    player:SetAttribute("Biomass", biomass)
    player:SetAttribute("GrowthStage", stage)
    progressChanged:Fire(player, biomass, stage)
end

local function onPlayerAdded(player: Player)
    if biomassByPlayer[player] ~= nil then
        return
    end
    biomassByPlayer[player] = 0
    publish(player, 0)
end

function PlayerDataService.Init()
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(function(player)
        biomassByPlayer[player] = nil
    end)
    for _, player in Players:GetPlayers() do
        onPlayerAdded(player)
    end
end

function PlayerDataService.GetBiomass(player: Player): number?
    return biomassByPlayer[player]
end

function PlayerDataService.GetStageIndex(player: Player): number
    local biomass = biomassByPlayer[player] or 0
    return Growth.GetStageIndex(biomass, Config.GrowthStages)
end

-- True if the player has a record and has not reached the biomass cap.
function PlayerDataService.CanGainBiomass(player: Player): boolean
    local biomass = biomassByPlayer[player]
    return biomass ~= nil and biomass < Config.EvolutionBiomassRequired
end

-- Adds biomass (clamped to the cap). Returns the amount actually added.
function PlayerDataService.AddBiomass(player: Player, amount: number): number
    local current = biomassByPlayer[player]
    if current == nil then
        return 0
    end
    local updated, gained = Growth.AddBiomass(current, amount, Config.EvolutionBiomassRequired)
    if gained <= 0 then
        return 0
    end
    biomassByPlayer[player] = updated
    publish(player, updated)
    return gained
end

-- Puts the player's biomass back to the starting value for a new life (called by ResetService
-- when a life ends). Returns false if the player has no record. Publishes like any change, so
-- the stage, the attributes and the progress listeners follow.
function PlayerDataService.ResetBiomass(player: Player): boolean
    if biomassByPlayer[player] == nil then
        return false
    end
    biomassByPlayer[player] = LifeReset.StartingBiomass
    publish(player, LifeReset.StartingBiomass)
    return true
end

return PlayerDataService
