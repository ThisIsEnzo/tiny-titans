--!strict
-- Optional lifecycle timeline tests (P1-05). Run with Lune from the repository root:
--   lune run tests/Lifecycle.test.lua
-- Lune is NOT part of rokit.toml; this file is outside the Rojo project tree.
--
-- A "player" is a plain table that replays server events through the REAL pure Life, LifeReset
-- and Respawn rules in the order the services apply them: LifeService (begin/end), ResetService
-- (reset exactly once, gating the next life), RespawnService (spawn operations, pending recap,
-- handshake) and the recap client's display rule. This proves the decisions and orderings.
-- It does NOT prove Roblox behaviour: LoadCharacter yielding, CharacterAdded/Removing timing,
-- BindableEvent delivery order, remotes, attributes, tweens, instance cleanup, or the UI. Those
-- need Studio (README P1-05 checklist).

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

type Client = {
    listening: boolean,
    shown: number,
    dismissed: number,
    visible: boolean,
    received: number, -- recap messages that reached the client
}

type Sim = {
    life: Life.Record,
    rec: Respawn.Record,
    tracker: LifeReset.Tracker,
    present: boolean,
    characters: number, -- living characters (must never exceed 1)
    loads: number, -- LoadCharacter calls made
    ops: { number }, -- spawn operations whose LoadCharacter has not returned
    pending: number?, -- lifeId of the recap the server is holding for the player
    client: Client,
    resets: number,
}

local function newSim(): Sim
    return {
        life = Life.Initial(),
        rec = Respawn.Initial(),
        tracker = LifeReset.NewTracker(),
        present = true,
        characters = 0,
        loads = 0,
        ops = {},
        pending = nil,
        client = { listening = false, shown = -1, dismissed = -1, visible = false, received = 0 },
        resets = 0,
    }
end

-- Server -> client delivery of a recap (lost if the client is not listening yet).
local function sendRecap(s: Sim, lifeId: number)
    if not s.client.listening then
        return
    end
    s.client.received += 1
    if Respawn.ShouldShowRecap(lifeId, s.client.dismissed, s.client.shown) then
        s.client.shown = lifeId
        s.client.visible = true
    end
end

-- The client announces it is ready; the server replays the pending recap it holds (it is cleared
-- when a newer life begins, so nothing is replayed while the player is alive).
local function clientReady(s: Sim)
    s.client.listening = true
    local pending = s.pending
    if s.present and pending ~= nil then
        sendRecap(s, pending)
    end
end

local function startOperation(s: Sim, record: Respawn.Record)
    s.rec = record
    s.loads += 1
    table.insert(s.ops, record.inFlightSeq)
end

-- The server's first spawn.
local function startInitial(s: Sim): string
    local record, reason = Respawn.StartInitialSpawn(s.rec)
    if reason == "Ok" then
        startOperation(s, record)
    end
    return reason
end

-- A character is added (this happens while LoadCharacter is still yielding): LifeService begins a
-- life, ResetService's LifeBegan safety net and RespawnService's handler run, the client hides.
local function characterAdded(s: Sim)
    s.characters += 1
    local newLife = select(1, Life.Begin(s.life))
    s.life = newLife
    s.rec = Respawn.OnLifeBegan(s.rec, newLife.lifeId)
    local pending = s.pending
    if pending ~= nil and newLife.lifeId > pending then
        s.pending = nil
    end
    LifeReset.OnBegan(s.tracker, newLife.lifeId, function()
        s.resets += 1
    end)
    s.client.dismissed = math.max(s.client.dismissed, s.client.shown)
    s.client.shown = -1
    s.client.visible = false
end

