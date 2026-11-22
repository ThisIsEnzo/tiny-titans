--!strict
-- Drawline Yank rules. Pure Luau: no Roblox services or Instances.
local Yank = {}

Yank.Reason = table.freeze({
	Ok = "Ok", Invalid = "Invalid", NoTarget = "NoTarget", Locked = "Locked",
	Completed = "Completed", OutOfRange = "OutOfRange", Dead = "Dead",
	Cooldown = "Cooldown", RateLimited = "RateLimited", AlreadyActive = "AlreadyActive",
})
Yank.CancelReason = table.freeze({
	Released = "Released", Death = "Death", Respawn = "Respawn",
	OutOfRange = "OutOfRange", Disconnected = "Disconnected", TargetInvalid = "TargetInvalid",
})
Yank.Defaults = table.freeze({ Duration = 2, MaxRange = 18, Cooldown = 0.75, RateWindow = 1, RateMax = 8 })

export type Vec3 = { x: number, y: number, z: number }
type Target = {
	id: string, startPos: Vec3, endPos: Vec3, duration: number, maxRange: number,
	progress: number, completed: boolean, lockedBy: string?,
}
type Session = { playerId: string, targetId: string, progress: number }
export type State = {
	targets: { [string]: Target }, sessions: { [string]: Session },
	cooldownUntil: { [string]: number }, rate: { [string]: { window: number, count: number } },
}
export type PlayerContext = { alive: boolean, position: Vec3? }
export type Context = { [string]: PlayerContext }
export type MovementSettings = { walkSpeed: number, useJumpPower: boolean, jumpPower: number, jumpHeight: number }
export type MovementRecord = { characterKey: any, settings: MovementSettings, restored: boolean }

local function finite(n: any): boolean
	return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end
local function validId(v: any): boolean
	return type(v) == "string" and #v > 0 and #v <= 64
end
local function validVec(v: any): boolean
	return type(v) == "table" and finite(v.x) and finite(v.y) and finite(v.z)
end
local function copyVec(v: Vec3): Vec3
	return { x = v.x, y = v.y, z = v.z }
end

function Yank.newState(): State
	return { targets = {}, sessions = {}, cooldownUntil = {}, rate = {} }
end
function Yank.distance(a: Vec3, b: Vec3): number
	local x, y, z = a.x - b.x, a.y - b.y, a.z - b.z
	return math.sqrt(x*x + y*y + z*z)
end
function Yank.positionAt(target: Target, progress: number): Vec3
	local t = math.clamp(progress, 0, 1)
	return {
		x = target.startPos.x + (target.endPos.x - target.startPos.x) * t,
		y = target.startPos.y + (target.endPos.y - target.startPos.y) * t,
		z = target.startPos.z + (target.endPos.z - target.startPos.z) * t,
	}
end
function Yank.getTarget(state: State, id: string) return state.targets[id] end
function Yank.getSession(state: State, id: string) return state.sessions[id] end

function Yank.sanitizeStartPayload(payload: any): string?
	if type(payload) ~= "table" or not validId(payload.targetId) then return nil end
	return payload.targetId
end

function Yank.registerTarget(state: State, def: any): boolean
	if type(def) ~= "table" or not validId(def.id) then return false end
	if not validVec(def.startPos) or not validVec(def.endPos) then return false end
	if def.duration ~= nil and (not finite(def.duration) or def.duration <= 0) then return false end
	if def.maxRange ~= nil and (not finite(def.maxRange) or def.maxRange <= 0) then return false end
	if state.targets[def.id] ~= nil then return false end
	state.targets[def.id] = {
		id = def.id, startPos = copyVec(def.startPos), endPos = copyVec(def.endPos),
		duration = def.duration or Yank.Defaults.Duration,
		maxRange = def.maxRange or Yank.Defaults.MaxRange,
		progress = 0, completed = false, lockedBy = nil,
	}
	return true
end

local function endSession(state: State, playerId: string, applyCooldown: boolean, now: number?)
	local session = state.sessions[playerId]
	if session == nil then return nil end
	local target = state.targets[session.targetId]
	if target ~= nil then
		target.lockedBy = nil
		target.progress = session.progress
	end
	state.sessions[playerId] = nil
	if applyCooldown and now ~= nil then state.cooldownUntil[playerId] = now + Yank.Defaults.Cooldown end
	return session
end
local function cancelled(session: Session, reason: string)
	return { kind = "Cancelled", playerId = session.playerId, targetId = session.targetId,
		progress = session.progress, reason = reason }
end

