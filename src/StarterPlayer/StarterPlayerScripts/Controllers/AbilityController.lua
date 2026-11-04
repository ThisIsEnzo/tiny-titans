--!strict
-- Tank Defensive Shell client: input, button and status display.
-- The client only sends a bare activation request (no duration, cooldown or state).
-- The button shows the server-owned Player attributes "ShellActiveUntil" and
-- "ShellReadyAt", so a rejected request changes nothing on screen. The button is
-- visible only while the replicated EvolutionForm is the shell's form; the server
-- still validates everything. The shell itself is created by the server.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config") :: ModuleScript)
local Ability = require(Shared:WaitForChild("Ability") :: ModuleScript)

local AbilityController = {}

local GUI_NAME = "AbilityHud"
local READY_COLOR = Color3.fromRGB(60, 150, 100)
local ACTIVE_COLOR = Color3.fromRGB(70, 130, 210)
local COOLDOWN_COLOR = Color3.fromRGB(70, 74, 86)

local initialized = false

local function readNumber(player: Player, name: string): number
    local value = player:GetAttribute(name)
    if type(value) == "number" and value == value then
        return value
    end
    return 0
end

local function makeLabel(name: string, position: UDim2, size: UDim2, maxTextSize: number): TextLabel
    local label = Instance.new("TextLabel")
    label.Name = name
    label.BackgroundTransparency = 1
    label.Position = position
    label.Size = size
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    local limit = Instance.new("UITextSizeConstraint")
    limit.MinTextSize = 10
    limit.MaxTextSize = maxTextSize
    limit.Parent = label
    return label
end

local function buildGui(): (ScreenGui, TextButton, TextLabel)
    local gui = Instance.new("ScreenGui")
    gui.Name = GUI_NAME
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 12
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Large enough for a touch target; sits mid-right, above the touch jump button.
    local button = Instance.new("TextButton")
    button.Name = "ShellButton"
    button.AnchorPoint = Vector2.new(1, 0.5)
    button.Position = UDim2.new(1, -20, 0.58, 0)
    button.Size = UDim2.fromOffset(96, 72)
    button.Text = ""
    button.AutoButtonColor = true
    button.BackgroundColor3 = READY_COLOR
    button.BorderSizePixel = 0
    button.Visible = false
    button.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = button
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.6
    stroke.Parent = button

    local title = makeLabel("Title", UDim2.fromScale(0.06, 0.08), UDim2.fromScale(0.88, 0.36), 18)
    title.Text = "SHELL [" .. Config.AbilityKey .. "]"
    title.Parent = button

    local status = makeLabel("Status", UDim2.fromScale(0.06, 0.48), UDim2.fromScale(0.88, 0.42), 20)
    status.Font = Enum.Font.Gotham
    status.Parent = button

    return gui, button, status
end

function AbilityController.Init()
    if initialized then
        return
    end
    initialized = true

    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local gui, button, status = buildGui()

    local remote: RemoteEvent? = nil
    local heartbeat: RBXScriptConnection? = nil
    local state = "ready" -- "ready" | "active" | "cooldown"

    local render: () -> ()

    local function stopTicking()
        if heartbeat ~= nil then
            heartbeat:Disconnect()
            heartbeat = nil
        end
    end

    render = function()
        local isTank = player:GetAttribute("EvolutionForm") == Config.TankShellForm
        button.Visible = isTank
        if not isTank then
            state = "ready"
            stopTicking()
            return
        end

        local now = workspace:GetServerTimeNow()
        local activeUntil = readNumber(player, "ShellActiveUntil")
        local readyAt = readNumber(player, "ShellReadyAt")

        if Ability.IsActive(now, activeUntil) then
            state = "active"
            button.BackgroundColor3 = ACTIVE_COLOR
            status.Text = string.format("Active %.1fs", activeUntil - now)
        elseif Ability.GetCooldownRemaining(now, readyAt) > 0 then
            state = "cooldown"
            button.BackgroundColor3 = COOLDOWN_COLOR
            status.Text = string.format("Cooldown %.1fs", readyAt - now)
        else
            state = "ready"
            button.BackgroundColor3 = READY_COLOR
            status.Text = "Ready"
        end

        -- Tick only while a countdown is showing; no polling while ready/hidden.
        if state == "ready" then
            stopTicking()
        elseif heartbeat == nil then
            heartbeat = RunService.Heartbeat:Connect(function()
                render()
            end)
        end
    end

    local function request()
        if remote == nil or state ~= "ready" or not button.Visible then
            return
        end
        remote:FireServer() -- bare request; the server decides the outcome
    end

    button.Activated:Connect(request)

    local keyCode: any = (Enum.KeyCode :: any)[Config.AbilityKey]
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or UserInputService:GetFocusedTextBox() ~= nil then
            return
        end
        if input.KeyCode == keyCode then
            request()
        end
    end)

    player:GetAttributeChangedSignal("EvolutionForm"):Connect(render)
    player:GetAttributeChangedSignal("ShellActiveUntil"):Connect(render)
    player:GetAttributeChangedSignal("ShellReadyAt"):Connect(render)
    render()
    gui.Parent = playerGui

    task.spawn(function()
        local remotes = ReplicatedStorage:WaitForChild("Remotes")
        remote = remotes:WaitForChild("RequestAbility") :: RemoteEvent
    end)
end

return AbilityController
