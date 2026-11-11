--!strict
-- Optional multiplayer-correctness tests for the pure rules (Food, Growth, Evolution, Ability).
-- Run with Lune from the repository root:  lune run tests/Multiplayer.test.lua
-- Lune is NOT part of rokit.toml; this file is outside the Rojo project tree.
--
-- "Players" here are string keys in plain tables. These tests prove the rules are correct
-- and independent when used the way the services use them. They do NOT prove the Roblox
-- wiring (Player-keyed tables, event connections, character lifecycle); that is covered by
-- code review and the manual Studio checklist in the README. Scenarios 10 (player cleanup)
-- and 12 (respawn duplicates) depend on Roblox objects and are manual-only.

local Config = require("../src/ReplicatedStorage/Shared/Config")
local Food = require("../src/ReplicatedStorage/Shared/Food")
local Growth = require("../src/ReplicatedStorage/Shared/Growth")
local Evolution = require("../src/ReplicatedStorage/Shared/Evolution")
local CreatureDefinitions = require("../src/ReplicatedStorage/Shared/CreatureDefinitions")
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

local cap = Config.EvolutionBiomassRequired
local foodBiomass = Config.FoodBiomass

-- 1. Independent biomass.
local biomass: { [string]: number } = { A = 0, B = 0 }
local newA = Growth.AddBiomass(biomass.A, foodBiomass, cap)
biomass.A = newA
check("1: A gained biomass", biomass.A == foodBiomass)
check("1: B biomass untouched by A's gain", biomass.B == 0)
local newB = Growth.AddBiomass(biomass.B, foodBiomass * 3, cap)
biomass.B = newB
check("1: B gains independently", biomass.B == foodBiomass * 3 and biomass.A == foodBiomass)
check("1: stages are independent", Growth.GetStageIndex(biomass.A, Config.GrowthStages) ~= Growth.GetStageIndex(biomass.B, Config.GrowthStages))

-- 2. Two players cannot both collect the same food.
local item: Food.Item = { active = true }
local index = Food.PickClosest({ 3, 3 }, Config.FoodPickupRange)
check("2: a winner is chosen when both are in range", index == 1)
check("2: first consume succeeds", Food.TryConsume(item))
check("2: second consume of the same food fails", not Food.TryConsume(item))
check("2: closer player wins", Food.PickClosest({ 4, 2 }, Config.FoodPickupRange) == 2)
check("2: nobody in range means no winner", Food.PickClosest({ Config.FoodPickupRange + 0.1 }, Config.FoodPickupRange) == nil)
check("2: exactly at range counts", Food.PickClosest({ Config.FoodPickupRange }, Config.FoodPickupRange) == 1)
check("2: empty list has no winner", Food.PickClosest({}, Config.FoodPickupRange) == nil)
check("2: NaN distance is ignored", Food.PickClosest({ 0 / 0, 4 }, Config.FoodPickupRange) == 2)

-- 3. One food item pays out once, across repeated scans.
local scanItem: Food.Item = { active = true }
local total = 0
for _ = 1, 20 do
    local winner = Food.PickClosest({ 1, 2 }, Config.FoodPickupRange)
    if scanItem.active and winner ~= nil and Food.TryConsume(scanItem) then
        total += foodBiomass
    end
end
check("3: 20 scans, both in range, paid exactly once", total == foodBiomass)
check("3: respawn re-enables once", Food.Respawn(scanItem) and not Food.Respawn(scanItem))
check("3: respawn of an active item does not duplicate it", scanItem.active)
check("3: re-spawned food can be consumed once again", Food.TryConsume(scanItem) and not Food.TryConsume(scanItem))

-- 4. Biomass never exceeds the cap.
local nearCap, gained = Growth.AddBiomass(cap - 5, foodBiomass, cap)
check("4: partial gain at the cap", nearCap == cap and gained == 5)
local atCap, gainedAtCap = Growth.AddBiomass(cap, foodBiomass, cap)
check("4: no gain at the cap", atCap == cap and gainedAtCap == 0)
local huge = Growth.AddBiomass(0, math.huge, cap)
check("4: infinite amount is clamped", huge == cap)
local _, badGain = Growth.AddBiomass(10, 0 / 0, cap)
check("4: NaN amount adds nothing", badGain == 0)
local _, negGain = Growth.AddBiomass(10, -5, cap)
check("4: negative amount adds nothing", negGain == 0)

