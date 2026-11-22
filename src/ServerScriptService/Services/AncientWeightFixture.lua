--!strict
-- First playable Tiny Titans slice: the puzzle arena is now the starting level.
-- The previous Nest prototype is removed from the project; no portal or hidden test room.
local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local Fixture = {}
local ROOT = "AncientWeight"
local ORIGIN = Vector3.new(0, 0, 0)

local PALETTE = {
	stone = Color3.fromRGB(83, 91, 94),
	stoneLight = Color3.fromRGB(119, 128, 126),
	stoneDark = Color3.fromRGB(45, 53, 57),
	bronze = Color3.fromRGB(157, 112, 55),
	gold = Color3.fromRGB(225, 184, 105),
	ember = Color3.fromRGB(255, 133, 57),
	floor = Color3.fromRGB(65, 72, 73),
}

local function part(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3,
	material: Enum.Material, collide: boolean, transparency: number?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Anchored = true
	p.CanCollide = collide
	p.CanTouch = false
	p.CanQuery = collide
	p.Color = color
	p.Material = material
	p.Transparency = transparency or 0
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function pillar(parent: Instance, position: Vector3)
	part(parent, "PillarBase", Vector3.new(4, 1, 4), CFrame.new(position + Vector3.new(0, .5, 0)),
		PALETTE.stoneDark, Enum.Material.Slate, true)
	part(parent, "Pillar", Vector3.new(2.4, 9, 2.4), CFrame.new(position + Vector3.new(0, 5, 0)),
		PALETTE.stoneLight, Enum.Material.Rock, true)
	part(parent, "PillarCapital", Vector3.new(3.6, 1, 3.6), CFrame.new(position + Vector3.new(0, 10, 0)),
		PALETTE.bronze, Enum.Material.Metal, true)
end

local function torch(parent: Instance, position: Vector3)
	part(parent, "TorchBracket", Vector3.new(.35, 1.5, .35), CFrame.new(position),
		PALETTE.bronze, Enum.Material.Metal, false)
	local flame = part(parent, "EternalFlame", Vector3.new(.7, 1.2, .7),
		CFrame.new(position + Vector3.new(0, 1, 0)), PALETTE.ember, Enum.Material.Neon, false, .12)
	local light = Instance.new("PointLight")
	light.Color = PALETTE.ember
	light.Brightness = 1.8
	light.Range = 18
	light.Shadows = true
	light.Parent = flame
end

function Fixture.Build(): boolean
	local existing = Workspace:FindFirstChild(ROOT)
	if existing then return false end

	local root = Instance.new("Folder")
	root.Name = ROOT
	root:SetAttribute("PuzzleId", "ancient_weight")
	root:SetAttribute("BlockId", "ancient_weight_block")
	root:SetAttribute("Tolerance", 1.5)
	root:SetAttribute("SettleSpeed", 0.5)
	root.Parent = Workspace

	-- A compact ruin courtyard with an unobstructed central puzzle lane.
	part(root, "CourtyardFloor", Vector3.new(44, 1, 38),
		CFrame.new(ORIGIN + Vector3.new(0, .5, 0)), PALETTE.floor, Enum.Material.Slate, true)
	part(root, "EntryLanding", Vector3.new(14, 1, 10),
		CFrame.new(ORIGIN + Vector3.new(0, .5, 23)), PALETTE.stoneDark, Enum.Material.Slate, true)
	part(root, "RearThreshold", Vector3.new(14, 1, 8),
		CFrame.new(ORIGIN + Vector3.new(0, .5, -22)), PALETTE.stoneDark, Enum.Material.Slate, true)

	-- Low perimeter walls frame the space without hiding the mechanism from the spawn.
	part(root, "WestLowWall", Vector3.new(1.5, 5, 38),
		CFrame.new(ORIGIN + Vector3.new(-22, 2.5, 0)), PALETTE.stone, Enum.Material.Rock, true)
	part(root, "EastLowWall", Vector3.new(1.5, 5, 38),
		CFrame.new(ORIGIN + Vector3.new(22, 2.5, 0)), PALETTE.stone, Enum.Material.Rock, true)
	part(root, "RearWallLeft", Vector3.new(16, 12, 1.5),
		CFrame.new(ORIGIN + Vector3.new(-14, 6, -19)), PALETTE.stone, Enum.Material.Rock, true)
	part(root, "RearWallRight", Vector3.new(16, 12, 1.5),
		CFrame.new(ORIGIN + Vector3.new(14, 6, -19)), PALETTE.stone, Enum.Material.Rock, true)

	-- Monumental framing and warm light make the objective readable from the entrance.
	for _, x in ipairs({ -17, 17 }) do
		pillar(root, ORIGIN + Vector3.new(x, 0, 12))
		pillar(root, ORIGIN + Vector3.new(x, 0, -13))
		torch(root, ORIGIN + Vector3.new(x * .82, 7, 5))
	end
	part(root, "EntranceLintel", Vector3.new(38, 2, 3),
		CFrame.new(ORIGIN + Vector3.new(0, 11, 15)), PALETTE.bronze, Enum.Material.Metal, true)
	part(root, "MechanismPedestal", Vector3.new(12, .7, 8),
		CFrame.new(ORIGIN + Vector3.new(0, .85, -1)), PALETTE.stoneDark, Enum.Material.Slate, true)

	-- Rail and plate share the same level. Yank moves the block from x=-10 to x=+6.
	part(root, "Rail", Vector3.new(20, .18, 2.4),
		CFrame.new(ORIGIN + Vector3.new(-2, 1.1, 0)), PALETTE.bronze, Enum.Material.Metal, false)
	local plate = part(root, "Plate", Vector3.new(6, .35, 6),
		CFrame.new(ORIGIN + Vector3.new(6, 1.18, 0)), PALETTE.gold, Enum.Material.Metal, true)
	plate:SetAttribute("PlateState", "Inactive")

	local door = part(root, "Door", Vector3.new(8, 11, 1.5),
		CFrame.new(ORIGIN + Vector3.new(0, 6.5, -19)), PALETTE.bronze, Enum.Material.Metal, true)
	door:SetAttribute("PuzzleDoorOpen", false)
	part(root, "DoorFrameLeft", Vector3.new(2, 13, 2),
		CFrame.new(ORIGIN + Vector3.new(-5, 6.5, -19)), PALETTE.stoneLight, Enum.Material.Rock, true)
	part(root, "DoorFrameRight", Vector3.new(2, 13, 2),
		CFrame.new(ORIGIN + Vector3.new(5, 6.5, -19)), PALETTE.stoneLight, Enum.Material.Rock, true)
	part(root, "DoorHeader", Vector3.new(12, 2, 2),
		CFrame.new(ORIGIN + Vector3.new(0, 13, -19)), PALETTE.stoneLight, Enum.Material.Rock, true)

	local block = part(root, "Block", Vector3.new(4, 4, 4),
		CFrame.new(ORIGIN + Vector3.new(-10, 3, 0)), PALETTE.gold, Enum.Material.Sandstone, true)
	block:SetAttribute("YankId", "ancient_weight_block")
	block:SetAttribute("YankDuration", 3)
	block:SetAttribute("YankRange", 24)
	local start = Instance.new("Attachment")
	start.Name = "YankStart"
	start.Parent = block
	local finish = Instance.new("Attachment")
	finish.Name = "YankEnd"
	finish.Position = Vector3.new(16, 0, 0)
	finish.Parent = block
	CollectionService:AddTag(block, "DrawlineTarget")
	CollectionService:AddTag(root, "AncientWeightPuzzle")

	-- Spawn directly inside the arena. The objective and exit are visible immediately.
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "PuzzleStart"
	spawn.Size = Vector3.new(8, .5, 8)
	spawn.CFrame = CFrame.new(ORIGIN + Vector3.new(0, 1.25, 23))
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.CanCollide = true
	spawn.Color = PALETTE.stoneLight
	spawn.Material = Enum.Material.Slate
	spawn.Parent = root

	return true
end

return Fixture
