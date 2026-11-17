--!strict
-- Catalog of the habitat's EXPEDITION DISCOVERIES (TT-P3-02): per-life exploration objectives. The same
-- places can be found again in every life and nothing is saved; the unqualified word "Discoveries" is
-- reserved for the future permanent (Legacy) knowledge system. This module is the single source of
-- truth for each place's stable id, player-facing name, the clue shown for finding it, and its small
-- Biomass reward (repeatable per life, so it can be earned again in each new life).
-- Pure data: no Roblox services, no requires, so it loads in Studio and in Lune.
--
-- WHERE a discovery happens is not here: it is an invisible trigger volume in the map
-- (Workspace/Habitat/DiscoverySites, one part per discovery, tag "DiscoverySite", part Name = id).
-- DiscoveryService reads those parts; tools/habitat/validate_habitat.py checks that every id here has
-- exactly one reachable volume and vice versa.
--
-- Order matters: it is the suggested exploration order (the "Next:" clue is the first discovery the
-- player has not found yet) and the order of the recap. Rewards are deliberately modest next to
-- Config.FoodBiomass (10): ordinary food stays the main source of Biomass.
-- IDs are stable strings; never reuse or rename them.

export type DiscoveryDefinition = {
    id: string,
    displayName: string,
    clue: string, -- one short sentence that points at the place without giving coordinates
    biomass: number, -- Biomass granted once per life (clamped to the cap by PlayerDataService)
}

local definitions: { DiscoveryDefinition } = table.freeze({
    table.freeze({
        id = "GREAT_STUMP",
        displayName = "Great Stump Lookout",
        clue = "Climb the log ramp onto the Great Stump and look around.",
        biomass = 4,
    }),
    table.freeze({
        id = "MUSHROOM_GROVE",
        displayName = "Mushroom Grove",
        clue = "A grove of giant caps shades the meadow's far east side.",
        biomass = 4,
    }),
    table.freeze({
        id = "ROCK_TERRACE",
        displayName = "Rock Terrace",
        clue = "Stone terraces climb above the Rock Garden's winding passage.",
        biomass = 4,
    }),
    table.freeze({
        id = "OLD_TREE",
        displayName = "Foot of the Old Tree",
        clue = "The Old Tree towers in the north-east. Find its foot.",
        biomass = 4,
    }),
    table.freeze({
        id = "ROOT_ARCH",
        displayName = "Root Arch Top",
        clue = "Get above the Root Arch for a view over the roots.",
        biomass = 5,
    }),
    table.freeze({
        id = "DEWDROP_GLADE",
        displayName = "Dewdrop Glade",
        clue = "A pale beam rises behind the Rock Garden. Something hides there.",
        biomass = 8,
    }),
})

local byId: { [string]: DiscoveryDefinition } = {}
local ids: { string } = {}
for _, definition in definitions do
    assert(byId[definition.id] == nil, "duplicate discovery id: " .. definition.id)
    byId[definition.id] = definition
    table.insert(ids, definition.id)
end
table.freeze(byId)

local DiscoveryDefinitions = {
    Discoveries = definitions, -- ordered, frozen
    Ids = table.freeze(ids), -- ordered, frozen
}

-- The definition for an exact, case-sensitive id, or nil (unknown ids and non-strings included).
function DiscoveryDefinitions.GetDiscovery(id: any): DiscoveryDefinition?
    if type(id) ~= "string" then
        return nil
    end
    return byId[id]
end

return table.freeze(DiscoveryDefinitions)
