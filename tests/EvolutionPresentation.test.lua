--!strict
-- Optional unit tests for Shared/EvolutionPresentation.lua (P2-04): the pure data preparation
-- behind the evolution UI. Run with Lune from the repository root:
--   lune run tests/EvolutionPresentation.test.lua
-- It does NOT instantiate any Roblox GUI (layout, taps and tags need Studio; README checklist).
-- Tests describe relationships to the catalogs rather than re-asserting today's literal values.

local Creatures = require("../src/ReplicatedStorage/Shared/CreatureDefinitions")
local Abilities = require("../src/ReplicatedStorage/Shared/AbilityDefinitions")
local Evolution = require("../src/ReplicatedStorage/Shared/Evolution")
local Presentation = require("../src/ReplicatedStorage/Shared/EvolutionPresentation")

local failures = 0
local function check(name: string, condition: boolean)
    if not condition then
        failures += 1
        print("FAIL: " .. name)
    else
        print("ok:   " .. name)
    end
end

local function metBy(biomass: number): (any) -> boolean
    return function(requirement: any): boolean
        return Evolution.IsRequirementMet(requirement, biomass)
    end
end

-- Catalog relationships the UI depends on.
local referencesKnown = true
local metadataPresent = true
for _, form in Creatures.EvolvedForms do
    for _, abilityId in form.abilities do
        if Abilities.GetAbility(abilityId) == nil then
            referencesKnown = false
        end
    end
    if form.displayName == "" or form.role == "" or form.description == "" or form.requirement == nil then
        metadataPresent = false
    end
end
check("every evolved form references only known ability ids", referencesKnown)
check("every evolved form has a display name, role, description and requirement", metadataPresent)

