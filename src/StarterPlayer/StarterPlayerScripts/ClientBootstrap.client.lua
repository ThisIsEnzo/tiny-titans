--!strict
-- TINY TITANS client entry point.
-- Presentation controllers are wired here. The standard Roblox avatar and its built-in Animate
-- script are the active character presentation; no creature/form controllers are started.

local RunService = game:GetService("RunService")
assert(RunService:IsClient(), "ClientBootstrap.client.lua must run on the client.")

local Controllers = (script.Parent :: Instance):WaitForChild("Controllers")
local LifeRecapController = require(Controllers:WaitForChild("LifeRecapController") :: ModuleScript)

LifeRecapController.Init()
