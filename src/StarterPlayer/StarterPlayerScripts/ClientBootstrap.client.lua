--!strict
-- TINY TITANS client entry point.
-- Input and UI controllers are wired here.

local RunService = game:GetService("RunService")
assert(RunService:IsClient(), "ClientBootstrap.client.lua must run on the client.")

local Controllers = (script.Parent :: Instance):WaitForChild("Controllers")
local BiomassUIController = require(Controllers:WaitForChild("BiomassUIController") :: ModuleScript)
local EvolutionUIController = require(Controllers:WaitForChild("EvolutionUIController") :: ModuleScript)
local AbilityController = require(Controllers:WaitForChild("AbilityController") :: ModuleScript)

BiomassUIController.Init()
EvolutionUIController.Init()
AbilityController.Init()
