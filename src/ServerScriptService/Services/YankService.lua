--!strict
-- Drawline Yank: server-authoritative target registration, validation and movement.
-- Target authoring: tag a BasePart "DrawlineTarget"; set YankId (string), optional
-- YankDuration/YankRange (numbers), and add YankStart + YankEnd Attachments as rail markers.
-- YankStart is optional (defaults to the part pivot). YankEnd marks where YankStart must arrive.
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Yank = require(Shared:WaitForChild("Yank") :: ModuleScript)

local YankService = {}
local TAG = "DrawlineTarget"
local state = Yank.newState()
local cache: { [string]: { part: BasePart, startCFrame: CFrame, endCFrame: CFrame, anchored: boolean } } = {}
local movement: { [Player]: Yank.MovementRecord } = {}
local connections: { RBXScriptConnection } = {}
local playerConnections: { [Player]: { RBXScriptConnection } } = {}
local startRemote: RemoteEvent? = nil
local stopRemote: RemoteEvent? = nil
local stateRemote: RemoteEvent? = nil
local destroyed = false

local function vec(v: Vector3)
	return { x = v.X, y = v.Y, z = v.Z }
end
local function playerKey(player: Player): string return tostring(player.UserId) end
local function notify(player: Player?, payload: any)
	if stateRemote ~= nil and player ~= nil and player.Parent == Players then stateRemote:FireClient(player, payload) end
end
local function setTargetState(id: string)
	local entry = cache[id]
	local target = Yank.getTarget(state, id)
	if entry == nil or target == nil or entry.part.Parent == nil then return end
	entry.part:SetAttribute("YankState",
		if target.completed then "Completed" elseif target.lockedBy ~= nil then "InProgress" else "Eligible")
end

local function restoreMovement(player: Player)
	local record = movement[player]
	if record == nil then return end
	movement[player] = nil
	local character = player.Character
	if not Yank.canRestore(record, character) then return end
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil or humanoid.Parent ~= character then return end
	local s = record.settings
	humanoid.WalkSpeed = s.walkSpeed
	humanoid.JumpPower = s.jumpPower
	humanoid.JumpHeight = s.jumpHeight
	humanoid.UseJumpPower = s.useJumpPower
	Yank.markRestored(record)
end
local function freezeMovement(player: Player): boolean
	local character = player.Character
	if character == nil then return false end
	local existing = movement[player]
	if existing ~= nil then
		if existing.characterKey == character then return true end
		movement[player] = nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil or humanoid.Parent ~= character or humanoid.Health <= 0 then return false end
	movement[player] = Yank.newMovementRecord(character, {
		walkSpeed = humanoid.WalkSpeed, useJumpPower = humanoid.UseJumpPower,
		jumpPower = humanoid.JumpPower, jumpHeight = humanoid.JumpHeight,
	})
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
	return true
end

local function applyMotion(id: string, progress: number)
	local entry = cache[id]
	if entry == nil or entry.part.Parent == nil then return end
	entry.part.CFrame = entry.startCFrame:Lerp(entry.endCFrame, math.clamp(progress, 0, 1))
end
local function beginMotion(entry: any)
	if not entry.part.Anchored then
		pcall(function() entry.part:SetNetworkOwner(nil) end)
		entry.part.Anchored = true
	end
end
local function endMotion(entry: any)
	if entry.part.Parent ~= nil and entry.part.Anchored ~= entry.anchored then
		entry.part.Anchored = entry.anchored
	end
end

local function applyEvent(event: any)
	if event == nil then return end
	local player = Players:GetPlayerByUserId(tonumber(event.playerId) or 0)
	local entry = cache[event.targetId]
	if event.kind == "Progress" or event.kind == "Completed" then applyMotion(event.targetId, event.progress) end
	if event.kind == "Completed" then
		if entry ~= nil then endMotion(entry) end
		if player ~= nil then restoreMovement(player) end
		setTargetState(event.targetId)
		notify(player, { kind = "Completed", targetId = event.targetId })
	elseif event.kind == "Cancelled" then
		if entry ~= nil then endMotion(entry) end
		if player ~= nil then restoreMovement(player) end
		setTargetState(event.targetId)
		notify(player, { kind = "Cancelled", targetId = event.targetId, reason = event.reason })
	end
end

