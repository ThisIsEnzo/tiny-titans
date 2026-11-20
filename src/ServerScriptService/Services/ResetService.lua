--!strict
-- Exactly-once per-life reset orchestration (P1-03, retained through M1).
-- ResetService is the only subscriber that decides WHEN a life's state is reset. It listens to
-- LifeService.LifeEnded/LifeBegan and applies the pure rules in Shared/LifeReset.lua:
--   * at most one reset per (player, lifeId); duplicate events are ignored
--   * a LifeEnded whose life is no longer current is "Stale"; the LifeBegan handler then
--     performs that missed reset before the new life has any state of its own
--   * a player who has left is ignored and their tracker removed
-- The tracker is marked BEFORE the reset is applied, so re-entrant events cannot double-reset.
--
-- M1: the legacy per-life state owners (Biomass, form, abilities, discovery log) are no longer
-- part of runtime, so no active system currently owns per-life state and the reset payload below
-- is intentionally empty. The exactly-once GATE is still load-bearing: RespawnService calls
-- IsResetDone and must not begin a new life before the previous life's reset has been recorded.
-- Future adventure systems add their own small reset API here, one call per owning service.
--
-- No client request or client value is involved. Respawn remains player-driven.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local LifeReset = require(Shared:WaitForChild("LifeReset") :: ModuleScript)

local ResetService = {}

local trackers: { [Player]: LifeReset.Tracker } = {}
local life: any = nil

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

-- Per-life reset payload. M1: no active system owns per-life state (see header).
-- Each future owning service is called here through its own small reset function.
local function resetCurrentLife(_player: Player) end

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

-- True once the reset of lifeId (or a later life) has been applied for this player. Used by
-- RespawnService so a new life is never started before that life's reset has run.
function ResetService.IsResetDone(player: Player, lifeId: number): boolean
    local tracker = trackers[player]
    return tracker ~= nil and tracker.lastResetLifeId >= lifeId
end

-- lifeService must already be initialised. Call before RespawnService.
function ResetService.Init(lifeService: any)
    life = lifeService

    lifeService.LifeEnded:Connect(onLifeEnded)
    lifeService.LifeBegan:Connect(onLifeBegan)
    Players.PlayerRemoving:Connect(function(player)
        trackers[player] = nil
    end)
end

return ResetService
