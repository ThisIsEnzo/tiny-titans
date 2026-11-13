--!strict
-- Optional unit tests for the pure ability rules (Defensive Shell and Air Glide), tuned from AbilityDefinitions.
-- Run with Lune from the repository root:  lune run tests/Ability.test.lua
-- Lune is NOT part of rokit.toml; this file is outside the Rojo project tree.

local Config = require("../src/ReplicatedStorage/Shared/Config")
local AbilityDefinitions = require("../src/ReplicatedStorage/Shared/AbilityDefinitions")
local shellDef: any = AbilityDefinitions.GetAbility(AbilityDefinitions.ShellId)
local glideDef: any = AbilityDefinitions.GetAbility(AbilityDefinitions.GlideId)
local Ability = require("../src/ReplicatedStorage/Shared/Ability")

local failures = 0
local function check(name: string, condition: boolean)
    if not condition then
        failures += 1
        print("FAIL: " .. name)
    else
        print("ok:   " .. name)
    end
end

local tank = shellDef.requiredForm
local duration = shellDef.durationSeconds
local cooldown = shellDef.cooldownSeconds

local function validate(form: string, alive: boolean, now: number, activeUntil: number, readyAt: number)
    local ok, reason = Ability.Validate(form, alive, now, activeUntil, readyAt, tank)
    return ok, reason
end

-- Fresh state: never used (timestamps 0), server time well past 0.
local ok, reason = validate("TANK", true, 100, 0, 0)
check("TANK can activate when ready", ok and reason == "Ok")
ok, reason = validate("BABY_BUG", true, 100, 0, 0)
check("BABY_BUG cannot activate", not ok and reason == "WrongForm")
ok, reason = validate("GLIDER", true, 100, 0, 0)
check("GLIDER cannot activate", not ok and reason == "WrongForm")
ok, reason = validate("tank", true, 100, 0, 0)
check("lowercase form cannot activate", not ok and reason == "WrongForm")
ok, reason = validate("TANK", false, 100, 0, 0)
check("dead/missing character rejected", not ok and reason == "NoLivingCharacter")
ok, reason = validate("GLIDER", false, 100, 0, 0)
check("wrong form reported before character state", not ok and reason == "WrongForm")

-- Activation at t=100.
local activeUntil = 100 + duration
local readyAt = 100 + cooldown
ok, reason = validate("TANK", true, 100.5, activeUntil, readyAt)
check("cannot re-activate while active", not ok and reason == "AlreadyActive")
ok, reason = validate("TANK", true, activeUntil - 0.01, activeUntil, readyAt)
check("still active just before expiry", not ok and reason == "AlreadyActive")
ok, reason = validate("TANK", true, activeUntil, activeUntil, readyAt)
check("on cooldown right after the shell expires", not ok and reason == "OnCooldown")
ok, reason = validate("TANK", true, readyAt - 0.01, activeUntil, readyAt)
check("on cooldown just before ready", not ok and reason == "OnCooldown")
ok, reason = validate("TANK", true, readyAt, activeUntil, readyAt)
check("available exactly at readyAt", ok and reason == "Ok")
ok, reason = validate("TANK", true, readyAt + 5, activeUntil, readyAt)
check("available after cooldown", ok and reason == "Ok")

-- Shell ended early (death/respawn): activeUntil cleared but cooldown still applies.
ok, reason = validate("TANK", true, 101, 0, readyAt)
check("early end does not reset cooldown", not ok and reason == "OnCooldown")

-- Helpers.
check("IsActive before end", Ability.IsActive(1, 3))
check("IsActive false at end", not Ability.IsActive(3, 3))
check("IsActive false when never used", not Ability.IsActive(100, 0))
check("cooldown remaining counts down", Ability.GetCooldownRemaining(4, 12) == 8)
check("cooldown remaining never negative", Ability.GetCooldownRemaining(20, 12) == 0)

