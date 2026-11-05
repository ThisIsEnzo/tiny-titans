--!strict
-- Optional unit tests for the pure evolution rules.
-- Run with Lune from the repository root:  lune run tests/Evolution.test.lua
-- Lune is NOT part of rokit.toml; this file is outside the Rojo project tree.

local Config = require("../src/ReplicatedStorage/Shared/Config")
local Evolution = require("../src/ReplicatedStorage/Shared/Evolution")
local Ability = require("../src/ReplicatedStorage/Shared/Ability")

local failures = 0
local function check(name: string, condition: boolean)
    if not condition then
        failures += 1
        print("FAIL: " .. name)
    else
        print("ok:   " .. name)
    end
end

local base = Config.BaseForm
local forms = Config.EvolutionForms
local cap = Config.EvolutionBiomassRequired

local function validate(form: any, biomass: number, current: string)
    local ok, reason = Evolution.Validate(form, biomass, cap, current, base, forms)
    return ok, reason
end

check("valid TANK", Evolution.IsValidForm("TANK", forms))
check("valid GLIDER", Evolution.IsValidForm("GLIDER", forms))
check("base form is not a branch", not Evolution.IsValidForm(base, forms))
check("lowercase rejected", not Evolution.IsValidForm("tank", forms))
check("nil rejected", not Evolution.IsValidForm(nil, forms))
check("number rejected", not Evolution.IsValidForm(1, forms))
check("table rejected", not Evolution.IsValidForm({ "TANK" }, forms))
check("empty string rejected", not Evolution.IsValidForm("", forms))

check("not available below threshold", not Evolution.IsAvailable(cap - 1, cap, base, base))
check("available at threshold", Evolution.IsAvailable(cap, cap, base, base))
check("not available once evolved", not Evolution.IsAvailable(cap, cap, "TANK", base))
check("not available for NaN biomass", not Evolution.IsAvailable(0 / 0, cap, base, base))

local ok, reason = validate("TANK", cap, base)
check("accepts TANK at threshold", ok and reason == "Ok")
ok, reason = validate("GLIDER", cap, base)
check("accepts GLIDER at threshold", ok and reason == "Ok")
ok, reason = validate("TANK", cap - 1, base)
check("rejects below threshold", not ok and reason == "ThresholdNotReached")
ok, reason = validate("TANK", 0 / 0, base)
check("rejects NaN biomass", not ok and reason == "ThresholdNotReached")
ok, reason = validate("TANK", cap, "GLIDER")
check("rejects repeat after evolving", not ok and reason == "AlreadyEvolved")
ok, reason = validate("GLIDER", cap, "GLIDER")
check("rejects same branch again", not ok and reason == "AlreadyEvolved")
ok, reason = validate("FLY", cap, base)
check("rejects unknown branch", not ok and reason == "InvalidForm")
ok, reason = validate(base, cap, base)
check("rejects base form as target", not ok and reason == "InvalidForm")
ok, reason = validate(nil, cap, base)
check("rejects nil branch", not ok and reason == "InvalidForm")

local cooldown = Config.EvolutionRequestCooldown
check("cooldown is positive", cooldown > 0)
check("first request is not limited", not Evolution.IsRateLimited(nil, 100, cooldown))
check("request inside cooldown is limited", Evolution.IsRateLimited(100, 100 + cooldown / 2, cooldown))
check("request in the same instant is limited", Evolution.IsRateLimited(100, 100, cooldown))
check("request at exactly the cooldown is allowed", not Evolution.IsRateLimited(100, 100 + cooldown, cooldown))
check("request after the cooldown is allowed", not Evolution.IsRateLimited(100, 100 + cooldown + 1, cooldown))
check("zero interval never limits", not Evolution.IsRateLimited(100, 100, 0))
-- Simulated spam: 1000 requests spread over 1 second, processed ones advance the timestamp.
local last: number? = nil
local processed = 0
for i = 0, 999 do
    local now = i / 1000
    if not Evolution.IsRateLimited(last, now, cooldown) then
        last = now
        processed += 1
    end
