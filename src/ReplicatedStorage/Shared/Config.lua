--!strict
-- Shared, non-authoritative tuning/configuration.
-- Keep gameplay decisions and validation on the server.

local Config = {
    EvolutionEnergyRequired = 100,

    -- Evolution (server-authoritative; see ServerScriptService/Services/EvolutionService).
    BaseForm = "BABY_BUG", -- form every player starts in
    EvolutionForms = table.freeze({ "TANK", "GLIDER" }), -- valid branches
    EvolutionRequestCooldown = 0.5, -- min seconds between processed requests per player (keep below the UI click lock)

    -- Tank Defensive Shell (server-authoritative, visual only; see AbilityService).
    AbilityKey = "Q", -- client activation key (KeyCode name)
    TankShellForm = "TANK", -- only this form may activate the shell
    TankShellDuration = 3, -- seconds the shell stays up
    TankShellCooldown = 12, -- seconds from activation until it can be used again
    AbilityRequestInterval = 0.25, -- min seconds between processed RequestAbility calls per player (anti-spam; not gameplay)

    -- RequestAbility identifiers (the only thing a client sends; the server checks it against the player's form).
    AbilityShellId = "SHELL",
    AbilityGlideId = "GLIDE",

    -- Glider Air Glide (server-authoritative; see AbilityService). A bounded glide, not flight.
    GliderForm = "GLIDER", -- only this form may glide
    GliderDuration = 3, -- max seconds of glide per activation (landing ends it earlier)
    GliderCooldown = 10, -- seconds from activation until it can be used again
    GliderGravityCompensation = 0.65, -- fraction of gravity cancelled while gliding (always capped below 1)

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
