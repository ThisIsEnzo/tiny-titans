--!strict
-- Optional unit tests for the pure rules of the per-life Expedition Discoveries (TT-P3-02): Shared/Discovery.lua and
-- Shared/DiscoveryDefinitions.lua. Run with Lune from the repository root:
--   lune run tests/Discovery.test.lua
-- Lune is NOT part of rokit.toml; this file is outside the Rojo project tree.
--
-- These tests prove the rules (once per life, stale events, per-player isolation, recap numbers,
-- trigger-volume maths, display formatting). They do NOT prove the Roblox wiring: DiscoveryService
-- polling real characters, the trigger volumes in the map (checked offline by
-- tools/habitat/validate_habitat.py), the RemoteEvent, the HUD or the recap panel. That needs Studio.

local Config = require("../src/ReplicatedStorage/Shared/Config")
local Defs = require("../src/ReplicatedStorage/Shared/DiscoveryDefinitions")
local Discovery = require("../src/ReplicatedStorage/Shared/Discovery")

local failures = 0
local function check(name: string, condition: boolean)
    if not condition then
        failures += 1
        print("FAIL: " .. name)
    else
        print("ok:   " .. name)
    end
end

local function throws(fn: () -> ()): boolean
    return not pcall(fn)
end

-- 1. Catalog ---------------------------------------------------------------------------------------
check("at least five discoveries", #Defs.Discoveries >= 5)
check("ids list matches the ordered list", #Defs.Ids == #Defs.Discoveries)
local seen: { [string]: boolean } = {}
local catalogOk, rewardTotal = true, 0
for index, d in Defs.Discoveries do
    if seen[d.id] or Defs.Ids[index] ~= d.id or string.match(d.id, "^[A-Z_]+$") == nil then
        catalogOk = false
    end
    seen[d.id] = true
    if d.displayName == "" or #d.displayName > 40 or d.clue == "" or #d.clue > 120 or d.displayName == d.id then
        catalogOk = false
    end
    if type(d.biomass) ~= "number" or d.biomass <= 0 or d.biomass ~= math.floor(d.biomass) then
        catalogOk = false
    end
    if d.biomass > Config.FoodBiomass then
        catalogOk = false -- a discovery never pays more than one food item
    end
    rewardTotal += d.biomass
end
check("ids unique, stable-looking, names and clues present, rewards whole and at most one food item", catalogOk)
check("all discoveries together are worth less than half the Biomass cap (food stays the main source)", rewardTotal < Config.EvolutionBiomassRequired / 2)
check("the most valuable discovery is the last one in the suggested order (the secret)", (function()
    local best = Defs.Discoveries[#Defs.Discoveries].biomass
    for _, d in Defs.Discoveries do
        if d.biomass > best then
            return false
        end
    end
    return true
end)())
check("catalog and entries are frozen", table.isfrozen(Defs) and table.isfrozen(Defs.Discoveries) and table.isfrozen(Defs.Ids) and table.isfrozen(Defs.Discoveries[1]))
check("catalog cannot be changed", throws(function()
    (Defs.Discoveries[1] :: any).biomass = 999
end) and throws(function()
    table.insert(Defs.Discoveries :: any, {})
end))
check("lookup by id", (Defs.GetDiscovery("GREAT_STUMP") :: any).id == "GREAT_STUMP")
local badIds: { any } = { "great_stump", "Great Stump Lookout", "", "NOPE", 1, true, {}, false }
local allNil = Defs.GetDiscovery(nil) == nil
for _, value in badIds do
    if Defs.GetDiscovery(value) ~= nil then
        allNil = false
    end
end
check("unknown or malformed ids resolve to nil", allNil)

-- 2. Logs, lives and once-per-life ----------------------------------------------------------------
local tracker = Discovery.NewTracker()
check("a new tracker is empty", tracker.log == nil and tracker.ended == nil)
local ok, reason, def = Discovery.TryDiscover(tracker, 1, "GREAT_STUMP", Defs)
check("first discovery succeeds and returns its definition", ok and reason == "Ok" and def ~= nil and def.id == "GREAT_STUMP")
check("it is now found for that life", Discovery.HasFound(tracker, 1, "GREAT_STUMP"))
check("it is not 'found' for another life or id", not Discovery.HasFound(tracker, 2, "GREAT_STUMP") and not Discovery.HasFound(tracker, 1, "OLD_TREE"))
ok, reason = Discovery.TryDiscover(tracker, 1, "GREAT_STUMP", Defs)
check("the same discovery cannot be found twice in a life", not ok and reason == "AlreadyFound")
check("a repeat leaves exactly one entry", #(tracker.log :: any).order == 1)
ok, reason = Discovery.TryDiscover(tracker, 1, "NOPE", Defs)
check("an unknown id is rejected", not ok and reason == "Unknown")
for _, badLife in { 0, -1, 1.5, 0 / 0, math.huge, "1" :: any, nil :: any } do
    local fresh = Discovery.NewTracker()
    local okBad, why = Discovery.TryDiscover(fresh, badLife, "GREAT_STUMP", Defs)
    check("malformed life id " .. tostring(badLife) .. " is rejected without creating state", not okBad and why == "StaleLife" and fresh.log == nil)
end
ok, reason = Discovery.TryDiscover(tracker, nil, "OLD_TREE", Defs)
check("a nil id and life never grant anything", not ok)
check("a second, different discovery in the same life works", (Discovery.TryDiscover(tracker, 1, "MUSHROOM_GROVE", Defs)))

-- Rewards are recorded only when valid.
Discovery.RecordBiomass(tracker, 1, 4)
Discovery.RecordBiomass(tracker, 1, 0)
Discovery.RecordBiomass(tracker, 1, -5)
Discovery.RecordBiomass(tracker, 1, 0 / 0)
Discovery.RecordBiomass(tracker, 1, "9" :: any)
Discovery.RecordBiomass(tracker, 2, 7) -- another life: ignored
check("only valid grants for the current life count toward the life's Biomass", (tracker.log :: any).biomassEarned == 4)

-- Stale events: an older life can never touch a newer log.
local newer = Discovery.NewTracker()
Discovery.TryDiscover(newer, 5, "OLD_TREE", Defs)
ok, reason = Discovery.TryDiscover(newer, 4, "GREAT_STUMP", Defs)
check("an event for an OLDER life is stale and changes nothing", not ok and reason == "StaleLife" and #(newer.log :: any).order == 1 and (newer.log :: any).lifeId == 5)
check("a stale record of Biomass is ignored", (function()
    Discovery.RecordBiomass(newer, 4, 50)
    return (newer.log :: any).biomassEarned == 0
end)())

-- 3. Lifecycle: death, reset, new life, recap order independence -----------------------------------
local life = Discovery.NewTracker()
Discovery.TryDiscover(life, 1, "GREAT_STUMP", Defs)
Discovery.RecordBiomass(life, 1, 4)
Discovery.TryDiscover(life, 1, "DEWDROP_GLADE", Defs)
Discovery.RecordBiomass(life, 1, 8)
local before = Discovery.SummaryForLife(life, 1, Defs) -- recap read BEFORE the reset
Discovery.ResetTracker(life) -- the life ended; ResetService resets
local after = Discovery.SummaryForLife(life, 1, Defs) -- recap read AFTER the reset
check("the recap of the ended life is identical whether it is read before or after the reset",
    before.count == after.count and before.biomass == after.biomass and before.notable == after.notable and #before.names == #after.names)
check("the ended life had 2 discoveries worth 12 Biomass, most notable the secret", after.count == 2 and after.biomass == 12 and after.notable == "Dewdrop Glade")
check("after the reset nothing is found for the new life", not Discovery.HasFound(life, 2, "GREAT_STUMP") and Discovery.SummaryForLife(life, 2, Defs).count == 0)
check("resetting twice is harmless and keeps the finished life's log", (function()
    Discovery.ResetTracker(life)
    Discovery.ResetTracker(life)
    return Discovery.SummaryForLife(life, 1, Defs).count == 2
end)())
ok = Discovery.TryDiscover(life, 2, "GREAT_STUMP", Defs)
check("the same discovery can be found again in the next life", ok)
check("starting the next life archived nothing wrong: life 1's recap is still readable", Discovery.SummaryForLife(life, 1, Defs).count == 2)
check("and life 2 counts only its own discovery", Discovery.SummaryForLife(life, 2, Defs).count == 1)
ok, reason = Discovery.TryDiscover(life, 2, "GREAT_STUMP", Defs)
check("once per life again in the next life", not ok and reason == "AlreadyFound")
-- A new life begins without an explicit reset in between: the previous log is archived.
local skipped = Discovery.NewTracker()
Discovery.TryDiscover(skipped, 1, "OLD_TREE", Defs)
Discovery.TryDiscover(skipped, 2, "OLD_TREE", Defs)
check("a newer life archives the older log by itself", Discovery.SummaryForLife(skipped, 1, Defs).count == 1 and Discovery.SummaryForLife(skipped, 2, Defs).count == 1)
check("a life with no discoveries has an empty recap", Discovery.SummaryForLife(Discovery.NewTracker(), 7, Defs).count == 0)
check("a life that is neither current nor the last finished one has an empty recap", Discovery.SummaryForLife(skipped, 9, Defs).count == 0)

-- 4. Player isolation ---------------------------------------------------------------------------------
local a, b = Discovery.NewTracker(), Discovery.NewTracker()
Discovery.TryDiscover(a, 1, "ROOT_ARCH", Defs)
check("player B did not discover what player A discovered", not Discovery.HasFound(b, 1, "ROOT_ARCH") and Discovery.SummaryForLife(b, 1, Defs).count == 0)
check("player B can discover the same place independently", (Discovery.TryDiscover(b, 1, "ROOT_ARCH", Defs)))
Discovery.ResetTracker(a)
check("resetting A does not touch B", Discovery.HasFound(b, 1, "ROOT_ARCH"))
check("the same life id in two trackers is two separate logs", (a.ended :: any) ~= (b.log :: any))

-- 5. Summary, notable, next clue -------------------------------------------------------------------------
local s = Discovery.NewTracker()
for _, id in { "ROCK_TERRACE", "GREAT_STUMP", "OLD_TREE" } do
    Discovery.TryDiscover(s, 1, id, Defs)
end
local summary = Discovery.SummaryForLife(s, 1, Defs)
check("summary lists names in the order found", summary.names[1] == "Rock Terrace" and summary.names[2] == "Great Stump Lookout" and summary.names[3] == "Foot of the Old Tree")
check("summary total is the catalog size", summary.total == #Defs.Discoveries and summary.count == 3)
check("a tie for the most valuable keeps the earliest discovery", summary.notable == "Rock Terrace")
Discovery.TryDiscover(s, 1, "ROOT_ARCH", Defs)
check("a more valuable discovery becomes the notable one", Discovery.SummaryForLife(s, 1, Defs).notable == "Root Arch Top")
local nextClue = Discovery.NextClue(s, 1, Defs)
check("the next clue is the first undiscovered in catalog order", nextClue ~= nil and nextClue.id == "MUSHROOM_GROVE" and nextClue.clue ~= "")
for _, d in Defs.Discoveries do
    Discovery.TryDiscover(s, 1, d.id, Defs)
end
check("when everything is found there is no next clue", Discovery.NextClue(s, 1, Defs) == nil and Discovery.SummaryForLife(s, 1, Defs).count == #Defs.Discoveries)
check("a fresh life's next clue is the first discovery", (Discovery.NextClue(Discovery.NewTracker(), 1, Defs) :: any).id == Defs.Discoveries[1].id)
-- fixtures: the logic reads the catalog it is given (nothing hard-coded)
local fixture = {
    Discoveries = { { id = "A", displayName = "Alpha", clue = "c", biomass = 1 }, { id = "B", displayName = "Beta", clue = "d", biomass = 2 } },
    GetDiscovery = function(id: any): any
        if id == "A" then
            return { id = "A", displayName = "Alpha", clue = "c", biomass = 1 }
        elseif id == "B" then
            return { id = "B", displayName = "Beta", clue = "d", biomass = 2 }
        end
        return nil
    end,
}
local ft = Discovery.NewTracker()
check("works with another catalog", (Discovery.TryDiscover(ft, 1, "B", fixture)) and Discovery.SummaryForLife(ft, 1, fixture).total == 2 and Discovery.NextClue(ft, 1, fixture).id == "A")

-- 6. Trigger volume maths ---------------------------------------------------------------------------------
check("the centre is inside", Discovery.IsInside(0, 0, 0, 5, 3, 5))
check("the surface counts as inside", Discovery.IsInside(5, 3, -5, 5, 3, 5))
check("just outside on each axis is not inside", not Discovery.IsInside(5.01, 0, 0, 5, 3, 5) and not Discovery.IsInside(0, 3.01, 0, 5, 3, 5) and not Discovery.IsInside(0, 0, -5.01, 5, 3, 5))
check("far away is not inside", not Discovery.IsInside(500, 0, 0, 5, 3, 5))
check("above or below the volume is not inside (a different floor)", not Discovery.IsInside(0, 9, 0, 5, 3, 5) and not Discovery.IsInside(0, -9, 0, 5, 3, 5))
check("NaN and infinity are never inside", not Discovery.IsInside(0 / 0, 0, 0, 5, 3, 5) and not Discovery.IsInside(math.huge, 0, 0, 5, 3, 5) and not Discovery.IsInside(0, 0, 0, 0 / 0, 3, 5))
check("a degenerate or negative volume contains nothing", not Discovery.IsInside(0, 0, 0, 0, 3, 5) and not Discovery.IsInside(0, 0, 0, -5, 3, 5))
check("missing or non-numeric arguments are never inside", not Discovery.IsInside(nil, 0, 0, 5, 3, 5) and not Discovery.IsInside(0, "0" :: any, 0, 5, 3, 5) and not Discovery.IsInside(0, 0, 0, 5, 3, nil))

-- 7. Recap formatting (client display; malformed input is safe) -----------------------------------------
local line, notable = Discovery.FormatRecap({ count = 3, total = 6, biomass = 13, names = {}, notable = "Dewdrop Glade" })
check("recap line shows count, total and Biomass (expedition wording)", line == "Expedition finds: 3/6 (+13 Biomass)")
check("recap notable line", notable == "Best find: Dewdrop Glade")
line, notable = Discovery.FormatRecap({ count = 2, total = 6, biomass = 0, notable = "X" })
check("no Biomass part when none was gained", line == "Expedition finds: 2/6")
line, notable = Discovery.FormatRecap({ count = 0, total = 6, biomass = 0, notable = "Ghost" })
check("no notable line without discoveries", line == "Expedition finds: 0/6" and notable == nil)
for _, bad in { nil :: any, 5, "x", true, {} } do
    local l, n = Discovery.FormatRecap(bad)
    check("malformed summary " .. tostring(bad) .. " falls back safely", type(l) == "string" and l ~= "" and (n == nil or type(n) == "string"))
end
line = Discovery.FormatRecap({ count = 9, total = 2, biomass = -4, notable = 7 })
check("a total below the count is raised and a negative Biomass is dropped", line == "Expedition finds: 9/9")
line, notable = Discovery.FormatRecap({ count = 1, total = 1, biomass = 1, notable = string.rep("a", 500) })
check("an oversized notable name is truncated", notable ~= nil and #notable <= #"Best find: " + 40)
line = Discovery.FormatRecap({ count = 1.9, total = 6.2, biomass = 3.7 })
check("fractional values are floored", line == "Expedition finds: 1/6 (+3 Biomass)")

-- 8. The persistent clue (TT-P3-02 polish): a fresh expedition has the first clue, every discovery advances it,
-- the last one clears it, and a new life restores the first one. The server publishes exactly this string.
local first = Defs.Discoveries[1]
local clueTracker = Discovery.NewTracker()
check("a fresh expedition shows the first clue", Discovery.CurrentClue(clueTracker, 1, Defs) == first.clue and first.clue ~= "")
check("the clue also works before any life id exists (initial spawn)", Discovery.CurrentClue(clueTracker, nil, Defs) == first.clue and Discovery.CurrentClue(clueTracker, 0 / 0, Defs) == first.clue)
check("the published clue never exceeds the maximum length", (function()
    for _, d in Defs.Discoveries do
        local t = Discovery.NewTracker()
        for _, other in Defs.Discoveries do
            if other.id ~= d.id then
                Discovery.TryDiscover(t, 1, other.id, Defs)
            end
        end
        local clue = Discovery.CurrentClue(t, 1, Defs)
        if clue ~= d.clue or #clue > Discovery.MaxClueLength then
            return false
        end
    end
    return true
end)())
local walker = Discovery.NewTracker()
local advanceOk = true
for index, d in Defs.Discoveries do
    if Discovery.CurrentClue(walker, 1, Defs) ~= d.clue then
        advanceOk = false -- before finding place #index the clue must be place #index's
    end
    Discovery.TryDiscover(walker, 1, d.id, Defs)
    local expected = if index < #Defs.Discoveries then Defs.Discoveries[index + 1].clue else ""
    if Discovery.CurrentClue(walker, 1, Defs) ~= expected then
        advanceOk = false
    end
end
check("each discovery advances the clue to the next undiscovered place, in catalog order", advanceOk)
check("the final discovery leaves no clue", Discovery.CurrentClue(walker, 1, Defs) == "" and Discovery.SummaryForLife(walker, 1, Defs).count == #Defs.Discoveries)
check("finding places out of order skips found ones", (function()
    local t = Discovery.NewTracker()
    Discovery.TryDiscover(t, 1, Defs.Discoveries[2].id, Defs)
    local afterSecond = Discovery.CurrentClue(t, 1, Defs) -- still the first place
    Discovery.TryDiscover(t, 1, Defs.Discoveries[1].id, Defs)
    return afterSecond == Defs.Discoveries[1].clue and Discovery.CurrentClue(t, 1, Defs) == Defs.Discoveries[3].clue
end)())
Discovery.ResetTracker(walker) -- the life ended (ResetService): the next life starts clean
check("resetting for a new life restores the first clue", Discovery.CurrentClue(walker, 1, Defs) == first.clue and Discovery.CurrentClue(walker, 2, Defs) == first.clue)
check("no stale clue: the finished life's log never decides the next life's clue", (function()
    local t = Discovery.NewTracker()
    for _, d in Defs.Discoveries do
        Discovery.TryDiscover(t, 1, d.id, Defs)
    end
    local doneClue = Discovery.CurrentClue(t, 1, Defs) -- ""
    Discovery.TryDiscover(t, 2, Defs.Discoveries[1].id, Defs) -- a newer life starts without an explicit reset
    return doneClue == "" and Discovery.CurrentClue(t, 2, Defs) == Defs.Discoveries[2].clue and Discovery.CurrentClue(t, 3, Defs) == first.clue
end)())
check("the same place stays once per life while the clue stays put", (function()
    local t = Discovery.NewTracker()
    Discovery.TryDiscover(t, 1, first.id, Defs)
    local clueAfterFirst = Discovery.CurrentClue(t, 1, Defs)
    local again = Discovery.TryDiscover(t, 1, first.id, Defs)
    return not again and Discovery.CurrentClue(t, 1, Defs) == clueAfterFirst and Discovery.SummaryForLife(t, 1, Defs).count == 1
end)())
check("a place can be found and clued again in the next life", (function()
    local t = Discovery.NewTracker()
    Discovery.TryDiscover(t, 1, first.id, Defs)
    Discovery.ResetTracker(t)
    return Discovery.CurrentClue(t, 2, Defs) == first.clue and (Discovery.TryDiscover(t, 2, first.id, Defs)) and Discovery.CurrentClue(t, 2, Defs) == Defs.Discoveries[2].clue
end)())
local clueA, clueB = Discovery.NewTracker(), Discovery.NewTracker()
Discovery.TryDiscover(clueA, 1, first.id, Defs)
Discovery.TryDiscover(clueA, 1, Defs.Discoveries[2].id, Defs)
check("each player's clue is independent", Discovery.CurrentClue(clueA, 1, Defs) == Defs.Discoveries[3].clue and Discovery.CurrentClue(clueB, 1, Defs) == first.clue)
check("a rejected discovery does not move the clue", (function()
    local before = Discovery.CurrentClue(clueB, 1, Defs)
    Discovery.TryDiscover(clueB, 1, "NOPE", Defs)
    Discovery.TryDiscover(clueB, 0, first.id, Defs)
    return Discovery.CurrentClue(clueB, 1, Defs) == before
end)())
check("a catalog entry without clue text gives an empty clue instead of an error", Discovery.CurrentClue(Discovery.NewTracker(), 1, {
    Discoveries = { { id = "A", displayName = "Alpha", biomass = 1 } },
    GetDiscovery = function(): any
        return nil
    end,
}) == "")

-- 9. The persistent hint text (client display from the three server attributes).
check("a clue is shown with its prefix", Discovery.FormatHint("Climb the stump.", 0, 6) == "Clue: Climb the stump.")
check("an empty clue with everything found shows the completed message", Discovery.FormatHint("", 6, 6) == "All expedition places found!")
check("an empty clue before the totals are known hides the hint", Discovery.FormatHint("", 0, 0) == nil and Discovery.FormatHint(nil, nil, nil) == nil)
check("an empty clue mid-expedition hides the hint (nothing stale)", Discovery.FormatHint("", 3, 6) == nil)
check("a malformed clue is ignored", Discovery.FormatHint(5, 6, 6) == "All expedition places found!" and Discovery.FormatHint({}, 1, 6) == nil and Discovery.FormatHint(true, 0, 0) == nil)
check("an oversized clue is truncated", (function()
    local text = Discovery.FormatHint(string.rep("x", 500), 0, 6)
    return text ~= nil and #text <= #"Clue: " + Discovery.MaxClueLength
end)())

if failures > 0 then
    error(failures .. " test(s) failed")
end
print("all tests passed")
