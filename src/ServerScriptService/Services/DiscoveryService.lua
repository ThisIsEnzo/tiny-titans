--!strict
-- Server-authoritative exploration discoveries (TT-P3-02). A discovery is found when a living
-- character's HumanoidRootPart is INSIDE an invisible trigger volume of the map: a part tagged
-- "DiscoverySite" under Workspace/Habitat/DiscoverySites whose Name is the discovery id (see
-- Shared/DiscoveryDefinitions). Like FoodService there is no client request: the server polls player
-- positions, so a client cannot claim a discovery it is not standing in. A volume is a region of
-- space, so a trigger cannot fire through a wall or from far away. No scripts live in map parts.
--
-- Rules (the pure rules are in Shared/Discovery.lua and are unit-tested):
--   * Individual per player: nobody grants anything to anybody else; other players being nearby changes
--     nothing, so solo play gets the whole loop.
--   * Once per life: the player's discovery log belongs to one lifeId. The first valid scan marks the
--     discovery found BEFORE the reward is granted, in one thread without yielding, so it cannot be
--     found twice. A new life starts with an empty log (ResetService calls ResetLife).
--   * Only while the character is alive and the log belongs to the CURRENT life: events for an older
--     life are rejected as stale, so a late scan can never touch a newer life.
--   * The reward is a small Biomass bonus through PlayerDataService.AddBiomass (clamped to the cap, so
--     discoveries never exceed it); a discovery found at the cap still counts, it just grants 0.
--   * Feedback: a server-to-client DiscoveryFound event (display only) plus the Player attributes
--     "Discoveries" and "DiscoveryTotal" (display mirrors, never read for a decision).
--   * The recap reads GetLifeSummary(player, lifeId); the pure tracker keeps the just-finished life's
--     log, so it does not matter whether the reset or the recap runs first.
--   Not persisted: discoveries last one life, no DataStore.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config") :: ModuleScript)
local Discovery = require(Shared:WaitForChild("Discovery") :: ModuleScript)
local DiscoveryDefinitions = require(Shared:WaitForChild("DiscoveryDefinitions") :: ModuleScript)

local DiscoveryService = {}

local SITE_TAG = "DiscoverySite"
local MAX_CLUE_LENGTH = 120

local life: any = nil
local playerData: any = nil
local foundEvent: RemoteEvent? = nil
local sites: { [string]: BasePart } = {} -- discovery id -> its trigger volume
local trackers: { [Player]: any } = {} -- Discovery.Tracker per player
local elapsed = 0

local function registerSite(instance: Instance)
    if not instance:IsA("BasePart") then
        return
    end
    local id = instance.Name
    if DiscoveryDefinitions.GetDiscovery(id) == nil then
        warn(string.format("[DiscoveryService] DiscoverySite '%s' has no definition; ignored.", id))
        return
    end
    if sites[id] ~= nil and sites[id] ~= instance then
        warn(string.format("[DiscoveryService] Duplicate DiscoverySite '%s'; the first one is used.", id))
        return
    end
    sites[id] = instance
end

