--!strict
-- Shared, non-authoritative tuning/configuration.
-- Keep gameplay decisions and validation on the server.

-- CreatureDefinitions is the single source of truth for forms. This loader supports both
-- Roblox sibling ModuleScripts and Lune's relative file paths.
local function loadSibling(name: string): any
    local here: any = script
    if here ~= nil then
        return require(here.Parent:WaitForChild(name) :: ModuleScript)
    end
    return (require :: any)("./" .. name)
end

local CreatureDefinitions = loadSibling("CreatureDefinitions")

local Config = {
    -- TEMPORARY: this is the Biomass cap, not the evolution eligibility rule.
    -- P2-09 decides the cap's final name and value.
    EvolutionBiomassRequired = 100,

    -- Evolution (server-authoritative; see ServerScriptService/Services/EvolutionService).
    -- Compatibility aliases only; definitions live in CreatureDefinitions.
    BaseForm = CreatureDefinitions.StarterFormId :: string,
    EvolutionForms = CreatureDefinitions.EvolvedFormIds :: { string },
    EvolutionRequestCooldown = 0.5, -- min seconds between processed requests per player (keep below the UI click lock)

    -- Global ability settings. Ability ids, required forms and per-ability tuning (durations,
    -- cooldowns, gravity compensation) live in AbilityDefinitions.
    AbilityKey = "Q", -- client activation key (KeyCode name), shared by all abilities
    AbilityDebugLogging = false, -- true: AbilityService prints why and when a glide ended (Output); leave false in production
    AbilityRequestInterval = 0.25, -- min seconds between processed RequestAbility calls per player (anti-spam; not a gameplay cooldown)

    -- Food (server-authoritative; see ServerScriptService/Services/FoodService).
    FoodBiomass = 10, -- evolution biomass awarded per food item
    FoodRespawnDelay = 8, -- seconds until a collected food item reappears
    FoodPickupRange = 5, -- studs from the character root to the food center
    FoodHoverHeight = 2, -- studs above the FoodSpawn marker's center
    FoodCheckInterval = 0.1, -- seconds between server pickup checks

    -- Discoveries (server-authoritative; see ServerScriptService/Services/DiscoveryService).
    DiscoveryCheckInterval = 0.25, -- seconds between server checks of player positions against discovery volumes

    -- Growth stages. A player is in the last stage whose MinBiomass they have reached.
    -- Scale is applied to the R15 body scale values (visual growth).
    GrowthStages = table.freeze({
        table.freeze({ MinBiomass = 0, Scale = 0.6 }),
        table.freeze({ MinBiomass = 30, Scale = 0.8 }),
        table.freeze({ MinBiomass = 60, Scale = 1.0 }),
    }),
    GrowthTweenSeconds = 0.8, -- length of the smooth transition when a stage threshold is crossed
    AppearanceFallbackSeconds = 5, -- scale a new character anyway if its appearance never finishes loading
}

return table.freeze(Config)
