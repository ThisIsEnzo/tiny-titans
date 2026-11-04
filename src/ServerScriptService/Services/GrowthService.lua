--!strict
-- Applies the visual growth stage to each player's R15 character.
-- Only the body scale values change; no collision/physics rules are altered
-- beyond what R15 scaling does. R6 characters are not scaled (warned once).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config") :: ModuleScript)
local Growth = require(Shared:WaitForChild("Growth") :: ModuleScript)

local GrowthService = {}

local SCALE_VALUE_NAMES = { "BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale" }

local playerData: any = nil
local warnedRig = false

local function applyScale(character: Model, scale: number)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid == nil then
        return
    end
    if humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        if not warnedRig then
            warnedRig = true
            warn("[GrowthService] Character is not R15; growth scaling skipped. Set Avatar Type to R15.")
        end
        return
    end
    for _, name in SCALE_VALUE_NAMES do
        local existing = humanoid:FindFirstChild(name)
        local value: NumberValue
        if existing ~= nil and existing:IsA("NumberValue") then
            value = existing
        else
            value = Instance.new("NumberValue")
            value.Name = name
            value.Parent = humanoid
        end
        value.Value = scale
    end
end

local function applyForPlayer(player: Player)
    local character = player.Character
    if character == nil then
        return
    end
    local stage = playerData.GetStageIndex(player)
    applyScale(character, Growth.GetScale(stage, Config.GrowthStages))
end

local function onPlayerAdded(player: Player)
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("Humanoid", 10) -- bounded: the character may be removed meanwhile
        applyForPlayer(player)
    end)
    -- Avatar appearance loading can reset scale values, so apply again afterwards.
    player.CharacterAppearanceLoaded:Connect(function()
        applyForPlayer(player)
    end)
    if player.Character ~= nil then
        task.spawn(applyForPlayer, player)
    end
end

-- playerDataService must already be initialised.
function GrowthService.Init(playerDataService: any)
    playerData = playerDataService
    playerDataService.ProgressChanged:Connect(function(player: Player)
        applyForPlayer(player)
    end)
    Players.PlayerAdded:Connect(onPlayerAdded)
    for _, player in Players:GetPlayers() do
        onPlayerAdded(player)
    end
end

return GrowthService
