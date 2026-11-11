--!strict
-- Pure evolution rules. No Roblox services; callers pass the creature catalog explicitly.

local Evolution = {}

export type Requirement = { resource: string, amount: number }
export type FormLike = { id: string, requirement: Requirement? }
export type Catalog = { StarterFormId: string, Forms: { any } }

local function findForm(catalog: Catalog, id: string): FormLike?
    for _, entry in catalog.Forms do
        local form = entry :: FormLike
        if form.id == id then
            return form
        end
    end
    return nil
end

function Evolution.IsRequirementMet(requirement: Requirement?, biomass: number): boolean
    if requirement == nil or requirement.resource ~= "Biomass" then
        return false
    end
    return biomass == biomass and biomass >= requirement.amount
end

function Evolution.IsValidForm(form: any, catalog: Catalog): boolean
    return type(form) == "string" and form ~= catalog.StarterFormId and findForm(catalog, form) ~= nil
end

function Evolution.IsRateLimited(lastRequestAt: number?, now: number, minInterval: number): boolean
    if lastRequestAt == nil then
        return false
    end
    return now - lastRequestAt < minInterval
end

function Evolution.IsAvailable(biomass: number, currentForm: string, catalog: Catalog): boolean
    if currentForm ~= catalog.StarterFormId then
        return false
    end
    for _, entry in catalog.Forms do
        local form = entry :: FormLike
        if form.id ~= catalog.StarterFormId and Evolution.IsRequirementMet(form.requirement, biomass) then
            return true
        end
    end
    return false
end

function Evolution.Validate(form: any, biomass: number, currentForm: string, catalog: Catalog): (boolean, string)
    if currentForm ~= catalog.StarterFormId then
        return false, "AlreadyEvolved"
    end
    if not Evolution.IsValidForm(form, catalog) then
        if not Evolution.IsAvailable(biomass, currentForm, catalog) then
            return false, "ThresholdNotReached"
        end
        return false, "InvalidForm"
    end
    local definition = findForm(catalog, form :: string) :: FormLike
    if not Evolution.IsRequirementMet(definition.requirement, biomass) then
        return false, "ThresholdNotReached"
    end
    return true, "Ok"
end

function Evolution.Select(form: any, biomass: number, currentForm: string, catalog: Catalog): (string, string)
    local ok, reason = Evolution.Validate(form, biomass, currentForm, catalog)
    if ok then
        return form :: string, reason
    end
    return currentForm, reason
end

return table.freeze(Evolution)
