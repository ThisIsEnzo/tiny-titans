--!strict
-- Optional Lune tests for the P2-02 creature catalog and its Config compatibility aliases.

local Config = require("../src/ReplicatedStorage/Shared/Config")
local Definitions = require("../src/ReplicatedStorage/Shared/CreatureDefinitions")
local failures = 0
local function check(name: string, ok: boolean)
    if not ok then
        failures += 1
        print("FAIL: " .. name)
    end
end
local function throws(fn: () -> ()): boolean
    return not pcall(fn)
end

check("starter id", Definitions.StarterFormId == "BABY_BUG")
check("starter lookup", Definitions.GetForm("BABY_BUG") == Definitions.Starter)
check("exactly three forms", #Definitions.Forms == 3)
check("ordered IDs", Definitions.Forms[1].id == "BABY_BUG" and Definitions.Forms[2].id == "TANK" and Definitions.Forms[3].id == "GLIDER")
check("unique IDs", Definitions.Forms[1].id ~= Definitions.Forms[2].id and Definitions.Forms[2].id ~= Definitions.Forms[3].id and Definitions.Forms[1].id ~= Definitions.Forms[3].id)
check("unknown lookup", Definitions.GetForm("FLY") == nil and Definitions.GetForm("Tank") == nil and Definitions.GetForm(nil) == nil)
check("starter has no requirement", Definitions.Starter.requirement == nil)
local tank = Definitions.GetForm("TANK") :: any
local glider = Definitions.GetForm("GLIDER") :: any
check("Tank requires 100 Biomass", tank.requirement.resource == "Biomass" and tank.requirement.amount == 100)
check("Glider requires 100 Biomass", glider.requirement.resource == "Biomass" and glider.requirement.amount == 100)
check("Tank ability reference", #tank.abilities == 1 and tank.abilities[1] == Config.AbilityShellId and Config.AbilityShellId == "SHELL")
check("Glider ability reference", #glider.abilities == 1 and glider.abilities[1] == Config.AbilityGlideId and Config.AbilityGlideId == "GLIDE")
check("honest Tank description", string.find(string.lower(tank.description), "visual") ~= nil)
check("honest Glider description", string.find(string.lower(glider.description), "not flight") ~= nil)
check("Config aliases", Config.BaseForm == Definitions.StarterFormId and #Config.EvolutionForms == 2 and Config.EvolutionForms[1] == "TANK" and Config.EvolutionForms[2] == "GLIDER")
check("frozen aliases and catalog", table.isfrozen(Config.EvolutionForms) and table.isfrozen(Definitions) and table.isfrozen(Definitions.Forms) and table.isfrozen(Definitions.EvolvedForms) and table.isfrozen(Definitions.EvolvedFormIds))
local frozen = true
for _, form in Definitions.Forms do
    if not table.isfrozen(form) or not table.isfrozen(form.abilities) or (form.requirement ~= nil and not table.isfrozen(form.requirement)) then frozen = false end
end
check("nested definitions frozen", frozen)
local mutable: any = Definitions
check("catalog immutable", throws(function() mutable.StarterFormId = "OTHER" end))
check("form immutable", throws(function() tank.id = "OTHER" end))
check("requirement immutable", throws(function() tank.requirement.amount = 1 end))
check("ability list immutable", throws(function() table.insert(tank.abilities, "GLIDE") end))
check("cap and reward unchanged", Config.EvolutionBiomassRequired == 100 and Config.FoodBiomass == 10)
local stages = Config.GrowthStages
check("growth stages unchanged", #stages == 3 and stages[1].MinBiomass == 0 and stages[1].Scale == 0.6 and stages[2].MinBiomass == 30 and stages[2].Scale == 0.8 and stages[3].MinBiomass == 60 and stages[3].Scale == 1.0)
if failures > 0 then error(failures .. " creature definition test(s) failed") end
print("all creature definition tests passed")
