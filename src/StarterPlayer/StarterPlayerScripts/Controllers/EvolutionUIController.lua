--!strict
-- Evolution UI. Display-only except for one request: when the server marks evolution
-- available, the player picks TANK or GLIDER (local highlight only), then presses Confirm,
-- which fires RequestEvolution with only the branch name. The panel, form badge and
-- success toast are driven by the server-owned Player attributes "EvolutionAvailable" and
-- "EvolutionForm"; the UI never assumes a request succeeded. The server's
-- EvolutionResult(reason) reply, sent to this player only, just explains a rejection.
-- Also shows an overhead form tag for evolved players so other clients can see it.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config") :: ModuleScript)

local EvolutionUIController = {}

local GUI_NAME = "EvolutionHud"
local TAG_NAME = "FormTag"
local RESPONSE_TIMEOUT_SECONDS = 3
local TOAST_SECONDS = 3

-- Honest descriptions: the forms differ only by their ability. Tank's shell is visual only.
local FORM_INFO: { [string]: { role: string, ability: string, color: Color3 } } = {
    TANK = {
        role = "Defensive",
        ability = "Shell [" .. Config.AbilityKey .. "]: protective bubble (visual only for now)",
        color = Color3.fromRGB(70, 110, 160),
    },
    GLIDER = {
        role = "Mobility",
        ability = "Air Glide [" .. Config.AbilityKey .. "]: slow your fall in the air",
        color = Color3.fromRGB(60, 150, 140),
    },
}

local RESULT_MESSAGES: { [string]: string } = {
    ThresholdNotReached = "Not enough Energy yet.",
    AlreadyEvolved = "You have already evolved.",
    InvalidForm = "That form is not available.",
    NoLivingCharacter = "Respawn first, then try again.",
}

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

local function makeFormCard(form: string, position: UDim2): (TextButton, UIStroke)
    local info = FORM_INFO[form]
    local card = Instance.new("TextButton")
    card.Name = form .. "Card"
    card.Position = position
    card.Size = UDim2.fromScale(0.44, 0.46)
    card.BackgroundColor3 = info.color
    card.AutoButtonColor = true
    card.Text = ""
    card.BorderSizePixel = 0
    roundCorners(card, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 0
    stroke.Parent = card

    local title = makeLabel("Title", UDim2.fromScale(0.06, 0.06), UDim2.fromScale(0.88, 0.26), 24, Enum.TextXAlignment.Center)
    title.Text = string.upper(displayName(form))
    title.Parent = card

    local role = makeLabel("Role", UDim2.fromScale(0.06, 0.32), UDim2.fromScale(0.88, 0.16), 15, Enum.TextXAlignment.Center)
    role.Font = Enum.Font.GothamMedium
    role.Text = info.role
    role.Parent = card

    local ability = makeLabel("Ability", UDim2.fromScale(0.06, 0.5), UDim2.fromScale(0.88, 0.44), 14, Enum.TextXAlignment.Center)
    ability.Font = Enum.Font.Gotham
    ability.TextWrapped = true
    ability.Text = info.ability
    ability.Parent = card
    return card, stroke
end

type Ui = {
    gui: ScreenGui,
    formLabel: TextLabel,
    panel: Frame,
    cards: { [string]: TextButton },
    strokes: { [string]: UIStroke },
    confirm: TextButton,
    status: TextLabel,
    toast: TextLabel,
}

local function buildGui(): Ui
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
    panel.Position = UDim2.fromScale(0.5, 0.42)
    panel.Size = UDim2.fromScale(0.5, 0.62)
    panel.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    panel.BackgroundTransparency = 0.1
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.Parent = gui
    roundCorners(panel, 12)
    local panelLimit = Instance.new("UISizeConstraint")
    panelLimit.MinSize = Vector2.new(320, 240)
    panelLimit.MaxSize = Vector2.new(560, 340)
    panelLimit.Parent = panel
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 200, 60)
    stroke.Thickness = 2
    stroke.Parent = panel

    local heading = makeLabel("Heading", UDim2.fromScale(0.05, 0.03), UDim2.fromScale(0.9, 0.12), 28, Enum.TextXAlignment.Center)
    heading.Text = "EVOLUTION READY"
    heading.TextColor3 = Color3.fromRGB(255, 200, 60)
    heading.Parent = panel

    local sub = makeLabel("Subheading", UDim2.fromScale(0.05, 0.15), UDim2.fromScale(0.9, 0.07), 15, Enum.TextXAlignment.Center)
    sub.Font = Enum.Font.Gotham
    sub.Text = "Pick a form, then confirm. The choice is final this session."
    sub.Parent = panel

    local cards: { [string]: TextButton } = {}
    local strokes: { [string]: UIStroke } = {}
    local tankCard, tankStroke = makeFormCard("TANK", UDim2.fromScale(0.04, 0.25))
    tankCard.Parent = panel
    cards.TANK = tankCard
    strokes.TANK = tankStroke
    local gliderCard, gliderStroke = makeFormCard("GLIDER", UDim2.fromScale(0.52, 0.25))
    gliderCard.Parent = panel
    cards.GLIDER = gliderCard
    strokes.GLIDER = gliderStroke

    local confirm = Instance.new("TextButton")
    confirm.Name = "ConfirmButton"
    confirm.Position = UDim2.fromScale(0.25, 0.74)
    confirm.Size = UDim2.fromScale(0.5, 0.14)
    confirm.BorderSizePixel = 0
    confirm.Font = Enum.Font.GothamBold
    confirm.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirm.TextScaled = true
    confirm.Text = ""
    confirm.Parent = panel
    roundCorners(confirm, 8)
    local confirmLimit = Instance.new("UITextSizeConstraint")
    confirmLimit.MinTextSize = 10
    confirmLimit.MaxTextSize = 20
    confirmLimit.Parent = confirm

    local status = makeLabel("Status", UDim2.fromScale(0.05, 0.9), UDim2.fromScale(0.9, 0.08), 14, Enum.TextXAlignment.Center)
    status.Font = Enum.Font.Gotham
    status.Parent = panel

    -- Short confirmation after a successful evolution.
    local toast = makeLabel("Toast", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), 22, Enum.TextXAlignment.Center)
    toast.BackgroundTransparency = 0.2
    toast.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    toast.AnchorPoint = Vector2.new(0.5, 0)
    toast.Position = UDim2.new(0.5, 0, 0.08, 0)
    toast.Size = UDim2.new(0.5, 0, 0, 44)
    toast.Visible = false
    toast.Parent = gui
    roundCorners(toast, 10)
    local toastLimit = Instance.new("UISizeConstraint")
    toastLimit.MinSize = Vector2.new(260, 36)
    toastLimit.MaxSize = Vector2.new(520, 52)
    toastLimit.Parent = toast

    return {
        gui = gui,
        formLabel = formLabel,
        panel = panel,
        cards = cards,
        strokes = strokes,
        confirm = confirm,
        status = status,
        toast = toast,
    }
