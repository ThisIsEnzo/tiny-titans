--!strict
-- Lightweight feedback for EXPEDITION DISCOVERIES (TT-P3-02), display only. These are per-life exploration
-- objectives, not permanent discoveries, so the wording says "Expedition" and never implies anything was
-- saved. Three small elements, no quest panel, no map, no arrows:
--   * a tiny "Expedition 2/6" counter in the top-left corner;
--   * a persistent one-line hint under it with the clue for the next place (or a completed message),
--     driven by the server-owned Player attributes "Discoveries", "DiscoveryTotal" and "DiscoveryClue".
--     Attributes replicate with the player, so the hint is correct from the first frame, after a
--     respawn and after a reset, and never depends on an event that could arrive before this script;
--   * a short toast when the server sends DiscoveryFound: which place, the Biomass it gave (if any) and
--     the next clue.
-- The client never asks for or grants anything; malformed events are ignored or shown as safe text.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Discovery = require(Shared:WaitForChild("Discovery") :: ModuleScript)

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

local function buildGui(): (ScreenGui, TextLabel, TextLabel, Frame, TextLabel)
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

    -- Persistent hint under the counter: wraps to two lines, readable on a phone.
    local hint = makeLabel("Hint", 15)
    hint.Position = UDim2.new(0, 12, 0, 44)
    hint.Size = UDim2.new(0, 270, 0, 44)
    hint.BackgroundTransparency = 0.45
    hint.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    hint.TextXAlignment = Enum.TextXAlignment.Left
    hint.Visible = false
    hint.Parent = gui
    roundCorners(hint, 8)
    local hintPadding = Instance.new("UIPadding")
    hintPadding.PaddingLeft = UDim.new(0, 8)
    hintPadding.PaddingRight = UDim.new(0, 8)
    hintPadding.Parent = hint

    local toast = Instance.new("Frame")
    toast.Name = "Toast"
    toast.AnchorPoint = Vector2.new(0.5, 0)
    toast.Position = UDim2.new(0.5, 0, 0.26, 0) -- below the top-left counter and hint, also in landscape
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
    return gui, counter, hint, toast, text
end

function DiscoveryUIController.Init()
    if initialized then
        return
    end
    initialized = true

    local player = Players.LocalPlayer
    local gui, counter, hint, toast, toastText = buildGui()
    gui.Parent = player:WaitForChild("PlayerGui")

    -- Counter and hint are both rebuilt from the three server-owned attributes, so any one of them
    -- changing (or all being set before this script runs) always ends in a consistent display.
    local function refresh()
        local count: any = player:GetAttribute("Discoveries")
        local total: any = player:GetAttribute("DiscoveryTotal")
        local clue: any = player:GetAttribute("DiscoveryClue")
        local totalNumber = wholeNumber(total, 0)
        counter.Visible = totalNumber > 0
        counter.Text = string.format("Expedition %d/%d", math.min(wholeNumber(count, 0), totalNumber), totalNumber)
        local hintText = Discovery.FormatHint(clue, count, total)
        hint.Visible = hintText ~= nil
        hint.Text = hintText or ""
    end
    for _, attribute in { "Discoveries", "DiscoveryTotal", "DiscoveryClue" } do
        player:GetAttributeChangedSignal(attribute):Connect(refresh)
    end
    refresh()

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
            local title = "EXPEDITION FIND: " .. cleanText(payload.name, "A new place")
            local reward = if biomass > 0 then string.format("+%d Biomass", biomass) else "No more Biomass to gain"
            local lines = { title, string.format("%s  (%d/%d)", reward, count, total) }
            if type(payload.nextClue) == "string" and payload.nextClue ~= "" then
                table.insert(lines, "Next: " .. cleanText(payload.nextClue, ""))
            elseif count >= total and total > 0 then
                table.insert(lines, "Every expedition place found this life!")
            end
            showToast(table.concat(lines, "\n"))
        end)
    end)
end

return DiscoveryUIController
