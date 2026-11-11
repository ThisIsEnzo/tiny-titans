--!strict
-- Pure rules for controlled respawn and the life recap (P1-04, hardened in P1-05). No Roblox
-- services, so they are unit-testable outside Studio. RespawnService (server) applies them;
-- LifeService stays the only authority on whether a life is Alive or Ended.
--
-- A record is frozen and never mutated: every function returns the record to keep (the SAME
-- table when nothing changes).
--   awaitingLifeId  the ended life whose recap waits for "begin new life" (0 = none)
--   retryInitial    the server's FIRST spawn failed, so the player may request it (lifeId is 0)
--   beganLifeId     the newest life that has begun (a LifeEnded for an OLDER life is stale)
--   spawnSeq        number of spawn operations started so far
--   inFlightSeq     the spawn operation whose LoadCharacter has not returned yet (0 = none)
--
-- Only ONE spawn operation may be in flight. It is released only when ITS LoadCharacter call
-- returns (EndSpawn with its own sequence number), NOT when a life begins: the character is
-- added while LoadCharacter is still yielding, so a death in that window must not allow a
-- second LoadCharacter. A stale operation (an old sequence number) can never release or
-- modify a newer one.
--
-- TryBegin reasons: "Ok", "NoPlayer", "LifeActive", "NotAwaiting", "StaleLife",
--   "SpawnInProgress", "ResetPending".

local Respawn = {}

export type Record = {
    awaitingLifeId: number,
    retryInitial: boolean,
    beganLifeId: number,
    spawnSeq: number,
    inFlightSeq: number,
}

local function make(awaitingLifeId: number, retryInitial: boolean, beganLifeId: number, spawnSeq: number, inFlightSeq: number): Record
    return table.freeze({
        awaitingLifeId = awaitingLifeId,
        retryInitial = retryInitial,
        beganLifeId = beganLifeId,
        spawnSeq = spawnSeq,
        inFlightSeq = inFlightSeq,
    })
end

local function isWhole(value: any, minimum: number): boolean
    return type(value) == "number" and value == value and value >= minimum and value < math.huge and value == math.floor(value)
end

local function isLifeId(value: any): boolean
    return isWhole(value, 1)
end

-- The record every player starts with: no recap pending, nothing spawning.
function Respawn.Initial(): Record
    return make(0, false, 0, 0, 0)
end

-- A life ended: its recap now waits for "begin new life". Malformed ids, ids already awaited
-- and STALE ids (a newer life has already begun) are ignored, so a late event cannot re-arm a recap.
function Respawn.OnLifeEnded(record: Record, endedLifeId: any): Record
    if not isLifeId(endedLifeId) or endedLifeId <= record.awaitingLifeId or endedLifeId < record.beganLifeId then
        return record
    end
    return make(endedLifeId, false, record.beganLifeId, record.spawnSeq, record.inFlightSeq)
end

-- A life began: the recap wait is over (only if the new life is newer than the awaiting one,
-- so a stale LifeBegan cannot clear a newer recap). An in-flight spawn is NOT released here.
function Respawn.OnLifeBegan(record: Record, lifeId: any): Record
    if not isLifeId(lifeId) or lifeId <= record.awaitingLifeId or lifeId <= record.beganLifeId then
        return record
    end
    return make(0, false, math.max(record.beganLifeId, lifeId), record.spawnSeq, record.inFlightSeq)
end

local function beginSpawn(record: Record): Record
    local seq = record.spawnSeq + 1
    return make(record.awaitingLifeId, record.retryInitial, record.beganLifeId, seq, seq)
end

-- The server's first spawn of a player (not a request). Returns (record, "Ok" | "SpawnInProgress");
-- the new operation's number is record.inFlightSeq.
function Respawn.StartInitialSpawn(record: Record): (Record, string)
    if record.inFlightSeq ~= 0 then
        return record, "SpawnInProgress"
    end
    return beginSpawn(record), "Ok"
end

