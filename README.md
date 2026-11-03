# TINY TITANS

Roblox prototype: a multiplayer creature evolution arena.

## Toolchain

- Roblox Studio
- Rojo 7.6.1
- Rokit 1.2.0 (existing tool manager)

These are the versions recorded for the existing development setup. Verify locally before syncing; do not upgrade the toolchain as part of this prototype.

## Project mapping

- `src/ReplicatedStorage/Shared`: shared configuration and data contracts
- `src/ServerScriptService`: server-authoritative gameplay
- `src/StarterPlayer/StarterPlayerScripts`: client input and UI
- `src/Workspace`: minimal starting environment (see below). Everything in this folder, including the greybox arena in `src/Workspace/Arena`, is managed by Rojo.

## Starting environment

`src/Workspace` contains two static Rojo model files that are written into the generated place, so a fresh build is playable with no manual setup in Studio:

- `Baseplate.model.json`: anchored 512x20x512 concrete floor. Its top surface is at Y = 0.
- `SpawnLocation.model.json`: anchored, neutral 12x1x12 spawn pad resting on the floor (Y = 0 to 1), with `Duration = 0` (no spawn forcefield).

Implications:

- The environment is declarative place data, not a runtime script, so it exists before any player joins and cannot create duplicates when the server restarts or a script re-runs. There is exactly one instance of each object.
- The `Workspace` node sets `$ignoreUnknownInstances`, so objects you author in Studio (for example the future greybox arena) are not deleted when Rojo syncs.
- Rojo matches instances by name. If a place you already saved contains a manually inserted `Baseplate` or `SpawnLocation`, delete the extra copies, or start from a fresh `rojo build`, to avoid two floors or two spawns.
- The 512x512 Baseplate is kept unchanged as the safety floor under and around the arena, so there is no void anywhere near the play area. Keep one valid neutral `SpawnLocation` above solid, anchored ground.

## Greybox arena

`src/Workspace/Arena` holds the greybox arena as static Rojo `.model.json` Parts (anchored, `Locked`, simple materials, no scripts). It is declarative place data: it exists in the built place before any player joins, and nothing creates it at runtime. The arena itself contains no scripts; gameplay on top of it is described in the next section.

Coordinates: arena is centered on the origin, +X is east, -Z is north. Floor top is Y = 0.5; studs.

Layout (120x120 play area, X and Z from -60 to 60):

| Folder | Contents |
|---|---|
| `Ground` | `ArenaFloor` 120x1x120 grass slab (top Y = 0.5), sitting on the Baseplate |
| `Landmark` | `CentralPlaza` 36x36 sand pad around the existing `SpawnLocation`, and `Beacon`, a 16-stud neon pillar at (0, -14) visible from most of the arena |
| `Platforms` | Jump route NE: `HillTier1` (top Y = 3.5) then `HillTier2` (top Y = 6.5). Jump route SW: `LedgeA` (top 3.5) then `LedgeB` (top 6.5). Each step is 3 studs |
| `GliderPlatforms` | `GliderPlatform1` (center 12, -36, top Y = 16), `GliderPlatform2` (-16, -44, top Y = 20), `GliderPlatform3` (-22, 24, top Y = 16). Tops are well above default jump reach even from the 6.5 tiers, with horizontal gaps of 9+ studs from jumpable surfaces |
| `Obstacles` | `Wall1`-`Wall3` (8 studs tall) and `Boulder1`-`Boulder5` (4-6 studs tall) forming detours. Obstacles keep at least 6 studs of clearance from each other, the plaza and the boundary |
| `FoodSpawns` | `FoodSpawn1`-`FoodSpawn8`: small non-colliding neon markers. 6 on the ground, 1 on `HillTier2` (jump reward), 1 on `GliderPlatform2` (glide reward) |
| `Boundaries` | `WallNorth/South/East/West`: 40-stud tall, 60% transparent collidable walls with inner faces at +/-60 |

Main areas: center plaza (spawn and orientation), open ground ring with food, two jumpable climbs (NE hill, SW ledges), and a high glider layer reachable only with a future glide ability.

CollectionService tags (set in the model files, so they exist in the built place):

- `FoodSpawn`: the 8 food markers
- `GliderPlatform`: the 3 high platforms
- `ArenaBoundary`: the 4 boundary walls

Future server code can use `CollectionService:GetTagged("FoodSpawn")` and so on.

### Build with Rojo

```powershell
rojo build default.project.json -o build.rbxlx
```

Open `build.rbxlx` in Studio, or connect the Rojo plugin with `rojo serve`. No manual Studio setup is required. If a saved place already contains manually inserted `Baseplate`, `SpawnLocation` or an `Arena` folder, delete them first or start from a fresh build.

