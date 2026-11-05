--!strict
-- Pure evolution rules. No Roblox services, so they are unit-testable outside Studio.
-- Callers pass tuning data (see Config) explicitly.

local Evolution = {}

-- True only for a string that is one of the allowed branches (exact match).
function Evolution.IsValidForm(form: any, forms: { string }): boolean
    return type(form) == "string" and table.find(forms, form) ~= nil
end

-- True if a request arrives sooner than minInterval seconds after the last processed one.
-- lastRequestAt is nil when the player has not made a processed request yet.
function Evolution.IsRateLimited(lastRequestAt: number?, now: number, minInterval: number): boolean
    if lastRequestAt == nil then
        return false
    end
    return now - lastRequestAt < minInterval
end

-- True while the player has reached the threshold and has not evolved yet.
function Evolution.IsAvailable(biomass: number, threshold: number, currentForm: string, baseForm: string): boolean
    return currentForm == baseForm and biomass == biomass and biomass >= threshold
end

-- Validates an evolution request against server-owned state.
-- Returns (ok, reason). Reasons: "Ok", "AlreadyEvolved", "ThresholdNotReached", "InvalidForm".
function Evolution.Validate(
    form: any,
    biomass: number,
    threshold: number,
    currentForm: string,
    baseForm: string,
    forms: { string }
): (boolean, string)
    if currentForm ~= baseForm then
        return false, "AlreadyEvolved"
    end
    if not (biomass == biomass and biomass >= threshold) then
        return false, "ThresholdNotReached"
    end
    if not Evolution.IsValidForm(form, forms) then
        return false, "InvalidForm"
    end
    return true, "Ok"
end

-- Applies a selection to one player's form. Returns (newForm, reason): newForm is the
-- requested branch only when reason is "Ok"; on any rejection it is currentForm, so a
-- rejected request can never change state. Each player has their own currentForm.
function Evolution.Select(
    form: any,
    biomass: number,
    threshold: number,
    currentForm: string,
    baseForm: string,
    forms: { string }
): (string, string)
    local ok, reason = Evolution.Validate(form, biomass, threshold, currentForm, baseForm, forms)
    if ok then
        return form :: string, reason
    end
    return currentForm, reason
end

return table.freeze(Evolution)
