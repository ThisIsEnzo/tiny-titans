--!strict
-- Custom creature appearance (P2-05). The R15 Humanoid stays the movement, physics and lifecycle
-- controller; for forms that have a visual spec (today only BABY_BUG) the default avatar is made
-- invisible and a cosmetic model, built from BabyBugSpec by CreatureModelBuilder, is welded to the
-- HumanoidRootPart. Forms without a spec (TANK, GLIDER) keep the normal avatar: their models do not
-- exist yet, and nothing here pretends they do.
--
-- Rules:
--   * Server authoritative: the form is the server-owned Player attribute EvolutionForm; no remote.
--   * At most one visual per character. Repeated events re-run `evaluate`, which is idempotent.
--   * Hiding: every BasePart/Decal of the character (accessories, face, body) gets Transparency 1,
--     the original values are remembered and restored if the form later has no visual. New parts
--     added by appearance loading are hidden as they arrive (DescendantAdded) and once more on
--     CharacterAppearanceLoaded. Nothing is destroyed: Humanoid and the rig stay intact.
--   * Growth: the visual follows the Humanoid's BodyHeightScale value that GrowthService already
--     tweens (GrowthService.SubscribeScale), so thresholds, tween time and the "absolute, never
--     compounding" rule stay in one place. Before that value is known the scale comes from the same
--     Config.GrowthStages via Growth.GetScale.
--   * Lifecycle: state is per player and per character; delayed callbacks check the character and a
--     session number, so an old character can never modify a newer one. On Humanoid.Died the visual
--     is destroyed (death breaks the joints anyway; this avoids falling debris) and the body stays
--     hidden until the character is replaced. This service never detects death for gameplay and never
--     spawns characters; LifeService and RespawnService stay authoritative.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config") :: ModuleScript)
local Growth = require(Shared:WaitForChild("Growth") :: ModuleScript)
local CreatureDefinitions = require(Shared:WaitForChild("CreatureDefinitions") :: ModuleScript)
local BabyBugSpec = require(Shared:WaitForChild("BabyBugSpec") :: ModuleScript)
local CreatureModelBuilder = require(Shared:WaitForChild("CreatureModelBuilder") :: ModuleScript)

local CreatureAppearanceService = {}

-- Form id -> visual spec. Add Tank/Glider here when their models exist.
local specs: { [string]: any } = {
    [CreatureDefinitions.StarterFormId] = BabyBugSpec,
}

type Visual = {
    formId: string,
    spec: any,
    model: Model,
    rootMotor: Motor6D,
    connections: { RBXScriptConnection },
    scaleConnection: RBXScriptConnection?,
}

type State = {
    character: Model,
    humanoid: Humanoid?,
    root: BasePart?,
    ready: boolean, -- Humanoid and HumanoidRootPart found; evaluation allowed
    dead: boolean,
    visual: Visual?,
    originals: { [Instance]: number }, -- original Transparency of hidden instances
    hideConnection: RBXScriptConnection?,
    scaleSource: NumberValue?, -- the Humanoid scale value GrowthService is driving
    connections: { RBXScriptConnection }, -- character-level connections
}

local playerData: any = nil
local growth: any = nil
local states: { [Player]: State } = {}
local playerConnections: { [Player]: { RBXScriptConnection } } = {}
local warnedRig = false

local function readForm(player: Player): string
    local form = player:GetAttribute("EvolutionForm")
    if type(form) == "string" and form ~= "" then
        return form
    end
    return CreatureDefinitions.StarterFormId -- attribute not set yet: players start as the starter
end

local function disconnectAll(connections: { RBXScriptConnection })
    for _, connection in connections do
        connection:Disconnect()
    end
    table.clear(connections)
end

-- Hiding ---------------------------------------------------------------------------------------

local function hideInstance(state: State, instance: Instance)
    if not (instance:IsA("BasePart") or instance:IsA("Decal")) then
        return
    end
    local visual = state.visual
    if visual ~= nil and visual.model:IsAncestorOf(instance) then
        return -- never hide the creature's own parts
    end
    local item = instance :: any -- BasePart and Decal both have Transparency
    if state.originals[instance] == nil then
        state.originals[instance] = item.Transparency
    end
    item.Transparency = 1