-- Humanoid dies: LifeService ends the life; ResetService (optionally not yet) and RespawnService react.
local function die(s: Sim, resetHandled: boolean): string
    local endedLife, reason = Life.End(s.life, s.life.lifeId)
    if reason ~= "Ok" then
        return reason
    end
    s.life = endedLife
    s.characters = 0
    s.rec = Respawn.OnLifeEnded(s.rec, endedLife.lifeId)
    if resetHandled then
        LifeReset.OnEnded(s.tracker, endedLife.lifeId, endedLife.lifeId, function()
            s.resets += 1
        end)
    end
    if s.present and Respawn.CanSendRecap(s.life.lifeId, endedLife.lifeId, Life.IsAlive(s.life), false) then
        s.pending = endedLife.lifeId
        sendRecap(s, endedLife.lifeId)
    end
    return reason
end

local function resetNow(s: Sim, lifeId: number)
    LifeReset.OnEnded(s.tracker, lifeId, s.life.lifeId, function()
        s.resets += 1
    end)
end

-- The player presses BEGIN NEW LIFE.
local function requestBegin(s: Sim): string
    if not s.present then
        return "NoPlayer"
    end
    local resetDone = s.life.lifeId >= 1 and s.tracker.lastResetLifeId >= s.life.lifeId
    local record, reason = Respawn.TryBegin(s.rec, s.life.state, s.life.lifeId, resetDone)
    if reason == "Ok" then
        startOperation(s, record)
    end
    return reason
end

-- LoadCharacter of operation `seq` returns (the character may or may not have appeared before).
local function loadReturns(s: Sim, seq: number)
    local index = table.find(s.ops, seq)
    if index ~= nil then
        table.remove(s.ops, index)
    end
    if not s.present then
        return -- the player left: nothing is recreated
    end
    local before = s.rec
    s.rec = Respawn.EndSpawn(before, seq, Life.IsAlive(s.life), s.life.lifeId)
    if s.rec.retryInitial and not before.retryInitial then
        s.pending = 0
        sendRecap(s, 0)
    end
end

local function leave(s: Sim)
    s.present = false -- operations still running are only resolved later by loadReturns
    s.pending = nil
end