-- Validates a "begin new life" request against SERVER state only. The request carries no
-- values. lifeState is LifeService's state for the player (nil if unknown), currentLifeId is
-- LifeService's current lifeId, resetDone says P1-03's reset of the awaiting life is complete.
-- Returns (record, reason); the record changes only when reason is "Ok", and then
-- record.inFlightSeq is the new spawn operation's number.
function Respawn.TryBegin(record: Record, lifeState: string?, currentLifeId: number?, resetDone: boolean): (Record, string)
    if lifeState == nil or currentLifeId == nil then
        return record, "NoPlayer"
    end
    if lifeState ~= "Ended" then
        return record, "LifeActive"
    end
    if record.awaitingLifeId >= 1 then
        if record.awaitingLifeId ~= currentLifeId then
            return record, "StaleLife"
        end
    elseif record.retryInitial then
        if currentLifeId ~= 0 then
            return record, "StaleLife"
        end
    else
        return record, "NotAwaiting"
    end
    if record.inFlightSeq ~= 0 then
        return record, "SpawnInProgress"
    end
    if currentLifeId >= 1 and not resetDone then
        return record, "ResetPending"
    end
    return beginSpawn(record), "Ok"
end

-- LoadCharacter of operation `seq` returned (successfully or after an error). Releases the
-- operation only if it is still THE in-flight one (a stale or unknown sequence changes nothing).
-- If the very first spawn produced no life (lifeAlive false, currentLifeId 0), the player is
-- allowed to request it again (retryInitial). A failed later spawn simply leaves the recap awaiting.
function Respawn.EndSpawn(record: Record, seq: any, lifeAlive: boolean, currentLifeId: number): Record
    if not isLifeId(seq) or seq ~= record.inFlightSeq then
        return record
    end
    local retry = record.retryInitial
    if not lifeAlive and record.awaitingLifeId == 0 and currentLifeId == 0 then
        retry = true
    end
    return make(record.awaitingLifeId, retry, record.beganLifeId, record.spawnSeq, 0)
end

-- Client side: should a received recap be shown? lifeId 0 is the failed-first-spawn notice.
-- dismissedLifeId is the highest recap already dismissed by a new character; shownLifeId is the
-- one on screen (-1 if none). Older, dismissed or malformed recaps are ignored; the same recap
-- again just refreshes.
function Respawn.ShouldShowRecap(recapLifeId: any, dismissedLifeId: number, shownLifeId: number): boolean
    if not isWhole(recapLifeId, 0) then
        return false
    end
    return recapLifeId > dismissedLifeId and recapLifeId >= shownLifeId
end

-- Highest form reached in a life. One evolution is allowed per life, so the first evolved
-- form reached sticks and the base form is only the fallback (no ranking between forms).
function Respawn.UpdateHighestForm(highestForm: string, currentForm: any, baseForm: string): string
    if type(currentForm) ~= "string" or currentForm == baseForm then
        return highestForm
    end
    if highestForm ~= baseForm then
        return highestForm
    end
    return currentForm
end

-- Whole seconds are not required; negative or invalid spans become 0.
function Respawn.Duration(startedAt: any, endedAt: any): number
    if type(startedAt) ~= "number" or type(endedAt) ~= "number" or startedAt ~= startedAt or endedAt ~= endedAt then
        return 0
    end
    return math.max(0, endedAt - startedAt)
end

-- True if a recap should be sent: the player is not leaving, and the ended life is still the
-- player's current life and has not been replaced by a living one (a late LifeEnded after a new
-- life began must not pop up a recap). The recap is sent even if no statistics were recorded
-- (it then shows safe defaults), so a player can never be stuck dead without a button.
function Respawn.CanSendRecap(currentLifeId: number?, endedLifeId: any, lifeAlive: boolean, leaving: boolean): boolean
    return not leaving and not lifeAlive and isLifeId(endedLifeId) and currentLifeId == endedLifeId
end

-- "45s", "2m 05s", "1h 02m". Invalid input shows "0s".
function Respawn.FormatDuration(seconds: any): string
    if type(seconds) ~= "number" or seconds ~= seconds or seconds < 0 or seconds == math.huge then
        return "0s"
    end
    local total = math.floor(seconds)
    if total < 60 then
        return string.format("%ds", total)
    elseif total < 3600 then
        return string.format("%dm %02ds", total // 60, total % 60)
    end
    return string.format("%dh %02dm", total // 3600, (total % 3600) // 60)
end

return table.freeze(Respawn)
