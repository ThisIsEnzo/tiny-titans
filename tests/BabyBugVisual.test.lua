--!strict
-- Optional unit tests for the pure parts of the Baby Bug visual (P2-05):
-- Shared/BabyBugSpec.lua (structure of the model data) and Shared/BabyBugPose.lua (animation maths).
-- Run with Lune from the repository root:  lune run tests/BabyBugVisual.test.lua
-- It does NOT build Instances or test hiding, scaling, joints or animation playback; those need
-- Studio (README checklist).

local Spec = require("../src/ReplicatedStorage/Shared/BabyBugSpec")
local Pose = require("../src/ReplicatedStorage/Shared/BabyBugPose")
local Config = require("../src/ReplicatedStorage/Shared/Config")

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

-- Spec structure ---------------------------------------------------------------------------------
local byName: { [string]: any } = {}
local unique, orderOk, parentsOk, rootCount = true, true, true, 0
for _, part in Spec.Parts do
    if byName[part.name] ~= nil then
        unique = false
    end
    if part.parent == nil then
        rootCount += 1
    elseif byName[part.parent] == nil then
        orderOk = false -- a parent must be defined before its children (also rules out cycles)
    end
    byName[part.name] = part
end
check("part names are unique", unique)
check("exactly one root part, and it is the named root", rootCount == 1 and byName[Spec.RootPart] ~= nil and byName[Spec.RootPart].parent == nil)
check("every parent exists and is defined earlier", orderOk)

local function countMatching(pattern: string): number
    local n = 0
    for name in byName do
        if string.match(name, pattern) ~= nil then
            n += 1
        end
    end
    return n
end
check("six upper and six lower leg segments", countMatching("^Leg[RL][123]Upper$") == 6 and countMatching("^Leg[RL][123]Lower$") == 6)
check("three legs per side", countMatching("^LegR%d") == 6 and countMatching("^LegL%d") == 6)
check("two antennae with two segments each", countMatching("^Antenna[RL]1$") == 2 and countMatching("^Antenna[RL]2$") == 2)
check("two eyes with highlights", countMatching("^Eye[RL]$") == 2 and countMatching("^EyeShine[RL]$") == 2)
check("distinct head, body and shell", byName.Head ~= nil and byName.Body ~= nil and byName.Shell ~= nil)
check("head and shell hang off the body", byName.Head.parent == "Body" and byName.Shell.parent == "Body")
check("legs hang off the body, lowers off their upper", (function()
    for name, part in byName do
        if string.match(name, "^Leg[RL][123]Upper$") ~= nil and part.parent ~= "Body" then
            return false
        end
        if string.match(name, "^Leg[RL][123]Lower$") ~= nil and part.parent ~= string.gsub(name, "Lower$", "Upper") then
            return false
        end
    end
    return true
end)())

-- Left and right mirror each other.
local mirrored = true
for name, part in byName do
    if string.match(name, "^Leg[R]%d") ~= nil then
        local twin = byName[string.gsub(name, "^LegR", "LegL")]
        if twin == nil or math.abs(twin.jointPos[1] + part.jointPos[1]) > 1e-9 or twin.jointPos[3] ~= part.jointPos[3] then
            mirrored = false
        end
    end
end
check("left legs mirror right legs", mirrored)

-- Values are sane and use only built-in primitives.
local valuesOk = true
local allowedMaterials: { [string]: boolean } = { SmoothPlastic = true, Plastic = true }
for _, part in Spec.Parts do
    for _, size in part.size do
        if not (size > 0 and size <= 4) then
            valuesOk = false
        end
    end
    for _, channel in part.color do
        if not (channel >= 0 and channel <= 255) then
            valuesOk = false
        end
    end
    if #part.size ~= 3 or #part.color ~= 3 or #part.jointPos ~= 3 or #part.jointRot ~= 3 or #part.centerPos ~= 3 or #part.centerRot ~= 3 then
        valuesOk = false
    end
    if not allowedMaterials[part.material] then
        valuesOk = false
    end
    if part.shape ~= "Block" and part.shape ~= "Sphere" and part.shape ~= "Cylinder" then
        valuesOk = false
    end
end
check("sizes, colours, vectors, materials and shapes are valid", valuesOk)

