--!strict
-- Server-authoritative food. One food item hovers over each FoodSpawn-tagged marker.
-- There is no client request: the server polls player positions, so a client cannot
-- claim food it is not near. The scan runs in a single thread and marks a food item
-- inactive before awarding, so each item can be collected once per spawn cycle.
-- If several players are in range in the same scan, the closest one gets it.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config") :: ModuleScript)
local Food = require(Shared:WaitForChild("Food") :: ModuleScript)

local FoodService = {}

type FoodItem = {
    marker: BasePart,
    part: Part,
    active: boolean,
}

local foods: { FoodItem } = {}
local playerData: any = nil
local elapsed = 0
local candidates: { Player } = {} -- reused every scan
local distances: { number } = {}

local function createFoodItem(marker: BasePart, folder: Folder): FoodItem
    local part = Instance.new("Part")
    part.Name = "Food"
    part.Shape = Enum.PartType.Ball
    part.Size = Vector3.new(2, 2, 2)
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(120, 255, 90)
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Locked = true
    part.Position = marker.Position + Vector3.new(0, Config.FoodHoverHeight, 0)
    part.Parent = folder
    return { marker = marker, part = part, active = true }
end

-- Returns the character root if the player is alive and may gain biomass.
local function getEligibleRoot(player: Player): BasePart?
    if not playerData.CanGainBiomass(player) then
        return nil
    end
    local character = player.Character
    if character == nil then
        return nil
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if humanoid == nil or humanoid.Health <= 0 or root == nil or not root:IsA("BasePart") then
        return nil
    end
    return root
end

local function respawnFood(food: FoodItem, folder: Folder)
    if food.marker.Parent == nil then
        food.part:Destroy()
        local index = table.find(foods, food)
        if index ~= nil then
            table.remove(foods, index)
        end
        return
    end
    if Food.Respawn(food) then
        food.part.Parent = folder
    end
end

local function step(folder: Folder)
    for _, food in foods do
        if not food.active then
            continue
        end
        table.clear(candidates)
        table.clear(distances)
        for _, player in Players:GetPlayers() do
            local root = getEligibleRoot(player)
            if root ~= nil then
                table.insert(candidates, player)
                table.insert(distances, (root.Position - food.part.Position).Magnitude)
            end
        end
        local index = Food.PickClosest(distances, Config.FoodPickupRange)
        local winner = if index ~= nil then candidates[index] else nil
        -- TryConsume marks the item inactive before anything else can run (this loop never
        -- yields), so the item can be collected by one player only, once per spawn cycle.
        if winner ~= nil and Food.TryConsume(food) then
            food.part.Parent = nil
            local gained = playerData.AddBiomass(winner, Config.FoodBiomass)
            if gained > 0 then
                task.delay(Config.FoodRespawnDelay, respawnFood, food, folder)
            else
                -- Nothing was awarded (the player's record vanished): put the food back.
                Food.Respawn(food)
                food.part.Parent = folder
            end
        end
    end
end

-- playerDataService must already be initialised.
function FoodService.Init(playerDataService: any)
    playerData = playerDataService

    local folder = Instance.new("Folder")
    folder.Name = "Food"
    folder.Parent = workspace

    for _, instance in CollectionService:GetTagged("FoodSpawn") do
        if instance:IsA("BasePart") then
            table.insert(foods, createFoodItem(instance, folder))
        end
    end
    if #foods == 0 then
        warn("[FoodService] No FoodSpawn-tagged parts found; no food will spawn.")
    end

    RunService.Heartbeat:Connect(function(dt)
        elapsed += dt
        if elapsed < Config.FoodCheckInterval then
            return
        end
        elapsed = 0
        step(folder)
    end)
end

return FoodService
