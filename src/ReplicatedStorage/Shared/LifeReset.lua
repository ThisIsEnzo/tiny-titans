--!strict
-- Pure rules for WHEN to reset one player's Current Life. No Roblox services, so they are
-- unit-testable outside Studio. ResetService (server) applies them to LifeService events.
--
-- The reset runs at most once per lifeId. A Tracker remembers the highest lifeId whose
-- reset has been applied. Decisions:
--   LifeEnded(lifeId):
--     "Reset"     the ended life is the player's current life and not yet reset
--     "Duplicate" that life (or an older one) was already reset
--     "Stale"     a newer life has already begun, so this late event must not touch it
--     "NoPlayer"  the player is gone (no current lifeId)
--     "Invalid"   malformed ids
--   LifeBegan(lifeId): the safety net for a "Stale" LifeEnded. If the previous life was
--     never reset (its LifeEnded was handled after the new life began), the reset is done
--     now, before the new life has any state of its own. Otherwise "None".
-- The tracker is marked BEFORE the reset is applied, so a re-entrant or repeated event can
-- never apply it twice. Errors inside the reset are not swallowed.

local LifeReset = {}

export type Tracker = { lastResetLifeId: number }

LifeReset.Outcome = table.freeze({
    Reset = "Reset",
    Duplicate = "Duplicate",
    Stale = "Stale",
    NoPlayer = "NoPlayer",
    Invalid = "Invalid",
    None = "None",
})

local function isLifeId(value: any): boolean
    return type(value) == "number" and value == value and value >= 1 and value < math.huge and value == math.floor(value)
end

-- A new tracker for a player who has not had a reset yet.
function LifeReset.NewTracker(): Tracker
    return { lastResetLifeId = 0 }
end

-- Decides what to do with LifeEnded(endedLifeId) given the player's current lifeId
-- (nil when the player is gone).
function LifeReset.DecideEnded(tracker: Tracker, endedLifeId: any, currentLifeId: any): string
    if currentLifeId == nil then
        return LifeReset.Outcome.NoPlayer
    end
    if not isLifeId(endedLifeId) or not isLifeId(currentLifeId) then
        return LifeReset.Outcome.Invalid
    end
    if endedLifeId <= tracker.lastResetLifeId then
        return LifeReset.Outcome.Duplicate
    end
    if endedLifeId ~= currentLifeId then
        return LifeReset.Outcome.Stale
    end
    return LifeReset.Outcome.Reset
end

-- Decides what to do when life newLifeId begins. Returns (outcome, lifeIdToMark): when the
-- outcome is "Reset", lifeIdToMark is the previous life whose reset was missed.
function LifeReset.DecideBegan(tracker: Tracker, newLifeId: any): (string, number)
    if not isLifeId(newLifeId) then
        return LifeReset.Outcome.Invalid, 0
    end
    local previous = newLifeId - 1
    if previous < 1 or previous <= tracker.lastResetLifeId then
        return LifeReset.Outcome.None, 0
    end
    return LifeReset.Outcome.Reset, previous
end

-- Records that lifeId (and everything before it) has been reset. Never moves backwards.
function LifeReset.Commit(tracker: Tracker, lifeId: number)
    if lifeId > tracker.lastResetLifeId then
        tracker.lastResetLifeId = lifeId
    end
end

-- Handles LifeEnded: decides, marks, then calls apply() only for "Reset". Returns the outcome.
function LifeReset.OnEnded(tracker: Tracker, endedLifeId: any, currentLifeId: any, apply: () -> ()): string
    local outcome = LifeReset.DecideEnded(tracker, endedLifeId, currentLifeId)
    if outcome == LifeReset.Outcome.Reset then
        LifeReset.Commit(tracker, endedLifeId :: number)
        apply()
    end
    return outcome
end

-- Handles LifeBegan: performs a missed reset of the previous life. Returns the outcome.
function LifeReset.OnBegan(tracker: Tracker, newLifeId: any, apply: () -> ()): string
    local outcome, previous = LifeReset.DecideBegan(tracker, newLifeId)
    if outcome == LifeReset.Outcome.Reset then
        LifeReset.Commit(tracker, previous)
        apply()
    end
    return outcome
end

return table.freeze(LifeReset)
