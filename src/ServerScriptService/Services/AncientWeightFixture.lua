--!strict
-- Temporary playable puzzle arena, reachable through paired portals beside the Nest.
-- Existing authored Workspace.AncientWeight takes precedence.
local CollectionService=game:GetService("CollectionService")
local Workspace=game:GetService("Workspace")
local Players=game:GetService("Players")
local Fixture={}
local ROOT="AncientWeight"
local ORIGIN=Vector3.new(120,0,0)
local function make(parent: Instance,name: string,size: Vector3,cf: CFrame,color: Color3,material: Enum.Material,collide: boolean): Part
	local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=cf
	p.Anchored=true; p.CanCollide=collide; p.CanTouch=false; p.CanQuery=collide
	p.Color=color; p.Material=material; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
	p.Parent=parent; return p
end
local function portal(parent: Instance,name: string,position: Vector3,target: Vector3,color: Color3)
	local p=make(parent,name,Vector3.new(5,7,1),CFrame.new(position),color,Enum.Material.Neon,false)
	p.Transparency=0.25; p.CanTouch=true
	local busy: {[Player]: boolean}={}
	p.Touched:Connect(function(hit)
		local character=hit:FindFirstAncestorOfClass("Model")
		local player=character and Players:GetPlayerFromCharacter(character)
		if not player or busy[player] then return end
		local root=character:FindFirstChild("HumanoidRootPart")
		local humanoid=character:FindFirstChildOfClass("Humanoid")
		if not root or not root:IsA("BasePart") or not humanoid or humanoid.Health<=0 then return end
		busy[player]=true
		root.CFrame=CFrame.new(target)
		task.delay(1,function() busy[player]=nil end)
	end)
	return p
end
function Fixture.Build()
	if Workspace:FindFirstChild(ROOT) then return false end
	local root=Instance.new("Folder"); root.Name=ROOT
	root:SetAttribute("PuzzleId","ancient_weight"); root:SetAttribute("BlockId","ancient_weight_block")
	root:SetAttribute("Tolerance",1.5); root:SetAttribute("SettleSpeed",0.5); root.Parent=Workspace
	local stone=Color3.fromRGB(122,118,108); local floor=Color3.fromRGB(88,86,78)
	make(root,"Floor",Vector3.new(40,1,24),CFrame.new(ORIGIN+Vector3.new(0,.5,0)),floor,Enum.Material.Slate,true)
	make(root,"LeftWall",Vector3.new(1,12,24),CFrame.new(ORIGIN+Vector3.new(-20,6,0)),stone,Enum.Material.Slate,true)
	make(root,"RightWall",Vector3.new(1,12,24),CFrame.new(ORIGIN+Vector3.new(20,6,0)),stone,Enum.Material.Slate,true)
	make(root,"BackWallLeft",Vector3.new(16,12,1),CFrame.new(ORIGIN+Vector3.new(-12,6,-12)),stone,Enum.Material.Slate,true)
	make(root,"BackWallRight",Vector3.new(16,12,1),CFrame.new(ORIGIN+Vector3.new(12,6,-12)),stone,Enum.Material.Slate,true)
	make(root,"ExitFloor",Vector3.new(12,1,16),CFrame.new(ORIGIN+Vector3.new(0,.5,-20)),floor,Enum.Material.Slate,true)
	make(root,"Rail",Vector3.new(20,.2,2),CFrame.new(ORIGIN+Vector3.new(-2,.62,0)),Color3.fromRGB(58,54,48),Enum.Material.SmoothPlastic,false)
	local plate=make(root,"Plate",Vector3.new(6,.4,6),CFrame.new(ORIGIN+Vector3.new(6,.7,0)),stone,Enum.Material.Slate,true)
	local door=make(root,"Door",Vector3.new(8,12,1),CFrame.new(ORIGIN+Vector3.new(0,6,-12)),Color3.fromRGB(120,62,44),Enum.Material.Wood,true)
	door.CanTouch=false
	local block=make(root,"Block",Vector3.new(4,4,4),CFrame.new(ORIGIN+Vector3.new(-10,3,0)),Color3.fromRGB(196,168,96),Enum.Material.Sandstone,true)
	block:SetAttribute("YankId","ancient_weight_block"); block:SetAttribute("YankDuration",3); block:SetAttribute("YankRange",24)
	local start=Instance.new("Attachment"); start.Name="YankStart"; start.Parent=block
	local finish=Instance.new("Attachment"); finish.Name="YankEnd"; finish.Position=Vector3.new(16,0,0); finish.Parent=block
	CollectionService:AddTag(block,"DrawlineTarget")
	CollectionService:AddTag(root,"AncientWeightPuzzle")
	-- Portal near the Nest's east edge; return portal in the puzzle's exit alcove.
	portal(Workspace,"AncientWeightEntryPortal",Vector3.new(-27,4,42),ORIGIN+Vector3.new(0,3,8),Color3.fromRGB(80,190,220))
	portal(root,"ReturnPortal",ORIGIN+Vector3.new(0,4,-27),Vector3.new(-27,4,46),Color3.fromRGB(220,180,90))
	return true
end
return Fixture
