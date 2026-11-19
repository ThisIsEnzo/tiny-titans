--!strict
-- TINY TITANS server entry point.
-- Gameplay services are wired here.

local RunService = game:GetService("RunService")
assert(RunService:IsServer(), "Bootstrap.server.lua must run on the server.")

-- Controlled respawn (P1-04): no automatic character. RespawnService spawns the first character
-- and a new one only when the player asks after a life ended. Set before anything yields.
game:GetService("Players").CharacterAutoLoads = false

local Services = (script.Parent :: Instance):WaitForChild("Services")
local LifeService = require(Services:WaitForChild("LifeService") :: ModuleScript)
local PlayerDataService = require(Services:WaitForChild("PlayerDataService") :: ModuleScript)
local FoodService = require(Services:WaitForChild("FoodService") :: ModuleScript)
local EvolutionService = require(Services:WaitForChild("EvolutionService") :: ModuleScript)
local AbilityService = require(Services:WaitForChild("AbilityService") :: ModuleScript)
local DiscoveryService = require(Services:WaitForChild("DiscoveryService") :: ModuleScript)
local ResetService = require(Services:WaitForChild("ResetService") :: ModuleScript)
local RespawnService = require(Services:WaitForChild("RespawnService") :: ModuleScript)

LifeService.Init() -- first: later milestones subscribe other services to its events
PlayerDataService.Init()
FoodService.Init(PlayerDataService)
EvolutionService.Init(PlayerDataService)
-- Tank/Glider abilities are retired from the active player experience; keep the module
-- available to ResetService as a compatibility no-op while old state is phased out.
DiscoveryService.Init(LifeService, PlayerDataService) -- before ResetService, which resets its per-life log
ResetService.Init(LifeService, PlayerDataService, EvolutionService, AbilityService, DiscoveryService) -- last: resets a life's state when LifeService reports its end
-- Do not initialise CreatureAppearanceService: standard Roblox avatars remain visible.
-- The old BabyBugVisual replacement is intentionally inactive.
RespawnService.Init(LifeService, EvolutionService, ResetService, DiscoveryService) -- very last: spawns characters, so every service above must already listen
