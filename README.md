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

`src/Workspace/Arena` holds the greybox arena as static Rojo `.model.json` Parts (anchored, `Locked`, simple materials, no scripts). It is declarative place data: it exists in the built place before any player joins, and nothing creates it at runtime. No gameplay systems are included (food collection, energy, evolution, abilities, UI and persistence are not implemented).

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

## Validate

```powershell
rojo build default.project.json -o build.rbxlx
```

Then connect Studio using the Rojo plugin. The project currently contains bootstrap placeholders and the greybox arena only; gameplay systems are not implemented.

See `docs/Game Design Document v0.1.md` and `docs/Technical Design & Implementation Plan v0.1.md`.