-- Request rate limiter (anti-spam; separate from the gameplay cooldown).
local interval = Config.AbilityRequestInterval
check("first request is not rate limited", not Ability.IsRateLimited(nil, 100, interval))
check("request inside the interval is limited", Ability.IsRateLimited(100, 100 + interval / 2, interval))
check("request in the same instant is limited", Ability.IsRateLimited(100, 100, interval))
check("request exactly at the interval is allowed", not Ability.IsRateLimited(100, 100 + interval, interval))
check("request after the interval is allowed", not Ability.IsRateLimited(100, 100 + interval + 1, interval))
check("zero interval never limits", not Ability.IsRateLimited(100, 100, 0))
-- Dropped requests must not extend the interval: only processed requests advance the timestamp.
local last: number? = nil
local processed = 0
for i = 0, 999 do
    local now = i / 1000
    if not Ability.IsRateLimited(last, now, interval) then
        last = now
        processed += 1
    end
end
check("spam over 1s processes at most ceil(1/interval) requests", processed <= math.ceil(1 / interval))
check("a request is processed again once the interval passes", processed >= 2)

-- Glider: validation rules.
local glider = glideDef.requiredForm
local gDuration = glideDef.durationSeconds
local gCooldown = glideDef.cooldownSeconds

local function validateGlide(form: string, alive: boolean, airborne: boolean, now: number, activeUntil: number, readyAt: number)
    local ok2, reason2 = Ability.ValidateGlide(form, alive, airborne, now, activeUntil, readyAt, glider)
    return ok2, reason2
end

ok, reason = validateGlide("GLIDER", true, true, 100, 0, 0)
check("GLIDER can glide when airborne and ready", ok and reason == "Ok")
ok, reason = validateGlide("TANK", true, true, 100, 0, 0)
check("TANK cannot glide", not ok and reason == "WrongForm")
ok, reason = validateGlide("BABY_BUG", true, true, 100, 0, 0)
check("BABY_BUG cannot glide", not ok and reason == "WrongForm")
ok, reason = validateGlide("GLIDER", false, true, 100, 0, 0)
check("glide needs a living character", not ok and reason == "NoLivingCharacter")
ok, reason = validateGlide("GLIDER", true, false, 100, 0, 0)
check("glide needs to be airborne", not ok and reason == "NotAirborne")
ok, reason = validateGlide("TANK", true, false, 100, 0, 0)
check("wrong form reported before airborne state", not ok and reason == "WrongForm")

local gActiveUntil = 100 + gDuration
local gReadyAt = 100 + gCooldown
ok, reason = validateGlide("GLIDER", true, true, 100.5, gActiveUntil, gReadyAt)
check("cannot re-activate while gliding", not ok and reason == "AlreadyActive")
ok, reason = validateGlide("GLIDER", true, true, gActiveUntil - 0.01, gActiveUntil, gReadyAt)
check("still gliding just before the duration ends", not ok and reason == "AlreadyActive")
ok, reason = validateGlide("GLIDER", true, true, gActiveUntil, gActiveUntil, gReadyAt)
check("on cooldown right after the duration ends", not ok and reason == "OnCooldown")
ok, reason = validateGlide("GLIDER", true, true, gReadyAt - 0.01, gActiveUntil, gReadyAt)
check("on cooldown just before ready", not ok and reason == "OnCooldown")
ok, reason = validateGlide("GLIDER", true, true, gReadyAt, gActiveUntil, gReadyAt)
check("glide available exactly at readyAt", ok and reason == "Ok")
ok, reason = validateGlide("GLIDER", true, true, 101, 0, gReadyAt)
check("landing early does not reset the cooldown", not ok and reason == "OnCooldown")
ok, reason = validateGlide("GLIDER", true, false, gReadyAt + 1, 0, gReadyAt)
check("ready but on the ground is still rejected", not ok and reason == "NotAirborne")

-- Glider: state machine over time. Only accepted requests may change the timestamps.
local gActive = 0
local gReady = 0
local accepted = 0
local function tryGlide(now: number): boolean
    local accept = Ability.ValidateGlide("GLIDER", true, true, now, gActive, gReady, glider)
    if accept then
        gActive = now + gDuration
        gReady = now + gCooldown
        accepted += 1
    end
    return accept
end
check("sim: first request accepted", tryGlide(10))
local stampActive, stampReady = gActive, gReady
local spamRejected = true
for i = 1, 200 do
    if tryGlide(10 + i * 0.049) then -- 0.049 .. 9.8 s after activation
        spamRejected = false
    end
end
check("sim: spam during glide and cooldown is all rejected", spamRejected)
check("sim: rejected requests did not move the timestamps", gActive == stampActive and gReady == stampReady)
check("sim: accepted again once the cooldown has passed", tryGlide(10 + gCooldown))
check("sim: exactly two activations in total", accepted == 2)

