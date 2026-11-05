--!strict
-- Optional unit tests for the pure growth helpers.
-- Run with Lune from the repository root:  lune run tests/Growth.test.lua
-- Lune is NOT part of rokit.toml; this file is outside the Rojo project tree.

local Config = require("../src/ReplicatedStorage/Shared/Config")
local Growth = require("../src/ReplicatedStorage/Shared/Growth")

local failures = 0
local function check(name: string, condition: boolean)
    if not condition then
        failures += 1
        print("FAIL: " .. name)
    else
        print("ok:   " .. name)
    end
end

local stages = Config.GrowthStages
local cap = Config.EvolutionBiomassRequired

check("stage 1 at 0 biomass", Growth.GetStageIndex(0, stages) == 1)
check("still stage 1 just below stage 2", Growth.GetStageIndex(stages[2].MinBiomass - 1, stages) == 1)
check("stage 2 at its threshold", Growth.GetStageIndex(stages[2].MinBiomass, stages) == 2)
check("stage 3 at its threshold", Growth.GetStageIndex(stages[3].MinBiomass, stages) == 3)
check("stage 3 at cap", Growth.GetStageIndex(cap, stages) == #stages)
check("scale grows with stage", Growth.GetScale(1, stages) < Growth.GetScale(2, stages) and Growth.GetScale(2, stages) < Growth.GetScale(3, stages))
check("scale index clamps low", Growth.GetScale(-5, stages) == stages[1].Scale)
check("scale index clamps high", Growth.GetScale(99, stages) == stages[#stages].Scale)
check("clamp above cap", Growth.ClampBiomass(cap + 50, cap) == cap)
check("clamp below zero", Growth.ClampBiomass(-10, cap) == 0)
check("clamp NaN", Growth.ClampBiomass(0 / 0, cap) == 0)
check("stages sorted ascending", stages[1].MinBiomass < stages[2].MinBiomass and stages[2].MinBiomass < stages[3].MinBiomass)
check("last stage reachable before cap", stages[#stages].MinBiomass <= cap)
check("ratio at 0", Growth.GetProgressRatio(0, cap) == 0)
check("ratio at half", Growth.GetProgressRatio(cap / 2, cap) == 0.5)
check("ratio at cap", Growth.GetProgressRatio(cap, cap) == 1)
check("ratio clamps above cap", Growth.GetProgressRatio(cap * 3, cap) == 1)
check("ratio clamps below zero", Growth.GetProgressRatio(-5, cap) == 0)
check("ratio NaN biomass", Growth.GetProgressRatio(0 / 0, cap) == 0)
check("ratio zero cap", Growth.GetProgressRatio(10, 0) == 0)
local addedTotal, addedGain = Growth.AddBiomass(0, Config.FoodBiomass, cap)
check("AddBiomass adds food biomass", addedTotal == Config.FoodBiomass and addedGain == Config.FoodBiomass)
local atCapTotal, atCapGain = Growth.AddBiomass(cap, Config.FoodBiomass, cap)
check("AddBiomass at cap adds nothing", atCapTotal == cap and atCapGain == 0)
-- Stage boundaries and targets are the agreed design values (regression protection).
check("boundary 0 is stage 1", Growth.GetStageIndex(0, stages) == 1)
check("boundary 29 is stage 1", Growth.GetStageIndex(29, stages) == 1)
check("boundary 30 is stage 2", Growth.GetStageIndex(30, stages) == 2)
check("boundary 59 is stage 2", Growth.GetStageIndex(59, stages) == 2)
check("boundary 60 is stage 3", Growth.GetStageIndex(60, stages) == 3)
check("boundary 100 is stage 3", Growth.GetStageIndex(100, stages) == 3)
check("thresholds are 0, 30, 60", stages[1].MinBiomass == 0 and stages[2].MinBiomass == 30 and stages[3].MinBiomass == 60)
check("targets are 0.6, 0.8, 1.0", Growth.GetScale(1, stages) == 0.6 and Growth.GetScale(2, stages) == 0.8 and Growth.GetScale(3, stages) == 1.0)
check("biomass cap and food reward unchanged", cap == 100 and Config.FoodBiomass == 10)
check("biomass 40 is stage 2 (as observed in Studio)", Growth.GetStageIndex(40, stages) == 2)

-- Scale updates use absolute targets, so repeating them cannot compound.
local applied: number? = nil
local appliedCount = 0
for _ = 1, 100 do
    local wanted = Growth.GetScale(2, stages)
    if Growth.ShouldUpdateScale(applied, wanted) then
        applied = wanted
        appliedCount += 1
    end
end
check("100 identical updates apply once", appliedCount == 1 and applied == 0.8)
check("a new stage target is applied", Growth.ShouldUpdateScale(0.8, 1.0))
check("a tiny float difference is not an update", not Growth.ShouldUpdateScale(0.8, 0.8 + 1e-6))
-- Respawn: a new character has no applied target, so it is set to its stage's scale
-- (not left at the previous character's value or at the default 1).
check("new character always needs a scale", Growth.ShouldUpdateScale(nil, Growth.GetScale(1, stages)))
check("new character at stage 3 needs a scale", Growth.ShouldUpdateScale(nil, Growth.GetScale(3, stages)))
check("growth tween is positive and short", Config.GrowthTweenSeconds > 0 and Config.GrowthTweenSeconds <= 2)
check("fallback delay is positive", Config.AppearanceFallbackSeconds > 0)
check("food biomass positive", Config.FoodBiomass > 0)

if failures > 0 then
    error(failures .. " test(s) failed")
end
print("all tests passed")