function Yank.unregisterTarget(state: State, targetId: string)
	local target = state.targets[targetId]
	if target == nil then return nil end
	local event
	if target.lockedBy ~= nil then
		local session = endSession(state, target.lockedBy, false, nil)
		if session ~= nil then event = cancelled(session, Yank.CancelReason.TargetInvalid) end
	end
	state.targets[targetId] = nil
	return event
end

function Yank.throttle(state: State, playerId: string, now: number): boolean
	if not validId(playerId) or not finite(now) then return false end
	local bucket = state.rate[playerId]
	if bucket == nil or now - bucket.window >= Yank.Defaults.RateWindow then
		state.rate[playerId] = { window = now, count = 1 }
		return true
	end
	bucket.count += 1
	return bucket.count <= Yank.Defaults.RateMax
end

function Yank.tryStart(state: State, req: { playerId: string, targetId: string, now: number }, ctx: Context)
	local playerId, targetId, now = req.playerId, req.targetId, req.now
	if not validId(playerId) or not finite(now) then return false, Yank.Reason.Invalid end
	if not Yank.throttle(state, playerId, now) then return false, Yank.Reason.RateLimited end
	if not validId(targetId) then return false, Yank.Reason.Invalid end
	local pc = ctx[playerId]
	if pc == nil or pc.alive ~= true or not validVec(pc.position) then return false, Yank.Reason.Dead end
	if state.sessions[playerId] ~= nil then return false, Yank.Reason.AlreadyActive end
	local target = state.targets[targetId]
	if target == nil then return false, Yank.Reason.NoTarget end
	if target.completed then return false, Yank.Reason.Completed end
	if target.lockedBy ~= nil then return false, Yank.Reason.Locked end
	local cooldown = state.cooldownUntil[playerId]
	if cooldown ~= nil and now < cooldown then return false, Yank.Reason.Cooldown end
	-- Re-acquisition is checked against the target's persisted current position, not rail origin.
	if Yank.distance(pc.position :: Vec3, Yank.positionAt(target, target.progress)) > target.maxRange then
		return false, Yank.Reason.OutOfRange
	end
	target.lockedBy = playerId
	state.sessions[playerId] = { playerId = playerId, targetId = targetId, progress = target.progress }
	return true, Yank.Reason.Ok
end

function Yank.cancel(state: State, playerId: string, now: number, reason: string)
	local session = endSession(state, playerId, true, now)
	if session == nil then return nil end
	return cancelled(session, reason)
end
function Yank.releasePlayer(state: State, playerId: string)
	local session = endSession(state, playerId, false, nil)
	state.cooldownUntil[playerId] = nil
	state.rate[playerId] = nil
	if session == nil then return nil end
	return cancelled(session, Yank.CancelReason.Disconnected)
end

function Yank.step(state: State, dt: number, now: number, ctx: Context, currentPositions: { [string]: Vec3 }?)
	local events = {}
	if not finite(dt) or dt <= 0 then return events end
	for playerId, session in pairs(state.sessions) do
		local target = state.targets[session.targetId]
		local pc = ctx[playerId]
		local current = if currentPositions ~= nil then currentPositions[session.targetId] else nil
		if target == nil then
			table.insert(events, Yank.cancel(state, playerId, now, Yank.CancelReason.TargetInvalid))
		elseif pc == nil or pc.alive ~= true or not validVec(pc.position) then
			table.insert(events, Yank.cancel(state, playerId, now, Yank.CancelReason.Death))
		elseif Yank.distance(pc.position :: Vec3, current or Yank.positionAt(target, session.progress)) > target.maxRange then
			table.insert(events, Yank.cancel(state, playerId, now, Yank.CancelReason.OutOfRange))
		else
			session.progress = math.min(1, session.progress + dt / target.duration)
			target.progress = session.progress
			if session.progress >= 1 then
				target.completed = true
				target.lockedBy = nil
				state.sessions[playerId] = nil
				state.cooldownUntil[playerId] = now + Yank.Defaults.Cooldown
				table.insert(events, { kind = "Completed", playerId = playerId, targetId = target.id, progress = 1 })
			else
				table.insert(events, { kind = "Progress", playerId = playerId, targetId = target.id, progress = session.progress })
			end
		end
	end
	return events
end

function Yank.newMovementRecord(characterKey: any, settings: MovementSettings): MovementRecord
	return {
		characterKey = characterKey,
		settings = { walkSpeed = settings.walkSpeed, useJumpPower = settings.useJumpPower,
			jumpPower = settings.jumpPower, jumpHeight = settings.jumpHeight },
		restored = false,
	}
end
function Yank.canRestore(record: MovementRecord?, liveCharacterKey: any): boolean
	return record ~= nil and not record.restored and liveCharacterKey ~= nil
		and record.characterKey == liveCharacterKey
end
function Yank.markRestored(record: MovementRecord) record.restored = true end

return Yank
