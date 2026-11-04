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

-- Config sanity.
check("duration positive", duration > 0)
check("cooldown not shorter than duration", cooldown >= duration)
check("shell form is a real evolution branch", table.find(Config.EvolutionForms, tank) ~= nil)
check("ability key set", #Config.AbilityKey > 0)

if failures > 0 then
    error(failures .. " test(s) failed")
end
print("all tests passed")
