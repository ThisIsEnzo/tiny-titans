--!strict
-- Optional unit tests for pure, definition-driven evolution rules.
local Config = require("../src/ReplicatedStorage/Shared/Config")
local Evolution = require("../src/ReplicatedStorage/Shared/Evolution")
local Definitions = require("../src/ReplicatedStorage/Shared/CreatureDefinitions")
local Ability = require("../src/ReplicatedStorage/Shared/Ability")
local failures = 0
local function check(name: string, ok: boolean)
    if not ok then failures += 1; print("FAIL: " .. name) end
end
local base = Definitions.StarterFormId
local requirement = (Definitions.GetForm("TANK") :: any).requirement.amount
local function validate(form: any, biomass: number, current: string)
    return Evolution.Validate(form, biomass, current, Definitions)
end

check("valid TANK", Evolution.IsValidForm("TANK", Definitions))
check("valid GLIDER", Evolution.IsValidForm("GLIDER", Definitions))
check("starter is not a branch", not Evolution.IsValidForm(base, Definitions))
check("invalid IDs rejected", not Evolution.IsValidForm("tank", Definitions) and not Evolution.IsValidForm(nil, Definitions) and not Evolution.IsValidForm(1, Definitions))
check("not available below requirement", not Evolution.IsAvailable(99, base, Definitions))
check("available at requirement", Evolution.IsAvailable(100, base, Definitions))
check("available above requirement", Evolution.IsAvailable(150, base, Definitions))
check("not available after evolving", not Evolution.IsAvailable(100, "TANK", Definitions))
check("NaN unavailable", not Evolution.IsAvailable(0 / 0, base, Definitions))
local ok, reason = validate("TANK", 99, base)
check("Tank below requirement", not ok and reason == "ThresholdNotReached")
ok, reason = validate("TANK", 100, base)
check("Tank at requirement", ok and reason == "Ok")
ok, reason = validate("GLIDER", 100, base)
check("Glider at requirement", ok and reason == "Ok")
ok, reason = validate("GLIDER", 99, base)
check("Glider below requirement", not ok and reason == "ThresholdNotReached")
ok, reason = validate("FLY", 100, base)
check("unknown ID", not ok and reason == "InvalidForm")
ok, reason = validate("FLY", 99, base)
check("unknown ID before anything available", not ok and reason == "ThresholdNotReached")
ok, reason = validate("TANK", 100, "GLIDER")
check("already evolved", not ok and reason == "AlreadyEvolved")
ok, reason = validate(nil, 100, base)
check("nil form", not ok and reason == "InvalidForm")

local fixture: Evolution.Catalog = {
    StarterFormId = "S",
    Forms = {
        { id = "S" },
        { id = "LOW", requirement = { resource = "Biomass", amount = 50 } },
        { id = "HIGH", requirement = { resource = "Biomass", amount = 150 } },
        { id = "NOREQ" },
    },
}
check("different requirements: available at 50", Evolution.IsAvailable(50, "S", fixture))
ok, reason = Evolution.Validate("LOW", 50, "S", fixture)
check("LOW at 50 accepted", ok and reason == "Ok")
ok, reason = Evolution.Validate("HIGH", 50, "S", fixture)
check("HIGH at 50 rejected", not ok and reason == "ThresholdNotReached")
ok, reason = Evolution.Validate("HIGH", 150, "S", fixture)
check("HIGH at 150 accepted", ok and reason == "Ok")
ok, reason = Evolution.Validate("NOREQ", 1000, "S", fixture)
check("missing requirement fails closed", not ok and reason == "ThresholdNotReached")

local selected, selectReason = Evolution.Select("TANK", 99, base, Definitions)
check("rejected selection unchanged", selected == base and selectReason == "ThresholdNotReached")
selected, selectReason = Evolution.Select("TANK", 100, base, Definitions)
check("accepted selection changes form", selected == "TANK" and selectReason == "Ok")
selected, selectReason = Evolution.Select("GLIDER", 100, "TANK", Definitions)
check("repeat selection unchanged", selected == "TANK" and selectReason == "AlreadyEvolved")
check("request cooldown unchanged", Evolution.IsRateLimited(10, 10.1, Config.EvolutionRequestCooldown))
check("ability form restrictions unchanged", not Ability.Validate("GLIDER", true, 100, 0, 0, Config.TankShellForm) and not Ability.ValidateGlide("TANK", true, true, 100, 0, 0, Config.GliderForm))
check("cap still reaches every requirement", Config.EvolutionBiomassRequired >= requirement)
if failures > 0 then error(failures .. " evolution test(s) failed") end
print("all evolution tests passed")
