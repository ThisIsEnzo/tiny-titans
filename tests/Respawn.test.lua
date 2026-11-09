--!strict
-- Optional unit tests for the pure rules in Shared/Respawn.lua (P1-04, hardened in P1-05).
-- Run with Lune from the repository root:  lune run tests/Respawn.test.lua
-- Lune is NOT part of rokit.toml; this file is outside the Rojo project tree.
-- Player timelines through Life + LifeReset + Respawn are in tests/Lifecycle.test.lua.
-- These tests do NOT prove Roblox behaviour (CharacterAutoLoads, LoadCharacter, remotes,
-- event delivery, UI); that needs Studio (README checklists).

local Config = require("../src/ReplicatedStorage/Shared/Config")
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

local bad: { any } = { 0, -1, 1.5, 0 / 0, math.huge, "1", true, {} }

-- Records and life events.
do
    local initial = Respawn.Initial()
    check("initial record is empty", initial.awaitingLifeId == 0 and not initial.retryInitial and initial.beganLifeId == 0 and initial.spawnSeq == 0 and initial.inFlightSeq == 0)
    check("records are frozen", table.isfrozen(initial))
    local ended = Respawn.OnLifeEnded(initial, 1)
    check("a life end sets the awaiting life", ended.awaitingLifeId == 1 and ended.inFlightSeq == 0)
    check("an older or equal life end is ignored (same table)", Respawn.OnLifeEnded(ended, 1) == ended and Respawn.OnLifeEnded(ended, 0) == ended)
    local ignored = true
    for _, value in bad do
        if Respawn.OnLifeEnded(initial, value) ~= initial or Respawn.OnLifeBegan(ended, value) ~= ended then
            ignored = false
        end
    end
    check("malformed ids are ignored", ignored and Respawn.OnLifeEnded(initial, nil) == initial)
    check("a newer life begin clears the wait and records the newest life", Respawn.OnLifeBegan(ended, 2).awaitingLifeId == 0 and Respawn.OnLifeBegan(ended, 2).beganLifeId == 2)
    local began2 = Respawn.OnLifeBegan(Respawn.Initial(), 2)
    check("a late LifeEnded of an older life cannot re-arm a recap", Respawn.OnLifeEnded(began2, 1) == began2)
    check("the ending of the newest life is accepted", Respawn.OnLifeEnded(began2, 2).awaitingLifeId == 2)
    check("a stale life begin does not clear a newer wait", Respawn.OnLifeBegan(Respawn.OnLifeEnded(initial, 3), 2).awaitingLifeId == 3)
    local spawning = select(1, Respawn.TryBegin(ended, "Ended", 1, true))
    check("a life begin does NOT release a spawn in flight", Respawn.OnLifeBegan(spawning, 2).inFlightSeq == spawning.inFlightSeq and spawning.inFlightSeq ~= 0)
    check("a life end keeps a spawn in flight", Respawn.OnLifeEnded(Respawn.OnLifeBegan(spawning, 2), 2).inFlightSeq == spawning.inFlightSeq)
end

-- TryBegin.
do
    local initial = Respawn.Initial()
    local ended = Respawn.OnLifeEnded(initial, 1)
    local r, reason = Respawn.TryBegin(ended, "Ended", 1, true)
    check("a valid request is accepted and starts operation 1", reason == "Ok" and r.inFlightSeq == 1 and r.spawnSeq == 1 and r.awaitingLifeId == 1)
    r, reason = Respawn.TryBegin(ended, "Ended", 1, false)
    check("the reset must be done first", reason == "ResetPending" and r == ended)
    r, reason = Respawn.TryBegin(ended, "Alive", 1, true)
    check("rejected while the life is alive", reason == "LifeActive" and r == ended)
    r, reason = Respawn.TryBegin(initial, "Ended", 0, true)
    check("rejected before any life ended (first spawn is not a request)", reason == "NotAwaiting")
    r, reason = Respawn.TryBegin(ended, "Ended", 2, true)
    check("rejected when the awaiting life is not the current life", reason == "StaleLife")
    r, reason = Respawn.TryBegin(ended, nil, nil, true)
    check("rejected for an unknown player", reason == "NoPlayer")
    local inFlight = select(1, Respawn.TryBegin(ended, "Ended", 1, true))
    r, reason = Respawn.TryBegin(inFlight, "Ended", 1, true)
    check("rejected while a spawn is in flight", reason == "SpawnInProgress" and r == inFlight)
    check("in flight is reported before the reset check", select(2, Respawn.TryBegin(inFlight, "Ended", 1, false)) == "SpawnInProgress")
    local secondRecap = Respawn.OnLifeEnded(Respawn.EndSpawn(inFlight, inFlight.inFlightSeq, true, 2), 2)
    local r2, reason2 = Respawn.TryBegin(secondRecap, "Ended", 2, true)
    check("operation numbers keep increasing", reason2 == "Ok" and r2.inFlightSeq == 2 and r2.spawnSeq == 2)
end

