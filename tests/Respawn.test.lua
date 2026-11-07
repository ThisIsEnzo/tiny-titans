--!strict
-- Optional unit tests for the pure controlled-respawn and recap rules in Shared/Respawn.lua (P1-04).
-- Run with Lune from the repository root:  lune run tests/Respawn.test.lua
-- Lune is NOT part of rokit.toml; this file is outside the Rojo project tree.
--
-- Section 2 replays player timelines through the REAL pure Life, LifeReset and Respawn rules the
-- way LifeService, ResetService and RespawnService use them (plain tables as players). This proves
-- the decisions: a valid request spawns exactly one character, requests while alive / duplicates /
-- stale / during a spawn / before the reset are rejected, and removal during the recap is safe.
-- It does NOT prove Roblox behaviour: CharacterAutoLoads, LoadCharacter, the remotes, event
-- delivery, the UI or the character lifecycle. Those need Studio (README checklist).

local Config = require("../src/ReplicatedStorage/Shared/Config")
local Life = require("../src/ReplicatedStorage/Shared/Life")
local LifeReset = require("../src/ReplicatedStorage/Shared/LifeReset")
local Respawn = require("../src/ReplicatedStorage/Shared/Respawn")

local failures = 0
local function check(name: string, condition: boolean)
    if not condition then
        failures += 1
        print("FAIL: " .. name)
    else
        print("ok:   " .. name)
    end
end

-- ---------------------------------------------------------------------------
-- 1. Rules on their own.
-- ---------------------------------------------------------------------------
do
    local initial = Respawn.Initial()
    check("1: initial record has no recap pending and nothing spawning", initial.awaitingLifeId == 0 and initial.spawning == false)
    check("1: records are frozen", table.isfrozen(initial))
    local ended = Respawn.OnLifeEnded(initial, 1)
    check("1: a life end sets the awaiting life", ended.awaitingLifeId == 1 and not ended.spawning)
    check("1: an older or equal life end is ignored (same table)", Respawn.OnLifeEnded(ended, 1) == ended and Respawn.OnLifeEnded(ended, 0) == ended)
    local bad: { any } = { 0, -1, 1.5, 0 / 0, math.huge, "1", true, {} }
    local ignored = true
    for _, value in bad do
        if Respawn.OnLifeEnded(initial, value) ~= initial or Respawn.OnLifeBegan(ended, value) ~= ended then
            ignored = false
        end
    end
    check("1: malformed ids are ignored", ignored and Respawn.OnLifeEnded(initial, nil) == initial)
    check("1: a newer life begin clears the wait", Respawn.OnLifeBegan(ended, 2).awaitingLifeId == 0)
    check("1: a stale life begin does not clear a newer wait", Respawn.OnLifeBegan(Respawn.OnLifeEnded(initial, 3), 2).awaitingLifeId == 3)
    check("1: a spawn failure re-allows a request", not Respawn.OnSpawnFailed(select(1, Respawn.TryBegin(ended, "Ended", 1, true))).spawning)
    check("1: a spawn failure without a recap changes nothing", Respawn.OnSpawnFailed(initial) == initial)

    local r, reason = Respawn.TryBegin(ended, "Ended", 1, true)
    check("1: a valid request is accepted and marks spawning", reason == "Ok" and r.spawning and r.awaitingLifeId == 1)
    r, reason = Respawn.TryBegin(ended, "Ended", 1, false)
    check("1: the reset must be done first", reason == "ResetPending" and r == ended)
    r, reason = Respawn.TryBegin(ended, "Alive", 1, true)
    check("1: rejected while the life is alive", reason == "LifeActive" and r == ended)
    r, reason = Respawn.TryBegin(initial, "Ended", 0, true)
    check("1: rejected before any life ended (first spawn is not a request)", reason == "NotAwaiting")
    r, reason = Respawn.TryBegin(ended, "Ended", 2, true)
    check("1: rejected when the awaiting life is not the current life", reason == "StaleLife")
    r, reason = Respawn.TryBegin(ended, nil, nil, true)
    check("1: rejected for an unknown player", reason == "NoPlayer")
    local spawning = select(1, Respawn.TryBegin(ended, "Ended", 1, true))
    r, reason = Respawn.TryBegin(spawning, "Ended", 1, true)
    check("1: rejected while a spawn is in progress", reason == "SpawnInProgress" and r == spawning)
    check("1: rejection order: unknown, alive, no recap, stale, spawning, reset", select(2, Respawn.TryBegin(spawning, "Ended", 1, false)) == "SpawnInProgress")
