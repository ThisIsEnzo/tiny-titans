--!strict
-- Optional unit tests for the pure life-cycle rules in Shared/Life.lua.
-- Run with Lune from the repository root:  lune run tests/Life.test.lua
-- Lune is NOT part of rokit.toml; this file is outside the Rojo project tree.
--
-- These tests prove the transition rules only. Section 12 replays signal orderings through
-- the pure rules the way LifeService uses them, with plain tables standing in for players;
-- it does NOT prove the Roblox wiring (Humanoid.Died, CharacterAdded/Removing, PlayerRemoving,
-- BindableEvents, connection cleanup). That needs Studio (README checklist).

local Life = require("../src/ReplicatedStorage/Shared/Life")

local failures = 0
local function check(name: string, condition: boolean)
    if not condition then
        failures += 1
        print("FAIL: " .. name)
    else
        print("ok:   " .. name)
    end
end

-- 1. Initial state.
local initial = Life.Initial()
check("1: initial state is Ended", initial.state == "Ended")
check("1: initial lifeId is 0", initial.lifeId == 0)
check("1: initial record is valid and not alive", Life.IsValid(initial) and not Life.IsAlive(initial))
check("1: records are frozen", table.isfrozen(initial))
check("1: each Initial() is a fresh table", Life.Initial() ~= initial)

-- 2. First life.
local first, firstReason = Life.Begin(initial)
check("2: first Begin is Ok", firstReason == "Ok")
check("2: state is Alive", first.state == "Alive")
check("2: lifeId is 1", first.lifeId == 1)
check("2: Begin returns a new record and leaves the old one alone", first ~= initial and initial.state == "Ended" and initial.lifeId == 0)
check("2: alive record is valid and alive", Life.IsValid(first) and Life.IsAlive(first))

-- 3. Beginning while Alive is rejected.
local again, againReason = Life.Begin(first)
check("3: Begin while Alive is rejected", againReason == "AlreadyAlive")
check("3: rejected Begin returns the same record", again == first)
check("3: lifeId did not change", again.lifeId == 1 and again.state == "Alive")

-- 4 and 5. Ending changes state, not lifeId.
local ended, endedReason = Life.End(first, nil)
check("4: End of an Alive life is Ok", endedReason == "Ok")
check("4: state is Ended", ended.state == "Ended")
check("5: End does not change lifeId", ended.lifeId == 1)
check("4: End returns a new record", ended ~= first and first.state == "Alive")
check("4: ended record is valid and not alive", Life.IsValid(ended) and not Life.IsAlive(ended))
local endedWithId, endedWithIdReason = Life.End(first, 1)
check("4: End with the matching lifeId is Ok", endedWithIdReason == "Ok" and endedWithId.state == "Ended" and endedWithId.lifeId == 1)

-- 6. Ending an already-ended life is idempotent.
local twice, twiceReason = Life.End(ended, nil)
check("6: second End is rejected", twiceReason == "AlreadyEnded")
check("6: second End returns the same record", twice == ended)
local twiceWithId, twiceWithIdReason = Life.End(ended, 1)
check("6: second End with the right lifeId is also AlreadyEnded", twiceWithIdReason == "AlreadyEnded" and twiceWithId == ended)
local fresh, freshReason = Life.End(initial, nil)
check("6: ending before any life is AlreadyEnded", freshReason == "AlreadyEnded" and fresh == initial and fresh.lifeId == 0)

-- 7. Begin after End.
local second, secondReason = Life.Begin(ended)
check("7: Begin after End is Ok", secondReason == "Ok")
check("7: lifeId is 2 and Alive", second.lifeId == 2 and second.state == "Alive")

