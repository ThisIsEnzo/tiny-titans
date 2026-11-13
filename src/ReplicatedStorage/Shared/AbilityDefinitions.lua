--!strict
-- Authoritative, immutable definitions of the abilities (P2-03).
-- Pure data: no Roblox services and no requires, so it loads both in Studio and in Lune tests.
--
-- Single source of truth for ability ids, display names, the form each ability requires and
-- the ability-specific tuning (duration, cooldown, gravity compensation). It does not contain
-- behaviour: the specialised Shell and Glide implementations stay in AbilityService, selected by
-- `kind`. Global settings (Config.AbilityKey, Config.AbilityRequestInterval) stay in Config.
--
-- Relationship with CreatureDefinitions: a form lists the ability ids it owns
-- (TANK -> SHELL, GLIDER -> GLIDE, BABY_BUG -> none) and each ability names the form that may
-- use it. Neither module requires the other, which avoids a dependency cycle; the tests
-- (tests/AbilityDefinitions.test.lua) check that the two references agree.
--
-- Honest behaviour notes:
--   * SHELL is VISUAL ONLY. It does not mitigate damage (there is no damage system yet).
--   * GLIDE is a bounded glide, NOT flight: it needs the player to be airborne, cancels only a
--     fraction of gravity (one share while rising, a larger one while descending, both capped below 1
--     by Ability.GetGlideForce) and ends on landing, death or when `durationSeconds` expires.
--
-- To add an ability later: add one entry below (and a `kind` plus its implementation if it needs
-- new behaviour). IDs are stable strings and must never be reused or renamed once shipped.

export type ShellDefinition = {
    id: string,
    displayName: string,
    kind: "Shell",
    requiredForm: string, -- server-owned form that may activate it
    durationSeconds: number, -- how long the shell stays up
    cooldownSeconds: number, -- from activation until it can be used again
}

export type GlideDefinition = {
    id: string,
    displayName: string,
    kind: "Glide",
    requiredForm: string,
    durationSeconds: number, -- MAXIMUM glide time; landing or death ends it earlier
    cooldownSeconds: number, -- from activation until it can be used again
    gravityCompensation: number, -- fraction of gravity cancelled while DESCENDING; must stay below 1
    ascentCompensation: number, -- fraction cancelled while still RISING (raises a glided jump's apex); must stay below 1
}

export type AbilityDefinition = ShellDefinition | GlideDefinition

local SHELL_ID = "SHELL"
local GLIDE_ID = "GLIDE"

local shell: ShellDefinition = table.freeze({
    id = SHELL_ID,
    displayName = "Defensive Shell",
    kind = "Shell" :: "Shell",
    requiredForm = "TANK",
    durationSeconds = 3,
    cooldownSeconds = 12,
})

local glide: GlideDefinition = table.freeze({
    id = GLIDE_ID,
    displayName = "Air Glide",
    kind = "Glide" :: "Glide",
    requiredForm = "GLIDER",
    durationSeconds = 3,
    cooldownSeconds = 10,
    -- Tuned from kinematics at default gravity (196.2), applied only while descending: a fall from the
    -- apex of a normal jump (7.2 studs) lasts 0.85 s instead of 0.27 s and a 20-stud drop 1.4 s instead
    -- of 0.45 s, with a gentle landing (about 17 studs/s). The earlier 0.65 gave only 0.45 s from the
    -- apex, shorter than the airtime of an ordinary jump. Net acceleration stays downward (never rises).
    gravityCompensation = 0.9,
    -- While rising the original 0.65 is kept on purpose: it gives the designed apex gain (about 20
    -- studs for a jump glided from take-off) that the glider-only platforms rely on.
    ascentCompensation = 0.65,
})

-- Ordered: the order abilities are listed in.
local definitions: { AbilityDefinition } = table.freeze({ shell, glide })

-- Derived once at load from `definitions`; never a second list to keep in sync.
local byId: { [string]: AbilityDefinition } = {}
local ids: { string } = {}
for _, ability in definitions do
    assert(byId[ability.id] == nil, "duplicate ability id: " .. ability.id)
    byId[ability.id] = ability
    table.insert(ids, ability.id)
end
table.freeze(byId)

local AbilityDefinitions = {
    ShellId = SHELL_ID,
    GlideId = GLIDE_ID,
    Abilities = definitions, -- ordered, frozen
    AbilityIds = table.freeze(ids), -- ordered, frozen
}

-- Returns the definition for an exact, case-sensitive ability id, or nil for anything else
-- (unknown ids and non-string values included).
function AbilityDefinitions.GetAbility(id: any): AbilityDefinition?
    if type(id) ~= "string" then
        return nil
    end
    return byId[id]
end

return table.freeze(AbilityDefinitions)