end

-- Overhead tag so other clients can see evolved forms (display only).
local function setupFormTags()
    local labels: { [Player]: TextLabel } = {}
    local tracked: { [Player]: boolean } = {}

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
        if tracked[player] then
            return -- PlayerAdded and the initial loop can overlap; connect once per player
        end
        tracked[player] = true
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
        tracked[player] = nil
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
    local ui = buildGui()

    local remote: RemoteEvent? = nil
    local selected: string? = nil -- local highlight only; nothing is sent until Confirm
    local pending = false
    local requestId = 0
    local toastId = 0
    local lastForm = readForm(player)

    local function setStatus(text: string, isError: boolean)
        ui.status.Text = text
        ui.status.TextColor3 = if isError then Color3.fromRGB(255, 130, 120) else Color3.fromRGB(255, 255, 255)
    end

    local function refreshPanel()
        for form, stroke in ui.strokes do
            stroke.Thickness = if selected == form then 3 else 0
        end
        local canConfirm = selected ~= nil and not pending
        ui.confirm.Active = canConfirm
        ui.confirm.AutoButtonColor = canConfirm
        ui.confirm.BackgroundColor3 = if canConfirm then Color3.fromRGB(60, 150, 100) else Color3.fromRGB(70, 74, 86)
        if pending then
            ui.confirm.Text = "Evolving..."
        elseif selected ~= nil then
            ui.confirm.Text = "Evolve into " .. displayName(selected)
        else
            ui.confirm.Text = "Choose a form"
        end
    end

    local function showToast(text: string)
        toastId += 1
        local id = toastId
        ui.toast.Text = text
        ui.toast.Visible = true
        task.delay(TOAST_SECONDS, function()
            if toastId == id then
                ui.toast.Visible = false
            end
        end)
    end

    -- Everything shown comes from the server-owned attributes.
    local function render()
        local form = readForm(player)
        ui.formLabel.Text = "Form: " .. displayName(form)
        local available = player:GetAttribute("EvolutionAvailable") == true
        ui.panel.Visible = available
        if not available then
            selected = nil
            pending = false
            setStatus("", false)
        end
        if lastForm == Config.BaseForm and form ~= Config.BaseForm then
            showToast("You evolved into " .. displayName(form) .. "!")
        end
        lastForm = form
        refreshPanel()
    end

    local function confirm()
        if pending or selected == nil or remote == nil or not ui.panel.Visible then
            return
        end
        pending = true
        requestId += 1
        local id = requestId
        setStatus("Sending...", false)
        refreshPanel()
        remote:FireServer(selected) -- only the branch name is sent
        task.delay(RESPONSE_TIMEOUT_SECONDS, function()
            if pending and requestId == id then
                pending = false
                setStatus("No response. Please try again.", true)
                refreshPanel()
            end
        end)
    end

    for form, card in ui.cards do
        card.Activated:Connect(function()
            if pending then
                return
            end
            selected = form
            setStatus("", false)
            refreshPanel()
        end)
    end
    ui.confirm.Activated:Connect(confirm)

    player:GetAttributeChangedSignal("EvolutionAvailable"):Connect(render)
    player:GetAttributeChangedSignal("EvolutionForm"):Connect(render)
    render()
    ui.gui.Parent = playerGui

    setupFormTags()

    task.spawn(function()
        local remotes = ReplicatedStorage:WaitForChild("Remotes")
        local request = remotes:WaitForChild("RequestEvolution") :: RemoteEvent
        local result = remotes:WaitForChild("EvolutionResult") :: RemoteEvent
        result.OnClientEvent:Connect(function(reason: any)
            -- Only explains the outcome; the panel itself follows the replicated attributes.
            if type(reason) ~= "string" then
                return
            end
            pending = false
            if reason ~= "Ok" then
                setStatus(RESULT_MESSAGES[reason] or "Could not evolve. Please try again.", true)
            end
            refreshPanel()
        end)
        remote = request
    end)
end

return EvolutionUIController
