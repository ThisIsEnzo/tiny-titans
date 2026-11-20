--!strict
-- Focused tests for the pure exactly-once reset rules in Shared/LifeReset.lua.
-- Run from the repository root: lune run tests/LifeReset.test.lua
-- These tests verify decision rules and observable reset effects using generic per-life
-- progress, without depending on retired gameplay systems or Roblox services.

local LifeReset = require("../src/ReplicatedStorage/Shared/LifeReset")
local Outcome = LifeReset.Outcome

local failures = 0
local function check(name: string, condition: boolean)
    if not condition then
        failures += 1
        print("FAIL: " .. name)
    else
        print("ok:   " .. name)
    end
end

type Sim = {
    currentLifeId: number?,
    tracker: LifeReset.Tracker,
    progress: number,
    resets: number,
}

local function newPlayer(): Sim
    return { currentLifeId = nil, tracker = LifeReset.NewTracker(), progress = 0, resets = 0 }
end

local function applyReset(player: Sim)
    player.progress = 0
    player.resets += 1
end

local function beginLife(player: Sim, lifeId: number): string
    player.currentLifeId = lifeId
    return LifeReset.OnBegan(player.tracker, lifeId, function()
        applyReset(player)
    end)
end

local function endLife(player: Sim, lifeId: any): string
    return LifeReset.OnEnded(player.tracker, lifeId, player.currentLifeId, function()
        applyReset(player)
    end)
end

-- 1. Decision rules and tracker invariants.
do
    local tracker = LifeReset.NewTracker()
    check("1: a new tracker has reset no lives", tracker.lastResetLifeId == 0)
    check("1: trackers are independent", LifeReset.NewTracker() ~= tracker)
    check("1: ending the current first life requests a reset", LifeReset.DecideEnded(tracker, 1, 1) == Outcome.Reset)
    check("1: ending an older life is stale", LifeReset.DecideEnded(tracker, 1, 2) == Outcome.Stale)
    check("1: an absent player is not reset", LifeReset.DecideEnded(tracker, 1, nil) == Outcome.NoPlayer)

    LifeReset.Commit(tracker, 1)
    check("1: the committed life is a duplicate", LifeReset.DecideEnded(tracker, 1, 1) == Outcome.Duplicate)
    check("1: older life ids remain duplicates", LifeReset.DecideEnded(tracker, 1, 3) == Outcome.Duplicate)
    check("1: the next current life can be reset", LifeReset.DecideEnded(tracker, 2, 2) == Outcome.Reset)
    LifeReset.Commit(tracker, 0)
    check("1: commit never moves the tracker backwards", tracker.lastResetLifeId == 1)

    local bad: { any } = { 0, -1, 1.5, 0 / 0, math.huge, "1", true, {}, false }
    local allInvalid = true
    for _, value in bad do
        if LifeReset.DecideEnded(LifeReset.NewTracker(), value, 1) ~= Outcome.Invalid
            or LifeReset.DecideEnded(LifeReset.NewTracker(), 1, value) ~= Outcome.Invalid
            or LifeReset.DecideBegan(LifeReset.NewTracker(), value) ~= Outcome.Invalid then
            allInvalid = false
        end
    end
    check("1: malformed life ids are rejected", allInvalid)
    check("1: nil ended id is invalid for a present player", LifeReset.DecideEnded(LifeReset.NewTracker(), nil, 1) == Outcome.Invalid)
    check("1: the first LifeBegan needs no reset", LifeReset.DecideBegan(LifeReset.NewTracker(), 1) == Outcome.None)

    local missed = LifeReset.NewTracker()
    local outcome, missedLifeId = LifeReset.DecideBegan(missed, 2)
    check("1: LifeBegan detects a missed reset of the previous life", outcome == Outcome.Reset and missedLifeId == 1)
    LifeReset.Commit(missed, 1)
    check("1: LifeBegan does not repeat an already completed reset", LifeReset.DecideBegan(missed, 2) == Outcome.None)
    check("1: the outcome table is frozen", table.isfrozen(Outcome))
end

-- 2. A current LifeEnded applies its reset exactly once; later progress is not erased by duplicates.
do
    local player = newPlayer()
    check("2: first life begins without a reset", beginLife(player, 1) == Outcome.None)
    player.progress = 42

    check("2: current life end applies the reset", endLife(player, 1) == Outcome.Reset)
    check("2: reset clears per-life progress", player.progress == 0)
    check("2: reset count increments once", player.resets == 1)
    check("2: tracker records the ended life", player.tracker.lastResetLifeId == 1)

    player.progress = 7
    check("2: duplicate LifeEnded is ignored", endLife(player, 1) == Outcome.Duplicate)
    check("2: repeated duplicate is also ignored", endLife(player, 1) == Outcome.Duplicate)
    check("2: duplicate events preserve progress gained after reset", player.progress == 7)
    check("2: duplicate events do not reapply reset", player.resets == 1)
