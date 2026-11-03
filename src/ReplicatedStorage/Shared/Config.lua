--!strict
-- Shared, non-authoritative tuning/configuration.
-- Keep gameplay decisions and validation on the server.

local Config = {
    EvolutionEnergyRequired = 100,

    -- Food (server-authoritative; see ServerScriptService/Services/FoodService).
    FoodEnergy = 10, -- evolution energy awarded per food item
    FoodRespawnDelay = 8, -- seconds until a collected food item reappears
    FoodPickupRange = 5, -- studs from the character root to the food center
    FoodHoverHeight = 2, -- studs above the FoodSpawn marker's center
    FoodCheckInterval = 0.1, -- seconds between server pickup checks

    -- Growth stages. A player is in the last stage whose MinEnergy they have reached.
    -- Scale is applied to the R15 body scale values (visual growth).
    GrowthStages = table.freeze({
        table.freeze({ MinEnergy = 0, Scale = 0.6 }),
        table.freeze({ MinEnergy = 30, Scale = 0.8 }),
        table.freeze({ MinEnergy = 60, Scale = 1.0 }),
    }),
}

return table.freeze(Config)
