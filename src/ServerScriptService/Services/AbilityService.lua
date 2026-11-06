--!strict
-- Server-authoritative abilities: Tank Defensive Shell and Glider Air Glide.
-- One RemoteEvent, RequestAbility(abilityId: string). The client sends only an ability
-- identifier; the server derives the player from the remote, checks the identifier
-- against the player's server-owned form, validates character/state, and owns all
-- timing. Replicated Player attributes (workspace:GetServerTimeNow() timestamps, 0 = never):
--   Tank:   "ShellActiveUntil", "ShellReadyAt"   (VISUAL ONLY: no damage/health effects)
--   Glider: "GliderActiveUntil", "GliderReadyAt"
-- Cooldowns run from activation and persist across death and respawn (session only).
-- Requests are rate limited per player (Config.AbilityRequestInterval) before any other work.
--
-- Glide physics: a server-created VectorForce (+ Attachment) on HumanoidRootPart cancels
-- Config.GliderGravityCompensation of the character's weight, so gravity still wins.
-- Network ownership is NOT changed: the player's client keeps simulating its character
-- and the replicated force acts on it. The server therefore cannot fully prevent a
-- modified client from ignoring the force or moving freely; it only owns when the
-- ability may start, when it ends, and the cooldown.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config") :: ModuleScript)
local Ability = require(Shared:WaitForChild("Ability") :: ModuleScript)

local AbilityService = {}

type GlideState = {
    activeUntil: number,
    readyAt: number,
    token: number, -- bumped on every end/activation so stale expiry timers do nothing
    attachment: Attachment?,
    force: VectorForce?,
    wings: { Part },
    connections: { RBXScriptConnection }, -- landing / death listeners for the active glide
}

type State = {
    activeUntil: number,
    readyAt: number,
    token: number, -- bumped on every end/activation so stale expiry timers do nothing
    shell: Part?,
    diedConnection: RBXScriptConnection?,
    glide: GlideState,
    connections: { RBXScriptConnection },
}

local KNOWN_ABILITY_IDS: { string } = { Config.AbilityShellId, Config.AbilityGlideId }
local SHELL_NAME = "DefensiveShell"
local SHELL_SIZE_FACTOR = 1.3

local states: { [Player]: State } = {}
local evolution: any = nil
local lastRequestAt: { [Player]: number } = {}

-- ---------------------------------------------------------------------------
-- Tank: Defensive Shell (visual only)
-- ---------------------------------------------------------------------------

local function endShell(player: Player, state: State)
    state.token += 1
    if state.diedConnection ~= nil then
        state.diedConnection:Disconnect()
        state.diedConnection = nil
    end
    if state.shell ~= nil then
        state.shell:Destroy()
        state.shell = nil
    end
    if state.activeUntil ~= 0 then
        state.activeUntil = 0
        if player.Parent == Players then
            player:SetAttribute("ShellActiveUntil", 0)
        end
    end
end

-- Non-physical bubble welded to the root part: no collision, touch or query,
-- massless and unanchored, so it cannot block movement or change physics.
local function createShell(character: Model, root: BasePart): Part
    local size = character:GetExtentsSize()
    local diameter = math.max(size.X, size.Y, size.Z) * SHELL_SIZE_FACTOR

    local shell = Instance.new("Part")
    shell.Name = SHELL_NAME
    shell.Shape = Enum.PartType.Ball
    shell.Size = Vector3.new(diameter, diameter, diameter)
    shell.Material = Enum.Material.ForceField
    shell.Color = Color3.fromRGB(90, 170, 255)
    shell.Transparency = 0.4
    shell.CanCollide = false
    shell.CanTouch = false
    shell.CanQuery = false
    shell.CastShadow = false
    shell.Massless = true
    shell.Anchored = false
    shell.Locked = true
    shell.CFrame = root.CFrame

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = shell
    weld.Parent = shell

    shell.Parent = character
    return shell
end

local function activateShell(
    player: Player,
    state: State,
    form: string,
    alive: boolean,
    character: Model?,
    humanoid: Humanoid?,
    rootInstance: Instance?,
    now: number
)
    local ok = Ability.Validate(form, alive, now, state.activeUntil, state.readyAt, Config.TankShellForm)
    if not ok or character == nil or humanoid == nil or rootInstance == nil or not rootInstance:IsA("BasePart") then
        return
    end

    endShell(player, state) -- defensive: guarantees at most one shell and a fresh token
    state.activeUntil = now + Config.TankShellDuration
    state.readyAt = now + Config.TankShellCooldown
    player:SetAttribute("ShellActiveUntil", state.activeUntil)
    player:SetAttribute("ShellReadyAt", state.readyAt)
    state.shell = createShell(character, rootInstance)
    state.diedConnection = humanoid.Died:Connect(function()
        endShell(player, state)
    end)

    local token = state.token
    task.delay(Config.TankShellDuration, function()
        if state.token == token then
            endShell(player, state)
        end
    end)