-- 1. Multiple respawn requests for the same life, including the same frame.
do
    local s = newSim()
    startInitial(s)
    characterAdded(s)
    loadReturns(s, 1)
    die(s, true)
    local accepted = 0
    local rejectedInProgress = 0
    for _ = 1, 100 do
        local reason = requestBegin(s)
        if reason == "Ok" then
            accepted += 1
        elseif reason == "SpawnInProgress" then
            rejectedInProgress += 1
        end
    end
    check("1: 100 requests for one ended life start exactly one operation", accepted == 1 and rejectedInProgress == 99 and #s.ops == 1 and s.loads == 2)
    characterAdded(s)
    check("1: requests are still refused after the character appears but LoadCharacter has not returned", requestBegin(s) == "LifeActive" and #s.ops == 1)
    loadReturns(s, s.ops[1])
    check("1: one life and one character in the end", s.life.lifeId == 2 and s.characters == 1 and #s.ops == 0)
end

-- 2. Rapid consecutive endings and beginnings, including death while LoadCharacter still yields.
do
    local s = newSim()
    startInitial(s)
    characterAdded(s)
    loadReturns(s, 1)
    die(s, true)
    requestBegin(s) -- operation 2
    characterAdded(s) -- life 2 begins while operation 2 still yields
    check("2: life 2 is alive", Life.IsAlive(s.life) and s.life.lifeId == 2)
    check("2: the reset of life 1 had run before life 2 began", s.tracker.lastResetLifeId == 1)
    die(s, true) -- the player dies at once, before LoadCharacter returned
    check("2: life 2 ended", s.life.state == "Ended" and s.rec.awaitingLifeId == 2)
    check("2: a request during the still-running operation is refused", requestBegin(s) == "SpawnInProgress" and s.loads == 2)
    loadReturns(s, 2)
    check("2: after it returned, the player can request again", requestBegin(s) == "Ok" and s.loads == 3)
    characterAdded(s)
    loadReturns(s, 3)
    check("2: life 3 is the only active life with one character", s.life.lifeId == 3 and s.characters == 1 and Life.IsAlive(s.life))
    check("2: every ended life was reset exactly once", s.resets == 2 and s.tracker.lastResetLifeId == 2)
    check("2: a double death signal is harmless", die(s, true) == "Ok" and die(s, true) == "AlreadyEnded")
end

-- 3. Duplicate and stale lifecycle events.
do
    local s = newSim()
    startInitial(s)
    characterAdded(s)
    loadReturns(s, 1)
    die(s, true)
    requestBegin(s)
    characterAdded(s)
    loadReturns(s, 2)
    local awaitingBefore = s.rec.awaitingLifeId
    s.rec = Respawn.OnLifeEnded(s.rec, 1) -- a late LifeEnded of life 1 reaches RespawnService
    check("3: a late LifeEnded of an older life changes nothing", s.rec.awaitingLifeId == awaitingBefore)
    check("3: it would not send a recap while the new life is alive", not Respawn.CanSendRecap(s.life.lifeId, 1, Life.IsAlive(s.life), false))
    local resetsBefore = s.resets
    LifeReset.OnEnded(s.tracker, 1, s.life.lifeId, function()
        s.resets += 1
    end)
    check("3: ResetService treats it as a duplicate", s.resets == resetsBefore)
    check("3: LifeBegan repeated for the same life is harmless", Respawn.OnLifeBegan(s.rec, 2) == s.rec)
    check("3: the pure life rules refuse a second active life", select(2, Life.Begin(s.life)) == "AlreadyAlive")
    check("3: the pure life rules refuse an end for a stale lifeId", select(2, Life.End(s.life, 1)) ~= "Ok")
end

-- 4a. A failed later spawn, then a valid retry.
do
    local s = newSim()
    startInitial(s)
    characterAdded(s)
    loadReturns(s, 1)
    die(s, true)
    check("4a: request accepted", requestBegin(s) == "Ok")
    loadReturns(s, 2) -- LoadCharacter errored: no character, no life
    check("4a: the flag is released and the recap is still awaited", #s.ops == 0 and s.rec.inFlightSeq == 0 and s.rec.awaitingLifeId == 1)
    check("4a: no character and no new life", s.characters == 0 and s.life.state == "Ended")
    check("4a: a retry is accepted", requestBegin(s) == "Ok" and s.loads == 3)
    characterAdded(s)
    loadReturns(s, 3)
    check("4a: the retry produced exactly one life and one character", s.life.lifeId == 2 and s.characters == 1)
end

-- 4b. The very first spawn fails: the player is told and can retry.
do
    local s = newSim()
    clientReady(s)
    check("4b: the first spawn starts", startInitial(s) == "Ok")
    check("4b: a second start is refused while in flight", startInitial(s) == "SpawnInProgress")
    check("4b: the player cannot request while it is in flight", requestBegin(s) == "NotAwaiting")
    loadReturns(s, 1) -- failed: no life
    check("4b: the failure releases the operation and allows a retry", s.rec.retryInitial and s.rec.inFlightSeq == 0)
    check("4b: the player received the spawn-failed notice (lifeId 0)", s.pending == 0 and s.client.visible and s.client.shown == 0)
    check("4b: the retry is accepted without a reset", requestBegin(s) == "Ok")
    check("4b: a duplicate retry is refused", requestBegin(s) == "SpawnInProgress")
    characterAdded(s)
    loadReturns(s, 2)
    check("4b: the first life began, the notice is gone, no retry flag", s.life.lifeId == 1 and not s.client.visible and not s.rec.retryInitial and s.pending == nil)
    check("4b: the notice is dismissed for good", not Respawn.ShouldShowRecap(0, s.client.dismissed, s.client.shown))
end

-- 5. Player removal during a pending operation.
do
    local s = newSim()
    startInitial(s)
    characterAdded(s)
    loadReturns(s, 1)
    die(s, true)
    requestBegin(s)
    local recBefore = s.rec
    leave(s)
    loadReturns(s, 2)
    check("5: a LoadCharacter returning after the player left changes nothing", s.rec == recBefore)
    check("5: no pending recap or character for the removed player", s.pending == nil and s.characters == 0 and #s.ops == 0)
    check("5: a request from the removed player is refused", requestBegin(s) == "NoPlayer")
    local t = newSim()
    startInitial(t)
    characterAdded(t)
    loadReturns(t, 1)
    die(t, true)
    leave(t)
    check("5: no recap is held for a player who left during the recap", t.pending == nil)
    check("5: no recap is sent to a leaving player", not Respawn.CanSendRecap(t.life.lifeId, 1, false, true))
    clientReady(t)
    check("5: a ready message from a removed player resends nothing", t.client.received == 0)
end

-- 6. Two players with independent lifecycles.
do
    local a = newSim()
    local b = newSim()
    clientReady(a)
    clientReady(b)
    startInitial(a)
    startInitial(b)
    characterAdded(a)
    characterAdded(b)
    loadReturns(a, 1)
    loadReturns(b, 1)
    die(a, true)
    check("6: A died; B is unaffected", a.life.state == "Ended" and Life.IsAlive(b.life) and b.rec.awaitingLifeId == 0 and b.resets == 0)
    check("6: B cannot start a life because A died", requestBegin(b) == "LifeActive")
    requestBegin(a)
    check("6: A's operation does not mark B in flight", a.rec.inFlightSeq ~= 0 and b.rec.inFlightSeq == 0 and #b.ops == 0)
    loadReturns(a, 2)
    check("6: A's failed spawn does not touch B", b.rec.spawnSeq == 1 and Life.IsAlive(b.life))
    die(b, true)
    check("6: each player's reset is independent and exactly once", a.resets == 1 and b.resets == 1)
    check("6: each player has their own recap", a.pending == 1 and b.pending == 1 and a.client.shown == 1 and b.client.shown == 1)
end

-- 7. Old-life callbacks after a new life began.
do
    local s = newSim()
    startInitial(s)
    characterAdded(s)
    loadReturns(s, 1)
    die(s, true)
    requestBegin(s)
    characterAdded(s)
    loadReturns(s, 2)
    local rec = s.rec
    check("7: a stale spawn return (old operation number) changes nothing", Respawn.EndSpawn(rec, 1, true, 2) == rec and Respawn.EndSpawn(rec, 2, true, 2) == rec)
    -- Life 2 ends and gets recap 2; a late delivery of recap 1 arrives afterwards.
    clientReady(s)
    die(s, true)
    check("7: recap 2 is on screen", s.client.shown == 2)
    sendRecap(s, 1)
    check("7: a late older recap does not overwrite the newer one", s.client.shown == 2)
    requestBegin(s)
    characterAdded(s)
    loadReturns(s, 3)
    check("7: the new character dismissed recap 2", not s.client.visible and s.client.dismissed == 2)
    sendRecap(s, 2)
    sendRecap(s, 1)
    check("7: late recaps of dismissed lives never reappear", not s.client.visible)
end

-- 7b. An OLD spawn operation completing after a NEWER one has started must not unlock it.
do
    local s = newSim()
    startInitial(s)
    characterAdded(s)
    loadReturns(s, 1)
    die(s, true)
    requestBegin(s) -- operation 2 is now in flight
    local before = s.rec
    loadReturns(s, 1) -- a late or duplicate completion of the old operation 1
    check("7b: the late old completion leaves the record untouched", s.rec == before and s.rec.inFlightSeq == 2)
    check("7b: operation 2 is still in flight and the player is still refused", #s.ops == 1 and requestBegin(s) == "SpawnInProgress")
    loadReturns(s, 2)
    check("7b: only operation 2's own completion releases it", s.rec.inFlightSeq == 0 and #s.ops == 0)
end

-- 8. Recap delivery and clearing across consecutive lives, with the handshake.
do
    local s = newSim()
    startInitial(s)
    characterAdded(s)
    loadReturns(s, 1)
    die(s, true) -- the client is NOT listening yet: this recap is lost on the wire
    check("8: the recap was lost but the server still holds it", s.client.received == 0 and s.pending == 1 and not s.client.visible)
    clientReady(s)
    check("8: the client connects late and the server re-sends the pending recap", s.client.received == 1 and s.client.visible and s.client.shown == 1)
    clientReady(s)
    check("8: a repeated ready message only repeats the same recap", s.client.received == 2 and s.client.shown == 1 and s.client.visible and s.pending == 1)
    requestBegin(s)
    characterAdded(s)
    loadReturns(s, 2)
    check("8: the new life cleared the pending recap and the screen", s.pending == nil and not s.client.visible)
    clientReady(s)
    check("8: a ready message while alive sends nothing", s.client.received == 2 and not s.client.visible)
    die(s, true)
    check("8: the next death shows the next recap", s.pending == 2 and s.client.shown == 2 and s.client.visible and s.client.received == 3)
    requestBegin(s)
    characterAdded(s)
    loadReturns(s, 3)
    check("8: cleared again across consecutive lives", s.pending == nil and not s.client.visible and s.client.dismissed == 2)
    local t = newSim()
    clientReady(t)
    check("8: a ready message with no recap sends nothing", t.client.received == 0 and not t.client.visible)
end

-- 9. Reset completion gates the next life.
do
    local s = newSim()
    startInitial(s)
    characterAdded(s)
    loadReturns(s, 1)
    die(s, false) -- ResetService has not handled LifeEnded yet
    check("9: the request is refused while the reset is pending", requestBegin(s) == "ResetPending" and s.loads == 1 and #s.ops == 0)
    resetNow(s, 1)
    check("9: accepted once the reset ran", requestBegin(s) == "Ok")
    characterAdded(s)
    loadReturns(s, 2)
    check("9: the new life began after exactly one reset", s.life.lifeId == 2 and s.resets == 1 and s.tracker.lastResetLifeId == 1)
    resetNow(s, 1)
    check("9: a repeated reset of the old life is a duplicate", s.resets == 1)
end

-- 10. Cleanup and idempotency over many cycles.
do
    local s = newSim()
    startInitial(s)
    characterAdded(s)
    loadReturns(s, 1)
    local maxCharacters = 1
    local ok = true
    for cycle = 1, 10 do
        die(s, true)
        local accepted = 0
        for _ = 1, 5 do
            if requestBegin(s) == "Ok" then
                accepted += 1
            end
        end
        if accepted ~= 1 then
            ok = false
        end
        characterAdded(s)
        loadReturns(s, s.ops[1])
        loadReturns(s, 999) -- a stale/unknown return is a no-op
        maxCharacters = math.max(maxCharacters, s.characters)
        if s.life.lifeId ~= cycle + 1 or #s.ops ~= 0 or s.rec.inFlightSeq ~= 0 then
            ok = false
        end
    end
    check("10: 10 cycles give exactly one life, one operation and no leftover flag each time", ok)
    check("10: never more than one living character", maxCharacters == 1)
    check("10: resets equal ended lives", s.resets == 10 and s.tracker.lastResetLifeId == 10)
    check("10: the loads equal the lives (first spawn plus 10 requests)", s.loads == 11 and s.life.lifeId == 11)
    leave(s)
    local before = s.rec
    loadReturns(s, 1)
    check("10: cleanup is idempotent (late returns after removal do nothing)", s.rec == before and s.pending == nil)
end

if failures > 0 then
    error(failures .. " test(s) failed")
end
print("all tests passed")