-- 8. Repeated cycles: lifeId rises exactly once per Begin and never on End.
do
    local record = Life.Initial()
    local monotonic = true
    local beginsOk = 0
    local endsOk = 0
    for cycle = 1, 50 do
        local beforeBegin = record.lifeId
        local afterBegin, beginResult = Life.Begin(record)
        if beginResult == "Ok" then
            beginsOk += 1
        end
        if afterBegin.lifeId ~= beforeBegin + 1 or afterBegin.lifeId ~= cycle then
            monotonic = false
        end
        local afterEnd, endResult = Life.End(afterBegin, afterBegin.lifeId)
        if endResult == "Ok" then
            endsOk += 1
        end
        if afterEnd.lifeId ~= afterBegin.lifeId then
            monotonic = false
        end
        record = afterEnd
    end
    check("8: 50 cycles, every Begin and End Ok", beginsOk == 50 and endsOk == 50)
    check("8: lifeId rose by exactly one per Begin and never on End", monotonic)
    check("8: final record is Ended with lifeId 50", record.state == "Ended" and record.lifeId == 50)
end

-- 9. Stale events cannot end a newer life.
do
    local life1 = select(1, Life.Begin(Life.Initial()))
    local afterEnd1 = select(1, Life.End(life1, 1))
    local life2 = select(1, Life.Begin(afterEnd1))
    local result, reason = Life.End(life2, 1) -- a delayed signal from life 1
    check("9: stale End is rejected", reason == "StaleLifeId")
    check("9: stale End returns the same record, life 2 stays Alive", result == life2 and result.state == "Alive" and result.lifeId == 2)
    check("9: a lifeId from the future is also stale", select(2, Life.End(life2, 3)) == "StaleLifeId")
    check("9: IsCurrent is true only for the current life", Life.IsCurrent(life2, 2) and not Life.IsCurrent(life2, 1) and not Life.IsCurrent(life2, 3))
    check("9: IsCurrent is false once the life has ended", not Life.IsCurrent(afterEnd1, 1))
    local ok2, reason2 = Life.End(life2, 2)
    check("9: the matching lifeId still ends it", reason2 == "Ok" and ok2.state == "Ended" and ok2.lifeId == 2)
    check("9: a stale End on an Ended record reports StaleLifeId", select(2, Life.End(afterEnd1, 5)) == "StaleLifeId")
end

-- 10. Invalid records and arguments are handled safely (no errors, no state change).
do
    local garbage: { any } = {
        "Alive",
        42,
        true,
        {},
        { state = "Alive" },
        { lifeId = 1 },
        { state = "Dead", lifeId = 1 },
        { state = "Alive", lifeId = 0 },
        { state = "Alive", lifeId = -1 },
        { state = "Ended", lifeId = -1 },
        { state = "Ended", lifeId = 1.5 },
        { state = "Ended", lifeId = 0 / 0 },
        { state = "Ended", lifeId = math.huge },
        { state = "Ended", lifeId = "1" },
        { state = "alive", lifeId = 1 },
    }
    local allRejected = true
    local allUnchanged = true
    for _, value in garbage do
        if Life.IsValid(value) or Life.IsAlive(value) then
            allRejected = false
        end
        local beginRecord, beginReason = Life.Begin(value :: any)
        local endRecord, endReason = Life.End(value :: any, nil)
        if beginReason ~= "Invalid" or endReason ~= "Invalid" then
            allRejected = false
        end
        if beginRecord ~= value or endRecord ~= value then
            allUnchanged = false
        end
    end
    check("10: malformed records are invalid and rejected by Begin and End", allRejected)
    check("10: rejected transitions return the input unchanged", allUnchanged)
    check("10: nil is not a valid record", not Life.IsValid(nil))
    check("10: End with a non-number lifeId is Invalid", select(2, Life.End(first, "1" :: any)) == "Invalid")
    check("10: End with a NaN lifeId is Invalid", select(2, Life.End(first, 0 / 0)) == "Invalid")
    check("10: End with a negative lifeId is Invalid", select(2, Life.End(first, -1)) == "Invalid")
    check("10: End with a fractional lifeId is Invalid", select(2, Life.End(first, 1.5)) == "Invalid")
    check("10: IsCurrent with bad arguments is false, not an error", not Life.IsCurrent(first, nil) and not Life.IsCurrent(first, "1") and not Life.IsCurrent(nil, 1))
end

