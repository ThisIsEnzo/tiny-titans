--!strict
-- Pure life-cycle rules. No Roblox services, so they are unit-testable outside Studio.
-- LifeService (server) owns one record per player and applies these rules to it.
--
-- A record is { state = "Alive" | "Ended", lifeId = number }. It starts as Ended with
-- lifeId 0 (no life yet). Records are frozen and never mutated: every transition returns
-- the record to keep, which is the SAME table when the request is rejected.
--
-- Transitions return (record, reason). The transition happened only when reason is "Ok".
--   Begin: "Ok", "AlreadyAlive", "Invalid"
--   End:   "Ok", "AlreadyEnded", "StaleLifeId", "Invalid"
-- lifeId increases only in Begin, by exactly one. End never changes it.

export type Record = { state: string, lifeId: number }

local Life = {}

Life.ALIVE = "Alive"
Life.ENDED = "Ended"

-- Why a life ended. LifeService passes one of these to LifeEnded subscribers.
Life.EndReason = table.freeze({
    HumanoidDied = "HumanoidDied",
    CharacterRemoving = "CharacterRemoving",
    CharacterReplaced = "CharacterReplaced",
    PlayerRemoving = "PlayerRemoving",
})

local function make(state: string, lifeId: number): Record
    return table.freeze({ state = state, lifeId = lifeId })
end

local function isCount(value: any): boolean
    return type(value) == "number" and value == value and value >= 0 and value < math.huge and value == math.floor(value)
end

-- The record every player starts with: Ended, lifeId 0.
function Life.Initial(): Record
    return make(Life.ENDED, 0)
end

-- True only for a well-formed record: state is exactly "Alive" or "Ended" and lifeId is a
-- non-negative whole number (an Alive record needs lifeId >= 1).
function Life.IsValid(record: any): boolean
    if type(record) ~= "table" then
        return false
    end
    local state = record.state
    local lifeId = record.lifeId
    if not isCount(lifeId) then
        return false
    end
    if state == Life.ENDED then
        return true
    end
    return state == Life.ALIVE and lifeId >= 1
end

-- True for a valid record whose life is Alive.
function Life.IsAlive(record: any): boolean
    return Life.IsValid(record) and record.state == Life.ALIVE
end

-- True only while the record is Alive AND lifeId is that life. A callback that captured an
-- older lifeId gets false once a newer life has begun (or the life has ended).
function Life.IsCurrent(record: any, lifeId: any): boolean
    return Life.IsAlive(record) and type(lifeId) == "number" and record.lifeId == lifeId
end

-- Starts a new life: Ended -> Alive with lifeId + 1. Rejected while a life is Alive.
function Life.Begin(record: Record): (Record, string)
    if not Life.IsValid(record) then
        return record, "Invalid"
    end
    if record.state == Life.ALIVE then
        return record, "AlreadyAlive"
    end
    return make(Life.ALIVE, record.lifeId + 1), "Ok"
end

-- Ends the current life: Alive -> Ended, lifeId unchanged.
-- expectedLifeId is the lifeId the caller captured when it started listening; pass it so a
-- delayed signal from an old life cannot end a newer one ("StaleLifeId"). nil skips the check.
-- Ending an already-ended life is a harmless rejection ("AlreadyEnded"), never a second end.
function Life.End(record: Record, expectedLifeId: number?): (Record, string)
    if not Life.IsValid(record) then
        return record, "Invalid"
    end
    if expectedLifeId ~= nil then
        if not isCount(expectedLifeId) then
            return record, "Invalid"
        end
        if expectedLifeId ~= record.lifeId then
            return record, "StaleLifeId"
        end
    end
    if record.state == Life.ENDED then
        return record, "AlreadyEnded"
    end
    return make(Life.ENDED, record.lifeId), "Ok"
end

return table.freeze(Life)