local function collectStrings(value: any, found: { string })
    if type(value) == "string" then
        table.insert(found, value)
    elseif type(value) == "table" then
        for _, child in value do
            collectStrings(child, found)
        end
    end
end
local strings: { string } = {}
collectStrings(Spec, strings)
local assetFree = true
for _, text in strings do
    local lower = string.lower(text)
    if string.find(lower, "rbxasset", 1, true) or string.find(lower, "http", 1, true) or string.find(text, "203785492", 1, true) or string.find(text, "81504106", 1, true) then
        assetFree = false
    end
end
check("no asset ids or urls anywhere in the spec", assetFree)

-- Animation list matches the parts and the pose module.
local animOk, kindsOk = true, true
for _, entry in Spec.Animated do
    if byName[entry.part] == nil then
        animOk = false
    end
    if not Pose.Kinds[entry.kind] then
        kindsOk = false
    end
end
check("every animated part exists in the spec", animOk)
check("every animated kind is known to the pose module", kindsOk)
check("all twelve leg segments, both antennae segments, head, shell and body are animated", #Spec.Animated == 12 + 4 + 3)

-- Immutability.
check("spec is frozen", table.isfrozen(Spec) and table.isfrozen(Spec.Parts) and table.isfrozen(Spec.Parts[1]) and table.isfrozen(Spec.Parts[1].size))
check("spec cannot be changed", throws(function()
    (Spec.Parts[1] :: any).name = "X"
end) and throws(function()
    table.insert(Spec.Animated :: any, {})
end))

-- Growth: the ground offset follows the scale the Humanoid reports.
local function hip(scale: number): number
    return 2 * scale
end
local function hrp(scale: number): number
    return 2 * scale
end
check("root sits RootHeight above the ground at the reference scale", math.abs(Spec.RootOffsetY(1, hip(1), hrp(1)) - (Spec.RootHeight - 3)) < 1e-9)
local scalesOk = true
for _, stage in Config.GrowthStages do
    -- The root part's centre must end up exactly RootHeight * scale above the ground.
    local offset = Spec.RootOffsetY(stage.Scale, hip(stage.Scale), hrp(stage.Scale))
    local rootCentreAboveGround = (hip(stage.Scale) + hrp(stage.Scale) / 2) + offset
    if math.abs(rootCentreAboveGround - Spec.RootHeight * stage.Scale) > 1e-9 then
        scalesOk = false
    end
end
check("root height scales with every configured growth stage", scalesOk)

-- Pose targets and rates --------------------------------------------------------------------------
local w, j, f = Pose.GetTargets(0, false, 0)
check("standing still is idle", w == 0 and j == 0 and f == 0)
w, j, f = Pose.GetTargets(0.2, false, 0)
check("tiny drift is still idle", w == 0 and j == 0 and f == 0)
w, j, f = Pose.GetTargets(3, false, 0)
check("walking partly weights walk", w > 0 and w < 1 and j == 0 and f == 0)
w, j, f = Pose.GetTargets(30, false, 0)
check("walk weight saturates at 1", w == 1)
w, j, f = Pose.GetTargets(10, true, 20)
check("airborne and rising is a jump", w == 0 and j == 1 and f == 0)
w, j, f = Pose.GetTargets(10, true, -20)
check("airborne and falling is a fall", w == 0 and j == 0 and f == 1)
w, j, f = Pose.GetTargets(0 / 0, false, 0)
check("NaN speed is idle", w == 0 and j == 0 and f == 0)
check("no phase rate when still or invalid", Pose.GetPhaseRate(0, 1) == 0 and Pose.GetPhaseRate(5, 0) == 0 and Pose.GetPhaseRate(0 / 0, 1) == 0)
check("phase rate grows with speed", Pose.GetPhaseRate(10, 1) > Pose.GetPhaseRate(5, 1))
check("a bigger creature cycles its legs more slowly", Pose.GetPhaseRate(8, 1) < Pose.GetPhaseRate(8, 0.6))
check("phase rate is capped", Pose.GetPhaseRate(1e6, 0.05) <= 30)

-- Pose evaluation ---------------------------------------------------------------------------------
local function evaluate(t: number, phase: number, walk: number, jump: number, fall: number): { [string]: any }
    local out: { [string]: any } = {}
    Pose.Evaluate(Spec.Animated, { t = t, phase = phase, walk = walk, jump = jump, fall = fall }, out)
    return out
end
local finiteAndBounded = true
for _, weights in { { 0, 0, 0 }, { 1, 0, 0 }, { 0, 1, 0 }, { 0, 0, 1 }, { 0.5, 0.5, 0 }, { 0.3, 0, 0.7 } } do
    for step = 0, 40 do
        local out = evaluate(step * 0.37, step * 0.5, weights[1], weights[2], weights[3])
        for _, entry in Spec.Animated do
            local a = out[entry.part]
            if a == nil then
                finiteAndBounded = false
            else
                for _, v in { a.rx, a.ry, a.rz } do
                    if v ~= v or math.abs(v) > 1.5 then
                        finiteAndBounded = false
                    end
                end
            end
        end
    end
end
check("every part gets a finite pose within 1.5 rad for every state", finiteAndBounded)

local idleA, idleB = evaluate(0, 0, 0, 0, 0), evaluate(1.3, 0, 0, 0, 0)
check("idle moves over time (antenna sway)", idleA.AntennaR1.rx ~= idleB.AntennaR1.rx)
check("idle is subtle", math.abs(idleB.AntennaR1.rx) < 0.2 and math.abs(idleB.Head.rx) < 0.1)

local walk1 = evaluate(0, 0.8, 1, 0, 0)
check("walking swings the legs", walk1.LegR1Upper.ry ~= 0)
check("tripod gait: the two groups swing half a cycle apart (R1 against R2)", math.abs(walk1.LegR1Upper.ry + walk1.LegR2Upper.ry) < 1e-9 and math.abs(walk1.LegR1Upper.ry) > 0.1)
check("a full cycle returns to the same pose", math.abs(walk1.LegR1Upper.ry - evaluate(0, 0.8 + 2 * math.pi, 1, 0, 0).LegR1Upper.ry) < 1e-9)
check("the two sides use opposite signs for the same swing", (function()
    local o = evaluate(0, 0.8, 1, 0, 0)
    -- R1 and L2 are in the same group, so their forward swing is equal: ry has opposite sign by side.
    return math.abs(o.LegR1Upper.ry + o.LegL2Upper.ry) < 1e-9
end)())
check("rising weight changes the pose from idle", evaluate(0, 0, 0, 1, 0).LegR2Upper.rz ~= evaluate(0, 0, 0, 0, 0).LegR2Upper.rz)
check("jump and fall poses differ", evaluate(0, 0, 0, 1, 0).Body.rx ~= evaluate(0, 0, 0, 0, 1).Body.rx)
check("jump pitches the nose up, fall down", evaluate(0, 0, 0, 1, 0).Body.rx > 0 and evaluate(0, 0, 0, 0, 1).Body.rx < 0)
check("the pose is deterministic", evaluate(2, 1, 0.4, 0.3, 0.3).LegL3Lower.rz == evaluate(2, 1, 0.4, 0.3, 0.3).LegL3Lower.rz)

local reuse: { [string]: any } = {}
Pose.Evaluate(Spec.Animated, { t = 0, phase = 0, walk = 1, jump = 0, fall = 0 }, reuse)
local first = reuse.LegR1Upper
Pose.Evaluate(Spec.Animated, { t = 1, phase = 1, walk = 1, jump = 0, fall = 0 }, reuse)
check("the output table is reused between calls", reuse.LegR1Upper == first)

local unknown: { [string]: any } = {}
Pose.Evaluate({ { part = "X", kind = "nope", side = 1, index = 1 } }, { t = 0, phase = 0, walk = 1, jump = 0, fall = 0 }, unknown)
check("an unknown kind gets a zero pose instead of an error", unknown.X.rx == 0 and unknown.X.ry == 0 and unknown.X.rz == 0)
local clamped = evaluate(0, 0, 5, -3, 0 / 0)
check("out-of-range weights are clamped (never NaN or huge)", (function()
    for _, entry in Spec.Animated do
        local a = clamped[entry.part]
        if a.rx ~= a.rx or a.ry ~= a.ry or a.rz ~= a.rz or math.abs(a.rx) > 1.5 then
            return false
        end
    end
    return true
end)())

if failures > 0 then
    error(failures .. " test(s) failed")
end
print("all tests passed")