-- 11. Independent players: separate records never interfere.
do
    local players: { [string]: any } = { A = Life.Initial(), B = Life.Initial() }
    players.A = select(1, Life.Begin(players.A))
    check("11: B is untouched when A begins", players.B.state == "Ended" and players.B.lifeId == 0)
    players.B = select(1, Life.Begin(players.B))
    players.A = select(1, Life.End(players.A, 1))
    check("11: ending A leaves B Alive", players.A.state == "Ended" and players.B.state == "Alive" and players.B.lifeId == 1)
    players.A = select(1, Life.Begin(players.A))
    players.A = select(1, Life.End(players.A, 2))
    players.A = select(1, Life.Begin(players.A))
    check("11: A is on lifeId 3 while B is still on lifeId 1", players.A.lifeId == 3 and players.B.lifeId == 1)
    local stale = select(2, Life.End(players.B, 3)) -- A's lifeId used against B's record
    check("11: an event carrying another player's lifeId is stale for B", stale == "StaleLifeId" and players.B.state == "Alive")
end

-- 12. Signal orderings replayed through the pure rules, as LifeService applies them.
-- (Model only: a "signal" here is a function call, not a Roblox event.)
do
    local record = Life.Initial()
    local endedEvents = {}
    local beganEvents = {}
    local function characterAdded()
        if Life.IsAlive(record) then
            local nextRecord, reason = Life.End(record, record.lifeId)
            if reason == "Ok" then
                record = nextRecord
                table.insert(endedEvents, record.lifeId)
            end
        end
        local nextRecord, reason = Life.Begin(record)
        if reason == "Ok" then
            record = nextRecord
            table.insert(beganEvents, record.lifeId)
        end
    end
    local function endCurrent(capturedLifeId: number)
        local nextRecord, reason = Life.End(record, capturedLifeId)
        if reason == "Ok" then
            record = nextRecord
            table.insert(endedEvents, record.lifeId)
        end
    end

    characterAdded() -- join: life 1
    check("12: join begins life 1 once", #beganEvents == 1 and beganEvents[1] == 1 and record.state == "Alive")
    endCurrent(1) -- Humanoid.Died
    endCurrent(1) -- CharacterRemoving for the same character
    check("12: Died then CharacterRemoving ends life 1 exactly once", #endedEvents == 1 and endedEvents[1] == 1 and record.state == "Ended")
    characterAdded() -- automatic respawn: life 2
    check("12: respawn begins life 2 once", #beganEvents == 2 and beganEvents[2] == 2 and record.state == "Alive")
    endCurrent(1) -- a delayed Died from the first character
    check("12: a delayed signal from life 1 does not end life 2", #endedEvents == 1 and record.state == "Alive" and record.lifeId == 2)
    characterAdded() -- replacement while Alive
    check("12: replacement ends life 2 then begins life 3", #endedEvents == 2 and endedEvents[2] == 2 and #beganEvents == 3 and beganEvents[3] == 3)
    check("12: never two Alive lives and lifeId rose once per new character", record.state == "Alive" and record.lifeId == 3)
    endCurrent(3) -- PlayerRemoving while Alive
    endCurrent(3) -- repeated leave signal
    check("12: leaving while Alive ends life 3 once", #endedEvents == 3 and endedEvents[3] == 3 and record.state == "Ended")
    local lifeIdsUnique = true
    for i = 2, #endedEvents do
        if endedEvents[i] == endedEvents[i - 1] then
            lifeIdsUnique = false
        end
    end
    check("12: no lifeId was ended twice", lifeIdsUnique)
end

-- Reasons are fixed, distinct strings.
do
    local reasons = Life.EndReason
    check("reasons: expected values", reasons.HumanoidDied == "HumanoidDied" and reasons.CharacterRemoving == "CharacterRemoving" and reasons.CharacterReplaced == "CharacterReplaced" and reasons.PlayerRemoving == "PlayerRemoving")
    check("reasons: table is frozen", table.isfrozen(reasons))
end

if failures > 0 then
    error(failures .. " test(s) failed")
end
print("all tests passed")
