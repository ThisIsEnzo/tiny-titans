--!strict
-- Minimal life recap (P1-04, hardened in P1-05). Shown only when the server sends LifeRecap after
-- a life ended: life duration and a BEGIN NEW LIFE button. Duration is server-derived and display
-- only. The button sends RequestBeginNewLife with NO values; the server decides whether a new life
-- may begin. The recap hides when a new character spawns (the new life), not when the button is
-- pressed, and the button re-enables after a timeout if nothing happened, so the player can never
-- get stuck.
-- Each recap carries the server's lifeId. Older, already dismissed or malformed recaps are
-- ignored (Respawn.ShouldShowRecap), so a late or replayed recap can neither overwrite a newer
-- one nor reappear after the new character spawned. lifeId 0 is the "first spawn failed" notice.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Respawn = require(Shared:WaitForChild("Respawn") :: ModuleScript)

local LifeRecapController = {}

local GUI_NAME = "LifeRecap"
local RETRY_SECONDS = 6
local BUTTON_TEXT = "BEGIN NEW LIFE"


local initialized = false

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
    limit.MinTextSize = 12
    limit.MaxTextSize = maxTextSize
    limit.Parent = label
    return label
end

local function roundCorners(instance: Instance, radius: number)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
end

local function buildGui(): (ScreenGui, TextLabel, TextLabel, TextButton)
    local gui = Instance.new("ScreenGui")
    gui.Name = GUI_NAME
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 20
    gui.Enabled = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Dim layer: marks the life as over and keeps clicks off the world behind it.
    local dim = Instance.new("Frame")
    dim.Name = "Dim"
    dim.Size = UDim2.fromScale(1, 1)
    dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    dim.BackgroundTransparency = 0.45
    dim.BorderSizePixel = 0
    dim.Active = true
    dim.Parent = gui

    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.fromScale(0.5, 0.5)
    panel.Size = UDim2.fromScale(0.5, 0.62)
    panel.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    panel.BackgroundTransparency = 0.05
    panel.BorderSizePixel = 0
    panel.Parent = dim
    roundCorners(panel, 12)
    local panelLimit = Instance.new("UISizeConstraint")
    panelLimit.MinSize = Vector2.new(300, 270)
    panelLimit.MaxSize = Vector2.new(480, 360)
    panelLimit.Parent = panel
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.7
    stroke.Parent = panel

    local title = makeLabel("Title", UDim2.fromScale(0.05, 0.04), UDim2.fromScale(0.9, 0.15), 30)
    title.Text = "LIFE ENDED"
    title.Parent = panel

    local duration = makeLabel("Duration", UDim2.fromScale(0.05, 0.22), UDim2.fromScale(0.9, 0.1), 20)
    duration.Font = Enum.Font.Gotham
    duration.Parent = panel


    local button = Instance.new("TextButton")
    button.Name = "BeginButton"
    button.AnchorPoint = Vector2.new(0.5, 0)
    button.Position = UDim2.fromScale(0.5, 0.68)
    button.Size = UDim2.fromScale(0.7, 0.24)
    button.BackgroundColor3 = Color3.fromRGB(60, 150, 100)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Text = BUTTON_TEXT
    button.Parent = panel
    roundCorners(button, 10)
    local buttonLimit = Instance.new("UISizeConstraint")
    buttonLimit.MinSize = Vector2.new(180, 56) -- comfortable touch target
    buttonLimit.Parent = button
    local textLimit = Instance.new("UITextSizeConstraint")
    textLimit.MinTextSize = 14
    textLimit.MaxTextSize = 26
    textLimit.Parent = button

    return gui, title, duration, button
end

function LifeRecapController.Init()
    if initialized then
        return
    end
    initialized = true

    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local gui, titleLabel, durationLabel, button = buildGui()

    local requestRemote: RemoteEvent? = nil
    local pending = false
    local attempt = 0
    local shownLifeId = -1 -- recap on screen (-1 = none)
    local dismissedLifeId = -1 -- highest recap already dismissed by a new character

    local function setPending(value: boolean)
        pending = value
        button.Active = not value
        button.AutoButtonColor = not value
        button.BackgroundColor3 = if value then Color3.fromRGB(70, 74, 86) else Color3.fromRGB(60, 150, 100)
        button.Text = if value then "Starting..." else BUTTON_TEXT
    end

    local function hide()
        attempt += 1
        dismissedLifeId = math.max(dismissedLifeId, shownLifeId)
        shownLifeId = -1
        gui.Enabled = false
        setPending(false)
    end

    button.Activated:Connect(function()
        if pending or requestRemote == nil or not gui.Enabled then
            return
        end
        setPending(true)
        attempt += 1
        local id = attempt
        requestRemote:FireServer() -- no values: the server owns the decision
        task.delay(RETRY_SECONDS, function()
            if gui.Enabled and pending and attempt == id then
                setPending(false) -- nothing happened; allow another try
            end
        end)
    end)

    -- A new character means a new life: the recap is over.
    player.CharacterAdded:Connect(hide)

    gui.Parent = playerGui

    task.spawn(function()
        local remotes = ReplicatedStorage:WaitForChild("Remotes")
        local request = remotes:WaitForChild("RequestBeginNewLife") :: RemoteEvent
        local recap = remotes:WaitForChild("LifeRecap") :: RemoteEvent
        recap.OnClientEvent:Connect(function(summary: any)
            -- Display only; malformed data is ignored or falls back to safe text.
            if type(summary) ~= "table" then
                return
            end
            local recapLifeId: any = summary.lifeId
            if not Respawn.ShouldShowRecap(recapLifeId, dismissedLifeId, shownLifeId) then
                return -- older, already dismissed, or malformed
            end
            local seconds: any = summary.durationSeconds
            local sameRecap = recapLifeId == shownLifeId
            shownLifeId = recapLifeId :: number
            titleLabel.Text = if recapLifeId == 0 then "SPAWN FAILED" else "LIFE ENDED"
            durationLabel.Text = "Life duration: " .. Respawn.FormatDuration(seconds)
            if not sameRecap then
                setPending(false) -- a replay of the recap already on screen must not undo a pending press
                attempt += 1
            end
            gui.Enabled = true
        end)
        requestRemote = request
        local ready = remotes:WaitForChild("LifeRecapReady") :: RemoteEvent
        ready:FireServer() -- handshake: the server replays a recap if one arrived before this listener was ready
    end)
end

return LifeRecapController