end

-- 3. One player's reset cannot affect another player's state or tracker.
do
    local a = newPlayer()
    local b = newPlayer()
    beginLife(a, 1)
    beginLife(b, 1)
    a.progress = 80
    b.progress = 25

    check("3: A's life ends and resets", endLife(a, 1) == Outcome.Reset)
    check("3: A's progress is cleared", a.progress == 0 and a.resets == 1)
    check("3: B's progress and reset count are untouched", b.progress == 25 and b.resets == 0)
    check("3: trackers remain independent", a.tracker.lastResetLifeId == 1 and b.tracker.lastResetLifeId == 0)
    check("3: B can reset its own life", endLife(b, 1) == Outcome.Reset and b.resets == 1 and b.progress == 0)
end

-- 4. If LifeBegan arrives before the previous LifeEnded handler, the safety net resets first.
do
    local player = newPlayer()
    beginLife(player, 1)
    player.progress = 90

    -- LifeService has advanced to life 2, but the deferred LifeEnded(1) handler has not run yet.
    player.currentLifeId = 2
    check("4: the late LifeEnded(1) is stale", endLife(player, 1) == Outcome.Stale)
    check("4: stale LifeEnded does not erase old state early", player.progress == 90 and player.resets == 0)

    check("4: LifeBegan(2) applies the missed reset", LifeReset.OnBegan(player.tracker, 2, function()
        applyReset(player)
    end) == Outcome.Reset)
    check("4: the new life starts with clean state", player.progress == 0 and player.resets == 1)
    player.progress = 12
    check("4: repeated old LifeEnded is now a duplicate", endLife(player, 1) == Outcome.Duplicate)
    check("4: late duplicate preserves new-life progress", player.progress == 12 and player.resets == 1)
end

-- 5. Several consecutive lives each receive exactly one reset.
do
    local player = newPlayer()
    beginLife(player, 1)
    player.progress = 10
    check("5: life 1 resets", endLife(player, 1) == Outcome.Reset)
    beginLife(player, 2)
    player.progress = 20
    check("5: life 2 resets", endLife(player, 2) == Outcome.Reset)
    beginLife(player, 3)
    player.progress = 30

    check("5: late events from lives 1 and 2 are duplicates", endLife(player, 1) == Outcome.Duplicate and endLife(player, 2) == Outcome.Duplicate)
    check("5: life 3 progress remains intact", player.progress == 30)
    check("5: reset count equals the number of ended lives", player.resets == 2 and player.tracker.lastResetLifeId == 2)
    check("5: an event for a future life is stale", endLife(player, 4) == Outcome.Stale)
end

-- 6. Player removal and malformed signals never apply a reset.
do
    local player = newPlayer()
    beginLife(player, 1)
    player.progress = 55
    player.currentLifeId = nil

    check("6: LifeEnded for a removed player is ignored", endLife(player, 1) == Outcome.NoPlayer)
    check("6: removed-player state is not reset", player.progress == 55 and player.resets == 0)
    check("6: removed-player tracker is not advanced", player.tracker.lastResetLifeId == 0)

    player.currentLifeId = 1
    check("6: string life id is invalid", endLife(player, "1") == Outcome.Invalid)
    check("6: nil life id is invalid", endLife(player, nil) == Outcome.Invalid)
    check("6: malformed signals leave state untouched", player.progress == 55 and player.resets == 0)
end

-- 7. The tracker is committed before invoking the reset callback (re-entrancy protection).
do
    local player = newPlayer()
    beginLife(player, 1)
    local nestedOutcome: string? = nil

    local outcome = LifeReset.OnEnded(player.tracker, 1, 1, function()
        player.resets += 1
        nestedOutcome = LifeReset.OnEnded(player.tracker, 1, 1, function()
            player.resets += 1
        end)
    end)

    check("7: outer event applies reset", outcome == Outcome.Reset)
    check("7: re-entrant duplicate sees the committed tracker", nestedOutcome == Outcome.Duplicate)
    check("7: reset callback runs exactly once", player.resets == 1 and player.tracker.lastResetLifeId == 1)
end

if failures > 0 then
    error(failures .. " test(s) failed")
end
print("all tests passed")
