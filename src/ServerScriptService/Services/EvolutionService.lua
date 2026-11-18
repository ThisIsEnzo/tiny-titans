--!strict
-- Compatibility-only player form record.
-- The old Baby Bug / Tank / Glider evolution feature is retired from the active game.
-- The standard Roblox avatar is now the canonical playable character. This service remains
-- temporarily because ResetService and RespawnService still depend on its small compatibility
-- API and FormChanged signal. It creates no remotes and exposes no client-selectable forms.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config") :: ModuleScript)

local EvolutionService = {}

local formChanged = Instance.new("BindableEvent")
EvolutionService.FormChanged = formChanged.Event

local formByPlayer: { [Player]: string } = {}

local function refresh(player: Player)
    if formByPlayer[player] == nil then
        return
    end
    -- Kept only as an internal compatibility value for existing recap/reset contracts.
    player:SetAttribute("EvolutionForm", Config.BaseForm)
    player:SetAttribute("EvolutionAvailable", false)
end

local function onPlayerAdded(player: Player)
    if formByPlayer[player] ~= nil then
        return
    end
    formByPlayer[player] = Config.BaseForm
    refresh(player)
end

function EvolutionService.GetForm(player: Player): string?
    return formByPlayer[player]
end

function EvolutionService.ResetForm(player: Player): boolean
    if formByPlayer[player] == nil then
        return false
    end
    formByPlayer[player] = Config.BaseForm
    refresh(player)
    return true
end

function EvolutionService.Init(_playerDataService: any)
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(function(player)
        formByPlayer[player] = nil
    end)
    for _, player in Players:GetPlayers() do
        onPlayerAdded(player)
    end
end

return EvolutionService
