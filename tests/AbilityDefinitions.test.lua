--!strict
-- Optional unit tests for Shared/AbilityDefinitions.lua (P2-03).
-- Run with Lune from the repository root:  lune run tests/AbilityDefinitions.test.lua
-- Lune is NOT part of rokit.toml; this file is outside the Rojo project tree.
--
-- Covers the catalog data, lookup, immutability, agreement with CreatureDefinitions, and that
-- the pure rules in Ability.lua behave as before when fed from the catalog. It does NOT cover
-- AbilityService or any Roblox wiring (shell/wing instances, timers, landing detection); that
-- needs Studio (README checklist).

local Config = require("../src/ReplicatedStorage/Shared/Config")
local Ability = require("../src/ReplicatedStorage/Shared/Ability")
local Abilities = require("../src/ReplicatedStorage/Shared/AbilityDefinitions")
local Creatures = require("../src/ReplicatedStorage/Shared/CreatureDefinitions")

local failures = 0
local function check(name: string, condition: boolean)
    if not condition then
        failures += 1
        print("FAIL: " .. name)
    else
        print("ok:   " .. name)
    end
end

local function throws(fn: () -> ()): boolean
    local ok = pcall(fn)
    return not ok
end

local shell: any = Abilities.GetAbility("SHELL")
local glide: any = Abilities.GetAbility("GLIDE")