-- Display mirrors for the client HUD: the current life's count and the catalog size.
local function publish(player: Player)
    if player.Parent ~= Players then
        return
    end
    local tracker = trackers[player]
    local lifeId = life.GetLifeId(player)
    local count = 0
    if tracker ~= nil and lifeId ~= nil then
        count = Discovery.SummaryForLife(tracker, lifeId, DiscoveryDefinitions).count
    end
    player:SetAttribute("Discoveries", count)
    player:SetAttribute("DiscoveryTotal", #DiscoveryDefinitions.Discoveries)
end

-- The character's root if the player is alive, else nil.
local function getLivingRoot(player: Player): BasePart?
    local character = player.Character
    if character == nil then
        return nil
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if humanoid == nil or humanoid.Health <= 0 or root == nil or not root:IsA("BasePart") then
        return nil
    end
    return root
end

local function award(player: Player, tracker: any, lifeId: number, id: string)
    -- Marks the discovery found first (atomic: no yield until the reward is recorded).
    local ok, _reason, definition = Discovery.TryDiscover(tracker, lifeId, id, DiscoveryDefinitions)
    if not ok then
        return
    end
    local gained = playerData.AddBiomass(player, definition.biomass)
    Discovery.RecordBiomass(tracker, lifeId, gained)
    publish(player)

    local summary = Discovery.SummaryForLife(tracker, lifeId, DiscoveryDefinitions)
    local nextDefinition = Discovery.NextClue(tracker, lifeId, DiscoveryDefinitions)
    if foundEvent ~= nil then
        foundEvent:FireClient(player, {
            id = definition.id,
            name = definition.displayName,
            biomass = gained,
            count = summary.count,
            total = summary.total,
            nextClue = if nextDefinition ~= nil then string.sub(nextDefinition.clue, 1, MAX_CLUE_LENGTH) else nil,
        })
    end
end

local function step()
    for _, player in Players:GetPlayers() do
        local tracker = trackers[player]
        if tracker == nil or not life.IsAlive(player) then
            continue
        end
        local lifeId = life.GetLifeId(player)
        local root = getLivingRoot(player)
        if lifeId == nil or root == nil then
            continue
        end
        local position = root.Position
        for id, part in sites do
            if part.Parent == nil or Discovery.HasFound(tracker, lifeId, id) then
                continue
            end
            local localPoint = part.CFrame:PointToObjectSpace(position)
            local half = part.Size / 2
            if Discovery.IsInside(localPoint.X, localPoint.Y, localPoint.Z, half.X, half.Y, half.Z) then
                award(player, tracker, lifeId, id)
            end
        end
    end
end

-- Called by ResetService when a life ends: the finished life's log is kept for the recap and the
-- next life starts with nothing found.
function DiscoveryService.ResetLife(player: Player)
    local tracker = trackers[player]
    if tracker == nil then
        return false
    end
    Discovery.ResetTracker(tracker)
    if player.Parent == Players then
        player:SetAttribute("Discoveries", 0) -- the next life starts with nothing found (the recap has the old count)
        player:SetAttribute("DiscoveryTotal", #DiscoveryDefinitions.Discoveries)
    end
    return true
end

-- Plain table with the discoveries of the given life (for the recap). Always a valid summary.
function DiscoveryService.GetLifeSummary(player: Player, lifeId: number): any
    local tracker = trackers[player]
    if tracker == nil then
        return Discovery.SummaryForLife(Discovery.NewTracker(), lifeId, DiscoveryDefinitions)
    end
    return Discovery.SummaryForLife(tracker, lifeId, DiscoveryDefinitions)
end

local function onPlayerAdded(player: Player)
    if trackers[player] ~= nil then
        return
    end
    trackers[player] = Discovery.NewTracker()
    publish(player)
end

-- lifeService and playerDataService must already be initialised. Init before ResetService.
function DiscoveryService.Init(lifeService: any, playerDataService: any)
    life = lifeService
    playerData = playerDataService

    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes == nil then
        remotes = Instance.new("Folder")
        remotes.Name = "Remotes"
        remotes.Parent = ReplicatedStorage
    end
    local found = Instance.new("RemoteEvent")
    found.Name = "DiscoveryFound" -- server to client only; the server ignores anything a client sends
    found.Parent = remotes
    foundEvent = found

    for _, instance in CollectionService:GetTagged(SITE_TAG) do
        registerSite(instance)
    end
    CollectionService:GetInstanceAddedSignal(SITE_TAG):Connect(registerSite)
    CollectionService:GetInstanceRemovedSignal(SITE_TAG):Connect(function(instance)
        if sites[instance.Name] == instance then
            sites[instance.Name] = nil
        end
    end)
    for _, definition in DiscoveryDefinitions.Discoveries do
        if sites[definition.id] == nil then
            warn(string.format("[DiscoveryService] No DiscoverySite part for '%s'; it cannot be found.", definition.id))
        end
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(function(player)
        trackers[player] = nil
    end)
    for _, player in Players:GetPlayers() do
        onPlayerAdded(player)
    end

    RunService.Heartbeat:Connect(function(dt)
        elapsed += dt
        if elapsed < Config.DiscoveryCheckInterval then
            return
        end
        elapsed = 0
        step()
    end)
end

return DiscoveryService
