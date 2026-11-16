--!strict
-- Lightweight discovery feedback (TT-P3-02), display only. Two small elements, no quest panel, no map,
-- no arrows:
--   * a tiny "Discoveries 2/6" counter in the top-left corner, driven by the server-owned Player
--     attributes "Discoveries" and "DiscoveryTotal";
--   * a short toast when the server sends DiscoveryFound: what was discovered, the Biomass it gave
--     (if any) and a one-line clue about what to explore next.
-- The client never asks for or grants anything; malformed events are ignored or shown as safe text.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DiscoveryUIController = {}

local GUI_NAME = "Discovery"
local TOAST_SECONDS = 6
local MAX_TEXT = 90

local initialized = false

local function roundCorners(instance: Instance, radius: number)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
end

local function makeLabel(name: string, maxTextSize: number): TextLabel
    local label = Instance.new("TextLabel")
    label.Name = name
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.TextWrapped = true
    local limit = Instance.new("UITextSizeConstraint")
    limit.MinTextSize = 11
    limit.MaxTextSize = maxTextSize
    limit.Parent = label
    return label
end

local function wholeNumber(value: any, fallback: number): number
    if type(value) == "number" and value == value and value >= 0 and value < 1e6 then
        return math.floor(value)
    end
    return fallback
end

local function cleanText(value: any, fallback: string): string
    if type(value) == "string" and value ~= "" then
        return string.sub(value, 1, MAX_TEXT)
    end
    return fallback
end

local function buildGui(): (ScreenGui, TextLabel, Frame, TextLabel)
    local gui = Instance.new("ScreenGui")
    gui.Name = GUI_NAME
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 6
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local counter = makeLabel("Counter", 18)
    counter.AnchorPoint = Vector2.new(0, 0)
    counter.Position = UDim2.new(0, 12, 0, 12)
    counter.Size = UDim2.new(0, 150, 0, 26)
    counter.BackgroundTransparency = 0.45
    counter.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    counter.Visible = false
    counter.Parent = gui
    roundCorners(counter, 8)

    local toast = Instance.new("Frame")
    toast.Name = "Toast"
    toast.AnchorPoint = Vector2.new(0.5, 0)
    toast.Position = UDim2.new(0.5, 0, 0.17, 0)
    toast.Size = UDim2.new(0.5, 0, 0, 84)
    toast.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    toast.BackgroundTransparency = 0.15
    toast.BorderSizePixel = 0
    toast.Visible = false
    toast.Parent = gui
    roundCorners(toast, 10)
    local size = Instance.new("UISizeConstraint")
    size.MinSize = Vector2.new(280, 72)
    size.MaxSize = Vector2.new(520, 96)
    size.Parent = toast
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(140, 240, 200)
    stroke.Transparency = 0.35
    stroke.Parent = toast

    local text = makeLabel("Text", 20)
    text.Position = UDim2.fromScale(0.04, 0.06)
    text.Size = UDim2.fromScale(0.92, 0.88)
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.Parent = toast
    return gui, counter, toast, text
end

function DiscoveryUIController.Init()
    if initialized then
        return
    end
    initialized = true

    local player = Players.LocalPlayer
    local gui, counter, toast, toastText = buildGui()
    gui.Parent = player:WaitForChild("PlayerGui")

    local function refreshCounter()
        local count: any = player:GetAttribute("Discoveries")
        local total: any = player:GetAttribute("DiscoveryTotal")
        local totalNumber = wholeNumber(total, 0)
        counter.Visible = totalNumber > 0
        counter.Text = string.format("Discoveries %d/%d", math.min(wholeNumber(count, 0), totalNumber), totalNumber)
    end
    player:GetAttributeChangedSignal("Discoveries"):Connect(refreshCounter)
    player:GetAttributeChangedSignal("DiscoveryTotal"):Connect(refreshCounter)
    refreshCounter()

    local toastId = 0
    local function showToast(text: string)
        toastId += 1
        local id = toastId
        toastText.Text = text
        toast.Visible = true
        task.delay(TOAST_SECONDS, function()
            if toastId == id then -- a newer toast keeps the frame
                toast.Visible = false
            end
        end)
    end
    -- A new character is a new life: drop any toast left over from the previous one.
    player.CharacterAdded:Connect(function()
        toastId += 1
        toast.Visible = false
    end)

    task.spawn(function()
        local remotes = ReplicatedStorage:WaitForChild("Remotes")
        local found = remotes:WaitForChild("DiscoveryFound") :: RemoteEvent
        found.OnClientEvent:Connect(function(payload: any)
            if type(payload) ~= "table" then
                return
            end
            local biomass = wholeNumber(payload.biomass, 0)
            local count = wholeNumber(payload.count, 0)
            local total = math.max(wholeNumber(payload.total, count), count)
            local title = "DISCOVERED: " .. cleanText(payload.name, "A new place")
            local reward = if biomass > 0 then string.format("+%d Biomass", biomass) else "No more Biomass to gain"
            local lines = { title, string.format("%s  (%d/%d)", reward, count, total) }
            if type(payload.nextClue) == "string" and payload.nextClue ~= "" then
                table.insert(lines, "Next: " .. cleanText(payload.nextClue, ""))
            elseif count >= total and total > 0 then
                table.insert(lines, "You found everything in this life!")
            end
            showToast(table.concat(lines, "\n"))
        end)
    end)
end

return DiscoveryUIController