-- Existence, ids, order.
check("SHELL exists", shell ~= nil and shell.id == "SHELL")
check("GLIDE exists", glide ~= nil and glide.id == "GLIDE")
check("exported id constants", Abilities.ShellId == "SHELL" and Abilities.GlideId == "GLIDE")
check("exactly two abilities", #Abilities.Abilities == 2 and #Abilities.AbilityIds == 2)
check("order is SHELL, GLIDE", Abilities.AbilityIds[1] == "SHELL" and Abilities.AbilityIds[2] == "GLIDE")
check("AbilityIds match Abilities", Abilities.Abilities[1].id == Abilities.AbilityIds[1] and Abilities.Abilities[2].id == Abilities.AbilityIds[2])
local seen: { [string]: boolean } = {}
local unique = true
for _, ability in Abilities.Abilities do
    if seen[ability.id] then
        unique = false
    end
    seen[ability.id] = true
end
check("ability ids are unique", unique)

-- Metadata and kinds.
check("SHELL display name", shell.displayName == "Defensive Shell")
check("GLIDE display name", glide.displayName == "Air Glide")
check("SHELL kind is Shell", shell.kind == "Shell")
check("GLIDE kind is Glide", glide.kind == "Glide")
check("ids are not display names", shell.id ~= shell.displayName and glide.id ~= glide.displayName)

-- Required forms.
check("SHELL requires TANK", shell.requiredForm == "TANK")
check("GLIDE requires GLIDER", glide.requiredForm == "GLIDER")

-- Tuning: shell and glide timings are unchanged from the Config values; the glide compensation was
-- deliberately retuned from 0.65 (see AbilityDefinitions and tests/Ability.test.lua kinematics).
check("SHELL duration is 3 s", shell.durationSeconds == 3)
check("SHELL cooldown is 12 s", shell.cooldownSeconds == 12)
check("GLIDE max duration is 3 s", glide.durationSeconds == 3)
check("GLIDE cooldown is 10 s", glide.cooldownSeconds == 10)
check("GLIDE gravity compensation is 0.9 (retuned from 0.65)", glide.gravityCompensation == 0.9)
check("GLIDE compensation is strong enough to be felt (at least half of gravity)", glide.gravityCompensation >= 0.5)
check("gravity compensation is below 1", glide.gravityCompensation > 0 and glide.gravityCompensation < 1)
check("gravity compensation is below the Ability clamp", glide.gravityCompensation < Ability.MaxGravityCompensation)
check("GLIDE compensation is not silently clamped", Ability.GetGlideForce(1, 1, glide.gravityCompensation) == glide.gravityCompensation)
check("GLIDE keeps its designed ascent compensation of 0.65", glide.ascentCompensation == 0.65)
check("ascent compensation is valid: positive, below 1 and below the clamp", glide.ascentCompensation > 0 and glide.ascentCompensation < 1 and glide.ascentCompensation < Ability.MaxGravityCompensation)
check("the ascent share is not stronger than the descent share", glide.ascentCompensation <= glide.gravityCompensation)
check("SHELL has no ascent compensation", shell.ascentCompensation == nil)
check("SHELL has no gravity compensation", shell.gravityCompensation == nil)
check("durations are positive and cooldowns not shorter", (function()
    for _, ability in Abilities.Abilities do
        if not (ability.durationSeconds > 0 and ability.cooldownSeconds >= ability.durationSeconds) then
            return false
        end
    end
    return true
end)())

-- Unknown or malformed ids resolve to nil.
local bad: { any } = { "FLY", "shell", "Shell", "glide", "SHELL ", "", "Defensive Shell", "Air Glide", "TANK", 0, 1, true, false, {}, { "SHELL" }, function() end }
local allNil = Abilities.GetAbility(nil) == nil
for _, value in bad do
    if Abilities.GetAbility(value) ~= nil then
        allNil = false
    end
end
check("unknown or malformed ids return nil", allNil)

-- Immutability.
local abilitiesAny: any = Abilities
check("module table is frozen", table.isfrozen(Abilities))
check("Abilities list is frozen", table.isfrozen(Abilities.Abilities))
check("AbilityIds list is frozen", table.isfrozen(Abilities.AbilityIds))
check("every definition is frozen", table.isfrozen(shell) and table.isfrozen(glide))
check("cannot change a duration", throws(function()
    shell.durationSeconds = 99
end))
check("cannot change a cooldown", throws(function()
    glide.cooldownSeconds = 0
end))
check("cannot change gravity compensation", throws(function()
    glide.gravityCompensation = 1
end) and throws(function()
    glide.ascentCompensation = 1
end))
check("cannot change a required form", throws(function()
    shell.requiredForm = "GLIDER"
end))
check("cannot add an ability", throws(function()
    table.insert(abilitiesAny.Abilities, { id = "EXTRA" })
end))
check("cannot add an id", throws(function()
    table.insert(abilitiesAny.AbilityIds, "EXTRA")
end))
check("cannot replace the lookup", throws(function()
    abilitiesAny.GetAbility = function()
        return nil
    end
end))
check("catalog unchanged after the mutation attempts",
    shell.durationSeconds == 3 and glide.cooldownSeconds == 10 and glide.gravityCompensation == 0.9
        and shell.requiredForm == "TANK" and #Abilities.Abilities == 2 and Abilities.GetAbility("EXTRA") == nil)

-- CreatureDefinitions <-> AbilityDefinitions agree.
local refsResolve = true
local referenced: { [string]: string } = {} -- ability id -> form that references it
for _, form in Creatures.Forms do
    for _, abilityId in form.abilities do
        if Abilities.GetAbility(abilityId) == nil then
            refsResolve = false
        end
        referenced[abilityId] = form.id
    end
end
check("every creature ability reference resolves to a definition", refsResolve)
check("BABY_BUG has no abilities", #(Creatures.GetForm("BABY_BUG") :: any).abilities == 0)
check("TANK references exactly SHELL", (function()
    local f: any = Creatures.GetForm("TANK")
    return #f.abilities == 1 and f.abilities[1] == "SHELL"
end)())
check("GLIDER references exactly GLIDE", (function()
    local f: any = Creatures.GetForm("GLIDER")
    return #f.abilities == 1 and f.abilities[1] == "GLIDE"
end)())
check("every ability is owned by the form it requires", (function()
    for _, ability in Abilities.Abilities do
        if referenced[ability.id] ~= ability.requiredForm then
            return false
        end
    end
    return true
end)())
check("every required form exists and is an evolved form", (function()
    for _, ability in Abilities.Abilities do
        local form = Creatures.GetForm(ability.requiredForm)
        if form == nil or form.isStarter then
            return false
        end
    end
    return true
end)())

-- Config keeps only global ability settings (the migrated keys are gone).
local configAny: any = Config
check("Config no longer defines migrated ability keys", (function()
    for _, key in { "TankShellForm", "TankShellDuration", "TankShellCooldown", "AbilityShellId", "AbilityGlideId", "GliderForm", "GliderDuration", "GliderCooldown", "GliderGravityCompensation" } do
        if configAny[key] ~= nil then
            return false
        end
    end
    return true
end)())
check("Config keeps AbilityKey", type(Config.AbilityKey) == "string" and #Config.AbilityKey > 0)
check("Config keeps AbilityRequestInterval (anti-spam, not a cooldown)",
    Config.AbilityRequestInterval == 0.25 and Config.AbilityRequestInterval < shell.cooldownSeconds / 10
        and Config.AbilityRequestInterval < glide.cooldownSeconds / 10)

-- The pure rules, fed from the catalog, behave as before.
local function shellOk(form: string, alive: boolean, now: number, activeUntil: number, readyAt: number)
    return Ability.Validate(form, alive, now, activeUntil, readyAt, shell.requiredForm)
end
local function glideOk(form: string, alive: boolean, airborne: boolean, now: number, activeUntil: number, readyAt: number)
    return Ability.ValidateGlide(form, alive, airborne, now, activeUntil, readyAt, glide.requiredForm)
end
local ok, reason = shellOk("TANK", true, 100, 0, 0)
check("TANK may use the shell", ok and reason == "Ok")
ok, reason = shellOk("GLIDER", true, 100, 0, 0)
check("shell rejects the wrong form", not ok and reason == "WrongForm")
ok, reason = shellOk(Creatures.StarterFormId, true, 100, 0, 0)
check("shell rejects the starter form", not ok and reason == "WrongForm")
ok, reason = shellOk("TANK", false, 100, 0, 0)
check("shell rejects a dead or missing character", not ok and reason == "NoLivingCharacter")
ok, reason = shellOk("TANK", true, 101, 100 + shell.durationSeconds, 100 + shell.cooldownSeconds)
check("shell rejects while active", not ok and reason == "AlreadyActive")
ok, reason = shellOk("TANK", true, 100 + shell.durationSeconds + 1, 100 + shell.durationSeconds, 100 + shell.cooldownSeconds)
check("shell rejects during the cooldown after it ended", not ok and reason == "OnCooldown")
ok, reason = shellOk("TANK", true, 100 + shell.cooldownSeconds, 100 + shell.durationSeconds, 100 + shell.cooldownSeconds)
check("shell is usable again exactly when the cooldown ends", ok and reason == "Ok")

ok, reason = glideOk("GLIDER", true, true, 100, 0, 0)
check("GLIDER may glide in the air", ok and reason == "Ok")
ok, reason = glideOk("GLIDER", true, false, 100, 0, 0)
check("glide is rejected while grounded", not ok and reason == "NotAirborne")
ok, reason = glideOk("TANK", true, true, 100, 0, 0)
check("glide rejects the wrong form", not ok and reason == "WrongForm")
ok, reason = glideOk("GLIDER", false, true, 100, 0, 0)
check("glide rejects a dead or missing character", not ok and reason == "NoLivingCharacter")
ok, reason = glideOk("GLIDER", true, true, 101, 100 + glide.durationSeconds, 100 + glide.cooldownSeconds)
check("glide rejects while active", not ok and reason == "AlreadyActive")
ok, reason = glideOk("GLIDER", true, true, 105, 0, 100 + glide.cooldownSeconds)
check("glide rejects during the cooldown (also after an early landing)", not ok and reason == "OnCooldown")
ok, reason = glideOk("GLIDER", true, true, 100 + glide.cooldownSeconds, 0, 100 + glide.cooldownSeconds)
check("glide is usable again exactly when the cooldown ends", ok and reason == "Ok")

local mass, gravity = 10, 196.2
local force = Ability.GetGlideForce(mass, gravity, glide.gravityCompensation)
check("glide force cancels the configured share of the weight", math.abs(force - mass * gravity * glide.gravityCompensation) < 1e-9)
check("glide force stays below the weight", force < mass * gravity)
check("an absurd compensation is still clamped below the weight", Ability.GetGlideForce(mass, gravity, 5) < mass * gravity)

-- Spam: 200 requests inside the cooldown activate each ability once and never extend it.
local function spam(def: any, validate: (number, number, number) -> boolean): (number, number)
    local activeUntil, readyAt, accepted = 0, 0, 0
    for i = 0, 199 do
        local now = 100 + i * 0.05
        if validate(now, activeUntil, readyAt) then
            activeUntil = now + def.durationSeconds
            readyAt = now + def.cooldownSeconds
            accepted += 1
        end
    end
    return accepted, activeUntil
end
local shellAccepted, shellEnd = spam(shell, function(now, a, r)
    return (shellOk("TANK", true, now, a, r))
end)
local glideAccepted, glideEnd = spam(glide, function(now, a, r)
    return (glideOk("GLIDER", true, true, now, a, r))
end)
check("200 shell requests activate once and do not extend it", shellAccepted == 1 and shellEnd == 100 + shell.durationSeconds)
check("200 glide requests activate once and do not extend it", glideAccepted == 1 and glideEnd == 100 + glide.durationSeconds)

-- Players are independent (plain tables, as in Multiplayer.test.lua).
local players: { [string]: { activeUntil: number, readyAt: number } } = {
    A = { activeUntil = 0, readyAt = 0 },
    B = { activeUntil = 0, readyAt = 0 },
}
local aOk = glideOk("GLIDER", true, true, 100, players.A.activeUntil, players.A.readyAt)
if aOk then
    players.A.activeUntil = 100 + glide.durationSeconds
    players.A.readyAt = 100 + glide.cooldownSeconds
end
check("a glide by A leaves B's state untouched and usable", aOk and players.B.readyAt == 0 and glideOk("GLIDER", true, true, 101, players.B.activeUntil, players.B.readyAt))

if failures > 0 then
    error(failures .. " test(s) failed")
end
print("all tests passed")
