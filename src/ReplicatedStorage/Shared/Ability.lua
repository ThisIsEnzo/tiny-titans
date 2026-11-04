--!strict
-- Pure ability rules (Tank Defensive Shell and Glider Air Glide). No Roblox services, so they are unit-testable outside Studio.
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

-- True only for a string that exactly matches one of the known ability identifiers.
function Ability.IsKnownAbilityId(id: any, knownIds: { string }): boolean
    return type(id) == "string" and table.find(knownIds, id) ~= nil
end

-- True if a request arrives sooner than minInterval seconds after the last processed one.
-- lastRequestAt is nil when the player has not made a processed request yet.
-- This is anti-spam only and is unrelated to the gameplay cooldown.
function Ability.IsRateLimited(lastRequestAt: number?, now: number, minInterval: number): boolean
    if lastRequestAt == nil then
        return false
    end
    return now - lastRequestAt < minInterval
end

-- Upper bound for the fraction of gravity a glide may cancel. Always below 1, so the
-- net vertical force on the character stays downward and a glide can never lift.
Ability.MaxGravityCompensation = 0.95

-- Upward force (in the engine's force units) that cancels `compensation` of the weight of
-- `mass` under `gravity`. Compensation is clamped to [0, MaxGravityCompensation];
-- invalid input yields 0.
function Ability.GetGlideForce(mass: number, gravity: number, compensation: number): number
    if mass ~= mass or gravity ~= gravity or compensation ~= compensation or mass <= 0 or gravity <= 0 then
        return 0
    end
    return mass * gravity * math.clamp(compensation, 0, Ability.MaxGravityCompensation)
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

-- Validates a Glider activation request. Same rules as Validate plus the airborne check.
-- Returns (ok, reason). Reasons: "Ok", "WrongForm", "NoLivingCharacter", "NotAirborne",
-- "AlreadyActive", "OnCooldown".
function Ability.ValidateGlide(
    form: string,
    hasLivingCharacter: boolean,
    isAirborne: boolean,
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
    if not isAirborne then
        return false, "NotAirborne"
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