end

local function hideCharacter(state: State)
    for _, descendant in state.character:GetDescendants() do
        hideInstance(state, descendant)
    end
end

local function restoreCharacter(state: State)
    if state.hideConnection ~= nil then
        state.hideConnection:Disconnect()
        state.hideConnection = nil
    end
    for instance, original in state.originals do
        if instance.Parent ~= nil then
            (instance :: any).Transparency = original
        end
    end
    table.clear(state.originals)
end

-- Visual ---------------------------------------------------------------------------------------

local function currentScale(player: Player, state: State): number
    local source = state.scaleSource
    if source ~= nil and source.Parent ~= nil then
        return source.Value
    end
    return Growth.GetScale(playerData.GetStageIndex(player), Config.GrowthStages)
end

-- Sets the model's absolute scale and re-seats the root joint on the ground. ScaleTo is absolute,
-- so repeating it cannot compound.
local function applyScale(state: State, scale: number)
    local visual = state.visual
    local humanoid = state.humanoid
    local root = state.root
    if visual == nil or humanoid == nil or root == nil then
        return
    end
    local clamped = math.max(scale, 0.05)
    if math.abs(visual.model:GetScale() - clamped) > 1e-4 then
        visual.model:ScaleTo(clamped) -- also scales the root joint's C0; reset below
    end
    visual.rootMotor.C0 = CFrame.new(0, visual.spec.RootOffsetY(visual.model:GetScale(), humanoid.HipHeight, root.Size.Y), 0)
end

local function bindScale(state: State)
    local visual = state.visual
    local source = state.scaleSource
    if visual == nil or source == nil then
        return
    end
    if visual.scaleConnection ~= nil then
        visual.scaleConnection:Disconnect()
        visual.scaleConnection = nil
    end
    applyScale(state, source.Value)
    visual.scaleConnection = source.Changed:Connect(function(value: number)
        applyScale(state, value)
    end)
end

-- Destroys the visual. restore = true also shows the normal avatar again (form changed); false
-- keeps it hidden (the character died and is about to be replaced).
local function removeVisual(state: State, restore: boolean)
    local visual = state.visual
    if visual ~= nil then
        state.visual = nil
        disconnectAll(visual.connections)
        if visual.scaleConnection ~= nil then
            visual.scaleConnection:Disconnect()
        end
        visual.model:Destroy()
    end
    if restore then
        restoreCharacter(state)
    end
end

local function applyVisual(player: Player, state: State, formId: string, spec: any)
    if state.visual ~= nil and state.visual.formId == formId then
        return -- already has exactly this visual
    end
    local humanoid = state.humanoid
    local root = state.root
    if humanoid == nil or root == nil then
        return
    end
    removeVisual(state, false)

    -- GrowthService may have applied this character's scale before this state existed (its callback
    -- then found nothing to update): catch up now instead of missing the growth tween.
    if state.scaleSource == nil and growth ~= nil then
        state.scaleSource = growth.GetAppliedScaleValue(player, state.character)
    end

    hideCharacter(state)
    if state.hideConnection == nil then
        state.hideConnection = state.character.DescendantAdded:Connect(function(instance: Instance)
            hideInstance(state, instance)
        end)
    end

    local model, rootPart = CreatureModelBuilder.Build(spec)
    local scale = currentScale(player, state)
    model:ScaleTo(math.max(scale, 0.05))
    local rootMotor = CreatureModelBuilder.AttachRoot(spec, rootPart, root)
    local visual: Visual = {
        formId = formId,
        spec = spec,
        model = model,
        rootMotor = rootMotor,
        connections = {},
        scaleConnection = nil,
    }
    state.visual = visual
    rootMotor.C0 = CFrame.new(0, spec.RootOffsetY(model:GetScale(), humanoid.HipHeight, root.Size.Y), 0)

    model:SetAttribute(spec.FormAttribute, formId)
    model.Parent = state.character
    CollectionService:AddTag(model, spec.Tag)

    -- Re-seat the root when the Humanoid's hip height changes (scaling, appearance loading).
    table.insert(visual.connections, humanoid:GetPropertyChangedSignal("HipHeight"):Connect(function()
        applyScale(state, currentScale(player, state))
    end))
    bindScale(state)
