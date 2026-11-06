--!strict
-- Optional unit tests for the pure reset rules in Shared/LifeReset.lua (P1-03).
-- Run with Lune from the repository root:  lune run tests/LifeReset.test.lua
-- Lune is NOT part of rokit.toml; this file is outside the Rojo project tree.
--
-- "Players" here are plain tables. Section 2 replays LifeService event orderings through the
-- pure rules exactly the way ResetService uses them, with the real Growth, Evolution and
-- Ability rules providing the gameplay side. This proves the decisions (exactly once per
-- lifeId, duplicates, stale events, removed players, clean next life). It does NOT prove the
-- Roblox wiring: BindableEvent delivery, the service reset APIs, attributes, tweens, instance
-- cleanup, or that the reset really happens on Humanoid death. That needs Studio (README).

local Config = require("../src/ReplicatedStorage/Shared/Config")
local Growth = require("../src/ReplicatedStorage/Shared/Growth")
local Evolution = require("../src/ReplicatedStorage/Shared/Evolution")
local Ability = require("../src/ReplicatedStorage/Shared/Ability")
local LifeReset = require("../src/ReplicatedStorage/Shared/LifeReset")

local failures = 0
local function check(name: string, condition: boolean)
    if not condition then
        failures += 1
        print("FAIL: " .. name)
    else
        print("ok:   " .. name)
    end
end

local cap = Config.EvolutionBiomassRequired
local stages = Config.GrowthStages
local Outcome = LifeReset.Outcome

-- ---------------------------------------------------------------------------
-- 1. The decision rules on their own.
-- ---------------------------------------------------------------------------
do
    local t = LifeReset.NewTracker()
    check("1: a new tracker has reset nothing", t.lastResetLifeId == 0)
    check("1: trackers are independent tables", LifeReset.NewTracker() ~= t)
    check("1: first ended life is reset", LifeReset.DecideEnded(t, 1, 1) == Outcome.Reset)
    check("1: ended life that is no longer current is stale", LifeReset.DecideEnded(t, 1, 2) == Outcome.Stale)
    check("1: a removed player (no current life) is NoPlayer", LifeReset.DecideEnded(t, 1, nil) == Outcome.NoPlayer)
    LifeReset.Commit(t, 1)
    check("1: after commit the same life is a duplicate", LifeReset.DecideEnded(t, 1, 1) == Outcome.Duplicate)
    check("1: after commit an older life is a duplicate", LifeReset.DecideEnded(t, 1, 3) == Outcome.Duplicate)
    check("1: the next life is not a duplicate", LifeReset.DecideEnded(t, 2, 2) == Outcome.Reset)
    LifeReset.Commit(t, 0)
    check("1: commit never moves backwards", t.lastResetLifeId == 1)
    local bad: { any } = { 0, -1, 1.5, 0 / 0, math.huge, "1", true, {}, false }
    local allInvalid = true
    for _, value in bad do
        if LifeReset.DecideEnded(LifeReset.NewTracker(), value, 1) ~= Outcome.Invalid then
            allInvalid = false
        end
        if LifeReset.DecideEnded(LifeReset.NewTracker(), 1, value) ~= Outcome.Invalid then
            allInvalid = false
        end
    end
    check("1: malformed ids are Invalid", allInvalid)
    check("1: nil ended id is Invalid", LifeReset.DecideEnded(LifeReset.NewTracker(), nil, 1) == Outcome.Invalid)
    local began = LifeReset.NewTracker()
    local firstOutcome = LifeReset.DecideBegan(began, 1)
    check("1: the first life needs no reset", firstOutcome == Outcome.None)
    local missedOutcome, missedId = LifeReset.DecideBegan(began, 2)
    check("1: a new life reports a missed reset of the previous life", missedOutcome == Outcome.Reset and missedId == 1)
    LifeReset.Commit(began, 1)
    check("1: no missed reset once the previous life was reset", LifeReset.DecideBegan(began, 2) == Outcome.None)
    check("1: malformed new life id is Invalid", LifeReset.DecideBegan(began, 0) == Outcome.Invalid)
    check("1: outcomes table is frozen", table.isfrozen(Outcome))
    check("1: starting biomass is 0 and below every stage threshold", LifeReset.StartingBiomass == 0 and LifeReset.StartingBiomass < stages[2].MinBiomass)
