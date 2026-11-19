--!strict
-- TINY TITANS client entry point.
-- Input and UI controllers are wired here.

local RunService = game:GetService("RunService")
assert(RunService:IsClient(), "ClientBootstrap.client.lua must run on the client.")

local Controllers = (script.Parent :: Instance):WaitForChild("Controllers")
local BiomassUIController = require(Controllers:WaitForChild("BiomassUIController") :: ModuleScript)
local LifeRecapController = require(Controllers:WaitForChild("LifeRecapController") :: ModuleScript)
local DiscoveryUIController = require(Controllers:WaitForChild("DiscoveryUIController") :: ModuleScript)

-- The standard Roblox avatar and its built-in Animate script are the active character presentation.
-- Historical form/evolution, ability and Baby Bug animation controllers are intentionally not started.
BiomassUIController.Init()
LifeRecapController.Init()
DiscoveryUIController.Init()
