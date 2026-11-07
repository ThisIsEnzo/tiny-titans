--!strict
-- Pure rules for controlled respawn and the life recap (P1-04). No Roblox services, so they
-- are unit-testable outside Studio. RespawnService (server) applies them; LifeService stays
-- the only authority on whether a life is Alive or Ended.
--
-- A record is { awaitingLifeId: number, spawning: boolean }, frozen and never mutated: every
-- function returns the record to keep (the SAME table when nothing changes).
--   awaitingLifeId  the ended life whose recap is waiting for "begin new life" (0 = none)
--   spawning        a requested spawn is in progress (the character is being loaded)
-- The very first spawn of a player is done by the server and is not a request, so a new
-- player has no awaiting life and cannot request one.
--
-- TryBegin reasons: "Ok", "NoPlayer", "LifeActive", "NotAwaiting", "StaleLife",
--   "SpawnInProgress", "ResetPending".

local Respawn = {}

export type Record = { awaitingLifeId: number, spawning: boolean }

local function make(awaitingLifeId: number, spawning: boolean): Record
    return table.freeze({ awaitingLifeId = awaitingLifeId, spawning = spawning })
end

local function isLifeId(value: any): boolean
    return type(value) == "number" and value == value and value >= 1 and value < math.huge and value == math.floor(value)
end

-- The record every player starts with: no recap pending, nothing spawning.
function Respawn.Initial(): Record
    return make(0, false)
end

-- A life ended: its recap now waits for "begin new life". Older or malformed ids are ignored.
function Respawn.OnLifeEnded(record: Record, endedLifeId: any): Record
    if not isLifeId(endedLifeId) or endedLifeId <= record.awaitingLifeId then
        return record
    end
    return make(endedLifeId, false)
end

-- A life began: the recap wait and any spawn in progress are over (only if the new life is
-- newer than the awaiting one, so a stale LifeBegan cannot clear a newer recap).
function Respawn.OnLifeBegan(record: Record, lifeId: any): Record
    if not isLifeId(lifeId) or lifeId <= record.awaitingLifeId then
        return record
    end
    return make(0, false)
end

-- Validates a "begin new life" request against SERVER state only. The request carries no
-- values. lifeState is LifeService's state for the player (nil if unknown), currentLifeId is
-- LifeService's current lifeId, resetDone says P1-03's reset of the awaiting life is complete.
-- Returns (record, reason); the record changes (spawning = true) only when reason is "Ok".
function Respawn.TryBegin(record: Record, lifeState: string?, currentLifeId: number?, resetDone: boolean): (Record, string)
    if lifeState == nil or currentLifeId == nil then
        return record, "NoPlayer"
    end
    if lifeState ~= "Ended" then
        return record, "LifeActive"
    end
    if record.awaitingLifeId == 0 then
        return record, "NotAwaiting"
    end
    if record.awaitingLifeId ~= currentLifeId then
        return record, "StaleLife"
    end
    if record.spawning then
        return record, "SpawnInProgress"
    end
    if not resetDone then
        return record, "ResetPending"
    end
    return make(record.awaitingLifeId, true), "Ok"
end

-- The spawn failed (for example LoadCharacter errored): allow a retry. No-op without a recap.
function Respawn.OnSpawnFailed(record: Record): Record
    if record.awaitingLifeId == 0 or not record.spawning then
        return record
    end
    return make(record.awaitingLifeId, false)
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
