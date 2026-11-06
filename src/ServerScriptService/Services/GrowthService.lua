--!strict
-- Applies the visual growth stage to each player's R15 character.
-- Only the four body scale values change; no collision/physics rules are altered
-- beyond what R15 scaling does. R6 characters are not scaled (warned once).
--
-- Targets are ABSOLUTE scales from Config.GrowthStages, never multipliers, so repeating an
-- update cannot compound. A new character (spawn/respawn) is set to its stage's scale
-- immediately; crossing a stage threshold on a living character tweens the scale values
-- over Config.GrowthTweenSeconds. At most one set of tweens exists per player: a new
-- target cancels the previous tweens, and a repeated identical target is ignored.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config") :: ModuleScript)
local Growth = require(Shared:WaitForChild("Growth") :: ModuleScript)

local GrowthService = {}

local SCALE_VALUE_NAMES = { "BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale" }

type ScaleState = {
    character: Model?, -- the character the target below was applied to
    target: number?, -- absolute scale last applied to that character
    tweens: { Tween },
}

local playerData: any = nil
local warnedRig = false
local scaleStates: { [Player]: ScaleState } = {}

local function cancelTweens(state: ScaleState)
    for _, tween in state.tweens do
        tween:Cancel()
    end
    table.clear(state.tweens)
end

-- Returns the character's four scale values. Missing values are created only when
-- createMissing is true (after the appearance has loaded or timed out), so the engine's
-- own values are never duplicated by a race at spawn.
local function getScaleValues(humanoid: Humanoid, createMissing: boolean): { NumberValue }?
    local values: { NumberValue } = {}
    for _, name in SCALE_VALUE_NAMES do
        local existing = humanoid:FindFirstChild(name)
        if existing ~= nil and existing:IsA("NumberValue") then
            table.insert(values, existing)
        elseif createMissing then
            local value = Instance.new("NumberValue")
            value.Name = name
            value.Value = 1
            value.Parent = humanoid
            table.insert(values, value)
        else
            return nil
        end
    end
    return values
end

-- instant: set the scale at once (new character or appearance reload); otherwise tween.
local function updateScale(player: Player, instant: boolean, createMissing: boolean)
    if player.Parent ~= Players then
        return -- delayed callbacks must not re-create state for a player who left
    end
    local character = player.Character
    if character == nil then
        return
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid == nil then
        return
    end
    if humanoid.Health <= 0 then
        return -- a dead body is not rescaled (for example after the reset on death)
    end
    if humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        if not warnedRig then
            warnedRig = true
            warn("[GrowthService] Character is not R15; growth scaling skipped. Set Avatar Type to R15.")
        end
        return
    end

    local state = scaleStates[player]
    if state == nil then
        state = { character = nil, target = nil, tweens = {} }
        scaleStates[player] = state
    end
    if state.character ~= character then
        -- New character (respawn): forget the old one's state so nothing carries over.
        cancelTweens(state)
        state.character = character
        state.target = nil
    end

    local target = Growth.GetScale(playerData.GetStageIndex(player), Config.GrowthStages)
    if not instant and not Growth.ShouldUpdateScale(state.target, target) then
        return -- already at (or tweening to) this target
    end

    local values = getScaleValues(humanoid, createMissing)
    if values == nil then
        return -- appearance not loaded yet; CharacterAppearanceLoaded (or the fallback) applies it
    end

    cancelTweens(state)
    if instant or state.target == nil then
        for _, value in values do
            value.Value = target
        end
    else
        local info = TweenInfo.new(Config.GrowthTweenSeconds, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        for _, value in values do
            local tween = TweenService:Create(value, info, { Value = target })
            table.insert(state.tweens, tween)
            tween:Play()
        end
    end
    state.target = target
end

local function onPlayerAdded(player: Player)
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("Humanoid", 10) -- bounded: the character may be removed meanwhile
        updateScale(player, true, false) -- applies now only if the scale values already exist
        -- Fallback: if the appearance never finishes loading, still scale the character.
        task.delay(Config.AppearanceFallbackSeconds, function()
            local state = scaleStates[player]
            if player.Character == character and (state == nil or state.character ~= character or state.target == nil) then
                updateScale(player, true, true)
            end
        end)
    end)
    -- Appearance loading can reset the scale values, so set them again afterwards.
    player.CharacterAppearanceLoaded:Connect(function()
        updateScale(player, true, true)
    end)
    player.CharacterRemoving:Connect(function()
        local state = scaleStates[player]
        if state ~= nil then
            cancelTweens(state)
            state.character = nil
            state.target = nil
        end
    end)
    if player.Character ~= nil then
        task.spawn(updateScale, player, true, true)
    end
end

-- Forgets the player's growth visuals state for a new life (called by ResetService when a
-- life ends): cancels running tweens and the applied target. The next character, or the
-- current one if it is alive, is set to the new life's stage scale at once. Idempotent.
function GrowthService.ResetLife(player: Player)
    local state = scaleStates[player]
    if state ~= nil then
        cancelTweens(state)
        state.target = nil
    end
end

-- playerDataService must already be initialised.
function GrowthService.Init(playerDataService: any)
    playerData = playerDataService
    playerDataService.ProgressChanged:Connect(function(player: Player)
        updateScale(player, false, false)
    end)
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(function(player)
        local state = scaleStates[player]
        if state ~= nil then
            cancelTweens(state)
        end
        scaleStates[player] = nil
    end)
    for _, player in Players:GetPlayers() do
        onPlayerAdded(player)
    end
end

return GrowthService
