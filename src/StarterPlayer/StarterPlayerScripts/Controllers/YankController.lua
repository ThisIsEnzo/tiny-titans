--!strict
-- Drawline Yank client controller. Client sends only a stable target id and release intent.
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local YankController = {}
local TAG = "DrawlineTarget"
local ACTION = "TT_Yank"
local PROMPT_RANGE = 24
local player = Players.LocalPlayer
local holding = false
local status = ""
local statusUntil = 0
local connections: { RBXScriptConnection } = {}

local function nearestTarget(): string?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root == nil or not root:IsA("BasePart") then return nil end
	local bestId: string? = nil
	local bestDistance = PROMPT_RANGE
	for _, instance in ipairs(CollectionService:GetTagged(TAG)) do
		if instance:IsA("BasePart") and instance:IsDescendantOf(workspace) then
			local id = instance:GetAttribute("YankId")
			if type(id) == "string" and instance:GetAttribute("YankState") ~= "Completed" then
				local distance = (instance.Position - (root :: BasePart).Position).Magnitude
				if distance <= bestDistance then bestId, bestDistance = id, distance end
			end
		end
	end
	return bestId
end

function YankController.Init()
	local folder = ReplicatedStorage:WaitForChild("DrawlineRemotes")
	local startRemote = folder:WaitForChild("YankStart") :: RemoteEvent
	local stopRemote = folder:WaitForChild("YankStop") :: RemoteEvent
	local stateRemote = folder:WaitForChild("YankState") :: RemoteEvent
	local gui = Instance.new("ScreenGui")
	gui.Name = "TT_YankPrompt"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.42, 0, 0, 34)
	label.Position = UDim2.new(0.29, 0, 0.78, 0)
	label.BackgroundColor3 = Color3.new(0, 0, 0)
	label.BackgroundTransparency = 0.35
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Visible = false
	label.Parent = gui

	local function beginHold()
		if holding then return end
		local id = nearestTarget()
		if id == nil then status, statusUntil = "No target in range", os.clock() + 1.5 return end
		holding = true
		startRemote:FireServer({ targetId = id })
	end
	local function endHold()
		if not holding then return end
		holding = false
		stopRemote:FireServer()
	end
	ContextActionService:BindAction(ACTION, function(_, inputState)
		if UserInputService:GetFocusedTextBox() ~= nil then return Enum.ContextActionResult.Pass end
		if inputState == Enum.UserInputState.Begin then beginHold()
		elseif inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then endHold() end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.R, Enum.KeyCode.ButtonX)
	table.insert(connections, UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.R or input.KeyCode == Enum.KeyCode.ButtonX then endHold() end
	end))
	if UserInputService.TouchEnabled then
		local button = Instance.new("TextButton")
		button.Name = "YankButton"
		button.Size = UDim2.fromOffset(76, 76)
		button.Position = UDim2.new(1, -100, 1, -190)
		button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		button.BackgroundTransparency = 0.3
		button.TextColor3 = Color3.new(1, 1, 1)
		button.TextScaled = true
		button.Text = "YANK"
		button.Parent = gui
		table.insert(connections, button.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then beginHold() end
		end))
		table.insert(connections, button.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then endHold() end
		end))
	end
	table.insert(connections, stateRemote.OnClientEvent:Connect(function(payload)
		if type(payload) ~= "table" then return end
		if payload.kind == "Rejected" then
			holding = false
			status, statusUntil = "Cannot yank: " .. tostring(payload.reason), os.clock() + 2
		elseif payload.kind == "Cancelled" then
			holding = false
			status, statusUntil = "Yank stopped (" .. tostring(payload.reason) .. ")", os.clock() + 2
		elseif payload.kind == "Completed" then
			holding = false
			status, statusUntil = "Yank complete", os.clock() + 2
		end
	end))
	table.insert(connections, player.CharacterRemoving:Connect(function()
		holding = false
		stopRemote:FireServer()
	end))
	local elapsed = 0
	table.insert(connections, RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed < 0.1 then return end
		elapsed = 0
		if holding then label.Visible, label.Text = true, "Yanking…"
		elseif os.clock() < statusUntil then label.Visible, label.Text = true, status
		else
			local id = nearestTarget()
			if id ~= nil then label.Visible, label.Text = true, "[Hold R / X] Yank"
			else label.Visible = false end
		end
	end))
end

function YankController.Destroy()
	ContextActionService:UnbindAction(ACTION)
	for _, connection in ipairs(connections) do connection:Disconnect() end
	table.clear(connections)
	holding = false
end

return YankController
