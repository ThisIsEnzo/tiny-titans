--!strict
-- Pure rules for EXPEDITION DISCOVERIES (TT-P3-02): temporary exploration objectives that belong to ONE
-- life. They are not permanent Legacy discoveries: nothing here is saved, and the same places can be
-- found again in the next life. (The unqualified word "Discoveries" is reserved for the future
-- permanent knowledge system; identifiers keep the short name Discovery for now.)
--
-- No Roblox services and no requires: callers pass the catalog (DiscoveryDefinitions) in, like
-- Evolution.lua, so everything here is unit-testable in Lune.
--
-- A Tracker belongs to ONE player (so players are isolated by construction) and holds:
--   log   the discovery log of the player's current life (created lazily, keyed by lifeId)
--   ended the log of the most recent finished life (kept so the recap can read it whichever of
--         "reset" and "recap" runs first when a life ends)
-- Each discovery id can be recorded once per Log, and a Log belongs to exactly one lifeId, so a
-- discovery is rewarded at most once per life. Events for an older life are rejected as stale.

local Discovery = {}

export type Log = {
    lifeId: number,
    found: { [string]: boolean },
    order: { string }, -- ids in the order they were found
    biomassEarned: number, -- Biomass actually granted by discoveries this life
}
export type Tracker = { log: Log?, ended: Log? }
export type Summary = {
    count: number,
    total: number,
    biomass: number,
    names: { string }, -- display names in the order found
    notable: string?, -- display name of the most valuable discovery of the life
}

-- Only the parts of the catalog this module reads (structural, so tests can pass fixtures).
export type Catalog = { Discoveries: { any }, GetDiscovery: (any) -> any }

local function isLifeId(value: any): boolean
    return type(value) == "number" and value == value and value >= 1 and value == math.floor(value) and value < 2 ^ 31
end

local function newLog(lifeId: number): Log
    return { lifeId = lifeId, found = {}, order = {}, biomassEarned = 0 }
end

function Discovery.NewTracker(): Tracker
    return { log = nil, ended = nil }
end

-- The log for `lifeId`, created if needed. A newer life archives the previous log (it becomes
-- tracker.ended). Returns nil for a malformed id or for a life OLDER than the current log (stale).
function Discovery.LogForLife(tracker: Tracker, lifeId: any): Log?
    if not isLifeId(lifeId) then
        return nil
    end
    local current = tracker.log
    if current == nil then
        local created = newLog(lifeId)
        tracker.log = created
        return created
    end
    if current.lifeId == lifeId then
        return current
    end
    if lifeId > current.lifeId then
        tracker.ended = current
        local created = newLog(lifeId)
        tracker.log = created
        return created
    end
    return nil
end

-- The player's life state is being reset (a new life is about to begin): the current log is kept
-- as the finished life's log and the next life starts clean. Safe to call repeatedly.
function Discovery.ResetTracker(tracker: Tracker)
    if tracker.log ~= nil then
        tracker.ended = tracker.log
        tracker.log = nil
    end
end

function Discovery.HasFound(tracker: Tracker, lifeId: any, id: any): boolean
    local log = tracker.log
    return log ~= nil and log.lifeId == lifeId and type(id) == "string" and log.found[id] == true
end

-- Records a discovery for the life. Returns (ok, reason, definition). Reasons: "Ok", "StaleLife"
-- (malformed or older life), "Unknown" (id not in the catalog), "AlreadyFound". A rejected call
-- changes nothing. The caller grants the reward only when ok is true, then calls RecordBiomass.
function Discovery.TryDiscover(tracker: Tracker, lifeId: any, id: any, catalog: Catalog): (boolean, string, any)
    local definition = catalog.GetDiscovery(id)
    if definition == nil then
        return false, "Unknown", nil
    end
    local log = Discovery.LogForLife(tracker, lifeId)
    if log == nil then
        return false, "StaleLife", nil
    end
    if log.found[definition.id] then
        return false, "AlreadyFound", nil
    end
    log.found[definition.id] = true
    table.insert(log.order, definition.id)
    return true, "Ok", definition
end

-- Adds the Biomass a discovery actually granted (0 is fine, e.g. at the cap) to the life's log.
function Discovery.RecordBiomass(tracker: Tracker, lifeId: any, gained: any)
    local log = tracker.log
    if log ~= nil and log.lifeId == lifeId and type(gained) == "number" and gained == gained and gained > 0 then
        log.biomassEarned += gained
    end
end

