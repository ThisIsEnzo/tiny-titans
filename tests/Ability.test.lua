--!strict
-- Optional unit tests for the pure Defensive Shell rules.
-- Run with Lune from the repository root:  lune run tests/Ability.test.lua
-- Lune is NOT part of rokit.toml; this file is outside the Rojo project tree.

local Config = require("../src/ReplicatedStorage/Shared/Config")
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

local tank = Config.TankShellForm
local duration = Config.TankShellDuration
local cooldown = Config.TankShellCooldown

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
local glider = Config.GliderForm
local gDuration = Config.GliderDuration
local gCooldown = Config.GliderCooldown

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
check("configured compensation leaves net downward force", Config.GliderGravityCompensation > 0 and Config.GliderGravityCompensation < 1)

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
check("ability ids differ", Config.AbilityShellId ~= Config.AbilityGlideId)
check("request interval is separate from glider cooldown", interval < gCooldown / 10)
check("ability key set", #Config.AbilityKey > 0)

if failures > 0 then
    error(failures .. " test(s) failed")
end
print("all tests passed")
