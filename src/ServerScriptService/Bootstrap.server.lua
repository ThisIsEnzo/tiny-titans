--!strict
-- TINY TITANS server entry point.
-- Gameplay services are wired here.

local RunService = game:GetService("RunService")
assert(RunService:IsServer(), "Bootstrap.server.lua must run on the server.")

local Services = (script.Parent :: Instance):WaitForChild("Services")
local LifeService = require(Services:WaitForChild("LifeService") :: ModuleScript)
local PlayerDataService = require(Services:WaitForChild("PlayerDataService") :: ModuleScript)
local GrowthService = require(Services:WaitForChild("GrowthService") :: ModuleScript)
local FoodService = require(Services:WaitForChild("FoodService") :: ModuleScript)
local EvolutionService = require(Services:WaitForChild("EvolutionService") :: ModuleScript)
local AbilityService = require(Services:WaitForChild("AbilityService") :: ModuleScript)
local ResetService = require(Services:WaitForChild("ResetService") :: ModuleScript)

LifeService.Init() -- first: later milestones subscribe other services to its events
PlayerDataService.Init()
GrowthService.Init(PlayerDataService)
FoodService.Init(PlayerDataService)
EvolutionService.Init(PlayerDataService)
AbilityService.Init(EvolutionService)
ResetService.Init(LifeService, PlayerDataService, EvolutionService, AbilityService, GrowthService) -- last: resets a life's state when LifeService reports its end
