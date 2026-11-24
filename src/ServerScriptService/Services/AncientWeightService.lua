--!strict
-- Observes server-owned Drawline target geometry; never moves or hooks Yank.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local AncientWeight = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AncientWeight") :: ModuleScript)
local Service = {}
local TAG = "AncientWeightPuzzle"
local STEP = 0.15
local DOOR_TIME = 1.2

type Entry = {
	root: Instance, block: BasePart, plate: BasePart?, door: BasePart?,
	rules: AncientWeight.Puzzle, doorClosed: CFrame?, doorOpen: CFrame?,
	plateColor: Color3?, plateMaterial: Enum.Material?, doorColor: Color3?, tween: Tween?,
}
local entries: {[string]: Entry} = {}
local connections: {RBXScriptConnection} = {}
local elapsed = 0
local initialized = false

local function xyz(v: Vector3)
	return {x=v.X, y=v.Y, z=v.Z}
end
local function stopTween(e: Entry)
	if e.tween then e.tween:Cancel(); e.tween=nil end
end
local function setDoor(e: Entry, open: boolean)
	local door=e.door
	if not door or not door.Parent then return end
	local target=if open then e.doorOpen else e.doorClosed
	if not target then return end
	stopTween(e)
	local tween=TweenService:Create(door, TweenInfo.new(DOOR_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame=target})
	e.tween=tween
	tween:Play()
end
local function publish(e: Entry)
	e.root:SetAttribute("PuzzleState", e.rules.state)
end
local function solve(e: Entry)
	if not AncientWeight.markSolved(e.rules, os.clock()) then return end
	publish(e)
	if e.plate and e.plate.Parent then
		e.plate.Color=Color3.fromRGB(96,200,120)
		e.plate.Material=Enum.Material.Neon
		e.plate:SetAttribute("PlateState","Active")
	end
	if e.door and e.door.Parent then
		e.door.Color=Color3.fromRGB(86,150,104)
		e.door:SetAttribute("PuzzleDoorOpen", true)
	end
	setDoor(e, true)
end
local function unregister(id: string)
	local e=entries[id]
	if not e then return end
	stopTween(e)
	entries[id]=nil
end
local function register(root: Instance)
	local id, blockId = root:GetAttribute("PuzzleId"), root:GetAttribute("BlockId")
	if type(id)~="string" or #id==0 or type(blockId)~="string" or #blockId==0 then
		warn("[AncientWeight] missing PuzzleId/BlockId:", root:GetFullName()); return
	end
	if entries[id] then warn("[AncientWeight] duplicate PuzzleId:", id); return end
	local block=root:FindFirstChild("Block")
	if not block or not block:IsA("BasePart") or block:GetAttribute("YankId")~=blockId
		or not CollectionService:HasTag(block,"DrawlineTarget") then
		warn("[AncientWeight] invalid Drawline Block:", id); return
	end
	local finish=block:FindFirstChild("YankEnd")
	if not finish or not finish:IsA("Attachment") then
		warn("[AncientWeight] missing YankEnd:", id); return
	end
	-- Yank snapshots the authored start-to-end attachment delta at registration.
	-- Its destination is the block pivot translated by that delta, not YankEnd.WorldPosition.
	local start=block:FindFirstChild("YankStart")
	local startWorld=if start and start:IsA("Attachment") then start.WorldPosition else block.Position
	local destination=block.Position+(finish.WorldPosition-startWorld)
	local tolerance=root:GetAttribute("Tolerance")
	local settle=root:GetAttribute("SettleSpeed")
	local rules=AncientWeight.newPuzzle({
		puzzleId=id, blockId=blockId, destination=xyz(destination),
		tolerance=if type(tolerance)=="number" then tolerance else nil,
		settleSpeed=if type(settle)=="number" then settle else nil,
	})
	if not rules then warn("[AncientWeight] invalid definition:",id); return end
	local p=root:FindFirstChild("Plate")
	local d=root:FindFirstChild("Door")
	local plate=if p and p:IsA("BasePart") then p else nil
	local door=if d and d:IsA("BasePart") then d else nil
	local entry: Entry={
		root=root, block=block, plate=plate, door=door, rules=rules,
		doorClosed=if door then door.CFrame else nil,
		doorOpen=if door then door.CFrame+Vector3.new(0,door.Size.Y,0) else nil,
		plateColor=if plate then plate.Color else nil,
		plateMaterial=if plate then plate.Material else nil,
		doorColor=if door then door.Color else nil, tween=nil,
	}
	entries[id]=entry
	publish(entry)
	if plate then plate.Color=Color3.fromRGB(96,96,104); plate.Material=Enum.Material.Slate end
	if door then door:SetAttribute("PuzzleDoorOpen",false) end
end
local function step()
	for id,e in pairs(entries) do
		if not e.root.Parent then unregister(id); continue end
		local present=e.block.Parent~=nil
		AncientWeight.setBlockMissing(e.rules,not present)
		if not present or e.rules.state~=AncientWeight.State.Locked then continue end
		-- Yank moves this part by server CFrame; anchored movement reports zero assembly velocity.
		local ok,speed=pcall(function() return e.block.AssemblyLinearVelocity.Magnitude end)
		if not ok then continue end
		local valid=AncientWeight.evaluate(e.rules,{
			blockId=e.block:GetAttribute("YankId"), position=xyz(e.block.Position), speed=speed,
		})
		if valid then solve(e) end
	end
end

function Service.Init()
	assert(RunService:IsServer(),"AncientWeightService is server-only")
	if initialized then return end
	initialized=true
	for _,root in ipairs(CollectionService:GetTagged(TAG)) do register(root) end
	table.insert(connections,CollectionService:GetInstanceAddedSignal(TAG):Connect(register))
	table.insert(connections,CollectionService:GetInstanceRemovedSignal(TAG):Connect(function(root)
		local id=root:GetAttribute("PuzzleId")
		if type(id)=="string" then unregister(id) end
	end))
	table.insert(connections,RunService.Heartbeat:Connect(function(dt)
		elapsed+=dt
		if elapsed>=STEP then elapsed=0; step() end
	end))
end
function Service.Destroy()
	for _,c in ipairs(connections) do c:Disconnect() end
	table.clear(connections)
	for id,e in pairs(entries) do stopTween(e); entries[id]=nil end
	initialized=false
end
return Service
