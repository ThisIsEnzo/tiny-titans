--!strict
-- Pure server puzzle rules. Drawline Yank owns all block movement.
local AncientWeight = {}

AncientWeight.State = table.freeze({ Locked = "Locked", Solved = "Solved" })
AncientWeight.Reject = table.freeze({
	AlreadySolved = "AlreadySolved", BlockMissing = "BlockMissing", WrongBlock = "WrongBlock",
	InvalidPosition = "InvalidPosition", InvalidObservation = "InvalidObservation",
	NotSettled = "NotSettled", OutOfRange = "OutOfRange", Ok = "Ok",
})
AncientWeight.Defaults = table.freeze({ Tolerance = 1.5, SettleSpeed = 0.5 })

export type Vec3 = { x: number, y: number, z: number }
export type Puzzle = {
	id: string, blockId: string, destination: Vec3, tolerance: number, settleSpeed: number,
	state: string, blockMissing: boolean, solvedAt: number?,
}

local function finite(n: any): boolean
	return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end
local function validId(v: any): boolean
	return type(v) == "string" and #v > 0 and #v <= 64
end
local function validVec(v: any): boolean
	return type(v) == "table" and finite(v.x) and finite(v.y) and finite(v.z)
end

function AncientWeight.distance(a: Vec3, b: Vec3): number
	local x, y, z = a.x-b.x, a.y-b.y, a.z-b.z
	return math.sqrt(x*x + y*y + z*z)
end

function AncientWeight.newPuzzle(config: any): Puzzle?
	if type(config) ~= "table" or not validId(config.puzzleId) or not validId(config.blockId)
		or not validVec(config.destination) then return nil end
	local tolerance = config.tolerance
	local settle = config.settleSpeed
	if tolerance == nil then tolerance = AncientWeight.Defaults.Tolerance end
	if settle == nil then settle = AncientWeight.Defaults.SettleSpeed end
	if not finite(tolerance) or tolerance <= 0 or not finite(settle) or settle < 0 then return nil end
	return {
		id = config.puzzleId, blockId = config.blockId,
		destination = { x=config.destination.x, y=config.destination.y, z=config.destination.z },
		tolerance = tolerance, settleSpeed = settle, state=AncientWeight.State.Locked,
		blockMissing=false, solvedAt=nil,
	}
end

function AncientWeight.evaluate(puzzle: Puzzle, observation: any): (boolean, string)
	if puzzle.state ~= AncientWeight.State.Locked then return false, AncientWeight.Reject.AlreadySolved end
	if puzzle.blockMissing then return false, AncientWeight.Reject.BlockMissing end
	if type(observation) ~= "table" then return false, AncientWeight.Reject.InvalidObservation end
	if observation.blockId ~= puzzle.blockId then return false, AncientWeight.Reject.WrongBlock end
	if not validVec(observation.position) then return false, AncientWeight.Reject.InvalidPosition end
	if not finite(observation.speed) or observation.speed < 0 then return false, AncientWeight.Reject.InvalidObservation end
	if observation.speed > puzzle.settleSpeed then return false, AncientWeight.Reject.NotSettled end
	if AncientWeight.distance(observation.position, puzzle.destination) > puzzle.tolerance then
		return false, AncientWeight.Reject.OutOfRange
	end
	return true, AncientWeight.Reject.Ok
end

function AncientWeight.markSolved(puzzle: Puzzle, now: number): boolean
	if puzzle.state ~= AncientWeight.State.Locked then return false end
	puzzle.state = AncientWeight.State.Solved
	puzzle.solvedAt = now
	return true
end

function AncientWeight.setBlockMissing(puzzle: Puzzle, missing: boolean)
	puzzle.blockMissing = missing
end

return AncientWeight