end

-- ---------------------------------------------------------------------------
-- 1b. Recap helpers.
-- ---------------------------------------------------------------------------
do
    local base = Config.BaseForm
    check("1b: highest form stays base without evolving", Respawn.UpdateHighestForm(base, base, base) == base)
    check("1b: the evolved form becomes the highest", Respawn.UpdateHighestForm(base, "TANK", base) == "TANK")
    check("1b: the first evolved form sticks", Respawn.UpdateHighestForm("TANK", "GLIDER", base) == "TANK")
    check("1b: dropping back to base keeps the highest", Respawn.UpdateHighestForm("GLIDER", base, base) == "GLIDER")
    check("1b: malformed form is ignored", Respawn.UpdateHighestForm(base, nil, base) == base and Respawn.UpdateHighestForm(base, 5, base) == base)
    check("1b: duration is end minus start", Respawn.Duration(10, 75.5) == 65.5)
    check("1b: duration is never negative", Respawn.Duration(10, 5) == 0)
    check("1b: invalid duration inputs give 0", Respawn.Duration(nil, 5) == 0 and Respawn.Duration(1, "2") == 0 and Respawn.Duration(0 / 0, 1) == 0)
    check("1b: format seconds", Respawn.FormatDuration(0) == "0s" and Respawn.FormatDuration(45.9) == "45s")
    check("1b: format minutes", Respawn.FormatDuration(60) == "1m 00s" and Respawn.FormatDuration(125) == "2m 05s" and Respawn.FormatDuration(3599) == "59m 59s")
    check("1b: format hours", Respawn.FormatDuration(3600) == "1h 00m" and Respawn.FormatDuration(3725) == "1h 02m")
    check("1b: format invalid input", Respawn.FormatDuration(nil) == "0s" and Respawn.FormatDuration(-5) == "0s" and Respawn.FormatDuration(0 / 0) == "0s" and Respawn.FormatDuration(math.huge) == "0s")
    check("1b: recap is sent for the current ended life", Respawn.CanSendRecap(2, 2, false, false))
    check("1b: no recap while the life is alive", not Respawn.CanSendRecap(2, 2, true, false))
    check("1b: no recap for a late event of an older life", not Respawn.CanSendRecap(3, 2, true, false) and not Respawn.CanSendRecap(3, 2, false, false))
    check("1b: no recap for a leaving player", not Respawn.CanSendRecap(2, 2, false, true))
    check("1b: no recap for a malformed life id", not Respawn.CanSendRecap(0, 0, false, false) and not Respawn.CanSendRecap(nil, 1, false, false))
end

-- ---------------------------------------------------------------------------
-- 2. Timelines through the real Life, LifeReset and Respawn rules.
-- ---------------------------------------------------------------------------
type Sim = {
    life: Life.Record,
    rec: Respawn.Record,
    tracker: LifeReset.Tracker,
    present: boolean,
    characters: number, -- living characters in the world (must never exceed 1)
    spawns: number, -- total characters loaded
    pendingSpawn: boolean, -- LoadCharacter has been called but has not finished yet
}

local function newSim(): Sim
    return {
        life = Life.Initial(),
        rec = Respawn.Initial(),
        tracker = LifeReset.NewTracker(),
        present = true,
        characters = 0,
        spawns = 0,
        pendingSpawn = false,
    }
end

-- A character appears (LoadCharacter finished): LifeService begins a life, then the handlers run.
local function characterAdded(s: Sim)
    s.characters += 1
    s.spawns += 1
    local newLife = select(1, Life.Begin(s.life))
    s.life = newLife
    s.rec = Respawn.OnLifeBegan(s.rec, newLife.lifeId)
    LifeReset.OnBegan(s.tracker, newLife.lifeId, function() end)
end

-- The server's first spawn (not a request): only for a player with no character and no life yet.
local function firstSpawn(s: Sim)
    if s.characters == 0 and s.life.lifeId == 0 then
        characterAdded(s)
    end
end

-- Humanoid dies: LifeService ends the life, then ResetService and RespawnService handle LifeEnded.
local function die(s: Sim, resetHandled: boolean): string
    local endedLife, reason = Life.End(s.life, s.life.lifeId)
    if reason ~= "Ok" then
        return reason
    end
    s.life = endedLife
    s.characters = 0 -- the dead character is no longer a living one
    s.rec = Respawn.OnLifeEnded(s.rec, endedLife.lifeId)
    if resetHandled then
        LifeReset.OnEnded(s.tracker, endedLife.lifeId, endedLife.lifeId, function() end)
    end
    return reason
