--!strict
-- Pure growth helpers. No Roblox services, so they are unit-testable outside Studio.
-- Callers pass tuning data (see Config) explicitly.

export type Stage = { MinEnergy: number, Scale: number }

local Growth = {}

-- Clamps energy to [0, cap]. Non-finite input becomes 0.
function Growth.ClampEnergy(energy: number, cap: number): number
    if energy ~= energy then
        return 0
    end
    return math.clamp(energy, 0, cap)
end

-- Returns the 1-based index of the highest stage whose MinEnergy has been reached.
-- Stages must be sorted by ascending MinEnergy.
function Growth.GetStageIndex(energy: number, stages: { Stage }): number
    local index = 1
    for i, stage in stages do
        if energy >= stage.MinEnergy then
            index = i
        end
    end
    return index
end

-- Returns the body scale for a stage index (out-of-range indexes are clamped).
function Growth.GetScale(stageIndex: number, stages: { Stage }): number
    local clamped = math.clamp(stageIndex, 1, #stages)
    return stages[clamped].Scale
end

-- Returns energy / cap as a 0..1 fill ratio. Invalid input yields 0.
function Growth.GetProgressRatio(energy: number, cap: number): number
    if energy ~= energy or cap ~= cap or cap <= 0 then
        return 0
    end
    return math.clamp(energy / cap, 0, 1)
end

return table.freeze(Growth)
