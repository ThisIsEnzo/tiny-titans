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

-- Vertical speed (studs/s) above which a character counts as still rising; small, so a hover at the
-- apex does not make the force flicker.
Ability.GlideRisingThreshold = 0.5

-- Upward force (in the engine's force units) that cancels `compensation` of the weight of
-- `mass` under `gravity`. Compensation is clamped to [0, MaxGravityCompensation];
-- invalid input yields 0.
--- Without `verticalVelocity` the force is the constant `compensation` share of the weight (the
--- original behaviour). With it the glide is phase-aware: while the character is rising faster than
--- Ability.GlideRisingThreshold the share is `ascentCompensation` (0 if omitted), otherwise
--- `compensation` (the descent). A weaker ascent keeps a glided jump from becoming flight while a
--- stronger descent makes the fall last. Every share is capped below 1, so gravity always wins; an
--- invalid velocity reading gives no force.
function Ability.GetGlideForce(
    mass: number,
    gravity: number,
    compensation: number,
    verticalVelocity: number?,
    ascentCompensation: number?
): number
    if mass ~= mass or gravity ~= gravity or compensation ~= compensation or mass <= 0 or gravity <= 0 then
        return 0
    end
    local share = compensation
    if verticalVelocity ~= nil then
        if verticalVelocity ~= verticalVelocity then
            return 0
        end
        if verticalVelocity > Ability.GlideRisingThreshold then
            share = ascentCompensation or 0
            if share ~= share then
                return 0
            end
        end
    end
    return mass * gravity * math.clamp(share, 0, Ability.MaxGravityCompensation)
end

--- Whether a landing-related event really means the character landed. The events are
--- "Landed" and "Running" (Humanoid states) and "FloorMaterial" (the floor changed to something
--- other than air). A transient or premature event, one that arrives while the Humanoid still
--- reports air and no ground is confirmed below, does not end the glide. Anything else is no landing.
function Ability.IsGlideLanding(event: any, floorIsAir: boolean, groundBelow: boolean): boolean
    if event ~= "Landed" and event ~= "Running" and event ~= "FloorMaterial" then
        return false
    end
    return (not floorIsAir) or groundBelow
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

-- Glide session state: a plain table { activeUntil, readyAt, token }. AbilityService keeps one per
-- player (with its Roblox objects alongside); these helpers hold the rules so they are testable.
export type GlideSession = { activeUntil: number, readyAt: number, token: number }

-- Starts a glide that has already been validated: bumps the token (invalidating every callback of an
-- earlier activation), sets the end time and starts the cooldown from now. The cooldown runs from
-- activation, so an early landing does not shorten it.
function Ability.StartGlide(session: GlideSession, now: number, durationSeconds: number, cooldownSeconds: number)
    session.token += 1
    session.activeUntil = now + durationSeconds
    session.readyAt = now + cooldownSeconds
end

-- Validates and starts. A rejected request changes nothing (in particular it never starts the
-- cooldown). Returns (ok, reason) like ValidateGlide.
function Ability.TryStartGlide(
    session: GlideSession,
    form: string,
    hasLivingCharacter: boolean,
    isAirborne: boolean,
    now: number,
    requiredForm: string,
    durationSeconds: number,
    cooldownSeconds: number
): (boolean, string)
    local ok, reason = Ability.ValidateGlide(form, hasLivingCharacter, isAirborne, now, session.activeUntil, session.readyAt, requiredForm)
    if not ok then
        return false, reason
    end
    Ability.StartGlide(session, now, durationSeconds, cooldownSeconds)
    return true, "Ok"
end

-- Ends the glide (landing, death, form change, character removal, expiry...). Always invalidates
-- pending callbacks and never touches the cooldown. Returns true if a glide was active.
function Ability.EndGlide(session: GlideSession): boolean
    local wasActive = session.activeUntil ~= 0
    session.token += 1
    session.activeUntil = 0
    return wasActive
end

-- True while `token` belongs to the glide that is currently active. A callback from an earlier
-- activation (stale expiry timer, old event connection) gets false and must do nothing.
function Ability.IsCurrentGlide(session: GlideSession, token: number): boolean
    return session.token == token and session.activeUntil ~= 0
end

-- New life: ends any glide and clears the cooldown.
function Ability.ResetGlide(session: GlideSession)
    Ability.EndGlide(session)
    session.readyAt = 0
end

return table.freeze(Ability)