end

-- The player presses BEGIN NEW LIFE. A spawn starts only when the reason is "Ok".
local function requestBegin(s: Sim): string
    if not s.present then
        return "NoPlayer"
    end
    local resetDone = s.life.lifeId >= 1 and s.tracker.lastResetLifeId >= s.life.lifeId
    local nextRec, reason = Respawn.TryBegin(s.rec, s.life.state, s.life.lifeId, resetDone)
    if reason == "Ok" then
        s.rec = nextRec
        s.pendingSpawn = true
    end
    return reason
end

-- LoadCharacter finishes (the character arrives), unless the player left.
local function finishSpawn(s: Sim)
    if s.pendingSpawn and s.present then
        characterAdded(s)
    end
    s.pendingSpawn = false
end

-- LoadCharacter fails: the spawn flag is cleared so the player can retry.
local function failSpawn(s: Sim)
    if s.pendingSpawn then
        s.pendingSpawn = false
        s.rec = Respawn.OnSpawnFailed(s.rec)
    end
end

-- 2.1 First join and the initial spawn.
do
    local s = newSim()
    check("2.1: a new player has no character and no life", s.characters == 0 and s.life.lifeId == 0)
    check("2.1: a request before any spawn is rejected (first spawn is not a request)", requestBegin(s) == "NotAwaiting")
    firstSpawn(s)
    check("2.1: the server's first spawn creates exactly one character and life 1", s.characters == 1 and s.spawns == 1 and s.life.lifeId == 1 and Life.IsAlive(s.life))
    firstSpawn(s)
    check("2.1: a repeated first spawn does nothing", s.spawns == 1)
    check("2.1: no recap is pending after the first spawn", s.rec.awaitingLifeId == 0)
end

-- 2.2 Death: recap, no automatic respawn, then a valid request spawns exactly one character.
do
    local s = newSim()
    firstSpawn(s)
    die(s, true)
    check("2.2: the life ended and a recap is awaited", s.life.state == "Ended" and s.rec.awaitingLifeId == 1)
    check("2.2: no automatic respawn after death", s.characters == 0 and s.spawns == 1 and not s.pendingSpawn)
    check("2.2: a valid request is accepted", requestBegin(s) == "Ok")
    check("2.2: nothing is spawned until the load finishes", s.characters == 0 and s.spawns == 1)
    finishSpawn(s)
    check("2.2: exactly one new character and life 2", s.characters == 1 and s.spawns == 2 and s.life.lifeId == 2 and Life.IsAlive(s.life))
    check("2.2: the recap wait and spawn flag are cleared", s.rec.awaitingLifeId == 0 and not s.rec.spawning)
    check("2.2: the previous life was reset before the new one began", s.tracker.lastResetLifeId == 1)
end

-- 2.3 Request while the life is active.
do
    local s = newSim()
    firstSpawn(s)
    check("2.3: rejected while alive", requestBegin(s) == "LifeActive")
    check("2.3: nothing spawned", s.spawns == 1 and s.characters == 1 and not s.pendingSpawn)
    check("2.3: the pure life rules also refuse a second active life", select(2, Life.Begin(s.life)) == "AlreadyAlive")
end

-- 2.4 Duplicate and spammed requests: exactly one spawn.
do
    local s = newSim()
    firstSpawn(s)
    die(s, true)
    local first = requestBegin(s)
    local reasons: { string } = {}
    for _ = 1, 50 do
        table.insert(reasons, requestBegin(s))
    end
    local allInProgress = true
    for _, reason in reasons do
        if reason ~= "SpawnInProgress" then
            allInProgress = false
        end
    end
    check("2.4: the first request is accepted", first == "Ok")
    check("2.4: 50 duplicates during the spawn are all rejected as in progress", allInProgress)
    finishSpawn(s)
    check("2.4: exactly one character was created", s.spawns == 2 and s.characters == 1)
    check("2.4: late duplicates after the spawn are rejected as alive", requestBegin(s) == "LifeActive" and s.spawns == 2)
end