## Food and growth loop

Server-only gameplay, wired in `ServerScriptService/Bootstrap.server.lua`:

| File | Responsibility |
|---|---|
| `ServerScriptService/Services/PlayerDataService.lua` | Per-player energy (session only). `AddEnergy` is server-only, clamps to `Config.EvolutionEnergyRequired`, mirrors `Energy` and `GrowthStage` to Player attributes, fires a server-side `ProgressChanged` signal |
| `ServerScriptService/Services/FoodService.lua` | Creates one food ball per `FoodSpawn`-tagged part, detects pickups, awards energy, respawns food |
| `ServerScriptService/Services/GrowthService.lua` | Applies the current stage's body scale to the player's R15 character (on stage change, spawn and appearance load) |
| `ReplicatedStorage/Shared/Growth.lua` | Pure stage/scale/clamp helpers (no Roblox services) |
| `ReplicatedStorage/Shared/Config.lua` | Tuning: `FoodEnergy`, `FoodRespawnDelay`, `FoodPickupRange`, `FoodHoverHeight`, `FoodCheckInterval`, `GrowthStages` |

How it works:

1. On server start, `FoodService` spawns a neon ball 2 studs above each `FoodSpawn` marker (8 in the arena), under `Workspace.Food`.
2. Every 0.1 s the server checks each active food item against every player. A player qualifies if their character is alive, has a `HumanoidRootPart` within `FoodPickupRange` (5 studs) of the food, and is below the energy cap. If several players qualify at once, the closest one wins.
3. The food is marked inactive and removed before energy is awarded, so it cannot be collected twice. It respawns after `FoodRespawnDelay` (8 s).
4. Each food gives `FoodEnergy` (10). Energy caps at 100 (`EvolutionEnergyRequired`); a player at the cap does not consume food.
5. Stages: 0 energy = 0.6 scale, 30 = 0.8, 60 = 1.0. Crossing a threshold rescales the character. Progress is kept across respawns in the same session and lost when the player leaves.

Design notes:

- There are **no RemoteEvents and no client scripts for this loop**. The client never sends a pickup request, so there is nothing to spoof. Pickup validation uses the character position as the server sees it, and the range check is a distance check only (a movement-speed or teleport check is not implemented).
- The technical plan mentions a client pickup request; this milestone deliberately uses server proximity checks instead to avoid adding a remote.
- Evolution at 100 energy, an energy UI, and food variety are not implemented. Read the `Energy` / `GrowthStage` attributes on the Player for debugging.
- Growth uses R15 body scale values. The place's Avatar Type must be R15 (Game Settings > Avatar). R6 characters are not scaled and a warning is printed once.

### Tests

`tests/Growth.test.lua` covers the pure helpers in `Growth.lua` and sanity-checks `Config`. It is optional and outside the Rojo tree. Run it with [Lune](https://lune-org.github.io/docs): `lune run tests/Growth.test.lua`. Lune is not part of `rokit.toml`. The service modules depend on Roblox APIs and are tested manually in Studio.

### Manual Studio test checklist

1. `rojo build default.project.json -o build.rbxlx`, open it in Studio (or use `rojo serve`) and confirm Avatar Type is R15.
2. Play Solo. Expected: character spawns small (scale 0.6); `Workspace.Food` holds 8 green balls above the green food markers; no output errors.
3. Walk into one ball. Expected: it disappears, and in Explorer `Players > <you>` attributes show `Energy = 10`, `GrowthStage = 1`.
4. Collect 3 balls total. Expected: `Energy = 30`, `GrowthStage = 2`, character visibly larger. Collect 6 total: `Energy = 60`, `GrowthStage = 3`, normal size.
5. Wait 8 s after collecting. Expected: the ball reappears.
6. Collect until `Energy = 100`. Expected: energy stops at 100 and food is no longer consumed by you.
7. Reset the character (or die). Expected: you respawn at your current stage's size, with energy unchanged.
8. Test > Clients and Servers, 2 players, both stand near the same ball. Expected: only one player gains energy; the closer one if distances differ.
9. Check the platform food: the ball on `HillTier2` is reachable by jumping, and the one on `GliderPlatform2` is not reachable yet (needs the future glide ability).
10. Check that the smaller character fits routes, jumps normally and the camera behaves at scale 0.6.

## Validate

```powershell
rojo build default.project.json -o build.rbxlx
```

Then connect Studio using the Rojo plugin. The project currently contains the greybox arena and the food/growth loop. Evolution, abilities, UI and persistence are not implemented.

See `docs/Game Design Document v0.1.md` and `docs/Technical Design & Implementation Plan v0.1.md`.