end

-- ---------------------------------------------------------------------------
-- Glider: Air Glide (bounded glide, not flight)
-- ---------------------------------------------------------------------------

-- Ends the glide and removes every temporary object. Safe to call repeatedly.
local function endGlide(player: Player, state: State)
    local glide = state.glide
    glide.token += 1
    for _, connection in glide.connections do
        connection:Disconnect()
    end
    table.clear(glide.connections)
    if glide.force ~= nil then
        glide.force:Destroy()
        glide.force = nil
    end
    if glide.attachment ~= nil then
        glide.attachment:Destroy()
        glide.attachment = nil
    end
    for _, wing in glide.wings do
        wing:Destroy()
    end
    table.clear(glide.wings)
    if glide.activeUntil ~= 0 then
        glide.activeUntil = 0
        if player.Parent == Players then
            player:SetAttribute("GliderActiveUntil", 0)
        end
    end
end

-- Simple procedural wing: a thin, non-physical plank welded beside the torso.
local function createWing(character: Model, root: BasePart, side: number, height: number): Part
    local wing = Instance.new("Part")
    wing.Name = "GlideWing"
    wing.Size = Vector3.new(height * 0.7, height * 0.05, height * 0.3)
    wing.Material = Enum.Material.Neon
    wing.Color = Color3.fromRGB(120, 230, 210)
    wing.Transparency = 0.35
    wing.CanCollide = false
    wing.CanTouch = false
    wing.CanQuery = false
    wing.CastShadow = false
    wing.Massless = true
    wing.Anchored = false
    wing.Locked = true
    wing.CFrame = root.CFrame
        * CFrame.new(side * height * 0.55, height * 0.1, height * 0.12)
        * CFrame.Angles(0, 0, side * math.rad(20))

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = wing
    weld.Parent = wing

    wing.Parent = character
    return wing
end

local function activateGlide(
    player: Player,
    state: State,
    form: string,
    alive: boolean,
    character: Model?,
    humanoid: Humanoid?,
    rootInstance: Instance?,
    now: number
)
    local glide = state.glide
    local airborne = humanoid ~= nil and humanoid.FloorMaterial == Enum.Material.Air
    local ok = Ability.ValidateGlide(form, alive, airborne, now, glide.activeUntil, glide.readyAt, Config.GliderForm)
    if not ok or character == nil or humanoid == nil or rootInstance == nil or not rootInstance:IsA("BasePart") then
        return
    end

    endGlide(player, state) -- defensive: fresh token and no leftover objects
    glide.activeUntil = now + Config.GliderDuration
    glide.readyAt = now + Config.GliderCooldown
    player:SetAttribute("GliderActiveUntil", glide.activeUntil)
    player:SetAttribute("GliderReadyAt", glide.readyAt)

    -- Upward force = compensation * weight (mass * gravity), capped below 1 in Ability.
    local attachment = Instance.new("Attachment")
    attachment.Name = "GlideAttachment"
    attachment.Parent = rootInstance
    local force = Instance.new("VectorForce")
    force.Name = "GlideForce"
    force.Attachment0 = attachment
    force.RelativeTo = Enum.ActuatorRelativeTo.World
    force.ApplyAtCenterOfMass = true
    force.Force = Vector3.new(
        0,
        Ability.GetGlideForce(rootInstance.AssemblyMass, workspace.Gravity, Config.GliderGravityCompensation),
        0
    )
    force.Parent = rootInstance
    glide.attachment = attachment
    glide.force = force

    local height = character:GetExtentsSize().Y
    table.insert(glide.wings, createWing(character, rootInstance, 1, height))
    table.insert(glide.wings, createWing(character, rootInstance, -1, height))

    -- Landing (or death) ends the glide immediately.
    table.insert(
        glide.connections,
        humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
            if humanoid.FloorMaterial ~= Enum.Material.Air then
                endGlide(player, state)
            end
        end)
    )
    table.insert(
        glide.connections,
        humanoid.StateChanged:Connect(function(_, newState)
            if newState == Enum.HumanoidStateType.Landed or newState == Enum.HumanoidStateType.Running then
                endGlide(player, state)
            end
        end)
    )
    table.insert(
        glide.connections,
        humanoid.Died:Connect(function()
            endGlide(player, state)
        end)
    )

    local token = glide.token
    task.delay(Config.GliderDuration, function()
        if glide.token == token then
            endGlide(player, state)
        end
    end)
