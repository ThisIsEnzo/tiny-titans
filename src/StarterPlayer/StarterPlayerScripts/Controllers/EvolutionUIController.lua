--!strict
-- Evolution UI. Display-only except for one request: when the server marks
-- evolution available, the player can click TANK or GLIDER, which fires the
-- RequestEvolution RemoteEvent with only the branch name. Everything shown is
-- driven by the server-owned Player attributes "EvolutionAvailable" and
-- "EvolutionForm"; the UI never assumes a request succeeded.
-- Also shows an overhead form tag for evolved players so other clients can see it.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config") :: ModuleScript)

local EvolutionUIController = {}

local GUI_NAME = "EvolutionHud"
local TAG_NAME = "FormTag"
local CLICK_LOCK_SECONDS = 0.6

local DISPLAY_NAMES: { [string]: string } = {
    BABY_BUG = "Baby Bug",
    TANK = "Tank",
    GLIDER = "Glider",
}

local initialized = false

local function displayName(form: string): string
    return DISPLAY_NAMES[form] or form
end

local function readForm(player: Player): string
    local value = player:GetAttribute("EvolutionForm")
    if type(value) == "string" then
        return value
    end
    return Config.BaseForm
end

local function makeLabel(
    name: string,
    position: UDim2,
    size: UDim2,
    maxTextSize: number,
    alignment: Enum.TextXAlignment
): TextLabel
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
    limit.MinTextSize = 10
    limit.MaxTextSize = maxTextSize
    limit.Parent = label
    return label
end

local function roundCorners(instance: Instance, radius: number)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
end

local function makeChoiceButton(form: string, description: string, color: Color3, position: UDim2): TextButton
    local button = Instance.new("TextButton")
    button.Name = form .. "Button"
    button.Position = position
    button.Size = UDim2.fromScale(0.425, 0.5)
    button.BackgroundColor3 = color
    button.AutoButtonColor = true
    button.Text = ""
    button.BorderSizePixel = 0
    roundCorners(button, 8)

    local title = makeLabel("Title", UDim2.fromScale(0.05, 0.1), UDim2.fromScale(0.9, 0.45), 26, Enum.TextXAlignment.Center)
    title.Text = string.upper(displayName(form))
    title.Parent = button

    local detail = makeLabel("Detail", UDim2.fromScale(0.05, 0.58), UDim2.fromScale(0.9, 0.34), 16, Enum.TextXAlignment.Center)
    detail.Font = Enum.Font.Gotham
    detail.Text = description
    detail.Parent = button
    return button
end

local function buildGui(): (ScreenGui, Frame, TextLabel, TextButton, TextButton)
    local gui = Instance.new("ScreenGui")
    gui.Name = GUI_NAME
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 11
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Form badge, just above the Energy HUD.
    local badge = Instance.new("Frame")
    badge.Name = "FormBadge"
    badge.AnchorPoint = Vector2.new(0.5, 1)
    badge.Position = UDim2.new(0.5, 0, 1, -96)
    badge.Size = UDim2.new(0.3, 0, 0, 30)
    badge.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    badge.BackgroundTransparency = 0.25
    badge.BorderSizePixel = 0
    badge.Parent = gui
    roundCorners(badge, 8)
    local badgeLimit = Instance.new("UISizeConstraint")
    badgeLimit.MinSize = Vector2.new(240, 26)
    badgeLimit.MaxSize = Vector2.new(420, 36)
    badgeLimit.Parent = badge
    local formLabel = makeLabel("FormLabel", UDim2.fromScale(0.05, 0.12), UDim2.fromScale(0.9, 0.76), 20, Enum.TextXAlignment.Center)
    formLabel.Parent = badge

    -- Choice panel, shown only while the server says evolution is available.
    local panel = Instance.new("Frame")
    panel.Name = "ChoicePanel"
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.fromScale(0.5, 0.4)
    panel.Size = UDim2.new(0.5, 0, 0, 200)
    panel.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    panel.BackgroundTransparency = 0.1
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.Parent = gui
    roundCorners(panel, 12)
    local panelLimit = Instance.new("UISizeConstraint")
    panelLimit.MinSize = Vector2.new(300, 170)
    panelLimit.MaxSize = Vector2.new(560, 240)
    panelLimit.Parent = panel
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 200, 60)
    stroke.Thickness = 2
    stroke.Parent = panel

    local heading = makeLabel("Heading", UDim2.fromScale(0.05, 0.05), UDim2.fromScale(0.9, 0.2), 28, Enum.TextXAlignment.Center)
    heading.Text = "EVOLUTION READY"
    heading.TextColor3 = Color3.fromRGB(255, 200, 60)
    heading.Parent = panel

    local sub = makeLabel("Subheading", UDim2.fromScale(0.05, 0.25), UDim2.fromScale(0.9, 0.1), 16, Enum.TextXAlignment.Center)
    sub.Font = Enum.Font.Gotham
    sub.Text = "Choose your form. This choice is final."
    sub.Parent = panel

    local tank = makeChoiceButton("TANK", "Tough and durable", Color3.fromRGB(70, 110, 160), UDim2.fromScale(0.05, 0.4))
    tank.Parent = panel
    local glider = makeChoiceButton("GLIDER", "Light and mobile", Color3.fromRGB(60, 150, 140), UDim2.fromScale(0.525, 0.4))
    glider.Parent = panel

    local note = makeLabel("Note", UDim2.fromScale(0.05, 0.9), UDim2.fromScale(0.9, 0.08), 13, Enum.TextXAlignment.Center)
    note.Font = Enum.Font.Gotham
    note.TextTransparency = 0.3
    note.Text = "Tank has a visual-only shell. Glider has no ability yet."
    note.Parent = panel

    return gui, panel, formLabel, tank, glider