end

-- ---------------------------------------------------------------------------
-- 2. Event orderings replayed through the rules, with real Growth/Evolution/Ability rules.
-- ---------------------------------------------------------------------------
type Sim = {
    name: string,
    currentLifeId: number?, -- nil once the player has left
    tracker: LifeReset.Tracker,
    biomass: number,
    form: string,
    shellReadyAt: number,
    resets: number,
}

local function newPlayer(name: string): Sim
    return {
        name = name,
        currentLifeId = 0,
        tracker = LifeReset.NewTracker(),
        biomass = 0,
        form = Config.BaseForm,
        shellReadyAt = 0,
        resets = 0,
    }
end

-- What ResetService's resetCurrentLife does, expressed with the same constants.
local function applyReset(p: Sim)
    p.biomass = LifeReset.StartingBiomass
    p.form = Config.BaseForm
    p.shellReadyAt = 0
    p.resets += 1
end

-- LifeService begins a life (LifeBegan), then the handler runs.
local function beginLife(p: Sim): string
    local id = (p.currentLifeId or 0) + 1
    p.currentLifeId = id
    return LifeReset.OnBegan(p.tracker, id, function()
        applyReset(p)
    end)
end

-- LifeService reports the end of life `id`; `deliver` runs the handler for that event.
local function deliverEnded(p: Sim, id: number): string
    return LifeReset.OnEnded(p.tracker, id, p.currentLifeId, function()
        applyReset(p)
    end)
end

local function eat(p: Sim)
    local updated = Growth.AddBiomass(p.biomass, Config.FoodBiomass, cap)
    p.biomass = updated
end

local function tryEvolve(p: Sim, form: string): string
    local newForm, reason = Evolution.Select(form, p.biomass, cap, p.form, Config.BaseForm, Config.EvolutionForms)
    p.form = newForm
    return reason
end

local function fillAndEvolve(p: Sim, form: string)
    for _ = 1, 10 do
        eat(p)
    end
    tryEvolve(p, form)
end

-- 2.1 Existing progression before death is unchanged and nothing is reset.
do
    local p = newPlayer("A")
    beginLife(p)
    for _ = 1, 3 do
        eat(p)
    end
    check("2.1: three foods reach stage 2", p.biomass == 30 and Growth.GetStageIndex(p.biomass, stages) == 2)
    for _ = 1, 3 do
        eat(p)
    end
    check("2.1: six foods reach stage 3", p.biomass == 60 and Growth.GetStageIndex(p.biomass, stages) == 3)
    for _ = 1, 10 do
        eat(p)
    end
    check("2.1: biomass stops at the cap", p.biomass == cap)
    check("2.1: evolution is available at the cap", Evolution.IsAvailable(p.biomass, cap, p.form, Config.BaseForm))
    check("2.1: evolving works", tryEvolve(p, "TANK") == "Ok" and p.form == "TANK")
    check("2.1: nothing was reset during the life", p.resets == 0)
    check("2.1: thresholds, cap and reward are unchanged", stages[1].MinBiomass == 0 and stages[2].MinBiomass == 30 and stages[3].MinBiomass == 60 and cap == 100 and Config.FoodBiomass == 10)
end

