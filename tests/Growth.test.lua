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
local cap = Config.EvolutionEnergyRequired

check("stage 1 at 0 energy", Growth.GetStageIndex(0, stages) == 1)
check("still stage 1 just below stage 2", Growth.GetStageIndex(stages[2].MinEnergy - 1, stages) == 1)
check("stage 2 at its threshold", Growth.GetStageIndex(stages[2].MinEnergy, stages) == 2)
check("stage 3 at its threshold", Growth.GetStageIndex(stages[3].MinEnergy, stages) == 3)
check("stage 3 at cap", Growth.GetStageIndex(cap, stages) == #stages)
check("scale grows with stage", Growth.GetScale(1, stages) < Growth.GetScale(2, stages) and Growth.GetScale(2, stages) < Growth.GetScale(3, stages))
check("scale index clamps low", Growth.GetScale(-5, stages) == stages[1].Scale)
check("scale index clamps high", Growth.GetScale(99, stages) == stages[#stages].Scale)
check("clamp above cap", Growth.ClampEnergy(cap + 50, cap) == cap)
check("clamp below zero", Growth.ClampEnergy(-10, cap) == 0)
check("clamp NaN", Growth.ClampEnergy(0 / 0, cap) == 0)
check("stages sorted ascending", stages[1].MinEnergy < stages[2].MinEnergy and stages[2].MinEnergy < stages[3].MinEnergy)
check("last stage reachable before cap", stages[#stages].MinEnergy <= cap)
check("ratio at 0", Growth.GetProgressRatio(0, cap) == 0)
check("ratio at half", Growth.GetProgressRatio(cap / 2, cap) == 0.5)
check("ratio at cap", Growth.GetProgressRatio(cap, cap) == 1)
check("ratio clamps above cap", Growth.GetProgressRatio(cap * 3, cap) == 1)
check("ratio clamps below zero", Growth.GetProgressRatio(-5, cap) == 0)
check("ratio NaN energy", Growth.GetProgressRatio(0 / 0, cap) == 0)
check("ratio zero cap", Growth.GetProgressRatio(10, 0) == 0)
local addedTotal, addedGain = Growth.AddEnergy(0, Config.FoodEnergy, cap)
check("AddEnergy adds food energy", addedTotal == Config.FoodEnergy and addedGain == Config.FoodEnergy)
local atCapTotal, atCapGain = Growth.AddEnergy(cap, Config.FoodEnergy, cap)
check("AddEnergy at cap adds nothing", atCapTotal == cap and atCapGain == 0)
check("food energy positive", Config.FoodEnergy > 0)

if failures > 0 then
    error(failures .. " test(s) failed")
end
print("all tests passed")