local function cancelSession(player: Player, reason: string, withCooldown: boolean)
	local key = playerKey(player)
	local event
	if withCooldown then
		event = Yank.cancel(state, key, os.clock(), reason)
	else
		event = Yank.releasePlayer(state, key)
		if event ~= nil then event.reason = reason end
	end
	if event ~= nil then applyEvent(event) else restoreMovement(player) end
end

local function buildContext()
	local ctx = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local alive = humanoid ~= nil and humanoid.Health > 0 and root ~= nil
			and root:IsA("BasePart") and character.Parent ~= nil
		ctx[playerKey(player)] = {
			alive = alive,
			position = if alive then vec((root :: BasePart).Position) else nil,
		}
	end
	return ctx
end
local function buildCurrentPositions()
	local positions = {}
	for id, entry in pairs(cache) do
		if entry.part.Parent ~= nil then positions[id] = vec(entry.part.Position) end
	end
	return positions
end

local function unregisterPart(part: BasePart)
	for id, entry in pairs(cache) do
		if entry.part == part then
			local event = Yank.unregisterTarget(state, id)
			endMotion(entry)
			cache[id] = nil
			if event ~= nil then applyEvent(event) end
			return
		end
	end
end

local function registerPart(instance: Instance)
	if not instance:IsA("BasePart") or not instance:IsDescendantOf(workspace) then return end
	local id = instance:GetAttribute("YankId")
	if type(id) ~= "string" or #id == 0 or #id > 64 then
		warn("[Yank] DrawlineTarget requires a valid YankId:", instance:GetFullName())
		return
	end
	if cache[id] ~= nil then
		warn("[Yank] duplicate YankId; keeping the first registration:", id)
		return
	end
	local endAttachment = instance:FindFirstChild("YankEnd")
	if endAttachment == nil or not endAttachment:IsA("Attachment") then
		warn("[Yank] DrawlineTarget requires a YankEnd attachment:", id)
		return
	end
	local startAttachment = instance:FindFirstChild("YankStart")
	local startWorld = if startAttachment ~= nil and startAttachment:IsA("Attachment")
		then (startAttachment :: Attachment).WorldPosition else instance.Position
	local endWorld = (endAttachment :: Attachment).WorldPosition
	-- Translate the part so YankStart arrives at the authored YankEnd position.
	-- This preserves the part's pivot offset and its full orientation.
	local startCFrame = instance.CFrame
	local endCFrame = CFrame.new(instance.Position + (endWorld - startWorld)) * instance.CFrame.Rotation
	local duration = instance:GetAttribute("YankDuration")
	local range = instance:GetAttribute("YankRange")
	local ok = Yank.registerTarget(state, {
		id = id, startPos = vec(instance.Position), endPos = vec(endCFrame.Position),
		duration = if type(duration) == "number" then duration else nil,
		maxRange = if type(range) == "number" then range else nil,
	})
	if not ok then warn("[Yank] rejected target definition:", id) return end
	cache[id] = { part = instance, startCFrame = startCFrame, endCFrame = endCFrame, anchored = instance.Anchored }
	-- Static until acquired; an unanchored authored part is restored after each move.
	instance.Anchored = true
	instance.CFrame = startCFrame
	instance:SetAttribute("YankState", "Eligible")
end

local function onStart(player: Player, payload: any, ...: any)
	local targetId = Yank.sanitizeStartPayload(payload)
	local key = playerKey(player)
	if targetId == nil then
		Yank.throttle(state, key, os.clock())
		notify(player, { kind = "Rejected", reason = Yank.Reason.Invalid })
		return
	end
	local ok, reason = Yank.tryStart(state, { playerId = key, targetId = targetId, now = os.clock() }, buildContext())
	if not ok then
		notify(player, { kind = "Rejected", targetId = targetId, reason = reason })
		return
	end
	local entry = cache[targetId]
	if entry == nil or entry.part.Parent == nil then
		local event = Yank.cancel(state, key, os.clock(), Yank.CancelReason.TargetInvalid)
		if event ~= nil then applyEvent(event) end
		notify(player, { kind = "Rejected", targetId = targetId, reason = Yank.Reason.NoTarget })
		return
	end
	if not freezeMovement(player) then
		local event = Yank.cancel(state, key, os.clock(), Yank.CancelReason.Death)
		if event ~= nil then applyEvent(event) end
		notify(player, { kind = "Rejected", targetId = targetId, reason = Yank.Reason.Dead })
		return
	end
	beginMotion(entry)
	setTargetState(targetId)
	applyMotion(targetId, (Yank.getSession(state, key) :: any).progress)
	notify(player, { kind = "Started", targetId = targetId, reason = reason })