end

-- ---------------------------------------------------------------------------
-- Request handling and lifecycle
-- ---------------------------------------------------------------------------

-- Client input is only a request. Every failure is silent and changes nothing.
-- The rate limit runs first, so rejected requests count against it too.
local function onRequestAbility(player: Player, abilityId: any)
    local clock = os.clock()
    if Ability.IsRateLimited(lastRequestAt[player], clock, Config.AbilityRequestInterval) then
        return -- dropped without touching state (and without extending the interval)
    end
    if player.Parent ~= Players then
        return -- player already left; do not re-create their rate-limit entry
    end
    lastRequestAt[player] = clock

    local state = states[player]
    if state == nil or not Ability.IsKnownAbilityId(abilityId, KNOWN_ABILITY_IDS) then
        return
    end
    local form = evolution.GetForm(player)
    if form == nil then
        return
    end

    local character = player.Character
    local humanoid = if character ~= nil then character:FindFirstChildOfClass("Humanoid") else nil
    local rootInstance = if character ~= nil then character:FindFirstChild("HumanoidRootPart") else nil
    local alive = character ~= nil
        and humanoid ~= nil
        and humanoid.Health > 0
        and rootInstance ~= nil
        and rootInstance:IsA("BasePart")
    local now = workspace:GetServerTimeNow()

    -- The identifier selects a rule set; each one still requires the matching server-owned form.
    if abilityId == Config.AbilityShellId then
        activateShell(player, state, form, alive, character, humanoid, rootInstance, now)
    elseif abilityId == Config.AbilityGlideId then
        activateGlide(player, state, form, alive, character, humanoid, rootInstance, now)
    end
end

local function onPlayerAdded(player: Player)
    if states[player] ~= nil then
        return
    end
    local state: State = {
        activeUntil = 0,
        readyAt = 0,
        token = 0,
        shell = nil,
        diedConnection = nil,
        glide = {
            activeUntil = 0,
            readyAt = 0,
            token = 0,
            attachment = nil,
            force = nil,
            wings = {},
            connections = {},
        },
        connections = {},
    }
    states[player] = state
    player:SetAttribute("ShellActiveUntil", 0)
    player:SetAttribute("ShellReadyAt", 0)
    player:SetAttribute("GliderActiveUntil", 0)
    player:SetAttribute("GliderReadyAt", 0)

    -- Character replaced or removed: nothing may stay on an old character.
    table.insert(state.connections, player.CharacterRemoving:Connect(function()
        endShell(player, state)
        endGlide(player, state)
    end))
    -- Leaving a form (not possible today) also drops that form's ability effects.
    table.insert(state.connections, player:GetAttributeChangedSignal("EvolutionForm"):Connect(function()
        local form = player:GetAttribute("EvolutionForm")
        if form ~= Config.TankShellForm then
            endShell(player, state)
        end
        if form ~= Config.GliderForm then
            endGlide(player, state)
        end
    end))
end

local function onPlayerRemoving(player: Player)
    lastRequestAt[player] = nil
    local state = states[player]
    if state == nil then
        return
    end
    endShell(player, state)
    endGlide(player, state)
    for _, connection in state.connections do
        connection:Disconnect()
    end
    states[player] = nil
end

-- Clears all ability state of one player for a new life (called by ResetService when a life
-- ends): ends any active shell or glide (removing their instances and invalidating pending
-- expiry timers through the token) and clears both cooldowns. Rate-limit timestamps are
-- anti-spam, not life state, and are kept. Safe to call repeatedly or for an unknown player.
function AbilityService.ResetLife(player: Player)
    local state = states[player]
    if state == nil then
        return
    end
    endShell(player, state)
    endGlide(player, state)
    state.readyAt = 0
    state.glide.readyAt = 0
    if player.Parent == Players then
        player:SetAttribute("ShellReadyAt", 0)
        player:SetAttribute("GliderReadyAt", 0)
    end
end

-- evolutionService must already be initialised (provides the server-owned form).
function AbilityService.Init(evolutionService: any)
    evolution = evolutionService

    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes == nil then
        remotes = Instance.new("Folder")
        remotes.Name = "Remotes"
        remotes.Parent = ReplicatedStorage
    end
    local request = Instance.new("RemoteEvent")
    request.Name = "RequestAbility"
    request.Parent = remotes
    request.OnServerEvent:Connect(onRequestAbility)

    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
    for _, player in Players:GetPlayers() do
        onPlayerAdded(player)
    end
end

return AbilityService