-- Cards are generated from EvolvedForms, in order, keyed by form id.
local cards = Presentation.BuildCards(Creatures, Abilities, metBy(0))
check("one card per evolved form", #cards == #Creatures.EvolvedForms)
local orderOk, textOk, idsOk = true, true, true
for i, card in cards do
    local form = Creatures.EvolvedForms[i]
    if card.formId ~= form.id then
        orderOk = false
    end
    if card.displayName ~= form.displayName or card.role ~= form.role or card.description ~= form.description then
        textOk = false
    end
    if card.displayName == card.formId then
        idsOk = false
    end
end
check("cards follow catalog order and carry the stable form id", orderOk)
check("card text comes from the catalog", textOk)
check("the primary label is a display name, not the internal id", idsOk)
check("the starter form never gets a card", (function()
    for _, card in cards do
        if card.formId == Creatures.StarterFormId then
            return false
        end
    end
    return true
end)())

-- Abilities are resolved through AbilityDefinitions.
local abilitiesOk = true
for i, card in cards do
    local form = Creatures.EvolvedForms[i]
    if #card.abilities ~= #form.abilities then
        abilitiesOk = false
    end
    for j, view in card.abilities do
        local definition = Abilities.GetAbility(form.abilities[j])
        if definition == nil or not view.known or view.name ~= definition.displayName or view.id ~= definition.id then
            abilitiesOk = false
        end
    end
    if string.find(card.abilitySummary, "Unknown", 1, true) ~= nil then
        abilitiesOk = false
    end
end
check("ability names come from AbilityDefinitions and are all known", abilitiesOk)

-- Requirement text and locked state follow the catalog and Biomass (feedback only).
local requirementOk = true
for i, card in cards do
    local amount = Creatures.EvolvedForms[i].requirement.amount
    if card.requirementText == nil or string.find(card.requirementText, tostring(amount), 1, true) == nil then
        requirementOk = false
    end
end
check("requirement text states the form's own amount", requirementOk)
local lockedBelow = Presentation.BuildCards(Creatures, Abilities, metBy(-1))
local unlockedAt = Presentation.BuildCards(Creatures, Abilities, function(requirement: any): boolean
    return Evolution.IsRequirementMet(requirement, requirement.amount)
end)
local lockOk = true
for i = 1, #cards do
    if not lockedBelow[i].locked or unlockedAt[i].locked then
        lockOk = false
    end
end
check("cards are locked below and unlocked at their own requirement", lockOk)

-- Form names.
check("form name comes from the catalog", Presentation.GetFormName(Creatures, Creatures.StarterFormId) == Creatures.Starter.displayName)
check("unknown form id falls back to the id", Presentation.GetFormName(Creatures, "FLY") == "FLY")
check("non-string form falls back safely", Presentation.GetFormName(Creatures, nil) == "Unknown" and Presentation.GetFormName(Creatures, 5) == "Unknown")
check("empty form id falls back safely", Presentation.GetFormName(Creatures, "") == "Unknown")

-- Fixtures: a future form needs no UI change; unknown ability references are safe and visible.
local fixtureForms = {
    EvolvedForms = {
        {
            id = "ONE",
            displayName = "One",
            role = "R1",
            description = "D1",
            requirement = { resource = "Biomass", amount = 50 },
            abilities = { "KNOWN" },
        },
        {
            id = "TWO",
            displayName = "Two",
            role = "R2",
            description = "D2",
            requirement = { resource = "Biomass", amount = 200 },
            abilities = { "KNOWN", "MISSING" },
        },
        { id = "THREE", displayName = "Three", role = "R3", description = "D3", abilities = {} }, -- no requirement
    },
    GetForm = function(id: any): any
        for _, form in { { id = "ONE", displayName = "One" }, { id = "TWO", displayName = "Two" }, { id = "THREE", displayName = "Three" } } do
            if form.id == id then
                return form
            end
        end
        return nil
    end,
}
local fixtureAbilities = {
    GetAbility = function(id: any): any
        if id == "KNOWN" then
            return { id = "KNOWN", displayName = "Known Ability" }
        end
        return nil
    end,
}
local generated = Presentation.BuildCards(fixtureForms, fixtureAbilities, metBy(100))
check("fixture: a card per form with no UI change", #generated == 3 and generated[1].formId == "ONE" and generated[3].formId == "THREE")
check("fixture: requirements are per form", not generated[1].locked and generated[2].locked)
check("fixture: a form without a requirement is locked and has no requirement text", generated[3].locked and generated[3].requirementText == nil)
check("fixture: a known ability is resolved", generated[1].abilities[1].known and generated[1].abilities[1].name == "Known Ability")
check("fixture: single ability summary", generated[1].abilitySummary == "Ability: Known Ability")
check("fixture: an unknown ability id is visible and does not error",
    not generated[2].abilities[2].known and generated[2].abilities[2].name == "Unknown ability (MISSING)"
        and string.find(generated[2].abilitySummary, "Unknown ability (MISSING)", 1, true) ~= nil)
check("fixture: the known ability still resolves beside an unknown one", generated[2].abilities[1].known)
check("fixture: no abilities reads as no ability", generated[3].abilitySummary == "No ability")
local bad: { any } = { nil, 5, true, {}, "", "X" }
local badSafe = true
for i = 1, 6 do
    local ok, view = pcall(Presentation.GetAbilityView, fixtureAbilities, bad[i])
    if not ok or (view :: any).known then
        badSafe = false
    end
end
check("malformed ability ids never error and are never 'known'", badSafe)
check("requirement text ignores unsupported requirements",
    Presentation.RequirementText(nil) == nil and Presentation.RequirementText({ resource = "Gold", amount = 1 }) == nil
        and Presentation.RequirementText({ resource = "Biomass" }) == nil)

-- Layout rule.
check("one column for one form, two for two or more",
    Presentation.GetColumnCount(0) == 1 and Presentation.GetColumnCount(1) == 1 and Presentation.GetColumnCount(2) == 2
        and Presentation.GetColumnCount(3) == 2 and Presentation.GetColumnCount(7) == 2)

if failures > 0 then
    error(failures .. " test(s) failed")
end
print("all tests passed")