local function summarize(log: Log?, catalog: Catalog): Summary
    local names: { string } = {}
    local biomass = 0
    local notable: string? = nil
    local notableReward = -1
    if log ~= nil then
        biomass = log.biomassEarned
        for _, id in log.order do
            local definition = catalog.GetDiscovery(id)
            if definition ~= nil then
                table.insert(names, definition.displayName)
                if definition.biomass > notableReward then -- ties keep the earlier discovery
                    notableReward = definition.biomass
                    notable = definition.displayName
                end
            end
        end
    end
    return { count = #names, total = #catalog.Discoveries, biomass = biomass, names = names, notable = notable }
end

-- Summary of the given life: the current log, or the last finished life's log, or an empty summary
-- (a life without discoveries never created a log).
function Discovery.SummaryForLife(tracker: Tracker, lifeId: any, catalog: Catalog): Summary
    local log = tracker.log
    if log ~= nil and log.lifeId == lifeId then
        return summarize(log, catalog)
    end
    local ended = tracker.ended
    if ended ~= nil and ended.lifeId == lifeId then
        return summarize(ended, catalog)
    end
    return summarize(nil, catalog)
end

-- Longest clue text the server publishes to a client (and the client displays).
Discovery.MaxClueLength = 120

-- The first discovery (catalog order) the life has not found yet, or nil when all are found.
function Discovery.NextClue(tracker: Tracker, lifeId: any, catalog: Catalog): any
    local log = tracker.log
    local found = if log ~= nil and log.lifeId == lifeId then log.found else {}
    for _, definition in catalog.Discoveries do
        if not found[definition.id] then
            return definition
        end
    end
    return nil
end

-- The clue to show for the life as a plain string: the first place not found yet, or "" once every place
-- is found. Same rule as NextClue (a fresh expedition, a newer life, or a malformed life id all start
-- from the first place), so the server can publish it without any extra state.
function Discovery.CurrentClue(tracker: Tracker, lifeId: any, catalog: Catalog): string
    local definition = Discovery.NextClue(tracker, lifeId, catalog)
    if definition == nil or type(definition.clue) ~= "string" then
        return ""
    end
    return string.sub(definition.clue, 1, Discovery.MaxClueLength)
end

-- Point-in-box test in the volume's local space (centre at the origin, half sizes hx, hy, hz).
-- NaN or invalid numbers are never inside.
function Discovery.IsInside(x: any, y: any, z: any, hx: any, hy: any, hz: any): boolean
    if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then
        return false
    end
    if type(hx) ~= "number" or type(hy) ~= "number" or type(hz) ~= "number" then
        return false
    end
    if x ~= x or y ~= y or z ~= z or hx ~= hx or hy ~= hy or hz ~= hz then
        return false
    end
    return hx > 0 and hy > 0 and hz > 0 and math.abs(x) <= hx and math.abs(y) <= hy and math.abs(z) <= hz
end

local function whole(value: any, fallback: number): number
    if type(value) == "number" and value == value and value >= 0 and value < 1e6 then
        return math.floor(value)
    end
    return fallback
end

-- Client-side text of the persistent hint under the expedition counter (display only), from the
-- server-owned Player attributes: the clue while there is one, a completed message once every place is
-- found, otherwise nil (hide the hint). Malformed values are treated as "nothing to show".
function Discovery.FormatHint(clue: any, count: any, total: any): string?
    if type(clue) == "string" and clue ~= "" then
        return "Clue: " .. string.sub(clue, 1, Discovery.MaxClueLength)
    end
    local found, all = whole(count, 0), whole(total, 0)
    if all > 0 and found >= all then
        return "All expedition places found!"
    end
    return nil
end

-- Client-side display lines for a recap summary received from the server (display only; malformed
-- data falls back to safe text). The wording says "Expedition" on purpose: these finds belong to one
-- life and are not saved as permanent discoveries. Returns (line, notableLine or nil).
function Discovery.FormatRecap(summary: any): (string, string?)
    if type(summary) ~= "table" then
        return "Expedition finds: none", nil
    end
    local count = whole(summary.count, 0)
    local total = math.max(whole(summary.total, count), count)
    local biomass = whole(summary.biomass, 0)
    local line = string.format("Expedition finds: %d/%d", count, total)
    if biomass > 0 then
        line ..= string.format(" (+%d Biomass)", biomass)
    end
    local notable: string? = nil
    if count > 0 and type(summary.notable) == "string" and summary.notable ~= "" then
        notable = "Best find: " .. string.sub(summary.notable, 1, 40)
    end
    return line, notable
end

return table.freeze(Discovery)