-- 2.2 Ending a life resets biomass, form, growth state and ability cooldown.
do
    local p = newPlayer("A")
    beginLife(p)
    fillAndEvolve(p, "GLIDER")
    p.shellReadyAt = 12345
    check("2.2: setup: evolved Glider at the cap", p.form == "GLIDER" and p.biomass == cap)
    check("2.2: the ended life is reset", deliverEnded(p, 1) == Outcome.Reset)
    check("2.2: biomass is 0", p.biomass == 0)
    check("2.2: form is BABY_BUG", p.form == Config.BaseForm)
    check("2.2: growth stage is the initial stage 1", Growth.GetStageIndex(p.biomass, stages) == 1)
    check("2.2: growth scale is the stage 1 scale and must be applied afresh", Growth.GetScale(1, stages) == stages[1].Scale and Growth.ShouldUpdateScale(nil, stages[1].Scale))
    check("2.2: evolution is not available after the reset", not Evolution.IsAvailable(p.biomass, cap, p.form, Config.BaseForm))
    check("2.2: the cooldown is cleared", Ability.GetCooldownRemaining(1, p.shellReadyAt) == 0)
    check("2.2: reset ran once", p.resets == 1)
end

-- 2.3 Exactly once per lifeId, duplicates ignored.
do
    local p = newPlayer("A")
    beginLife(p)
    fillAndEvolve(p, "TANK")
    local first = deliverEnded(p, 1)
    eat(p) -- state changes after the reset; a duplicate must not wipe it
    local second = deliverEnded(p, 1)
    local third = deliverEnded(p, 1)
    check("2.3: first delivery resets", first == Outcome.Reset)
    check("2.3: duplicates are ignored", second == Outcome.Duplicate and third == Outcome.Duplicate)
    check("2.3: only one reset happened", p.resets == 1)
    check("2.3: a duplicate does not wipe state gained after the reset", p.biomass == Config.FoodBiomass)
end

-- 2.4 Two independent players.
do
    local a = newPlayer("A")
    local b = newPlayer("B")
    beginLife(a)
    beginLife(b)
    fillAndEvolve(a, "TANK")
    fillAndEvolve(b, "GLIDER")
    deliverEnded(a, 1)
    check("2.4: A was reset", a.biomass == 0 and a.form == Config.BaseForm and a.resets == 1)
    check("2.4: B is untouched", b.biomass == cap and b.form == "GLIDER" and b.resets == 0)
    check("2.4: A's tracker does not affect B's", b.tracker.lastResetLifeId == 0 and a.tracker.lastResetLifeId == 1)
    deliverEnded(b, 1)
    check("2.4: B resets once on its own life end", b.resets == 1 and b.biomass == 0 and a.resets == 1)
end

-- 2.5 A late LifeEnded from an old life cannot reset a newer life (the usual order).
do
    local p = newPlayer("A")
    beginLife(p)
    fillAndEvolve(p, "TANK")
    check("2.5: life 1 ends and is reset", deliverEnded(p, 1) == Outcome.Reset)
    check("2.5: life 2 begins without a second reset", beginLife(p) == Outcome.None)
    eat(p)
    eat(p)
    check("2.5: the new life gains biomass", p.biomass == 2 * Config.FoodBiomass)
    check("2.5: a late LifeEnded(1) is a duplicate", deliverEnded(p, 1) == Outcome.Duplicate)
    check("2.5: the new life is untouched", p.biomass == 2 * Config.FoodBiomass and p.resets == 1)
end

-- 2.6 Stale event: the next life began BEFORE the LifeEnded handler ran (for example a
-- replaced character). The late event must not reset the new life; the reset happens when
-- the new life begins, before it has any state.
do
    local p = newPlayer("A")
    beginLife(p)
    fillAndEvolve(p, "GLIDER")
    -- LifeService fired LifeEnded(1) then LifeBegan(2) back to back; deferred handlers run now.
    p.currentLifeId = 2
    check("2.6: the late LifeEnded(1) is stale and resets nothing", deliverEnded(p, 1) == Outcome.Stale)
    check("2.6: so far nothing was reset", p.resets == 0 and p.biomass == cap)
    local beganOutcome = LifeReset.OnBegan(p.tracker, 2, function()
        applyReset(p)
    end)
    check("2.6: the LifeBegan handler performs the missed reset", beganOutcome == Outcome.Reset and p.resets == 1)
    check("2.6: the new life starts clean", p.biomass == 0 and p.form == Config.BaseForm)
    eat(p)
    check("2.6: a repeat of the stale event is now a duplicate and keeps new-life state", deliverEnded(p, 1) == Outcome.Duplicate and p.biomass == Config.FoodBiomass)