-- 2.5 Stale life id: the awaiting life is not the current life.
do
    local rec = Respawn.OnLifeEnded(Respawn.Initial(), 1)
    local life = Life.Initial()
    life = select(1, Life.Begin(life))
    life = select(1, Life.End(life, 1))
    life = select(1, Life.Begin(life))
    life = select(1, Life.End(life, 2)) -- Ended, lifeId 2, but the recap waits for life 1
    local _, reason = Respawn.TryBegin(rec, life.state, life.lifeId, true)
    check("2.5: a recap for an older life cannot start a new life", reason == "StaleLife")
    local fresh = Respawn.OnLifeEnded(rec, 2)
    check("2.5: the matching recap can", select(2, Respawn.TryBegin(fresh, life.state, life.lifeId, true)) == "Ok")
end

-- 2.6 A failed spawn can be retried; still exactly one character in the end.
do
    local s = newSim()
    firstSpawn(s)
    die(s, true)
    check("2.6: first attempt accepted", requestBegin(s) == "Ok")
    failSpawn(s)
    check("2.6: the failure left no character and the player can retry", s.characters == 0 and s.spawns == 1 and not s.rec.spawning and s.rec.awaitingLifeId == 1)
    check("2.6: the retry is accepted", requestBegin(s) == "Ok")
    finishSpawn(s)
    check("2.6: exactly one character after the retry", s.characters == 1 and s.spawns == 2)
end

-- 2.7 A new life never starts before the reset of the ended life has run.
do
    local s = newSim()
    firstSpawn(s)
    die(s, false) -- the reset has not been handled yet
    check("2.7: rejected while the reset is pending", requestBegin(s) == "ResetPending" and s.spawns == 1 and not s.pendingSpawn)
    LifeReset.OnEnded(s.tracker, 1, 1, function() end)
    check("2.7: accepted once the reset is done", requestBegin(s) == "Ok")
    finishSpawn(s)
    check("2.7: the new life started after the reset", s.life.lifeId == 2 and s.tracker.lastResetLifeId == 1)
end

-- 2.8 Player removal during the recap and during a spawn.
do
    local s = newSim()
    firstSpawn(s)
    die(s, true)
    check("2.8: no recap is sent to a leaving player", not Respawn.CanSendRecap(s.life.lifeId, 1, false, true))
    s.present = false
    check("2.8: a request from a removed player is rejected", requestBegin(s) == "NoPlayer")
    check("2.8: nothing was spawned for the removed player", s.spawns == 1 and s.characters == 0 and not s.pendingSpawn)
    local t = newSim()
    firstSpawn(t)
    die(t, true)
    requestBegin(t)
    t.present = false -- left while LoadCharacter was running
    finishSpawn(t)
    check("2.8: leaving during the spawn creates no character", t.spawns == 1 and t.characters == 0 and not t.pendingSpawn)
end

-- 2.9 Rapid deaths and many cycles: one new life per valid request, never two active.
do
    local s = newSim()
    firstSpawn(s)
    local maxCharacters = s.characters
    local ok = true
    for cycle = 1, 8 do
        local firstDeath = die(s, true)
        local secondDeath = die(s, true) -- a second death signal in the same life
        if firstDeath ~= "Ok" or secondDeath ~= "AlreadyEnded" then
            ok = false
        end
        local accepted = 0
        for _ = 1, 10 do
            if requestBegin(s) == "Ok" then
                accepted += 1
            end
        end
        if accepted ~= 1 then
            ok = false
        end
        finishSpawn(s)
        maxCharacters = math.max(maxCharacters, s.characters)
        if s.life.lifeId ~= cycle + 1 or s.spawns ~= cycle + 1 then
            ok = false
        end
    end
    check("2.9: 8 cycles of death plus 10 spammed requests give exactly one new life each", ok)
    check("2.9: never more than one living character", maxCharacters == 1)
    check("2.9: lifeId equals the number of spawns", s.life.lifeId == s.spawns)
    check("2.9: every ended life was reset before the next began", s.tracker.lastResetLifeId == s.life.lifeId - 1)
end

-- 2.10 Independent players.
do
    local a = newSim()
    local b = newSim()
    firstSpawn(a)
    firstSpawn(b)
    die(a, true)
    check("2.10: B cannot begin a life because A died", requestBegin(b) == "LifeActive")
    check("2.10: A's recap wait does not leak into B", b.rec.awaitingLifeId == 0 and a.rec.awaitingLifeId == 1)
    requestBegin(a)
    finishSpawn(a)
    check("2.10: A respawned once, B untouched", a.spawns == 2 and b.spawns == 1 and b.characters == 1)
end

if failures > 0 then
    error(failures .. " test(s) failed")
end
print("all tests passed")
