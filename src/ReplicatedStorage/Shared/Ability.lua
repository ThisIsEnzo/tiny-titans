--!strict
-- Pure Defensive Shell rules. No Roblox services, so they are unit-testable outside Studio.
-- Times are seconds on one shared clock (the server passes workspace:GetServerTimeNow()).
-- State is two timestamps: activeUntil (shell is up until then) and readyAt (usable again at).

local Ability = {}

-- True while the shell is up.
function Ability.IsActive(now: number, activeUntil: number): boolean
    return now < activeUntil
end

-- Seconds until the ability can be used again (0 when ready).
function Ability.GetCooldownRemaining(now: number, readyAt: number): number
    return math.max(0, readyAt - now)
end

-- Validates an activation request against server-owned state.
-- Returns (ok, reason). Reasons: "Ok", "WrongForm", "NoLivingCharacter",
-- "AlreadyActive", "OnCooldown".
function Ability.Validate(
    form: string,
    hasLivingCharacter: boolean,
    now: number,
    activeUntil: number,
    readyAt: number,
    requiredForm: string
): (boolean, string)
    if form ~= requiredForm then
        return false, "WrongForm"
    end
    if not hasLivingCharacter then
        return false, "NoLivingCharacter"
    end
    if Ability.IsActive(now, activeUntil) then
        return false, "AlreadyActive"
    end
    if Ability.GetCooldownRemaining(now, readyAt) > 0 then
        return false, "OnCooldown"
    end
    return true, "Ok"
end

return table.freeze(Ability)
