--!strict
-- Pure procedural pose maths for the Baby Bug (P2-05). No Roblox services: unit-testable in Lune.
-- It only returns joint rotations (radians); the client controller applies them to Motor6D.Transform.
-- Idle, walk, jump and fall are blended by weights so transitions are continuous.

local BabyBugPose = {}

export type Entry = { part: string, kind: string, side: number, index: number }
export type Angles = { rx: number, ry: number, rz: number }
export type Params = {
    t: number, -- time in seconds (idle motion)
    phase: number, -- walk cycle phase in radians (advance with GetPhaseRate)
    walk: number, -- blend weights, each 0..1 (see GetTargets)
    jump: number,
    fall: number,
}

-- Anim kinds this module knows. Unknown kinds get a zero pose, never an error.
BabyBugPose.Kinds = table.freeze({
    body = true,
    head = true,
    shell = true,
    legUpper = true,
    legLower = true,
    antennaBase = true,
    antennaTip = true,
})

local WALK_FULL_SPEED = 6 -- studs/s at which the walk weight reaches 1
local WALK_MIN_SPEED = 0.5
local STRIDE_STUDS = 4 -- ground covered per leg cycle at the reference scale
local MAX_PHASE_RATE = 30

-- Target blend weights (walk, jump, fall) for the current movement. Airborne and rising is a jump,
-- airborne otherwise a fall; on the ground the walk weight grows with speed.
function BabyBugPose.GetTargets(horizontalSpeed: number, airborne: boolean, verticalVelocity: number): (number, number, number)
    if airborne then
        if verticalVelocity > 1 then
            return 0, 1, 0
        end
        return 0, 0, 1
    end
    if horizontalSpeed ~= horizontalSpeed or horizontalSpeed < WALK_MIN_SPEED then
        return 0, 0, 0
    end
    return math.clamp(horizontalSpeed / WALK_FULL_SPEED, 0, 1), 0, 0
end

-- Leg cycle speed (radians/s): proportional to ground speed, slower for a larger creature
-- (longer strides), capped so very fast movement cannot spin the legs.
function BabyBugPose.GetPhaseRate(horizontalSpeed: number, modelScale: number): number
    if horizontalSpeed ~= horizontalSpeed or horizontalSpeed <= 0 or modelScale ~= modelScale or modelScale <= 0 then
        return 0
    end
    return math.min(2 * math.pi * horizontalSpeed / (STRIDE_STUDS * modelScale), MAX_PHASE_RATE)
end

-- Alternating tripod gait: right 1 and 3 and left 2 move together, opposite the other three.
local function groupPhase(side: number, index: number): number
    if (index % 2 == 1) == (side == 1) then
        return 0
    end
    return math.pi
end

-- Clamps a blend weight to 0..1; NaN becomes 0 (math.clamp would pass NaN through).
local function clamp01(x: number): number
    if x ~= x then
        return 0
    end
    return math.clamp(x, 0, 1)
end

-- Fills out[part] = { rx, ry, rz } for every entry. `out` is reused between calls to avoid garbage.
function BabyBugPose.Evaluate(entries: { Entry }, p: Params, out: { [string]: Angles })
    local t, phase = p.t, p.phase
    local walk, jump, fall = clamp01(p.walk), clamp01(p.jump), clamp01(p.fall)
    local idle = math.max(0, 1 - math.max(walk, jump, fall))

    for _, entry in entries do
        local angles = out[entry.part]
        if angles == nil then
            angles = { rx = 0, ry = 0, rz = 0 }
            out[entry.part] = angles
        end
        local rx, ry, rz = 0, 0, 0
        local side, index, kind = entry.side, entry.index, entry.kind

        if kind == "legUpper" then
            local w = phase + groupPhase(side, index)
            local reach = if index == 1 then 1 elseif index == 3 then -1 else 0
            local swing = walk * 0.45 * math.sin(w) + (jump * 0.25 + fall * 0.2) * reach
                + idle * 0.02 * math.sin(t * 1.3 + index * 2.1 + side)
            local lift = walk * 0.4 * math.max(0, math.cos(w)) + jump * 0.5
                + fall * (0.65 + 0.12 * math.sin(t * 9 + index * 1.7))
            ry = side * swing
            rz = side * lift
        elseif kind == "legLower" then
            local w = phase + groupPhase(side, index)
            rz = side * (walk * 0.3 * math.max(0, math.cos(w)) + jump * 0.6 + fall * 0.5)
        elseif kind == "body" then
            rx = jump * 0.25 - fall * 0.2 + idle * 0.015 * math.sin(t * 2)
            rz = walk * 0.06 * math.sin(phase)
        elseif kind == "head" then
            rx = idle * 0.05 * math.sin(t * 1.6) + walk * 0.05 * math.sin(phase * 2) + jump * 0.15
            ry = idle * 0.06 * math.sin(t * 0.7)
        elseif kind == "shell" then
            rx = idle * 0.02 * math.sin(t * 2)
            rz = walk * 0.04 * math.sin(phase + math.pi)
        elseif kind == "antennaBase" then
            rx = (idle + 0.3) * 0.1 * math.sin(t * 1.8 + side) + walk * 0.15 * math.sin(phase * 2 + side)
                + jump * 0.3 - fall * 0.1
            rz = idle * 0.08 * math.sin(t * 1.3 + side * 1.7)
        elseif kind == "antennaTip" then
            rx = (idle + 0.3) * 0.15 * math.sin(t * 1.8 + side - 0.8) + walk * 0.2 * math.sin(phase * 2 + side - 0.9)
                + jump * 0.3
            rz = idle * 0.1 * math.sin(t * 1.3 + side * 1.7 - 0.6)
        end

        angles.rx, angles.ry, angles.rz = rx, ry, rz
    end
end

return table.freeze(BabyBugPose)
