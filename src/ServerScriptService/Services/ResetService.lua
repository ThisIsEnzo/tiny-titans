--!strict
-- Resets a player's Current Life when LifeService says the life ended (P1-03).
-- It is the only subscriber that decides WHEN to reset; each owning service performs its
-- own reset through one small API, so no state is duplicated or moved:
--   PlayerDataService.ResetBiomass, EvolutionService.ResetForm,
--   AbilityService.ResetLife, GrowthService.ResetLife.
-- There is no second death detection: this only listens to LifeService.LifeEnded/LifeBegan.
--
-- Exactly once per (player, lifeId): the pure rules in Shared/LifeReset.lua keep a per-player
-- Tracker. Duplicate events are ignored. LifeService events can arrive a moment after the
-- change (BindableEvent), so a LifeEnded whose life is no longer the player's current life
-- is "Stale" and does nothing; the LifeBegan handler then performs that missed reset before
-- the new life has any state. A player who has left is ignored and their tracker removed.
-- No client request or client value is involved. Respawn is untouched (still automatic).
--
-- Reset order: biomass first (stage and evolution availability are derived from it), then
-- the form, then ability state, then growth visuals.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local LifeReset = require(Shared:WaitForChild("LifeReset") :: ModuleScript)

local ResetService = {}

local trackers: { [Player]: LifeReset.Tracker } = {}
local life: any = nil
local playerData: any = nil
local evolution: any = nil
local abilities: any = nil
local growth: any = nil

-- The player's tracker. It is stored only while the player is still in the game, so a late
-- event for a player who left can never re-create state.
local function trackerFor(player: Player, currentLifeId: number?): LifeReset.Tracker
    local tracker = trackers[player]
    if tracker ~= nil then
        return tracker
    end
    tracker = LifeReset.NewTracker()
    if currentLifeId ~= nil and player.Parent == Players then
        trackers[player] = tracker
    end
    return tracker
end

local function resetCurrentLife(player: Player)
    playerData.ResetBiomass(player)
    evolution.ResetForm(player)
    abilities.ResetLife(player)
    growth.ResetLife(player)
end

local function onLifeEnded(player: Player, endedLifeId: number, _reason: string)
    local currentLifeId = life.GetLifeId(player)
    local tracker = trackerFor(player, currentLifeId)
    LifeReset.OnEnded(tracker, endedLifeId, currentLifeId, function()
        resetCurrentLife(player)
    end)
end

local function onLifeBegan(player: Player, lifeId: number)
    local currentLifeId = life.GetLifeId(player)
    if currentLifeId == nil or currentLifeId ~= lifeId then
        return -- the player left, or an even newer life already began
    end
    local tracker = trackerFor(player, currentLifeId)
    LifeReset.OnBegan(tracker, lifeId, function()
        resetCurrentLife(player)
    end)
end

-- Every argument must already be initialised. Call after the other services.
function ResetService.Init(lifeService: any, playerDataService: any, evolutionService: any, abilityService: any, growthService: any)
    life = lifeService
    playerData = playerDataService
    evolution = evolutionService
    abilities = abilityService
    growth = growthService

    lifeService.LifeEnded:Connect(onLifeEnded)
    lifeService.LifeBegan:Connect(onLifeBegan)
    Players.PlayerRemoving:Connect(function(player)
        trackers[player] = nil
    end)
end

return ResetService
