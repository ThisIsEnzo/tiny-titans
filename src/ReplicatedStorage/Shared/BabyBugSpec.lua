--!strict
-- Data description of the Baby Bug visual (P2-05). Pure data and math: no Roblox services, no
-- Instances, no requires, no asset ids; everything is built from built-in primitives by
-- CreatureModelBuilder. Other forms can later add their own spec with the same shape.
--
-- Coordinates are studs at the reference scale (1.0), +Y up, the creature faces -Z (the same way
-- a character's HumanoidRootPart faces). Each part is joined to its parent with a Motor6D:
--   part.CFrame = parent.CFrame * C0 * Transform * C1:Inverse()
--   C0 = CFrame.new(jointPos) * Angles(jointRot)        -- the joint, in the parent's frame
--   C1:Inverse() = CFrame.new(centerPos) * Angles(centerRot) -- the part, relative to the joint
-- Rotations are degrees, applied as CFrame.Angles(rx, ry, rz). Cylinders are described with their
-- length along Y; the builder maps that onto Roblox's X-axis cylinders.
--
-- Animation only rotates joints (Motor6D.Transform), so model scaling (which scales C0/C1) stays
-- correct. `Animated` lists which parts the pose code drives.

export type Vec = { number }
export type PartDef = {
    name: string,
    parent: string?, -- nil only for the root part
    shape: "Block" | "Sphere" | "Cylinder",
    size: Vec,
    color: Vec, -- RGB 0-255
    material: string, -- an Enum.Material name
    jointPos: Vec,
    jointRot: Vec,
    centerPos: Vec,
    centerRot: Vec,
}
export type AnimEntry = { part: string, kind: string, side: number, index: number }

local COLORS = {
    body = { 70, 50, 40 },
    head = { 88, 66, 50 },
    shell = { 206, 96, 56 },
    seam = { 132, 56, 34 },
    spot = { 52, 30, 28 },
    leg = { 62, 46, 38 },
    eye = { 18, 18, 22 },
    shine = { 255, 255, 255 },
    bulb = { 176, 122, 70 },
}
local ZERO = { 0, 0, 0 }
local MATERIAL = "SmoothPlastic"

local parts: { PartDef } = {}
local animated: { AnimEntry } = {}

local function add(
    name: string,
    parent: string?,
    shape: "Block" | "Sphere" | "Cylinder",
    size: Vec,
    color: Vec,
    jointPos: Vec,
    jointRot: Vec,
    centerPos: Vec,
    centerRot: Vec,
    kind: string?,
    side: number?,
    index: number?
)
    table.insert(parts, {
        name = name,
        parent = parent,
        shape = shape,
        size = size,
        color = color,
        material = MATERIAL,
        jointPos = jointPos,
        jointRot = jointRot,
        centerPos = centerPos,
        centerRot = centerRot,
    })
    if kind ~= nil then
        table.insert(animated, { part = name, kind = kind, side = side or 0, index = index or 0 })
    end
end

-- Root: the underside of the body. Its joint to the character's HumanoidRootPart is created at
-- runtime (CreatureModelBuilder.AttachRoot), so its own joint fields are unused.
add("Body", nil, "Sphere", { 1.8, 1.2, 2.2 }, COLORS.body, ZERO, ZERO, ZERO, ZERO, "body")

-- Rounded protective shell with a centre seam and four spots resting on its surface.
local SHELL_SIZE = { 2.5, 1.7, 2.9 }
add("Shell", "Body", "Sphere", SHELL_SIZE, COLORS.shell, { 0, 0.2, 0.15 }, ZERO, ZERO, ZERO, "shell")
add("ShellSeam", "Shell", "Sphere", { 0.1, 1.76, 2.96 }, COLORS.seam, ZERO, ZERO, ZERO, ZERO)
local function addSpot(name: string, x: number, zRel: number)
    local nx = x / (SHELL_SIZE[1] / 2)
    local nz = zRel / (SHELL_SIZE[3] / 2)
    local k = 1 - nx * nx - nz * nz
    assert(k > 0, "spot must lie on the shell")
    local y = (SHELL_SIZE[2] / 2) * math.sqrt(k) - 0.04 -- slightly sunk into the surface
    add(name, "Shell", "Sphere", { 0.5, 0.16, 0.5 }, COLORS.spot, { x, y, zRel }, ZERO, ZERO, ZERO)
end
addSpot("ShellSpotR1", 0.6, -0.45)
addSpot("ShellSpotL1", -0.6, -0.45)
addSpot("ShellSpotR2", 0.7, 0.55)
addSpot("ShellSpotL2", -0.7, 0.55)

-- Head with two large glossy eyes (each with a small highlight).
add("Head", "Body", "Sphere", { 1.5, 1.25, 1.3 }, COLORS.head, { 0, 0.1, -1.0 }, ZERO, ZERO, ZERO, "head")
for _, side in { 1, -1 } do
    local tag = if side == 1 then "R" else "L"
    add("Eye" .. tag, "Head", "Sphere", { 0.5, 0.6, 0.42 }, COLORS.eye, { side * 0.42, 0.15, -0.5 }, ZERO, ZERO, ZERO)
    add("EyeShine" .. tag, "Eye" .. tag, "Sphere", { 0.17, 0.17, 0.12 }, COLORS.shine, { side * -0.04, 0.14, -0.17 }, ZERO, ZERO, ZERO)
end

-- Two antennae: a base segment leaning forward and outward, a tip segment, and a small bulb.
for _, side in { 1, -1 } do
    local tag = if side == 1 then "R" else "L"
    local base = "Antenna" .. tag .. "1"
    local tip = "Antenna" .. tag .. "2"
    add(base, "Head", "Cylinder", { 0.12, 0.8, 0.12 }, COLORS.leg, { side * 0.3, 0.45, -0.35 }, { -35, 0, -side * 20 }, { 0, 0.4, 0 }, ZERO, "antennaBase", side, 1)
    add(tip, base, "Cylinder", { 0.1, 0.7, 0.1 }, COLORS.leg, { 0, 0.4, 0 }, { -30, 0, 0 }, { 0, 0.35, 0 }, ZERO, "antennaTip", side, 2)
    add("Antenna" .. tag .. "Bulb", tip, "Sphere", { 0.24, 0.24, 0.24 }, COLORS.bulb, { 0, 0.35, 0 }, ZERO, ZERO, ZERO)
end

-- Six legs (three per side), two segments each. The upper segment leans out and down, the lower
-- one points straight down so the feet reach the ground at the reference scale.
local UPPER_LENGTH = 0.7
local LOWER_LENGTH = 0.56
local TILT_DEGREES = 127
local BEND_DEGREES = 53
local function addLeg(side: number, index: number, hipX: number, hipZ: number, yawDegrees: number)
    local tag = (if side == 1 then "R" else "L") .. tostring(index)
    local theta = -side * TILT_DEGREES
    local th = math.rad(theta)
    local upper = "Leg" .. tag .. "Upper"
    add(
        upper,
        "Body",
        "Cylinder",
        { 0.2, UPPER_LENGTH, 0.2 },
        COLORS.leg,
        { side * hipX, -0.12, hipZ },
        { 0, side * yawDegrees, 0 },
        { -(UPPER_LENGTH / 2) * math.sin(th), (UPPER_LENGTH / 2) * math.cos(th), 0 },
        { 0, 0, theta },
        "legUpper",
        side,
        index
    )
    add(
        "Leg" .. tag .. "Lower",
        upper,
        "Cylinder",
        { 0.16, LOWER_LENGTH, 0.16 },
        COLORS.leg,
        { 0, UPPER_LENGTH / 2, 0 },
        { 0, 0, side * BEND_DEGREES },
        { 0, LOWER_LENGTH / 2, 0 },
        ZERO,
        "legLower",
        side,
        index
    )
end
for _, side in { 1, -1 } do
    addLeg(side, 1, 0.6, -0.55, 25) -- front legs reach forward
    addLeg(side, 2, 0.75, 0.1, 0)
    addLeg(side, 3, 0.62, 0.7, -25) -- rear legs reach back
end

local function deepFreeze(value: any): any
    if type(value) == "table" and not table.isfrozen(value) then
        for _, child in value do
            deepFreeze(child)
        end
        table.freeze(value)
    end
    return value
end

local BabyBugSpec = {
    ModelName = "BabyBugVisual",
    Tag = "TT_CreatureVisual", -- CollectionService tag on every creature visual model
    FormAttribute = "FormId", -- model attribute: the form whose visual this is
    RootPart = "Body",
    JointName = "Joint", -- every part holds one Motor6D with this name (to its parent / the character)
    RootHeight = 1.1, -- height of the root part's centre above the ground at the reference scale
    ReferenceScale = 1,
    Parts = parts :: { PartDef },
    Animated = animated :: { AnimEntry },
}

-- Vertical offset (studs) of the root joint from the HumanoidRootPart centre to where the root part
-- should sit: the root part's centre is rootHeight * modelScale above the ground, while the
-- HumanoidRootPart centre is hipHeight + hrpHeight / 2 above it (both already scaled by the Humanoid).
function BabyBugSpec.RootOffsetY(modelScale: number, hipHeight: number, hrpHeight: number): number
    return BabyBugSpec.RootHeight * modelScale - (hipHeight + hrpHeight / 2)
end

return deepFreeze(BabyBugSpec) :: typeof(BabyBugSpec)
