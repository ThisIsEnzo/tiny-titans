--!strict
-- Pure presentation helpers for the evolution UI (P2-04). No Roblox services and no requires:
-- callers pass the catalogs in (CreatureDefinitions, AbilityDefinitions), like Evolution.lua.
-- They only READ catalog data and prepare display values; nothing here decides whether an
-- evolution is allowed (the server does). "Locked" is UI feedback only.

local EvolutionPresentation = {}

export type AbilityView = {
    id: string,
    name: string, -- player-facing name, never the raw id (except for an unknown id, shown on purpose)
    known: boolean, -- false when the id has no AbilityDefinitions entry
}

export type CardView = {
    formId: string, -- stable id: the only thing the client ever sends
    displayName: string,
    role: string,
    description: string,
    abilities: { AbilityView },
    abilitySummary: string,
    requirementText: string?, -- nil when the form has no requirement
    locked: boolean, -- UI feedback only: the requirement is not met by the replicated Biomass
}

-- Only the parts of the catalogs this module reads (structural, so tests can pass fixtures).
export type FormCatalog = { EvolvedForms: { any }, GetForm: (any) -> any }
export type AbilityCatalog = { GetAbility: (any) -> any }

-- Player-facing name of a form id: the catalog's display name, else the id itself for an unknown
-- form (the previous fallback), else "Unknown" for a non-string.
function EvolutionPresentation.GetFormName(catalog: FormCatalog, form: any): string
    local definition = catalog.GetForm(form)
    if definition ~= nil and type(definition.displayName) == "string" and definition.displayName ~= "" then
        return definition.displayName
    end
    if type(form) == "string" and form ~= "" then
        return form
    end
    return "Unknown"
end

-- Resolves one ability id through the ability catalog. An unknown or malformed id never errors:
-- it is returned as a visible "Unknown ability" entry so a bad catalog reference can be noticed.
function EvolutionPresentation.GetAbilityView(catalog: AbilityCatalog, abilityId: any): AbilityView
    local definition = catalog.GetAbility(abilityId)
    if definition ~= nil and type(definition.displayName) == "string" and definition.displayName ~= "" then
        return { id = definition.id, name = definition.displayName, known = true }
    end
    local idText = if type(abilityId) == "string" then abilityId else tostring(abilityId)
    return { id = idText, name = "Unknown ability (" .. idText .. ")", known = false }
end

-- "Requires 100 Biomass", or nil without a (supported) requirement.
function EvolutionPresentation.RequirementText(requirement: any): string?
    if type(requirement) ~= "table" or requirement.resource ~= "Biomass" or type(requirement.amount) ~= "number" then
        return nil
    end
    return "Requires " .. tostring(requirement.amount) .. " Biomass"
end

local function summarize(abilities: { AbilityView }): string
    if #abilities == 0 then
        return "No ability"
    end
    local names: { string } = {}
    for _, ability in abilities do
        table.insert(names, ability.name)
    end
    return (if #abilities == 1 then "Ability: " else "Abilities: ") .. table.concat(names, ", ")
end

-- One view per evolved form, in catalog order. `meets(requirement)` tells whether the replicated
-- Biomass satisfies a requirement (the controller passes Evolution.IsRequirementMet); a form
-- without a usable requirement is shown locked.
function EvolutionPresentation.BuildCards(
    forms: FormCatalog,
    abilities: AbilityCatalog,
    meets: (any) -> boolean
): { CardView }
    local cards: { CardView } = {}
    for _, definition in forms.EvolvedForms do
        local abilityViews: { AbilityView } = {}
        for _, abilityId in definition.abilities or {} do
            table.insert(abilityViews, EvolutionPresentation.GetAbilityView(abilities, abilityId))
        end
        table.insert(cards, {
            formId = definition.id,
            displayName = EvolutionPresentation.GetFormName(forms, definition.id),
            role = definition.role or "",
            description = definition.description or "",
            abilities = abilityViews,
            abilitySummary = summarize(abilityViews),
            requirementText = EvolutionPresentation.RequirementText(definition.requirement),
            locked = not meets(definition.requirement),
        })
    end
    return cards
end

-- Card grid columns: two for two or more forms (the existing layout), one for a single form.
-- More forms add rows, never columns.
function EvolutionPresentation.GetColumnCount(formCount: number): number
    return if formCount >= 2 then 2 else 1
end

return table.freeze(EvolutionPresentation)
