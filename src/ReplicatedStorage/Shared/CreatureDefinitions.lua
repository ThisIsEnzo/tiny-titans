--!strict
-- Authoritative, immutable definitions of the creature forms (P2-02).
-- Pure data: no Roblox services and no requires, so it loads in Studio and Lune.
-- Ability behavior/tuning belongs to AbilityDefinitions (P2-03); generated evolution UI belongs to P2-04.
-- Growth milestones and the Biomass cap remain in Config.
-- Form IDs are stable identifiers and must never be reused or renamed once shipped.

export type Requirement = {
    resource: "Biomass",
    amount: number,
}

export type FormDefinition = {
    id: string,
    displayName: string,
    role: string,
    description: string,
    isStarter: boolean,
    requirement: Requirement?,
    abilities: { string }, -- ability ids; AbilityDefinitions holds their definitions
}

local STARTER_FORM_ID = "BABY_BUG"

local function biomass(amount: number): Requirement
    return table.freeze({ resource = "Biomass" :: "Biomass", amount = amount })
end

local function ids(list: { string }): { string }
    return table.freeze(list)
end

local definitions: { FormDefinition } = table.freeze({
    table.freeze({
        id = STARTER_FORM_ID,
        displayName = "Baby Bug",
        role = "Starter",
        description = "The small starting form. It has no ability and grows as it collects Biomass.",
        isStarter = true,
        requirement = nil,
        abilities = ids({}),
    }),
    table.freeze({
        id = "TANK",
        displayName = "Tank",
        role = "Defensive",
        description = "Evolved form with the Defensive Shell [Q]. The shell is a visual bubble only for now and does not reduce damage.",
        isStarter = false,
        requirement = biomass(100),
        abilities = ids({ "SHELL" }),
    }),
    table.freeze({
        id = "GLIDER",
        displayName = "Glider",
        role = "Mobility",
        description = "Evolved form with the Air Glide [Q]. A short, bounded glide that slows your fall in the air; it is not flight.",
        isStarter = false,
        requirement = biomass(100),
        abilities = ids({ "GLIDE" }),
    }),
})

local byId: { [string]: FormDefinition } = {}
local evolved: { FormDefinition } = {}
local evolvedIds: { string } = {}
local starter: FormDefinition? = nil

for _, form in definitions do
    assert(byId[form.id] == nil, "duplicate form id: " .. form.id)
    byId[form.id] = form
    if form.isStarter then
        assert(starter == nil, "more than one starter form")
        starter = form
    else
        table.insert(evolved, form)
        table.insert(evolvedIds, form.id)
    end
end

assert(starter ~= nil and starter.id == STARTER_FORM_ID, "missing starter form")
table.freeze(byId)

local CreatureDefinitions = {
    StarterFormId = STARTER_FORM_ID,
    Starter = starter :: FormDefinition,
    Forms = definitions,
    EvolvedForms = table.freeze(evolved),
    EvolvedFormIds = table.freeze(evolvedIds),
}

function CreatureDefinitions.GetForm(id: any): FormDefinition?
    if type(id) ~= "string" then
        return nil
    end
    return byId[id]
end

return table.freeze(CreatureDefinitions)
