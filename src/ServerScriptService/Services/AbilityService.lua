--!strict
-- Server-authoritative Tank Defensive Shell (VISUAL ONLY: no damage, health,
-- knockback or movement effects exist or are changed).
-- The client sends a bare activation request (RequestAbility); the server derives the
-- player from the remote, validates form/character/state, owns all timing, and builds
-- the shell. Replicated Player attributes: "ShellActiveUntil" and "ShellReadyAt"
-- (workspace:GetServerTimeNow() timestamps; 0 = never). The shell is a server-created
-- Part parented to the character, so every client sees it.
-- Cooldown runs from activation and persists across death and respawn (session only).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config") :: ModuleScript)
local Ability = require(Shared:WaitForChild("Ability") :: ModuleScript)

local AbilityService = {}

type State = {
    activeUntil: number,
    readyAt: number,
    token: number, -- bumped on every end/activation so stale expiry timers do nothing
    shell: Part?,
    diedConnection: RBXScriptConnection?,
    connections: { RBXScriptConnection },
}

local SHELL_NAME = "DefensiveShell"
local SHELL_SIZE_FACTOR = 1.3

local states: { [Player]: State } = {}
local evolution: any = nil

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

-- Client input is only a request. Every failure is silent and changes nothing.
local function onRequestAbility(player: Player)
    local state = states[player]
    if state == nil or player.Parent ~= Players then
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
        connections = {},
    }
    states[player] = state
    player:SetAttribute("ShellActiveUntil", 0)
    player:SetAttribute("ShellReadyAt", 0)

    -- Character replaced or removed: the shell must never stay on an old character.
    table.insert(state.connections, player.CharacterRemoving:Connect(function()
        endShell(player, state)
    end))
    -- Leaving the Tank form (not possible today) also drops the shell.
    table.insert(state.connections, player:GetAttributeChangedSignal("EvolutionForm"):Connect(function()
        if player:GetAttribute("EvolutionForm") ~= Config.TankShellForm then
            endShell(player, state)
        end
    end))
end

local function onPlayerRemoving(player: Player)
    local state = states[player]
    if state == nil then
        return
    end
    endShell(player, state)
    for _, connection in state.connections do
        connection:Disconnect()
    end
    states[player] = nil
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
