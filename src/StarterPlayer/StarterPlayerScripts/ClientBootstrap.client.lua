--!strict
-- TINY TITANS client entry point.
-- Input and UI controllers are wired here.

local RunService = game:GetService("RunService")
assert(RunService:IsClient(), "ClientBootstrap.client.lua must run on the client.")

local Controllers = (script.Parent :: Instance):WaitForChild("Controllers")
local EnergyUIController = require(Controllers:WaitForChild("EnergyUIController") :: ModuleScript)

EnergyUIController.Init()