-- Spawn operations (EndSpawn) and the failed first spawn.
do
    local ended = Respawn.OnLifeEnded(Respawn.Initial(), 1)
    local op = select(1, Respawn.TryBegin(ended, "Ended", 1, true))
    check("EndSpawn releases its own operation", Respawn.EndSpawn(op, 1, true, 2).inFlightSeq == 0)
    check("EndSpawn with a stale or unknown number changes nothing", Respawn.EndSpawn(op, 7, true, 2) == op and Respawn.EndSpawn(op, 0, true, 2) == op)
    local released = Respawn.EndSpawn(op, 1, true, 2)
    check("a second EndSpawn of the same operation is a no-op", Respawn.EndSpawn(released, 1, true, 2) == released)
    local failedLater = Respawn.EndSpawn(op, 1, false, 1)
    check("a failed later spawn releases the flag and keeps the recap awaiting", failedLater.inFlightSeq == 0 and failedLater.awaitingLifeId == 1 and not failedLater.retryInitial)
    check("the player can request again after a failed later spawn", select(2, Respawn.TryBegin(failedLater, "Ended", 1, true)) == "Ok")
    for _, value in bad do
        if Respawn.EndSpawn(op, value, true, 2) ~= op then
            check("EndSpawn ignores malformed sequence numbers", false)
        end
    end

    local first, startReason = Respawn.StartInitialSpawn(Respawn.Initial())
    check("the first spawn starts operation 1", startReason == "Ok" and first.inFlightSeq == 1)
    check("a second first-spawn start is refused while in flight", select(2, Respawn.StartInitialSpawn(first)) == "SpawnInProgress")
    check("an in-flight first spawn cannot be requested", select(2, Respawn.TryBegin(first, "Ended", 0, true)) == "NotAwaiting")
    local firstFailed = Respawn.EndSpawn(first, 1, false, 0)
    check("a failed first spawn allows a retry", firstFailed.retryInitial and firstFailed.inFlightSeq == 0)
    local retryRecord, retryReason = Respawn.TryBegin(firstFailed, "Ended", 0, false)
    check("the first-spawn retry needs no reset", retryReason == "Ok" and retryRecord.inFlightSeq == 2)
    check("a first-spawn retry for a later life is stale", select(2, Respawn.TryBegin(firstFailed, "Ended", 1, true)) == "StaleLife")
    check("a successful first spawn needs no retry", not Respawn.EndSpawn(first, 1, true, 1).retryInitial)
    check("the retry flag clears when the first life begins", not Respawn.OnLifeBegan(firstFailed, 1).retryInitial)
end

-- Recap display (client).
do
    check("client shows a new recap", Respawn.ShouldShowRecap(1, -1, -1))
    check("client shows the failed-spawn notice (lifeId 0)", Respawn.ShouldShowRecap(0, -1, -1))
    check("client refreshes the same recap", Respawn.ShouldShowRecap(2, 1, 2))
    check("client shows a newer recap over an older one", Respawn.ShouldShowRecap(3, 1, 2))
    check("client ignores an older recap", not Respawn.ShouldShowRecap(1, -1, 2))
    check("client ignores a recap already dismissed", not Respawn.ShouldShowRecap(2, 2, -1) and not Respawn.ShouldShowRecap(1, 2, -1))
    local allIgnored = true
    for _, value in { -1, 1.5, 0 / 0, math.huge, "1", true, {} } :: { any } do
        if Respawn.ShouldShowRecap(value, -1, -1) then
            allIgnored = false
        end
    end
    check("client ignores malformed recap ids", allIgnored and not Respawn.ShouldShowRecap(nil, -1, -1))
end

-- Recap helpers.
do
    local base = Config.BaseForm
    check("highest form stays base without evolving", Respawn.UpdateHighestForm(base, base, base) == base)
    check("the evolved form becomes the highest", Respawn.UpdateHighestForm(base, "TANK", base) == "TANK")
    check("the first evolved form sticks", Respawn.UpdateHighestForm("TANK", "GLIDER", base) == "TANK")
    check("dropping back to base keeps the highest", Respawn.UpdateHighestForm("GLIDER", base, base) == "GLIDER")
    check("malformed form is ignored", Respawn.UpdateHighestForm(base, nil, base) == base and Respawn.UpdateHighestForm(base, 5, base) == base)
    check("duration is end minus start", Respawn.Duration(10, 75.5) == 65.5)
    check("duration is never negative", Respawn.Duration(10, 5) == 0)
    check("invalid duration inputs give 0", Respawn.Duration(nil, 5) == 0 and Respawn.Duration(1, "2") == 0 and Respawn.Duration(0 / 0, 1) == 0)
    check("format seconds", Respawn.FormatDuration(0) == "0s" and Respawn.FormatDuration(45.9) == "45s")
    check("format minutes", Respawn.FormatDuration(60) == "1m 00s" and Respawn.FormatDuration(125) == "2m 05s" and Respawn.FormatDuration(3599) == "59m 59s")
    check("format hours", Respawn.FormatDuration(3600) == "1h 00m" and Respawn.FormatDuration(3725) == "1h 02m")
    check("format invalid input", Respawn.FormatDuration(nil) == "0s" and Respawn.FormatDuration(-5) == "0s" and Respawn.FormatDuration(0 / 0) == "0s" and Respawn.FormatDuration(math.huge) == "0s")
    check("recap is sent for the current ended life", Respawn.CanSendRecap(2, 2, false, false))
    check("no recap while the life is alive", not Respawn.CanSendRecap(2, 2, true, false))
    check("no recap for a late event of an older life", not Respawn.CanSendRecap(3, 2, true, false) and not Respawn.CanSendRecap(3, 2, false, false))
    check("no recap for a leaving player", not Respawn.CanSendRecap(2, 2, false, true))
    check("no recap for a malformed life id", not Respawn.CanSendRecap(0, 0, false, false) and not Respawn.CanSendRecap(nil, 1, false, false))
end

if failures > 0 then
    error(failures .. " test(s) failed")
end
print("all tests passed")
