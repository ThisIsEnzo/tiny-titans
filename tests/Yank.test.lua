--!strict
-- Pure rules tests for Drawline Yank. Run: lune run tests/Yank.test.lua
local Yank = require("../src/ReplicatedStorage/Shared/Yank")
local failures = 0
local function check(name: string, ok: boolean)
	if not ok then failures += 1; print("FAIL: " .. name) else print("ok: " .. name) end
end
local function setup()
	local state = Yank.newState()
	Yank.registerTarget(state, { id = "crate", startPos = {x=0,y=0,z=0}, endPos = {x=10,y=0,z=0}, duration=2, maxRange=18 })
	return state
end
local function context(alive: boolean, x: number?)
	return { ["1"] = { alive = alive, position = {x=x or 0,y=0,z=0} } }
end
local function start(state, now: number, alive: boolean?, x: number?)
	return Yank.tryStart(state, { playerId="1", targetId="crate", now=now }, context(alive ~= false, x))
end

do
	local s = setup()
	local ok, reason = start(s, 0, true, 5)
	check("valid start", ok and reason == Yank.Reason.Ok)
	check("target locked", Yank.getTarget(s,"crate").lockedBy == "1")
	check("session starts at zero", Yank.getSession(s,"1").progress == 0)
end
do
	local s = setup()
	local ok, reason = start(s, 0, true, 50)
	check("out of range rejected", not ok and reason == Yank.Reason.OutOfRange)
	check("no lock after rejection", Yank.getTarget(s,"crate").lockedBy == nil)
end
do
	local s = setup()
	local ok, reason = start(s, 0, false, 0)
	check("dead player rejected", not ok and reason == Yank.Reason.Dead)
end
do
	local s = setup()
	start(s,0,true,0)
	local c2 = { ["2"] = { alive=true, position={x=0,y=0,z=0} } }
	local ok, reason = Yank.tryStart(s,{playerId="2",targetId="crate",now=0},c2)
	check("second player cannot acquire locked target", not ok and reason == Yank.Reason.Locked)
end
do
	local s = setup()
	start(s,0,true,0)
	local _, reason = start(s,0.1,true,0)
	check("repeated start rejected", reason == Yank.Reason.AlreadyActive)
end
do
	local s = setup()
	start(s,0,true,0)
	local events = Yank.step(s,0.5,0.5,context(true,0))
	check("progress event emitted", #events == 1 and events[1].kind == "Progress")
	local e = Yank.cancel(s,"1",0.6,Yank.CancelReason.Released)
	check("release cancels", e ~= nil and e.kind == "Cancelled" and e.reason == Yank.CancelReason.Released)
	check("release unlocks target", Yank.getTarget(s,"crate").lockedBy == nil)
	check("partial progress persists", math.abs(Yank.getTarget(s,"crate").progress - 0.25) < 1e-9)
	check("repeat cancel is harmless", Yank.cancel(s,"1",0.7,Yank.CancelReason.Released) == nil)
end
do
	local s = setup()
	start(s,0,true,0)
	local events = Yank.step(s,0.2,0.2,context(false,0))
	check("death cancels active session", #events == 1 and events[1].reason == Yank.CancelReason.Death)
	check("death releases lock", Yank.getTarget(s,"crate").lockedBy == nil)
end
do
	local s = setup()
	start(s,0,true,0)
	Yank.step(s,1,1,context(true,0))
	local events = Yank.step(s,0.1,1.1,context(true,30),{crate={x=5,y=0,z=0}})
	check("moving out of range cancels", #events == 1 and events[1].reason == Yank.CancelReason.OutOfRange)
end
do
	local s = setup()
	start(s,0,true,0)
	local events = Yank.step(s,0.5,0.5,context(true,0))
	check("target unregister returns cancellation", Yank.unregisterTarget(s,"crate") ~= nil)
	check("target unregister clears session", Yank.getSession(s,"1") == nil)
	check("target unregister removes target", Yank.getTarget(s,"crate") == nil)
end
do
	local s = setup()
	local payload = {targetId="crate",progress=1,position={x=999,y=0,z=0},speed=999,duration=0.01}
	check("payload sanitizer keeps only id", Yank.sanitizeStartPayload(payload) == "crate")
	local malformed = Yank.sanitizeStartPayload({targetId=7})
	check("malformed target id rejected", malformed == nil)
	local ok = Yank.tryStart(s,{playerId="1",targetId=Yank.sanitizeStartPayload(payload),now=0},context(true,0))
	check("forged progress ignored", ok and Yank.getSession(s,"1").progress == 0)
	check("duration remains server-owned", Yank.getTarget(s,"crate").duration == 2)
end
do
	local s = setup()
	local count = 0
	for _=1,40 do if not Yank.throttle(s,"1",0) then count += 1 end end
	check("rate limit blocks after allowance", count == 40 - Yank.Defaults.RateMax)
	local _, reason = start(s,0,true,0)
	check("rate limit blocks action", reason == Yank.Reason.RateLimited)
	check("rate window resets", Yank.throttle(s,"1",1.01))
end
do
	local s = setup()
	start(s,0,true,0)
	local completions = 0
	for _=1,6 do
		for _, event in ipairs(Yank.step(s,0.5,1,context(true,0))) do
			if event.kind == "Completed" then completions += 1 end
		end
	end
	check("completion fires once", completions == 1)
	check("completed state persists", Yank.getTarget(s,"crate").completed)
	check("completion clears lock and session", Yank.getTarget(s,"crate").lockedBy == nil and Yank.getSession(s,"1") == nil)
	local _, reason = Yank.tryStart(s,{playerId="1",targetId="crate",now=99},context(true,0))
	check("completed target cannot restart", reason == Yank.Reason.Completed)
end
do
	local s = setup()
	start(s,0,true,0)
	Yank.step(s,0.5,0.5,context(true,0)) -- target is now at x=2.5
	Yank.cancel(s,"1",0.6,Yank.CancelReason.Released)
	-- x=20 is outside the original start range (20 > 18), but within range of
	-- the persisted current position (20 - 2.5 = 17.5).
	local c2 = { ["2"] = { alive=true, position={x=20,y=0,z=0} } }
	local ok = Yank.tryStart(s,{playerId="2",targetId="crate",now=0.2},c2)
	check("target can be reacquired from its persisted current position", ok)
end
do
	local rec = Yank.newMovementRecord("character-A",{walkSpeed=16,useJumpPower=false,jumpPower=50,jumpHeight=7.2})
	check("movement restores only on same character", Yank.canRestore(rec,"character-A"))
	check("movement never restores onto replacement character", not Yank.canRestore(rec,"character-B"))
	Yank.markRestored(rec)
	check("movement restoration is single-shot", not Yank.canRestore(rec,"character-A"))
end
if failures > 0 then error(failures .. " Yank test(s) failed") end
print("all Yank tests passed")
