--!strict
-- TINY TITANS server entry point (composition root).
-- Active services are required and initialized here in a documented order with explicit
-- dependency injection. No gameplay logic lives in this file.
--
-- Active service ownership (M1):
--   LifeService     character life state, life IDs, LifeBegan/LifeEnded events, stale-signal protection
--   ResetService    exactly-once per-life reset orchestration; gates the next life (IsResetDone)
--   YankService     server-authoritative Drawline Yank interaction and target movement
--   RespawnService  controlled first spawn and player-driven respawn; life recap delivery

local RunService = game:GetService("RunService")
assert(RunService:IsServer(), "Bootstrap.server.lua must run on the server.")
game:GetService("Players").CharacterAutoLoads = false

local Services = (script.Parent :: Instance):WaitForChild("Services")
local LifeService = require(Services:WaitForChild("LifeService") :: ModuleScript)
local ResetService = require(Services:WaitForChild("ResetService") :: ModuleScript)
local YankService = require(Services:WaitForChild("YankService") :: ModuleScript)
local RespawnService = require(Services:WaitForChild("RespawnService") :: ModuleScript)

LifeService.Init()
ResetService.Init(LifeService)
YankService.Init(LifeService) -- listens before RespawnService can spawn the first character
local AncientWeightFixture = require(Services:WaitForChild("AncientWeightFixture") :: ModuleScript)
local AncientWeightService = require(Services:WaitForChild("AncientWeightService") :: ModuleScript)
AncientWeightFixture.Build()
AncientWeightService.Init()
RespawnService.Init(LifeService, ResetService)