end

-- Makes the character's appearance match its server-owned form. Idempotent.
local function evaluate(player: Player)
    local state = states[player]
    if state == nil or not state.ready or state.dead then
        return
    end
    local humanoid = state.humanoid
    if humanoid == nil or humanoid.Health <= 0 or state.character.Parent == nil then
        return
    end
    local formId = readForm(player)
    local spec = specs[formId]
    if spec ~= nil then
        if humanoid.RigType ~= Enum.HumanoidRigType.R15 then
            if not warnedRig then
                warnedRig = true
                warn("[CreatureAppearanceService] Character is not R15; custom appearance skipped.")
            end
            return
        end
        applyVisual(player, state, formId, spec)
    else
        removeVisual(state, true) -- evolved form without a model yet: normal avatar
    end
end

-- Lifecycle ------------------------------------------------------------------------------------

local function cleanupCharacter(player: Player)
    local state = states[player]
    if state == nil then
        return
    end
    states[player] = nil
    removeVisual(state, false) -- the old character is going away; no need to restore it
    if state.hideConnection ~= nil then
        state.hideConnection:Disconnect()
        state.hideConnection = nil
    end
    disconnectAll(state.connections)
    table.clear(state.originals)
end

local function onCharacterAdded(player: Player, character: Model)
    cleanupCharacter(player) -- whatever belonged to a previous character
    local state: State = {
        character = character,
        humanoid = nil,
        root = nil,
        ready = false,
        dead = false,
        visual = nil,
        originals = {},
        hideConnection = nil,
        scaleSource = nil,
        connections = {},
    }
    states[player] = state

    local humanoid = character:WaitForChild("Humanoid", 10)
    local root = character:WaitForChild("HumanoidRootPart", 10)
    -- The waits yield: only continue if this is still the player's current character.
    if states[player] ~= state or player.Character ~= character or player.Parent ~= Players then
        return
    end
    if humanoid == nil or not humanoid:IsA("Humanoid") or root == nil or not root:IsA("BasePart") then
        return
    end
    state.humanoid = humanoid
    state.root = root
    state.ready = true

    table.insert(state.connections, humanoid.Died:Connect(function()
        if states[player] ~= state then
            return
        end
        state.dead = true
        removeVisual(state, false)
    end))
    evaluate(player)
end

local function onPlayerAdded(player: Player)
    local connections: { RBXScriptConnection } = {}
    playerConnections[player] = connections
    table.insert(connections, player.CharacterAdded:Connect(function(character)
        onCharacterAdded(player, character)
    end))
    table.insert(connections, player.CharacterRemoving:Connect(function()
        cleanupCharacter(player)
    end))
    -- Appearance loading can add accessories and clothing late: hide them again if needed.
    table.insert(connections, player.CharacterAppearanceLoaded:Connect(function()
        local state = states[player]
        if state ~= nil and state.visual ~= nil then
            hideCharacter(state)
        end
    end))
    table.insert(connections, player:GetAttributeChangedSignal("EvolutionForm"):Connect(function()
        evaluate(player)
    end))
    if player.Character ~= nil then
        task.spawn(onCharacterAdded, player, player.Character)
    end
end

-- playerDataService and growthService must already be initialised. Init after EvolutionService and
-- before RespawnService, so the first character is already covered.
function CreatureAppearanceService.Init(playerDataService: any, growthService: any)
    playerData = playerDataService
    growth = growthService
    growthService.SubscribeScale(function(player: Player, character: Model, scaleValue: NumberValue)
        local state = states[player]
        if state == nil or state.character ~= character then
            return -- stale: belongs to a different character
        end
        state.scaleSource = scaleValue
        bindScale(state)
    end)
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(function(player)
        cleanupCharacter(player)
        local connections = playerConnections[player]
        if connections ~= nil then
            disconnectAll(connections)
        end
        playerConnections[player] = nil
    end)
    for _, player in Players:GetPlayers() do
        onPlayerAdded(player)
    end
end

return CreatureAppearanceService
