--!strict
-- Procedural animation for creature visuals (P2-05), run locally on every client for every tagged
-- model, so each player sees everyone's creatures animated. Nothing is replicated or sent: only
-- Motor6D.Transform (client-local) is written, from the pure pose maths in BabyBugPose. One shared
-- RenderStepped connection serves all creatures; it exists only while at least one is registered.
-- Movement is never touched: this reads velocity and the replicated Humanoid state.

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local BabyBugSpec = require(Shared:WaitForChild("BabyBugSpec") :: ModuleScript)
local BabyBugPose = require(Shared:WaitForChild("BabyBugPose") :: ModuleScript)

local BabyBugAnimationController = {}

local SMOOTHING_RATE = 12 -- how quickly blend weights follow their targets (1/s)
local CULL_DISTANCE = 250 -- creatures farther than this from the camera are not animated

type Angles = { rx: number, ry: number, rz: number }
type Rig = {
    model: Model,
    motors: { [string]: Motor6D }, -- part name -> its joint
    out: { [string]: Angles },
    phase: number,
    walk: number,
    jump: number,
    fall: number,
    startedAt: number,
    ancestry: RBXScriptConnection,
}

local rigs: { [Model]: Rig } = {}
local rigCount = 0
local heartbeat: RBXScriptConnection? = nil

local function stepRig(rig: Rig, dt: number, now: number)
    local character = rig.model.Parent
    if character == nil then
        return
    end
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if root == nil or not root:IsA("BasePart") or humanoid == nil then
        return
    end

    local camera = workspace.CurrentCamera
    if camera ~= nil and (camera.CFrame.Position - root.Position).Magnitude > CULL_DISTANCE then
        return
    end

    local velocity = root.AssemblyLinearVelocity
    local speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
    local state = humanoid:GetState()
    local airborne = state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall
    local walkTarget, jumpTarget, fallTarget = BabyBugPose.GetTargets(speed, airborne, velocity.Y)

    local alpha = 1 - math.exp(-SMOOTHING_RATE * dt)
    rig.walk += (walkTarget - rig.walk) * alpha
    rig.jump += (jumpTarget - rig.jump) * alpha
    rig.fall += (fallTarget - rig.fall) * alpha
    rig.phase = (rig.phase + BabyBugPose.GetPhaseRate(speed, rig.model:GetScale()) * dt) % (2 * math.pi)

    BabyBugPose.Evaluate(BabyBugSpec.Animated, {
        t = now - rig.startedAt,
        phase = rig.phase,
        walk = rig.walk,
        jump = rig.jump,
        fall = rig.fall,
    }, rig.out)
    for partName, angles in rig.out do
        local motor = rig.motors[partName]
        if motor ~= nil then
            motor.Transform = CFrame.Angles(angles.rx, angles.ry, angles.rz)
        end
    end
end

local function onFrame(dt: number)
    local now = os.clock()
    for _, rig in rigs do
        stepRig(rig, dt, now)
    end
end

local function unregister(model: Model)
    local rig = rigs[model]
    if rig == nil then
        return
    end
    rigs[model] = nil
    rigCount -= 1
    rig.ancestry:Disconnect()
    if rigCount <= 0 and heartbeat ~= nil then
        heartbeat:Disconnect()
        heartbeat = nil
    end
end

local function register(model: Model)
    if rigs[model] ~= nil then
        return
    end
    -- The model replicates with its parts; wait (bounded) for the root before collecting joints.
    if model:WaitForChild(BabyBugSpec.RootPart, 10) == nil or not model:IsDescendantOf(game) or rigs[model] ~= nil then
        return
    end
    local motors: { [string]: Motor6D } = {}
    for _, entry in BabyBugSpec.Animated do
        local part = model:FindFirstChild(entry.part)
        local motor = if part ~= nil then part:FindFirstChild(BabyBugSpec.JointName) else nil
        if motor ~= nil and motor:IsA("Motor6D") then
            motors[entry.part] = motor
        end
    end
    rigs[model] = {
        model = model,
        motors = motors,
        out = {},
        phase = 0,
        walk = 0,
        jump = 0,
        fall = 0,
        startedAt = os.clock() - math.random() * 10, -- de-synchronise idle motion between creatures
        ancestry = model.AncestryChanged:Connect(function()
            if not model:IsDescendantOf(game) then
                unregister(model)
            end
        end),
    }
    rigCount += 1
    if heartbeat == nil then
        heartbeat = RunService.RenderStepped:Connect(onFrame)
    end
end

function BabyBugAnimationController.Init()
    CollectionService:GetInstanceAddedSignal(BabyBugSpec.Tag):Connect(function(instance)
        if instance:IsA("Model") then
            task.spawn(register, instance)
        end
    end)
    CollectionService:GetInstanceRemovedSignal(BabyBugSpec.Tag):Connect(function(instance)
        if instance:IsA("Model") then
            unregister(instance)
        end
    end)
    for _, instance in CollectionService:GetTagged(BabyBugSpec.Tag) do
        if instance:IsA("Model") then
            task.spawn(register, instance)
        end
    end
end

return BabyBugAnimationController
