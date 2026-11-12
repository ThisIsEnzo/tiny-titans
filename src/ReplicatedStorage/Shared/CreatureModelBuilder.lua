--!strict
-- Builds a creature visual Model from a spec table (see BabyBugSpec) using only built-in
-- primitives (Parts and SpecialMesh spheres): no asset ids. Roblox-only (creates Instances), so it
-- is not unit-tested in Lune; the spec data it consumes is.
--
-- Every part is a cosmetic: unanchored, massless and non-colliding, with CanTouch and CanQuery off,
-- so it cannot push the Humanoid, block queries or become its own physics object. Parts are joined
-- with Motor6Ds (one per part, named spec.JointName, parented to the child part), so the whole
-- model moves with whatever its root joint is attached to and is destroyed with its parent.

local CreatureModelBuilder = {}

local function toCFrame(pos: { number }, rot: { number }): CFrame
    return CFrame.new(pos[1], pos[2], pos[3])
        * CFrame.Angles(math.rad(rot[1]), math.rad(rot[2]), math.rad(rot[3]))
end

-- Builds the model at the spec's reference scale, not parented. Returns (model, rootPart). The root
-- part's joint to the character is added by AttachRoot.
function CreatureModelBuilder.Build(spec: any): (Model, BasePart)
    local model = Instance.new("Model")
    model.Name = spec.ModelName

    local built: { [string]: BasePart } = {}
    for _, def in spec.Parts do
        local part = Instance.new("Part")
        part.Name = def.name
        part.Color = Color3.fromRGB(def.color[1], def.color[2], def.color[3])
        part.Material = (Enum.Material :: any)[def.material] or Enum.Material.SmoothPlastic
        part.TopSurface = Enum.SurfaceType.Smooth
        part.BottomSurface = Enum.SurfaceType.Smooth
        part.Anchored = false
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.Massless = true
        part.CastShadow = true
        if def.shape == "Cylinder" then
            -- Roblox cylinders run along X; specs describe them along Y (length, diameter, diameter).
            part.Shape = Enum.PartType.Cylinder
            part.Size = Vector3.new(def.size[2], def.size[1], def.size[3])
        else
            part.Size = Vector3.new(def.size[1], def.size[2], def.size[3])
            if def.shape == "Sphere" then
                local mesh = Instance.new("SpecialMesh")
                mesh.MeshType = Enum.MeshType.Sphere
                mesh.Parent = part
            end
        end
        part.Parent = model
        built[def.name] = part
    end

    for _, def in spec.Parts do
        if def.parent ~= nil then
            local part = built[def.name]
            local joint = Instance.new("Motor6D")
            joint.Name = spec.JointName
            joint.Part0 = built[def.parent]
            joint.Part1 = part
            joint.C0 = toCFrame(def.jointPos, def.jointRot)
            local center = toCFrame(def.centerPos, def.centerRot)
            if def.shape == "Cylinder" then
                center = center * CFrame.Angles(0, 0, math.rad(90)) -- spec Y axis -> part X axis
            end
            joint.C1 = center:Inverse()
            joint.Parent = part
        end
    end

    local root = built[spec.RootPart]
    model.PrimaryPart = root
    return model, root
end

-- Joins the model's root part to the character's HumanoidRootPart. The caller sets the joint's C0
-- (the vertical offset depends on the Humanoid's current hip height and scale).
function CreatureModelBuilder.AttachRoot(spec: any, root: BasePart, humanoidRootPart: BasePart): Motor6D
    local joint = Instance.new("Motor6D")
    joint.Name = spec.JointName
    joint.Part0 = humanoidRootPart
    joint.Part1 = root
    joint.Parent = root
    return joint
end

return table.freeze(CreatureModelBuilder)