-- 5/6. Evolution isolation and eligibility.
local forms: { [string]: string } = { A = Config.BaseForm, B = Config.BaseForm }
local biomassEvo: { [string]: number } = { A = cap, B = cap - 1 }
local okB, reasonB = Evolution.Validate("TANK", biomassEvo.B, forms.B, CreatureDefinitions)
check("6: B cannot evolve before the threshold", not okB and reasonB == "ThresholdNotReached")
local okA = Evolution.Validate("TANK", biomassEvo.A, forms.A, CreatureDefinitions)
if okA then
    forms.A = "TANK"
end
check("5: A evolved to TANK", forms.A == "TANK")
check("5: B's form is unchanged by A's choice", forms.B == Config.BaseForm)
biomassEvo.B = cap
local okB2 = Evolution.Validate("GLIDER", biomassEvo.B, forms.B, CreatureDefinitions)
if okB2 then
    forms.B = "GLIDER"
end
check("5: B can still choose GLIDER", forms.B == "GLIDER" and forms.A == "TANK")
local okRepeat, reasonRepeat = Evolution.Validate("GLIDER", cap, forms.A, CreatureDefinitions)
check("5: A cannot re-select to change form", not okRepeat and reasonRepeat == "AlreadyEvolved")

-- 7. A form cannot use another form's ability.
local shellForGlider = Ability.Validate("GLIDER", true, 100, 0, 0, Config.TankShellForm)
check("7: GLIDER cannot use the shell", not shellForGlider)
local glideForTank = Ability.ValidateGlide("TANK", true, true, 100, 0, 0, Config.GliderForm)
check("7: TANK cannot glide", not glideForTank)
local shellForBug = Ability.Validate(Config.BaseForm, true, 100, 0, 0, Config.TankShellForm)
check("7: BABY_BUG cannot use the shell", not shellForBug)

-- 8. Cooldowns are per player.
local glideState: { [string]: { activeUntil: number, readyAt: number } } = {
    A = { activeUntil = 0, readyAt = 0 },
    B = { activeUntil = 0, readyAt = 0 },
}
local function tryGlide(who: string, now: number): boolean
    local s = glideState[who]
    local accepted = Ability.ValidateGlide("GLIDER", true, true, now, s.activeUntil, s.readyAt, Config.GliderForm)
    if accepted then
        s.activeUntil = now + Config.GliderDuration
        s.readyAt = now + Config.GliderCooldown
    end
    return accepted
end
check("8: A glides", tryGlide("A", 100))
check("8: A is on cooldown", not tryGlide("A", 105))
check("8: B is unaffected by A's cooldown", tryGlide("B", 105))
check("8: A's timestamps unchanged by B", glideState.A.readyAt == 100 + Config.GliderCooldown)

-- 9. Duplicate requests cannot bypass the cooldown.
local shellActive, shellReady = 0, 0
local shellAccepted = 0
for i = 0, 199 do
    local now = 100 + i * 0.05 -- 100 .. 109.95, inside the 12 s cooldown
    if Ability.Validate("TANK", true, now, shellActive, shellReady, Config.TankShellForm) then
        shellActive = now + Config.TankShellDuration
        shellReady = now + Config.TankShellCooldown
        shellAccepted += 1
    end
end
check("9: 200 shell requests inside the cooldown activate once", shellAccepted == 1)
check("9: the duration was not extended", shellActive == 100 + Config.TankShellDuration)

-- 11. Invalid remote arguments are rejected.
local abilityIds = { Config.AbilityShellId, Config.AbilityGlideId }
check("11: shell id accepted", Ability.IsKnownAbilityId(Config.AbilityShellId, abilityIds))
check("11: glide id accepted", Ability.IsKnownAbilityId(Config.AbilityGlideId, abilityIds))
local badValues: { any } = { false, true, 0, 1, 1.5, "", "shell", "SHELL ", "FLY", {}, { "SHELL" }, function() end }
local abilityRejected = not Ability.IsKnownAbilityId(nil, abilityIds)
local evolutionRejected = not Evolution.IsValidForm(nil, CreatureDefinitions)
for _, value in badValues do
    if Ability.IsKnownAbilityId(value, abilityIds) then
        abilityRejected = false
    end
    if Evolution.IsValidForm(value, CreatureDefinitions) then
        evolutionRejected = false
    end
end
check("11: malformed ability ids are rejected", abilityRejected)
check("11: malformed evolution forms are rejected", evolutionRejected)
check("11: base form is not a selectable branch", not Evolution.IsValidForm(Config.BaseForm, CreatureDefinitions))

if failures > 0 then
    error(failures .. " test(s) failed")
end
print("all tests passed")