end
check("spam over 1s processes at most ceil(1/cooldown) requests", processed <= math.ceil(1 / cooldown))
check("spam still lets the first request through", processed >= 1)

-- Select: the pure state transition used by EvolutionService.
local newForm, selectReason = Evolution.Select("TANK", cap - 1, cap, base, base, forms)
check("select below the threshold keeps the form", newForm == base and selectReason == "ThresholdNotReached")
newForm, selectReason = Evolution.Select("TANK", cap, cap, base, base, forms)
check("select TANK at the threshold", newForm == "TANK" and selectReason == "Ok")
newForm, selectReason = Evolution.Select("GLIDER", cap, cap, base, base, forms)
check("select GLIDER at the threshold", newForm == "GLIDER" and selectReason == "Ok")
newForm, selectReason = Evolution.Select("FLY", cap, cap, base, base, forms)
check("select an unsupported form keeps the form", newForm == base and selectReason == "InvalidForm")
newForm, selectReason = Evolution.Select(nil, cap, cap, base, base, forms)
check("select nil keeps the form", newForm == base and selectReason == "InvalidForm")
newForm, selectReason = Evolution.Select("GLIDER", cap, cap, "TANK", base, forms)
check("switching forms after evolving is rejected", newForm == "TANK" and selectReason == "AlreadyEvolved")
newForm, selectReason = Evolution.Select("TANK", cap, cap, "TANK", base, forms)
check("duplicate selection is rejected without changing state", newForm == "TANK" and selectReason == "AlreadyEvolved")

-- Two players: one selection never touches the other.
local playerForms: { [string]: string } = { A = base, B = base }
playerForms.A = Evolution.Select("TANK", cap, cap, playerForms.A, base, forms)
check("A is TANK, B still BABY_BUG", playerForms.A == "TANK" and playerForms.B == base)
playerForms.B = Evolution.Select("GLIDER", cap - 1, cap, playerForms.B, base, forms)
check("B cannot evolve below the threshold", playerForms.B == base)
playerForms.B = Evolution.Select("GLIDER", cap, cap, playerForms.B, base, forms)
check("B selects GLIDER independently", playerForms.A == "TANK" and playerForms.B == "GLIDER")

-- Evolution readiness (existing behaviour must not change).
check("not ready at 99 biomass", not Evolution.IsAvailable(99, cap, base, base))
check("ready at 100 biomass", Evolution.IsAvailable(100, cap, base, base))
check("not ready again after evolving", not Evolution.IsAvailable(100, cap, "GLIDER", base))

-- Forms and abilities: each form can only use its own ability.
check("TANK cannot use the glide", not (Ability.ValidateGlide("TANK", true, true, 100, 0, 0, Config.GliderForm)))
check("GLIDER cannot use the shell", not (Ability.Validate("GLIDER", true, 100, 0, 0, Config.TankShellForm)))
check("TANK can use the shell", (Ability.Validate("TANK", true, 100, 0, 0, Config.TankShellForm)))
check("GLIDER can glide in the air", (Ability.ValidateGlide("GLIDER", true, true, 100, 0, 0, Config.GliderForm)))
check("BABY_BUG has no ability", not (Ability.Validate(base, true, 100, 0, 0, Config.TankShellForm)) and not (Ability.ValidateGlide(base, true, true, 100, 0, 0, Config.GliderForm)))

-- Respawn: the server stores the form per Player, not per character, so a respawn never
-- goes through Select and cannot reset it. That wiring needs Roblox objects and is
-- verified manually (README checklist), not by this file.

check("branches are distinct", forms[1] ~= forms[2])
check("biomass threshold positive", cap > 0)

if failures > 0 then
    error(failures .. " test(s) failed")
end
print("all tests passed")
