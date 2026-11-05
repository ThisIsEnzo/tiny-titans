--!strict
-- Server-owned life tracking. Detects when each player's life begins and ends and tells
-- other server code through two server-only events. It resets NOTHING: Biomass, form,
-- abilities and growth keep their current behavior (resetting is a later milestone).
--
-- One life = one character. A life begins on CharacterAdded and ends on the first of
-- Humanoid.Died, CharacterRemoving, a replacement character, or the player leaving.
-- The rules live in the pure Shared/Life.lua; this module only wires Roblox signals to
-- them. The table below is the authority. The "LifeState" Player attribute is a debugging
-- mirror only: it replicates to clients and must never be read for a decision.
--
-- Events (BindableEvents kept in this module, never in ReplicatedStorage):
--   LifeBegan(player: Player, lifeId: number)
--   LifeEnded(player: Player, lifeId: number, reason: string)
--     reason is one of Life.EndReason: "HumanoidDied", "CharacterRemoving",
--     "CharacterReplaced", "PlayerRemoving".
-- Each lifeId gets exactly one LifeBegan and at most one LifeEnded. Subscribers may run a
-- moment after the change, so compare the payload lifeId with GetLifeId before acting.
--
-- Stale signals: every character-specific listener captures its character and lifeId, and
-- is disconnected when its life ends. A late callback must still match both the player's
-- current record and the current life, or it does nothing.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Life = require(Shared:WaitForChild("Life") :: ModuleScript)

local LifeService = {}

type LifeRecord = { state: string, lifeId: number } -- see Shared/Life.lua

type PlayerLife = {
    life: LifeRecord,
    character: Model?, -- character of the latest life (kept after it ends to ignore repeats)
    characterConnections: { RBXScriptConnection }, -- Humanoid.Died / lookup for the current life
    connections: { RBXScriptConnection }, -- CharacterAdded / CharacterRemoving for the player
}

local records: { [Player]: PlayerLife } = {}
local lifeBegan = Instance.new("BindableEvent")
local lifeEnded = Instance.new("BindableEvent")

-- Fires (player: Player, lifeId: number) on the server only.
LifeService.LifeBegan = lifeBegan.Event
-- Fires (player: Player, lifeId: number, reason: string) on the server only.
LifeService.LifeEnded = lifeEnded.Event

local function disconnectAll(connections: { RBXScriptConnection })
    for _, connection in connections do
        connection:Disconnect()
    end
    table.clear(connections)
end

local function publishState(player: Player, life: LifeRecord)
    player:SetAttribute("LifeState", life.state) -- debugging mirror, not an authority
end

-- Ends the life identified by lifeId. Does nothing (returns false) if that life is not the
-- current Alive one, so duplicate and stale signals cannot end a life twice or a newer life.
local function endLife(player: Player, data: PlayerLife, lifeId: number, reason: string): boolean
    local nextLife: LifeRecord, result: string = Life.End(data.life, lifeId)
    if result ~= "Ok" then
        return false
    end
    data.life = nextLife
    disconnectAll(data.characterConnections)
    publishState(player, nextLife)
    lifeEnded:Fire(player, nextLife.lifeId, reason)
    return true
end

local function onHumanoidDied(player: Player, data: PlayerLife, character: Model, lifeId: number)
    if records[player] ~= data or data.character ~= character then
        return -- player left, or this signal belongs to an older character
    end
    endLife(player, data, lifeId, Life.EndReason.HumanoidDied)
end

-- Listens for the character's death. The Humanoid may not exist yet when CharacterAdded
-- fires, so otherwise wait for it with a child listener. That listener belongs to this
-- life and is disconnected when the life ends, so it can never attach to a newer character
-- and needs no timer or retry loop.
local function trackHumanoid(player: Player, data: PlayerLife, character: Model, lifeId: number)
    local bound = false
    local function bind(humanoid: Humanoid)
        if bound then
            return
        end
        bound = true
        table.insert(
            data.characterConnections,
            humanoid.Died:Connect(function()
                onHumanoidDied(player, data, character, lifeId)
            end)
        )
        if humanoid.Health <= 0 then
            onHumanoidDied(player, data, character, lifeId) -- already dead: Died will not fire again
        end
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid ~= nil then
        bind(humanoid)
        return
    end
    table.insert(
        data.characterConnections,
        character.ChildAdded:Connect(function(child)
            if child:IsA("Humanoid") and records[player] == data and Life.IsCurrent(data.life, lifeId) then
                bind(child)
            end
        end)
    )
end

local function beginLife(player: Player, data: PlayerLife, character: Model)
    local nextLife: LifeRecord, result: string = Life.Begin(data.life)
    if result ~= "Ok" then
        return -- cannot happen: the caller ends an Alive life first
    end
    data.life = nextLife
    data.character = character
    publishState(player, nextLife)
    lifeBegan:Fire(player, nextLife.lifeId)
    trackHumanoid(player, data, character, nextLife.lifeId) -- after LifeBegan, so an instant death orders Began, Ended
end

local function onCharacterAdded(player: Player, data: PlayerLife, character: Model)
    if records[player] ~= data or player.Parent ~= Players then
        return
    end
    if data.character == character then
        return -- the same character again (for example one found at Init): not a new life
    end
    if Life.IsAlive(data.life) then
        -- A new character while the previous life is still Alive: end that life first, so
        -- a player never has two Alive lives.
        endLife(player, data, data.life.lifeId, Life.EndReason.CharacterReplaced)
    end
    beginLife(player, data, character)
end

local function onCharacterRemoving(player: Player, data: PlayerLife, character: Model)
    if records[player] ~= data or data.character ~= character then
        return -- not the character of the latest life
    end
    endLife(player, data, data.life.lifeId, Life.EndReason.CharacterRemoving)
end

local function onPlayerAdded(player: Player)
    if records[player] ~= nil then
        return
    end
    local data: PlayerLife = {
        life = Life.Initial(),
        character = nil,
        characterConnections = {},
        connections = {},
    }
    records[player] = data
    publishState(player, data.life)

    table.insert(
        data.connections,
        player.CharacterAdded:Connect(function(character)
            onCharacterAdded(player, data, character)
        end)
    )
    table.insert(
        data.connections,
        player.CharacterRemoving:Connect(function(character)
            onCharacterRemoving(player, data, character)
        end)
    )
    local existing = player.Character
    if existing ~= nil then
        onCharacterAdded(player, data, existing)
    end
end

local function onPlayerRemoving(player: Player)
    local data = records[player]
    if data == nil then
        return
    end
    endLife(player, data, data.life.lifeId, Life.EndReason.PlayerRemoving) -- no-op if already Ended
    disconnectAll(data.connections)
    disconnectAll(data.characterConnections)
    data.character = nil
    records[player] = nil
end

-- Returns "Alive" or "Ended", or nil if the player has no record (unknown or already left).
function LifeService.GetState(player: Player): string?
    local data = records[player]
    if data == nil then
        return nil
    end
    return data.life.state
end

-- Returns the player's current lifeId (0 before the first life), or nil if there is no record.
function LifeService.GetLifeId(player: Player): number?
    local data = records[player]
    if data == nil then
        return nil
    end
    return data.life.lifeId
end

function LifeService.IsAlive(player: Player): boolean
    local data = records[player]
    return data ~= nil and Life.IsAlive(data.life)
end

-- Starts life tracking. Call before services that will subscribe to LifeBegan / LifeEnded.
function LifeService.Init()
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
    for _, player in Players:GetPlayers() do
        onPlayerAdded(player)
    end
end

return LifeService
