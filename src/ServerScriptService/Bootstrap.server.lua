--!strict
-- TINY TITANS server entry point (composition root).
-- Active services are required and initialized here in a documented order with explicit
-- dependency injection. No gameplay logic lives in this file.
--
-- Active service ownership (M1):
--   LifeService     character life state, life IDs, LifeBegan/LifeEnded events, stale-signal protection
--   ResetService    exactly-once per-life reset orchestration; gates the next life (IsResetDone)
--   RespawnService  controlled first spawn and player-driven respawn; life recap delivery
--
-- M1: only the life, reset and controlled-respawn foundation is wired here. Add adventure
-- gameplay services alongside their first concrete vertical-slice use case, not as placeholders.

local RunService = game:GetService("RunService")
assert(RunService:IsServer(), "Bootstrap.server.lua must run on the server.")

-- Controlled respawn (P1-04): no automatic character. RespawnService spawns the first character
-- and a new one only when the player asks after a life ended. Set before anything yields.
game:GetService("Players").CharacterAutoLoads = false

local Services = (script.Parent :: Instance):WaitForChild("Services")
local LifeService = require(Services:WaitForChild("LifeService") :: ModuleScript)
local ResetService = require(Services:WaitForChild("ResetService") :: ModuleScript)
local RespawnService = require(Services:WaitForChild("RespawnService") :: ModuleScript)

LifeService.Init() -- first: the only authority on life state; the others subscribe to its events
ResetService.Init(LifeService) -- before RespawnService: a new life must not begin before the previous reset is recorded
RespawnService.Init(LifeService, ResetService) -- very last: spawns characters, so every service above must already listen