end
local function onStop(player: Player) cancelSession(player, Yank.CancelReason.Released, true) end

local function disconnectPlayer(player: Player)
	local list = playerConnections[player]
	if list ~= nil then
		for _, connection in ipairs(list) do connection:Disconnect() end
		playerConnections[player] = nil
	end
end
local function onPlayerAdded(player: Player)
	if playerConnections[player] ~= nil then return end
	local list: { RBXScriptConnection } = {}
	table.insert(list, player.CharacterAdded:Connect(function()
		cancelSession(player, Yank.CancelReason.Respawn, false)
	end))
	table.insert(list, player.CharacterRemoving:Connect(function()
		cancelSession(player, Yank.CancelReason.Death, false)
	end))
	playerConnections[player] = list
end
local function onPlayerRemoving(player: Player)
	cancelSession(player, Yank.CancelReason.Disconnected, false)
	disconnectPlayer(player)
end

function YankService.Init(lifeService: any?)
	local folder = ReplicatedStorage:FindFirstChild("DrawlineRemotes")
	if folder == nil then
		folder = Instance.new("Folder")
		folder.Name = "DrawlineRemotes"
		folder.Parent = ReplicatedStorage
	end
	local function getRemote(name: string): RemoteEvent
		local found = folder:FindFirstChild(name)
		if found ~= nil and found:IsA("RemoteEvent") then return found :: RemoteEvent end
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
		return remote
	end
	startRemote = getRemote("YankStart")
	stopRemote = getRemote("YankStop")
	stateRemote = getRemote("YankState")
	table.insert(connections, (startRemote :: RemoteEvent).OnServerEvent:Connect(onStart))
	table.insert(connections, (stopRemote :: RemoteEvent).OnServerEvent:Connect(onStop))
	for _, instance in ipairs(CollectionService:GetTagged(TAG)) do registerPart(instance) end
	table.insert(connections, CollectionService:GetInstanceAddedSignal(TAG):Connect(registerPart))
	table.insert(connections, CollectionService:GetInstanceRemovedSignal(TAG):Connect(function(instance)
		if instance:IsA("BasePart") then unregisterPart(instance) end
	end))
	table.insert(connections, Players.PlayerAdded:Connect(onPlayerAdded))
	table.insert(connections, Players.PlayerRemoving:Connect(onPlayerRemoving))
	for _, player in ipairs(Players:GetPlayers()) do onPlayerAdded(player) end
	if lifeService ~= nil and typeof(lifeService.LifeEnded) == "RBXScriptSignal" then
		table.insert(connections, lifeService.LifeEnded:Connect(function(player: Player, _lifeId: number, _reason: string)
			if player:IsA("Player") then cancelSession(player, Yank.CancelReason.Death, false) end
		end))
	end
	table.insert(connections, RunService.Heartbeat:Connect(function(dt)
		if destroyed or next(state.sessions) == nil then return end
		for playerId, session in pairs(state.sessions) do
			local entry = cache[session.targetId]
			if entry == nil or entry.part.Parent == nil then
				local event = Yank.cancel(state, playerId, os.clock(), Yank.CancelReason.TargetInvalid)
				if event ~= nil then applyEvent(event) end
			end
		end
		if next(state.sessions) == nil then return end
		local events = Yank.step(state, dt, os.clock(), buildContext(), buildCurrentPositions())
		for _, event in ipairs(events) do applyEvent(event) end
		for id in pairs(cache) do setTargetState(id) end
	end))
end

function YankService.Destroy()
	destroyed = true
	for _, connection in ipairs(connections) do connection:Disconnect() end
	table.clear(connections)
	for player in pairs(playerConnections) do disconnectPlayer(player) end
	for _, player in ipairs(Players:GetPlayers()) do cancelSession(player, Yank.CancelReason.Disconnected, false) end
	for _, entry in pairs(cache) do endMotion(entry) end
	table.clear(cache)
	state = Yank.newState()
end

return YankService