end

-- 2.7 A callback from an old life cannot modify the new life, several lives deep.
do
    local p = newPlayer("A")
    beginLife(p)
    deliverEnded(p, 1)
    beginLife(p)
    fillAndEvolve(p, "TANK")
    deliverEnded(p, 2)
    beginLife(p) -- life 3
    eat(p)
    eat(p)
    eat(p)
    local lateOld = deliverEnded(p, 2)
    local lateOlder = deliverEnded(p, 1)
    check("2.7: late events from lives 1 and 2 do nothing", lateOld == Outcome.Duplicate and lateOlder == Outcome.Duplicate)
    check("2.7: life 3 keeps its progress", p.biomass == 3 * Config.FoodBiomass and p.form == Config.BaseForm)
    check("2.7: exactly one reset per ended life", p.resets == 2)
    check("2.7: an event for a life that has not ended yet is not accepted as old", deliverEnded(p, 4) == Outcome.Stale)
end

-- 2.8 Player removal.
do
    local a = newPlayer("A")
    local b = newPlayer("B")
    beginLife(a)
    beginLife(b)
    fillAndEvolve(a, "TANK")
    fillAndEvolve(b, "TANK")
    a.currentLifeId = nil -- A left: LifeService has no record any more
    check("2.8: LifeEnded for a removed player does nothing", deliverEnded(a, 1) == Outcome.NoPlayer)
    check("2.8: no reset was applied to the removed player", a.resets == 0)
    check("2.8: another player is unaffected", b.biomass == cap and b.form == "TANK" and b.resets == 0)
    check("2.8: the removed player's tracker was not marked", a.tracker.lastResetLifeId == 0)
end

-- 2.9 A new life collects food and evolves normally after a reset.
do
    local p = newPlayer("A")
    beginLife(p)
    fillAndEvolve(p, "TANK")
    deliverEnded(p, 1)
    beginLife(p)
    check("2.9: the new life starts at 0 as BABY_BUG", p.biomass == 0 and p.form == Config.BaseForm)
    check("2.9: it cannot evolve before the threshold", tryEvolve(p, "GLIDER") == "ThresholdNotReached")
    for _ = 1, 3 do
        eat(p)
    end
    check("2.9: it grows through the same thresholds (stage 2 at 30)", Growth.GetStageIndex(p.biomass, stages) == 2)
    for _ = 1, 7 do
        eat(p)
    end
    check("2.9: it reaches the cap again", p.biomass == cap)
    check("2.9: it can evolve again, to the other form", tryEvolve(p, "GLIDER") == "Ok" and p.form == "GLIDER")
    check("2.9: a second death resets the second life once", deliverEnded(p, 2) == Outcome.Reset and p.biomass == 0 and p.form == Config.BaseForm and p.resets == 2)
end

-- 2.10 Reset eligibility never depends on a client value: the rules take only server ids.
do
    local p = newPlayer("A")
    beginLife(p)
    fillAndEvolve(p, "TANK")
    local outcome = LifeReset.OnEnded(p.tracker, "1", p.currentLifeId, function()
        applyReset(p)
    end)
    check("2.10: a string lifeId is rejected and resets nothing", outcome == Outcome.Invalid and p.resets == 0)
    outcome = LifeReset.OnEnded(p.tracker, nil, p.currentLifeId, function()
        applyReset(p)
    end)
    check("2.10: a nil lifeId is rejected and resets nothing", outcome == Outcome.Invalid and p.resets == 0)
    check("2.10: state is untouched by rejected events", p.biomass == cap and p.form == "TANK")
end

if failures > 0 then
    error(failures .. " test(s) failed")
end
print("all tests passed")
