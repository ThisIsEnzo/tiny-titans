--!strict
-- TINY TITANS server entry point.
-- Gameplay services will be wired here in subsequent implementation tasks.

local RunService = game:GetService("RunService")
assert(RunService:IsServer(), "Bootstrap.server.lua must run on the server.")
