--!strict
-- Controlled respawn and the minimal life recap (P1-04, hardened in P1-05).
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
--
-- Spawn guarantees (P1-05): at most ONE LoadCharacter operation per player is in flight. It is
-- released only when that call returns (not when the character is added, which happens while it
-- still yields) and only by its own sequence number, so a stale operation can never unlock or
-- modify a newer one. If the FIRST spawn fails, the player gets a "spawn failed" notice (the
-- recap with lifeId 0, same button) and may retry. A LoadCharacter that never returns would
-- keep the player locked: Roblox offers no timeout (known limitation, needs Studio observation).
--
-- Recap delivery: the recap carries the server's lifeId. It is stored in entry.pendingRecap
-- (cleared when a newer life begins) and sent once the client announced it is ready; each
-- LifeRecapReady message replays the pending recap. The client ignores older or dismissed recaps.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config") :: ModuleScript)
local Respawn = require(Shared:WaitForChild("Respawn") :: ModuleScript)

local RespawnService = {}

type Stats = { lifeId: number, startedAt: number, highestForm: string }
-- lifeId 0 is the "first spawn failed" notice.
type Recap = { lifeId: number, durationSeconds: number, highestForm: string }
type Entry = { record: Respawn.Record, stats: Stats?, pendingRecap: Recap?, clientReady: boolean, lastReadyAt: number? }

local READY_MIN_INTERVAL = 1 -- seconds: LifeRecapReady messages closer together than this are ignored

local SPAWN_CONFIRM_TIMEOUT = 10 -- allow LifeService's CharacterAdded listener to observe the new character
local SPAWN_CONFIRM_POLL_INTERVAL = 0.05

local entries: { [Player]: Entry } = {}
local life: any = nil
local evolution: any = nil
local reset: any = nil
local recapEvent: RemoteEvent? = nil

local function sendPendingRecap(player: Player, entry: Entry)
    if recapEvent ~= nil and entry.clientReady and entry.pendingRecap ~= nil and player.Parent == Players then
        recapEvent:FireClient(player, entry.pendingRecap)
    end
end

-- LoadCharacter can return before LifeService's CharacterAdded listener has run. Confirm
-- that a newer life was actually observed before classifying the operation as a failed spawn.
-- This bounded wait closes that event-ordering race without releasing the in-flight lock early.
local function waitForNewLife(player: Player, previousLifeId: number): boolean
    local deadline = os.clock() + SPAWN_CONFIRM_TIMEOUT
    repeat
        if player.Parent ~= Players then
            return false
        end
        local currentLifeId = life.GetLifeId(player)
        if currentLifeId ~= nil and currentLifeId > previousLifeId then
            return true
        end
        task.wait(SPAWN_CONFIRM_POLL_INTERVAL)
    until os.clock() >= deadline
    return false
end

-- Loads a character on its own thread (LoadCharacter yields) for spawn operation `seq`. The
-- operation stays in flight until LoadCharacter returns AND LifeService has had time to observe
-- the new life. Only that operation is released; stale operations and players who left do nothing.
-- If no newer life is observed within the bounded confirmation window, the first spawn may retry.
local function loadCharacter(player: Player, entry: Entry, seq: number)
    task.spawn(function()
        local previousLifeId = life.GetLifeId(player) or 0
        local ok, err = pcall(function()
            player:LoadCharacter()
        end)
        if not ok then
            warn(string.format("[RespawnService] LoadCharacter failed for %s: %s", player.Name, tostring(err)))
        end
        if entries[player] ~= entry or player.Parent ~= Players then
            return
        end

        local observedNewLife = waitForNewLife(player, previousLifeId)
        if not observedNewLife then
            warn(string.format(
                "[RespawnService] No new life observed for %s within %.1fs after LoadCharacter returned.",
                player.Name,
                SPAWN_CONFIRM_TIMEOUT
            ))
        end
        if entries[player] ~= entry or player.Parent ~= Players then
            return
        end

        local before = entry.record
        local currentLifeId = life.GetLifeId(player) or 0
        local lifeAlive = observedNewLife and life.IsAlive(player) and currentLifeId > previousLifeId
        entry.record = Respawn.EndSpawn(before, seq, lifeAlive, currentLifeId)
        if entry.record.retryInitial and not before.retryInitial then
            entry.pendingRecap = { lifeId = 0, durationSeconds = 0, highestForm = Config.BaseForm }
            sendPendingRecap(player, entry)
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
    local pending = entry.pendingRecap
    if pending ~= nil and lifeId > pending.lifeId then
        entry.pendingRecap = nil -- a newer life began: that recap is no longer awaited
    end
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
    entry.pendingRecap = { lifeId = endedLifeId, durationSeconds = duration, highestForm = highestForm }
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
-- silent and changes nothing; repeats and same-frame duplicates are rejected because the first
-- valid request marks its spawn operation in flight synchronously.
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
    loadCharacter(player, entry, nextRecord.inFlightSeq)
end

local function startFirstSpawn(player: Player, entry: Entry)
    local nextRecord, reason = Respawn.StartInitialSpawn(entry.record)
    if reason ~= "Ok" then
        return
    end
    entry.record = nextRecord
    loadCharacter(player, entry, nextRecord.inFlightSeq)
end

local function onPlayerAdded(player: Player)
    if entries[player] ~= nil then
        return
    end
    local entry: Entry = { record = Respawn.Initial(), stats = nil, pendingRecap = nil, clientReady = false, lastReadyAt = nil }
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
        startFirstSpawn(player, entry) -- the first spawn, decided by the server
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
    ready.OnServerEvent:Connect(function(player)
        local entry = entries[player]
        if entry == nil or player.Parent ~= Players then
            return
        end
        -- Idempotent: a repeated message only replays the same pending recap, at most once a second.
        local now = os.clock()
        local last = entry.lastReadyAt
        entry.clientReady = true
        if last ~= nil and now - last < READY_MIN_INTERVAL then
            return
        end
        entry.lastReadyAt = now
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