-- Rate limiter stays independent of the gameplay cooldowns.
check("rate limit interval differs from glide cooldown", interval ~= gCooldown and interval ~= gDuration)
check("a request after the rate limit but inside the cooldown is still a cooldown reject", not Ability.IsRateLimited(100, 100 + interval, interval) and not (Ability.ValidateGlide("GLIDER", true, true, 100 + interval, 100 + gDuration, 100 + gCooldown, glider)))

-- Glide force: bounded below the character's weight.
check("force cancels the configured share of weight", math.abs(Ability.GetGlideForce(10, 196.2, 0.65) - 10 * 196.2 * 0.65) < 1e-9)
check("force stays below weight even for absurd compensation", Ability.GetGlideForce(10, 196.2, 5) < 10 * 196.2)
check("force is never negative", Ability.GetGlideForce(10, 196.2, -1) == 0)
check("force is 0 for invalid mass", Ability.GetGlideForce(0, 196.2, 0.65) == 0)
check("force is 0 for NaN input", Ability.GetGlideForce(0 / 0, 196.2, 0.65) == 0)
check("configured compensation leaves net downward force", glideDef.gravityCompensation > 0 and glideDef.gravityCompensation < 1)

-- Config sanity.
check("duration positive", duration > 0)
check("cooldown not shorter than duration", cooldown >= duration)
check("shell form is a real evolution branch", table.find(Config.EvolutionForms, tank) ~= nil)
check("request interval positive", interval > 0)
check("request interval far below the gameplay cooldown", interval < cooldown / 10)
check("glider duration positive", gDuration > 0)
check("glider cooldown not shorter than duration", gCooldown >= gDuration)
check("glider form is a real evolution branch", table.find(Config.EvolutionForms, glider) ~= nil)
check("glider and tank forms differ", glider ~= tank)
check("ability ids differ", AbilityDefinitions.ShellId ~= AbilityDefinitions.GlideId)
check("request interval is separate from glider cooldown", interval < gCooldown / 10)
check("ability key set", #Config.AbilityKey > 0)

-- Phase-aware glide force: ascent share while rising, the stronger descent share otherwise.
local comp = glideDef.gravityCompensation
local ascent = glideDef.ascentCompensation
local weight = 10 * 196.2
check("falling: the descent share", math.abs(Ability.GetGlideForce(10, 196.2, comp, -20, ascent) - weight * comp) < 1e-9)
check("hovering at the apex: the descent share", math.abs(Ability.GetGlideForce(10, 196.2, comp, 0, ascent) - weight * comp) < 1e-9)
check("at the rising threshold exactly: still the descent share", math.abs(Ability.GetGlideForce(10, 196.2, comp, Ability.GlideRisingThreshold, ascent) - weight * comp) < 1e-9)
check("rising: the ascent share", math.abs(Ability.GetGlideForce(10, 196.2, comp, 30, ascent) - weight * ascent) < 1e-9 and math.abs(Ability.GetGlideForce(10, 196.2, comp, Ability.GlideRisingThreshold + 0.01, ascent) - weight * ascent) < 1e-9)
check("rising without an ascent share: no force", Ability.GetGlideForce(10, 196.2, comp, 30) == 0)
check("the ascent share is weaker than the descent share", ascent < comp and Ability.GetGlideForce(10, 196.2, comp, 30, ascent) < Ability.GetGlideForce(10, 196.2, comp, -30, ascent))
check("an out-of-range share is still capped below the weight", Ability.GetGlideForce(10, 196.2, 5, -5, 5) < weight and Ability.GetGlideForce(10, 196.2, 5, 30, 5) < weight)
check("a NaN ascent share gives no force", Ability.GetGlideForce(10, 196.2, comp, 30, 0 / 0) == 0)
check("an invalid velocity reading gives no force", Ability.GetGlideForce(10, 196.2, comp, 0 / 0, ascent) == 0)
check("without a velocity the force is the original constant", math.abs(Ability.GetGlideForce(10, 196.2, comp) - weight * comp) < 1e-9)

-- Kinematics at default gravity (semi-implicit Euler at 60 Hz, the force switching exactly like the service).
local G, MASS, DT = 196.2, 10, 1 / 60
local function simulate(startHeight: number, startVy: number, gliding: boolean, maxSeconds: number): (number, number, number, number)
    local y, vy, t, apex, minNet = startHeight, startVy, 0, startHeight, math.huge
    while t < maxSeconds do
        local force = if gliding then Ability.GetGlideForce(MASS, G, comp, vy, ascent) else 0
        local acceleration = -G + force / MASS
        minNet = math.min(minNet, -acceleration) -- most upward net acceleration is the smallest downward one
        vy += acceleration * DT
        y += vy * DT
        t += DT
        apex = math.max(apex, y)
        if y <= 0 then
            break
        end
    end
    return t, vy, apex, minNet
end
local jumpVelocity = math.sqrt(2 * G * 7.2) -- Roblox default JumpHeight 7.2
local freeAirtime = simulate(0, jumpVelocity, false, 10)
local _, _, freeApex = simulate(0, jumpVelocity, false, 10)
local _, _, glideApex, glideMinNet = simulate(0, jumpVelocity, true, 10)
check("a normal jump lasts about half a second (the reason the old glide died with it)", freeAirtime > 0.45 and freeAirtime < 0.65)
check("gliding from take-off keeps the designed apex gain (about 20 studs, glider platforms)", math.abs(glideApex - freeApex / (1 - ascent)) < 1.5 and glideApex < 3.5 * freeApex) -- tolerance covers the 60 Hz integration error
check("a glided jump from take-off lasts long but stays bounded below the 3 s limit", (function()
    local airtime = simulate(0, jumpVelocity, true, 10)
    return airtime > 1.8 and airtime < glideDef.durationSeconds
end)())
check("activating at the apex of a normal jump gives no apex gain", (function()
    local _, _, apex = simulate(7.2, 0, true, 10)
    return apex < 7.2 + 0.05
end)())
check("net acceleration is downward at every step", glideMinNet > 0)
local fallNormal, impactNormal = simulate(7.2, 0, false, 10)
local fallGlide, impactGlide = simulate(7.2, 0, true, 10)
check("from a jump apex the glide lasts at least 2.5x a normal fall", fallGlide >= 2.5 * fallNormal)
check("from a jump apex the glide lasts well beyond half a second", fallGlide > 0.7)
check("gliding makes the landing gentler", math.abs(impactGlide) < 0.5 * math.abs(impactNormal))
local drop20Normal = simulate(20, 0, false, 10)
local drop20Glide = simulate(20, 0, true, 10)
check("a 20-stud drop lasts at least 2.5x longer gliding", drop20Glide >= 2.5 * drop20Normal and drop20Glide > 1)
check("a glide cannot cover 100 studs within its 3 s limit (it descends; it is not flight)", simulate(100, 0, true, 3) >= 3 - DT)
check("the previous 0.65 would have ended within half a second of the apex", (function()
    local saved = comp
    comp = 0.65
    local t = simulate(7.2, 0, true, 10)
    comp = saved
    return t < 0.5
end)())

-- Landing confirmation: transient events are ignored.
for _, event in { "Landed", "Running", "FloorMaterial" } do
    check(event .. " with the floor confirmed lands", Ability.IsGlideLanding(event, false, false))
    check(event .. " with ground below lands even if the floor still reads air", Ability.IsGlideLanding(event, true, true))
    check(event .. " while still in the air is ignored", not Ability.IsGlideLanding(event, true, false))
end
for _, event in { "Freefall", "Jumping", "", "landed", 5, false } do
    check("unknown event " .. tostring(event) .. " never lands", not Ability.IsGlideLanding(event, false, true))
end
check("a nil event never lands", not Ability.IsGlideLanding(nil, false, true))

-- Glide lifecycle on the pure session state.
local gForm, gDur, gCd = glideDef.requiredForm, glideDef.durationSeconds, glideDef.cooldownSeconds
local function newSession(): Ability.GlideSession
    return { activeUntil = 0, readyAt = 0, token = 0 }
end
local function tryStart(session: Ability.GlideSession, now: number, form: string?, alive: boolean?, airborne: boolean?): (boolean, string)
    return Ability.TryStartGlide(session, form or gForm, if alive == nil then true else alive, if airborne == nil then true else airborne, now, gForm, gDur, gCd)
end

local session = newSession()
local started, startReason = tryStart(session, 100)
check("valid airborne activation succeeds", started and startReason == "Ok")
check("activation sets the end time and the cooldown", session.activeUntil == 100 + gDur and session.readyAt == 100 + gCd and session.token == 1)
check("the glide is active for its duration and not after", Ability.IsActive(100 + gDur - 0.01, session.activeUntil) and not Ability.IsActive(100 + gDur, session.activeUntil))
local activeToken = session.token
check("the current activation's token is current", Ability.IsCurrentGlide(session, activeToken))
local again, againReason = tryStart(session, 101)
check("a second request while active is rejected and changes nothing", not again and againReason == "AlreadyActive" and session.token == activeToken and session.activeUntil == 100 + gDur)

-- Early landing ends it but keeps the cooldown running from activation.
check("landing ends an active glide", Ability.EndGlide(session) == true)
check("after landing the glide is inactive and its token stale", session.activeUntil == 0 and not Ability.IsCurrentGlide(session, activeToken))
check("early landing does not touch the cooldown", session.readyAt == 100 + gCd)
local early, earlyReason = tryStart(session, 100.6)
check("a new glide right after an early landing is on cooldown", not early and earlyReason == "OnCooldown" and session.readyAt == 100 + gCd)
local lateStart, lateReason = tryStart(session, 100 + gCd - 0.01)
check("still on cooldown just before it ends", not lateStart and lateReason == "OnCooldown")
local afterCd = tryStart(session, 100 + gCd)
check("allowed again exactly 10 s after the activation", afterCd)
check("ending twice is harmless and reports nothing active", Ability.EndGlide(session) == true and Ability.EndGlide(session) == false and session.activeUntil == 0)

-- Rejected activations never start the cooldown.
local rejects = {
    { "grounded", gForm, true, false, "NotAirborne" },
    { "wrong form", "TANK", true, true, "WrongForm" },
    { "starter form", "BABY_BUG", true, true, "WrongForm" },
    { "dead or missing character", gForm, false, true, "NoLivingCharacter" },
}
for _, row in rejects do
    local case: any = row
    local fresh = newSession()
    local ok, why = tryStart(fresh, 50, case[2], case[3], case[4])
    check(case[1] .. " is rejected (" .. case[5] .. ")", not ok and why == case[5])
    check(case[1] .. " leaves the state and cooldown untouched", fresh.readyAt == 0 and fresh.activeUntil == 0 and fresh.token == 0)
end

-- Death, form change, character removal and reset all end the glide the same way.
local dying = newSession()
tryStart(dying, 10)
local dyingToken = dying.token
Ability.EndGlide(dying) -- death / form change / character removal
check("death or form change clears the active glide and invalidates its callbacks", dying.activeUntil == 0 and not Ability.IsCurrentGlide(dying, dyingToken))
check("death or form change keeps the cooldown", dying.readyAt == 10 + gCd)
Ability.ResetGlide(dying) -- a new life
check("a new life clears the cooldown too", dying.readyAt == 0 and dying.activeUntil == 0)
check("a new glide is possible right after a reset", (tryStart(dying, 11)))

-- Stale expiry: the timer of an earlier activation must not end a newer one.
local stale = newSession()
tryStart(stale, 0)
local firstToken = stale.token
Ability.EndGlide(stale) -- landed early
check("no timer from the first activation is current once it has ended", not Ability.IsCurrentGlide(stale, firstToken))
tryStart(stale, gCd) -- a new activation after the cooldown
local secondToken = stale.token
check("a new activation gets a new token", secondToken ~= firstToken)
check("the first activation's expiry callback is stale", not Ability.IsCurrentGlide(stale, firstToken))
check("the newer activation is still current", Ability.IsCurrentGlide(stale, secondToken) and stale.activeUntil == gCd + gDur)
-- What the service does when the old timer finally fires:
if Ability.IsCurrentGlide(stale, firstToken) then
    Ability.EndGlide(stale)
end
check("the old timer firing does not end the newer glide", stale.activeUntil == gCd + gDur and Ability.IsCurrentGlide(stale, secondToken))
if Ability.IsCurrentGlide(stale, secondToken) then
    Ability.EndGlide(stale) -- the newer one's own expiry
end
check("the newer glide ends on its own expiry", stale.activeUntil == 0)

if failures > 0 then
    error(failures .. " test(s) failed")
end
print("all tests passed")
