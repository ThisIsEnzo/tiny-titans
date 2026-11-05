--!strict
-- Read-only Biomass HUD. Displays the server-owned "Biomass" and "GrowthStage"
-- Player attributes. The client never writes these values and sends nothing
-- to the server; attribute replication is the only data source.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config") :: ModuleScript)
local Growth = require(Shared:WaitForChild("Growth") :: ModuleScript)

local BiomassUIController = {}

local GUI_NAME = "BiomassHud"
local FILL_COLOR = Color3.fromRGB(110, 220, 90)
local FULL_COLOR = Color3.fromRGB(255, 200, 60)
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local initialized = false

local function readNumber(player: Player, name: string, default: number): number
    local value = player:GetAttribute(name)
    if type(value) == "number" and value == value then
        return value
    end
    return default
end

local function makeLabel(name: string, position: UDim2, size: UDim2, alignment: Enum.TextXAlignment): TextLabel
    local label = Instance.new("TextLabel")
    label.Name = name
    label.BackgroundTransparency = 1
    label.Position = position
    label.Size = size
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.TextXAlignment = alignment
    local limit = Instance.new("UITextSizeConstraint")
    limit.MinTextSize = 12
    limit.MaxTextSize = 22
    limit.Parent = label
    return label
end

local function buildGui(): (ScreenGui, TextLabel, TextLabel, Frame)
    local gui = Instance.new("ScreenGui")
    gui.Name = GUI_NAME
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 10
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.AnchorPoint = Vector2.new(0.5, 1)
    panel.Position = UDim2.new(0.5, 0, 1, -24)
    panel.Size = UDim2.new(0.3, 0, 0, 64)
    panel.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    panel.BackgroundTransparency = 0.25
    panel.BorderSizePixel = 0
    panel.Parent = gui

    local sizeLimit = Instance.new("UISizeConstraint")
    sizeLimit.MinSize = Vector2.new(240, 56)
    sizeLimit.MaxSize = Vector2.new(420, 80)
    sizeLimit.Parent = panel

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = panel

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.7
    stroke.Thickness = 1
    stroke.Parent = panel

    local biomassLabel = makeLabel("BiomassLabel", UDim2.fromScale(0.05, 0.08), UDim2.fromScale(0.6, 0.42), Enum.TextXAlignment.Left)
    biomassLabel.Parent = panel

    local stageLabel = makeLabel("StageLabel", UDim2.fromScale(0.65, 0.08), UDim2.fromScale(0.3, 0.42), Enum.TextXAlignment.Right)
    stageLabel.Parent = panel

    local track = Instance.new("Frame")
    track.Name = "BarTrack"
    track.Position = UDim2.fromScale(0.05, 0.58)
    track.Size = UDim2.fromScale(0.9, 0.28)
    track.BackgroundColor3 = Color3.fromRGB(55, 58, 68)
    track.BorderSizePixel = 0
    track.ClipsDescendants = true
    track.Parent = panel

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Name = "BarFill"
    fill.Size = UDim2.fromScale(0, 1)
    fill.BackgroundColor3 = FILL_COLOR
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    return gui, biomassLabel, stageLabel, fill
end

-- Builds the HUD once and keeps it in sync with the local player's attributes.
function BiomassUIController.Init()
    if initialized then
        return
    end
    initialized = true

    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local gui, biomassLabel, stageLabel, fill = buildGui()

    local currentTween: Tween? = nil
    local firstRender = true

    local function render()
        local cap = Config.EvolutionBiomassRequired
        local biomass = math.clamp(readNumber(player, "Biomass", 0), 0, cap)
        local stageCount = #Config.GrowthStages
        local stage = math.clamp(math.floor(readNumber(player, "GrowthStage", 1)), 1, stageCount)
        local ratio = Growth.GetProgressRatio(biomass, cap)

        biomassLabel.Text = string.format("Biomass  %d / %d", math.floor(biomass), cap)
        stageLabel.Text = string.format("Stage %d/%d", stage, stageCount)
        fill.BackgroundColor3 = if ratio >= 1 then FULL_COLOR else FILL_COLOR

        if currentTween ~= nil then
            currentTween:Cancel()
            currentTween = nil
        end
        local goal = UDim2.fromScale(ratio, 1)
        if firstRender then
            firstRender = false
            fill.Size = goal
        else
            local tween = TweenService:Create(fill, TWEEN_INFO, { Size = goal })
            currentTween = tween
            tween:Play()
        end
    end

    player:GetAttributeChangedSignal("Biomass"):Connect(render)
    player:GetAttributeChangedSignal("GrowthStage"):Connect(render)
    render()
    gui.Parent = playerGui
end

return BiomassUIController
