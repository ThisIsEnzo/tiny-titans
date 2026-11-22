--!strict
local Rules=require("../src/ReplicatedStorage/Shared/AncientWeight")
local failures=0
local function check(name: string,ok: boolean)
	if not ok then failures+=1; print("FAIL "..name) else print("ok "..name) end
end
local destination={x=126,y=3,z=0}
local function setup()
	return Rules.newPuzzle({puzzleId="p",blockId="b",destination=destination,tolerance=1.5,settleSpeed=.5})
end
local function observation(x: number,y: number?,z: number?,speed: number?,id: string?)
	return {blockId=id or "b",position={x=x,y=y or 3,z=z or 0},speed=speed or 0}
end
do
	local p=setup()
	check("initial Locked",p.state==Rules.State.Locked)
	local ok,why=Rules.evaluate(p,observation(110))
	check("wrong position rejected",not ok and why==Rules.Reject.OutOfRange)
	ok,why=Rules.evaluate(p,observation(126,3,0,2))
	check("moving block rejected",not ok and why==Rules.Reject.NotSettled)
	ok,why=Rules.evaluate(p,observation(126,3,0,0,"other"))
	check("wrong target rejected",not ok and why==Rules.Reject.WrongBlock)
	ok=Rules.evaluate(p,observation(127,3,0))
	check("inside tolerance accepted",ok)
	ok=Rules.evaluate(p,observation(128,3,0))
	check("outside tolerance rejected",not ok)
	ok=Rules.evaluate(p,{blockId="b",position={x=126,y=3,z=0}})
	check("missing speed rejected",not ok)
	-- Solving is idempotent under repeated/concurrent callers.
	local granted=0
	for i=1,64 do if Rules.markSolved(p,i) then granted+=1 end end
	check("exactly one solve grant",granted==1)
	check("state remains Solved",p.state==Rules.State.Solved and p.solvedAt==1)
	ok,why=Rules.evaluate(p,observation(126,3,0))
	check("solved puzzle rejects repeat",not ok and why==Rules.Reject.AlreadySolved)
	Rules.setBlockMissing(p,true)
	check("removal does not erase solved state",p.state==Rules.State.Solved)
end
do
	local p=setup()
	Rules.setBlockMissing(p,true)
	local ok,why=Rules.evaluate(p,observation(126))
	check("missing block cannot solve",not ok and why==Rules.Reject.BlockMissing)
	Rules.setBlockMissing(p,false)
	check("restored block can solve",Rules.evaluate(p,observation(126)))
end
check("malformed config rejected",Rules.newPuzzle({puzzleId="p",blockId="b",destination="bad"})==nil)
check("invalid tolerance rejected",Rules.newPuzzle({puzzleId="p",blockId="b",destination=destination,tolerance=0})==nil)
if failures>0 then error(tostring(failures).." AncientWeight tests failed") end
print("all AncientWeight tests passed")
