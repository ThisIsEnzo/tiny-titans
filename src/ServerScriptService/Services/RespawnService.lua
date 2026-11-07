--!strict
-- Controlled respawn and the minimal life recap (P1-04).
-- Bootstrap sets Players.CharacterAutoLoads = false, so no character appears on its own:
--   * this service loads each player's FIRST character (the server decides, not a request);
--   * after a life ends it sends the recap to that player only and waits;
--   * RequestBeginNewLife (no arguments) spawns exactly one new character if, and only if,
--     the server's own state allows it (Shared/Respawn.lua rules).
-- LifeService stays the only authority on Alive/Ended; this service never detects death. A new
-- life begins when LifeService sees the new character (CharacterAdded) and fires LifeBegan.
-- ResetService must have reset the ended life first (IsResetDone), so a new life always starts
-- from clean state. The client never sends a duration, form, lifeId or any state.
--
-- Recap statistics (kept here, per player): the life's start time (server time) and the highest
-- form reached, taken from EvolutionService.FormChanged (server-validated selections only).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config") :: ModuleScript)
local Respawn = require(Shared:WaitForChild("Respawn") :: ModuleScript)

local RespawnService = {}

type Stats = { lifeId: number, startedAt: number, highestForm: string }
type Recap = { durationSeconds: number, highestForm: string }
type Entry = { record: Respawn.Record, stats: Stats?, pendingRecap: Recap?, clientReady: boolean }

local entries: { [Player]: Entry } = {}
local life: any = nil
local evolution: any = nil
local reset: any = nil
local recapEvent: RemoteEvent? = nil
local recapReadyEvent: RemoteEvent? = nil

local function sendPendingRecap(player: Player, entry: Entry)
    if recapEvent ~= nil and entry.clientReady and entry.pendingRecap ~= nil and player.Parent == Players then
        recapEvent:FireClient(player, entry.pendingRecap)
    end
end

-- Loads a character on its own thread (LoadCharacter yields). Never recreates state for a
-- player who left while it ran. If no life began (an error, or nothing spawned), the spawn
-- flag is cleared so the player can try again.
local function loadCharacter(player: Player, entry: Entry)
    task.spawn(function()
        local ok, err = pcall(function()
            player:LoadCharacter()
        end)
        if not ok then
            warn(string.format("[RespawnService] LoadCharacter failed for %s: %s", player.Name, tostring(err)))
        end
        if entries[player] == entry and not life.IsAlive(player) then
            entry.record = Respawn.OnSpawnFailed(entry.record)
        end
    end)
end

local function startStats(entry: Entry, lifeId: number, highestForm: string)
    entry.stats = { lifeId = lifeId, startedAt = workspace:GetServerTimeNow(), highestForm = highestForm }
end

local function onLifeBegan(player: Player, lifeId: number)
    local entry = entries[player]
    if entry == nil then
        return
    end
    entry.record = Respawn.OnLifeBegan(entry.record, lifeId)
    entry.pendingRecap = nil
    startStats(entry, lifeId, Config.BaseForm)
end

local function onLifeEnded(player: Player, endedLifeId: number, reason: string)
    local entry = entries[player]
    if entry == nil then
        return
    end
    entry.record = Respawn.OnLifeEnded(entry.record, endedLifeId)
    local leaving = reason == "PlayerRemoving" or player.Parent ~= Players
    if recapEvent == nil or not Respawn.CanSendRecap(life.GetLifeId(player), endedLifeId, life.IsAlive(player), leaving) then
        return
    end
    local stats = entry.stats
    local duration = 0
    local highestForm = Config.BaseForm
    if stats ~= nil and stats.lifeId == endedLifeId then
        duration = Respawn.Duration(stats.startedAt, workspace:GetServerTimeNow())
        highestForm = stats.highestForm
    end
    entry.pendingRecap = { durationSeconds = duration, highestForm = highestForm }
    sendPendingRecap(player, entry)
end

local function onFormChanged(player: Player, form: string)
    local entry = entries[player]
    local stats = if entry ~= nil then entry.stats else nil
    if stats == nil or not life.IsAlive(player) or life.GetLifeId(player) ~= stats.lifeId then
        return -- only a living life's evolution counts for its recap
    end
    stats.highestForm = Respawn.UpdateHighestForm(stats.highestForm, form, Config.BaseForm)
end

-- RequestBeginNewLife: no arguments are used (extra arguments are ignored). Every failure is
-- silent and changes nothing; repeats are rejected because the first valid request sets the
-- spawning flag at once.
local function onRequestBeginNewLife(player: Player)
    local entry = entries[player]
    if entry == nil or player.Parent ~= Players then
        return
    end
    local currentLifeId = life.GetLifeId(player)
    local resetDone = currentLifeId ~= nil and reset.IsResetDone(player, currentLifeId)
    local nextRecord, reason = Respawn.TryBegin(entry.record, life.GetState(player), currentLifeId, resetDone)
    if reason ~= "Ok" then
        return
    end
    entry.record = nextRecord
    loadCharacter(player, entry)
end

local function onPlayerAdded(player: Player)
    if entries[player] ~= nil then
        return
    end
    local entry: Entry = { record = Respawn.Initial(), stats = nil, pendingRecap = nil, clientReady = false }
    entries[player] = entry
    if life.IsAlive(player) then
        -- A character already existed (it spawned before CharacterAutoLoads was turned off):
        -- keep it and record its life, starting the clock now.
        local lifeId = life.GetLifeId(player)
        if lifeId ~= nil then
            local formNow = Respawn.UpdateHighestForm(Config.BaseForm, evolution.GetForm(player), Config.BaseForm)
            startStats(entry, lifeId, formNow)
        end
    elseif player.Character == nil then
        loadCharacter(player, entry) -- the first spawn, decided by the server
    end
end

-- Call very last in Bootstrap: loading a character begins a life, so every service must be
-- listening already. lifeService, evolutionService and resetService must be initialised.
function RespawnService.Init(lifeService: any, evolutionService: any, resetService: any)
    life = lifeService
    evolution = evolutionService
    reset = resetService

    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes == nil then
        remotes = Instance.new("Folder")
        remotes.Name = "Remotes"
        remotes.Parent = ReplicatedStorage
    end
    local recap = Instance.new("RemoteEvent")
    recap.Name = "LifeRecap"
    recap.Parent = remotes
    recapEvent = recap
    local ready = Instance.new("RemoteEvent")
    ready.Name = "LifeRecapReady"
    ready.Parent = remotes
    recapReadyEvent = ready
    ready.OnServerEvent:Connect(function(player)
        local entry = entries[player]
        if entry == nil or player.Parent ~= Players then
            return
        end
        entry.clientReady = true
        sendPendingRecap(player, entry)
    end)
    local request = Instance.new("RemoteEvent")
    request.Name = "RequestBeginNewLife"
    request.Parent = remotes
    request.OnServerEvent:Connect(onRequestBeginNewLife)

    lifeService.LifeBegan:Connect(onLifeBegan)
    lifeService.LifeEnded:Connect(onLifeEnded)
    evolutionService.FormChanged:Connect(onFormChanged)
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(function(player)
        entries[player] = nil
    end)
    for _, player in Players:GetPlayers() do
        onPlayerAdded(player)
    end
end

return RespawnService