end

-- Overhead tag so other clients can see evolved forms (display only).
local function setupFormTags()
    local labels: { [Player]: TextLabel } = {}

    local function updateTag(player: Player)
        local label = labels[player]
        if label == nil then
            return
        end
        local form = readForm(player)
        label.Text = string.upper(displayName(form))
        local tag = label.Parent
        if tag ~= nil and tag:IsA("BillboardGui") then
            tag.Enabled = form ~= Config.BaseForm
        end
    end

    local function attachTag(player: Player, character: Model)
        local head = character:WaitForChild("Head", 10)
        -- WaitForChild yields: the character may have been replaced or the player may
        -- have left meanwhile. Do not tag a stale character or re-register a gone player.
        if player.Parent ~= Players or player.Character ~= character then
            return
        end
        if head == nil or not head:IsA("BasePart") then
            return
        end
        local old = head:FindFirstChild(TAG_NAME)
        if old ~= nil then
            old:Destroy()
        end
        local tag = Instance.new("BillboardGui")
        tag.Name = TAG_NAME
        tag.Adornee = head
        tag.Size = UDim2.fromOffset(110, 26)
        tag.StudsOffset = Vector3.new(0, 2.2, 0)
        tag.MaxDistance = 80
        tag.Enabled = false
        local label = makeLabel("Label", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), 18, Enum.TextXAlignment.Center)
        label.TextStrokeTransparency = 0.4
        label.Parent = tag
        tag.Parent = head
        labels[player] = label
        updateTag(player)
    end

    local function track(player: Player)
        player:GetAttributeChangedSignal("EvolutionForm"):Connect(function()
            updateTag(player)
        end)
        player.CharacterAdded:Connect(function(character)
            attachTag(player, character)
        end)
        if player.Character ~= nil then
            task.spawn(attachTag, player, player.Character)
        end
    end

    Players.PlayerAdded:Connect(track)
    Players.PlayerRemoving:Connect(function(player)
        labels[player] = nil
    end)
    for _, player in Players:GetPlayers() do
        track(player)
    end
end

function EvolutionUIController.Init()
    if initialized then
        return
    end
    initialized = true

    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local gui, panel, formLabel, tankButton, gliderButton = buildGui()

    local remote: RemoteEvent? = nil
    local locked = false

    local function render()
        formLabel.Text = "Form: " .. displayName(readForm(player))
        panel.Visible = player:GetAttribute("EvolutionAvailable") == true
    end

    local function request(form: string)
        if locked or remote == nil or not panel.Visible then
            return
        end
        locked = true
        remote:FireServer(form) -- only the branch name is sent
        task.delay(CLICK_LOCK_SECONDS, function()
            locked = false
        end)
    end

    tankButton.MouseButton1Click:Connect(function()
        request("TANK")
    end)
    gliderButton.MouseButton1Click:Connect(function()
        request("GLIDER")
    end)

    player:GetAttributeChangedSignal("EvolutionAvailable"):Connect(render)
    player:GetAttributeChangedSignal("EvolutionForm"):Connect(render)
    render()
    gui.Parent = playerGui

    setupFormTags()

    task.spawn(function()
        local remotes = ReplicatedStorage:WaitForChild("Remotes")
        remote = remotes:WaitForChild("RequestEvolution") :: RemoteEvent
    end)
end

return EvolutionUIController
