# TINY TITANS

Roblox prototype: a multiplayer **Creature Exploration RPG** (currently a first habitat greybox).

## Current approved product direction

Each player inhabits one personal, customizable Tiny Titan in an oversized living ecosystem. Baby Bug, Tank and Glider are no longer separate playable forms; their useful verbs may be reconsidered as optional adaptations after real world use cases are proven. A combat system is not required for MVP. Exploration, discovery, collection, character attachment and replayable activities are the foundation. Existing form/evolution code described later in this README is historical prototype implementation, not the approved product model.

## Product and architecture documents

Use these documents as the current sources of truth:

- [Product Vision v2.2 — Personalized Creature Exploration RPG](docs/Product%20Vision%20v2.0%20%E2%80%94%20Hybrid%20Creature%20Exploration%20RPG.md): product north star, retention principles and cosmetic-first monetization.
- [GDD v2.2 — The Living World Adventure](docs/GDD%20v2.2%20%E2%80%94%20The%20Living%20World%20Adventure.md): unified goal, discovery loop, first ecological story proposal, MVP scope and playtest contract.
- [Gameplay Blueprint & MVP Contract](docs/Gameplay%20Blueprint%20%26%20MVP%20Contract.md): core loop, first habitat and MVP acceptance gates.
- [Tiny Titans Master Roadmap](docs/Tiny%20Titans%20Master%20Roadmap.md): the single execution roadmap and phase gates.
- [Player Identity & Adaptation Architecture](docs/Player%20Identity%20%26%20Adaptation%20Architecture.md): future character identity, appearance and optional adaptation boundaries.
- [Progression & Legacy Architecture Addendum](docs/Progression%20%26%20Legacy%20Architecture%20Addendum.md): future progression and persistence boundaries.

GDD v2.2 is the detailed experience contract; Gameplay Blueprint defines the first playable slice; Master Roadmap controls execution order. The former Evolution Sandbox Architecture and Combat Progression & Endgame Design are superseded/archived. Their detailed historical notes remain in Git history.

Sections below describe the current code and historical Baby Bug / Tank / Glider prototype work. They are retained as implementation/audit evidence, not as product requirements. Where those notes conflict with the approved one-Tiny-Titan direction, the current product documents above take precedence. Do not infer that Studio validation has occurred unless explicitly recorded.

## Toolchain

- Roblox Studio
- Rojo 7.6.1
- Rokit 1.2.0 (existing tool manager)

These are the versions recorded for the existing development setup. Verify locally before syncing; do not upgrade the toolchain as part of this prototype.

## Project mapping

- `src/ReplicatedStorage/Shared`: shared configuration and data contracts
- `src/ServerScriptService`: server-authoritative gameplay
- `src/StarterPlayer/StarterPlayerScripts`: client input and UI
- `src/Workspace`: the Baseplate and the First Habitat greybox in `src/Workspace/Habitat` (see below). Everything in this folder is managed by Rojo.
- `tools/habitat`: the habitat layout generator and its offline validator.

## Starting environment

`src/Workspace` contains the unchanged 512x512 `Baseplate.model.json` (anchored concrete floor, top at Y = 0, the safety floor under and around the play area, so there is no void anywhere near it) and the `Habitat` folder (below). Everything is declarative, anchored, script-free place data written into the generated place by Rojo, so a fresh build is playable with no manual setup in Studio.

- The environment exists before any player joins and cannot create duplicates when the server restarts. There is exactly one instance of each object.
- The `Workspace` node sets `$ignoreUnknownInstances`, so objects you author in Studio are not deleted when Rojo syncs.
- Rojo matches instances by name. If a place you already saved contains a manually inserted `Baseplate`, `SpawnLocation` or an old `Arena` folder, delete them or start from a fresh `rojo build`, to avoid two floors, extra spawns or the old arena.

```powershell
rojo build default.project.json -o build.rbxlx
```

Open `build.rbxlx` in Studio, or connect the Rojo plugin with `rojo serve`.

## First Habitat greybox (TT-P3-01)

`src/Workspace/Habitat` replaces the old test arena with a compact, connected habitat for a tiny creature in an oversized world. It follows the gameplay direction in `docs/Gameplay Blueprint & MVP Contract.md` (co-op-friendly PvE exploration; no mandatory ability gates). It is a **greybox**: simple materials, no external assets, no scripts, no new gameplay systems. **It has not been played in Roblox Studio** (checklist below); only the offline layout validator has been run.

Coordinates: centred on the origin, +X east, -Z north, floor top at Y = 0.5, play area X and Z from -70 to 70 (140 x 140), studs. The Nest is in the south-west corner and the Old Tree in the north-east.

| File (`Habitat/`) | Parts | Contents |
|---|---|---|
| `Terrain` | 9 | `HabitatFloor` grass slab, four tall opaque boundary walls (`CliffNorth/West`, `HedgeSouth/East`, inner faces at +/-70, 50 studs high) and four non-colliding zone tints so each area reads by ground colour |
| `Nest` | 18 | **A. Nest (safe start).** Twig rim (radius 14) with three 8-stud openings: east (main trail), north (Rock Garden lane), south-east (lowland lane). Three spawn pads, straw bed, loose twigs and the **Lone Dandelion** (22-stud stem, white puff), a home beacon visible from most of the habitat. One pickup just outside the east opening |
| `Meadow` | 101 | **B. Meadow (main exploration)** and the north clearing. Worn trails, the **Great Stump** (22 wide, 9 tall, log ramp up its west side, a lookout with a pickup), a fallen-leaf ramp, puddle with pebbles, giant acorn, stepping stones, the **Red Toadstool** (walk-under cap), a Mushroom Grove, berries, a clover hill (two 3-stud steps), a snail shell, pebble cairns, a hollow log, boulders and non-colliding giant grass blades |
| `RockGarden` | 32 | **C. Rock Garden.** Gate rocks, a wide S-curve passage with rock walls, a terrace stair (3-stud steps to a lookout), a roofed shelter den (7 studs of headroom), a **Tank nook** (alcove whose front is blocked by a static boulder, with a 6-stud side door), boulders on the strip toward the Nest |
| `GiantRoots` | 35 | **D. Giant Roots.** The **Old Tree** trunk (26 wide, 70 tall), a walk-through **root arch** (8 wide, 7 high) with a walkable top, an elevated route: ramp to the arch top, a root bridge, **Leaf Platform 1**, and a ramp down to the north; **Leaf Platform 2** across a 10-stud gap (the glider span; it is also reachable on foot by a ramp), fungus-step stairs up the trunk (3 steps to a 9-stud vantage), seed pods and stones |
| `DiscoverySites` | 6 | TT-P3-02: six invisible, non-solid trigger volumes (tag `DiscoverySite`, part name = discovery id), see "Exploration loop" |
| `Secret` | 28 | **E. Secret.** A 5-stud crack between two rock masses, its mouth hidden from the main passage by a screening rock, leading to the Dewdrop Glade (a 22-stud pocket with a glass dewdrop on a leaf and glowing mushrooms). Clues: glowing mushrooms near the approach and a tall translucent beam above the glade |

Total 229 parts (budget 260), all anchored and `Locked`. Static decoration that is not part of the walkable surface (grass blades, tints, trails, puddle, glow mushrooms, beam) has `CanCollide = false`, `CanQuery = false` and no shadow.

### Routes and design decisions

- **Primary route (about 490 studs, roughly 30 s at 16 studs/s; every part at least 6 studs wide):** Nest east opening, Meadow trail to the Great Stump, west to the Rock Garden gate, through the S-curve passage to the north exit, east along the north lane to the Roots, south through the ground corridor and under the arch, back across the Meadow to the Nest. Trails are visual ground overlays (no collision).
- **Alternatives:** three exits from the Nest (east, north lane, lowland lane along the south edge); the Meadow crossing from the stump straight to the Roots; in the Rock Garden the main passage, the terrace/den side loop and the secret crack; in the Roots the open ground, the elevated route over the arch (arch top, bridge, Leaf Platform 1, ramp down north) and the fungus steps. Routes differ in distance, height and exploration value, and ground-level alternatives always remain.
- **Nothing is gated by an ability.** Every part of the habitat and every pickup is reachable on foot with the Baby Bug using steps of at most 3 studs (the old arena's rule) and ramps of at most 31 degrees. Nothing is reachable only by gliding, and nothing depends on a Tank mechanic.
- **Reserved space for later forms (geometry only, nothing pretends to work yet):** the Tank nook (tags `TankNook`, `FutureTankPush`), roofed shelters, the arch gateway and the narrow crack; and for the Glider the high decks (Arch top, Leaf Platforms 1 and 2, the Great Stump top, the fungus-step vantage) and the 10-stud gap between Leaf Platforms 1 and 2 (tag `FutureGliderSpan`), which only saves a walk of roughly 50 studs. Falling from any height lands on solid floor.
- **Scale:** oversized stump, toadstool, acorn, Old Tree (70 studs), dandelion and giant grass blades; recognisable landmarks (tag `Landmark`): the Dandelion (Nest), Great Stump (Meadow), Red Toadstool, Old Tree and Root Arch (Roots), Dewdrop (secret). Zones are told apart by ground colour and landmark silhouette, so no minimap is needed.
- **Multiplayer:** three spawn pads (7x7, neutral, no forcefield), 8-stud nest openings, wide trails, and no unavoidable chokepoints on the primary route (narrow routes are optional). Roblox picks a random enabled `SpawnLocation` for each spawn. Solo play is unaffected.
- **Pickups (reuse of the existing `FoodSpawn` system, no new currency or inventory):** 24 markers (Nest 1, Meadow and north clearing 11, Rock Garden 4, Giant Roots 6, Secret 2). They sit along the trails and on optional detours (stump top, leaf perch, clover hill, Mushroom Grove, den, Tank nook, arch top, leaf platforms, fungus vantage, boulder garden, glade) at irregular spacing, never on a grid. `FoodService`, the 10 Biomass per pickup, the cap of 100 and the 8 second respawn are unchanged. Known risk: every pickup is identical and respawns after 8 s, so a player could farm one cluster; the spread is meant to make exploring more attractive, and tuning belongs to a later task.
- **Safety:** the whole area is solid floor on the Baseplate, bounded by tall opaque walls (no invisible walls, no void, no hazards, no precision platforming). The boundary is high enough that nothing in the current ability set clears it.

CollectionService tags (set in the model files): `FoodSpawn`, `Landmark`, `HabitatBoundary`, `DiscoverySite`, `TankNook`, `FutureTankPush`, `FutureGliderSpan`.

### Source of truth and tools

The `.model.json` files are generated by `tools/habitat/generate_habitat.py` (the layout, one function per area) and are committed, so `rojo build` needs no extra tool. To change the layout, edit the generator and run both scripts; do not hand-edit the generated files.

```powershell
python tools/habitat/generate_habitat.py
python tools/habitat/validate_habitat.py
```

`validate_habitat.py` (Python standard library only; an optional open-space check also needs `numpy` and `scipy`) reads the shipped JSON, rasterises the collidable parts and builds a walking graph for a baseline creature (step or jump up at most 3 studs, any drop, 6 studs of headroom, a body footprint). Run with `--map` for an ASCII map, `--crop=x0,x1,z0,z1` for a 1-stud view and `x,z[,h]` arguments to probe the widest body that fits a spot. It checks: structure, part budget, tags, three or more spawn pads, spawn safety, every pickup reachable on foot and able to return to the Nest, no trapped spots, the primary route and alternatives at 6-stud width, elevated and secret spots, the glider span not being a walkway, the Tank nook's side door, landmarks 15+ studs tall, proper rotation matrices, ramp slopes, the discovery volumes (one per catalog id, invisible and non-solid, reachable on foot and able to return, away from the Nest, not overlapping) and (with numpy and scipy) no open circle wider than 13 studs. It runs in CI.

What the validator does **not** prove: that the habitat is fun, readable through the real camera, or collision-correct in the engine, that the jump height at every growth stage reaches 3-stud steps, or that the CFrame orientations are applied as modelled. Those need Studio.

### Manual Studio checklist (all pending)

1. Open a fresh `rojo build` (or `rojo serve`). Output: no errors or warnings, no old `Arena` or extra `SpawnLocation`.
2. Spawn: the player appears on a Nest pad, facing the east opening and the Great Stump, with the Dandelion visible. Join with several players: they spread across the three pads and none spawns inside geometry.
3. Camera: with the default camera distance, check that rock walls, the Nest rim, the arch and the trunk do not trap or obstruct the camera and that the tall landmarks read.
4. Traverse the primary route and each alternative at growth stage 1 (scale 0.6) and stage 3 (1.0): the Nest openings, trails, the gate, the S-curve passage, the north lane, the Roots corridor, the arch, back to the Nest. Note every place where you snag, get stuck or find a gap too tight.
5. Jumps: every 3-stud step (terrace, clover hill, stepping stones, fungus steps, Tank nook) is jumpable at stage 1; ramps (stump log, fallen leaf, root ramps, leaf ramp) are walkable without sliding; falling from the leaf platforms and the stump lands safely.
6. Collect pickups: the markers line up with the ground and the platforms (the ball hovers 2 studs above the marker), pickups on the elevated decks and in the secret glade are collectable, and the first pickup outside the Nest is visible from the pads.
7. Return: from the Roots, the Rock Garden and the secret glade, find the way back to the Nest using only landmarks.
8. Secret: the crack mouth is not obvious from the main passage but can be found from the glow mushrooms and the beam; the glade is reachable and the exit works.
9. Evolve to Tank and Glider and repeat the key routes; confirm that nothing is blocked for the baseline form, that the static boulder at the Tank nook front is not mistaken for a mechanic, and, optionally, try gliding from Leaf Platform 1 (top Y = 10.5) to Leaf Platform 2 and record the result.
10. Two or more clients: both see the same Baby Bug appearance, landmarks and each other without collisions at the Nest openings; watch for choke points.
11. Performance and readability: frame rate and memory on a low-end phone or the Studio mobile emulator; check for z-fighting between the ground tints, trails and the floor.
12. Output: no errors or warnings during a full loop.

## Food and growth loop

Server-only gameplay, wired in `ServerScriptService/Bootstrap.server.lua`:

| File | Responsibility |
|---|---|
| `ServerScriptService/Services/PlayerDataService.lua` | Per-player biomass (session only). `AddBiomass` is server-only, clamps to `Config.EvolutionBiomassRequired`, mirrors `Biomass` and `GrowthStage` to Player attributes, fires a server-side `ProgressChanged` signal |
| `ServerScriptService/Services/FoodService.lua` | Creates one food ball per `FoodSpawn`-tagged part, detects pickups, awards biomass, respawns food |
| `ServerScriptService/Services/GrowthService.lua` | Applies the current stage's body scale to the player's R15 character (on stage change, spawn and appearance load) |
| `ReplicatedStorage/Shared/Growth.lua` | Pure stage/scale/clamp helpers (no Roblox services) |
| `ServerScriptService/Services/LifeService.lua` | Tracks each player's life (`Alive` / `Ended`) and `lifeId`; detects life start and end; server-only `LifeBegan` / `LifeEnded` events. Resets nothing itself (see Life tracking) |
| `ServerScriptService/Services/ResetService.lua` | Subscribes to `LifeEnded` / `LifeBegan` and resets the Current Life exactly once per `lifeId` through each service's own reset function (see Reset on death) |
| `ReplicatedStorage/Shared/LifeReset.lua` | Pure rules deciding when to reset: exactly once per `lifeId`, duplicate and stale events, removed players |
| `ServerScriptService/Services/RespawnService.lua` | Controlled respawn: loads the first character, sends the recap after a life ends, handles `RequestBeginNewLife`, records life start time and highest form (see Controlled respawn) |
| `ReplicatedStorage/Shared/Respawn.lua` | Pure rules: begin-new-life validation, recap helpers (highest form, duration, formatting) |
| `StarterPlayerScripts/Controllers/LifeRecapController.lua` | Life recap screen with the BEGIN NEW LIFE button |
| `ServerScriptService/Services/DiscoveryService.lua` | TT-P3-02: finds exploration discoveries (a living character inside a `DiscoverySite` volume), grants the Biomass bonus once per life, mirrors `Discoveries` / `DiscoveryTotal`, fires `Remotes.DiscoveryFound`, provides the per-life summary for the recap |
| `ReplicatedStorage/Shared/DiscoveryDefinitions.lua` | Frozen catalog of the discoveries: id, display name, clue, Biomass reward |
| `ReplicatedStorage/Shared/Discovery.lua` | Pure discovery rules (once per life, stale events, per-player tracker, summary, volume test, recap text) |
| `StarterPlayerScripts/Controllers/DiscoveryUIController.lua` | Display only: the "Discoveries 2/6" counter and the discovery toast |
| `ReplicatedStorage/Shared/Life.lua` | Pure life transition rules (no Roblox services) |
| `ReplicatedStorage/Shared/Config.lua` | Tuning: `FoodBiomass`, `FoodRespawnDelay`, `FoodPickupRange`, `FoodHoverHeight`, `FoodCheckInterval`, `GrowthStages` |

How it works:

1. On server start, `FoodService` spawns a neon ball 2 studs above each `FoodSpawn` marker (24 in the habitat), under `Workspace.Food`.
2. Every 0.1 s the server checks each active food item against every player. A player qualifies if their character is alive, has a `HumanoidRootPart` within `FoodPickupRange` (5 studs) of the food, and is below the biomass cap. If several players qualify at once, the closest one wins.
3. The food is marked inactive and removed before biomass is awarded, so it cannot be collected twice. It respawns after `FoodRespawnDelay` (8 s).
4. Each food gives `FoodBiomass` (10). Biomass caps at 100 (`EvolutionBiomassRequired`); a player at the cap does not consume food.
5. Stages: 0 biomass = 0.6 scale, 30 = 0.8, 60 = 1.0. Crossing a threshold on a living character tweens its scale over 0.8 s (`GrowthTweenSeconds`); a new character (spawn or respawn) is set to its stage's scale at once. Progress is kept across respawns in the same session and lost when the player leaves.

Design notes:

- There are **no RemoteEvents and no client scripts for the food loop itself** (the evolution choice below adds one RemoteEvent). The client never sends a pickup request, so there is nothing to spoof. Pickup validation uses the character position as the server sees it, and the range check is a distance check only (a movement-speed or teleport check is not implemented).
- The technical plan mentions a client pickup request; this milestone deliberately uses server proximity checks instead to avoid adding a remote.
- Food variety is not implemented. The `Biomass` / `GrowthStage` Player attributes are the source for the Biomass HUD below.
- Growth uses R15 body scale values. The place's Avatar Type must be R15 (Game Settings > Avatar). R6 characters are not scaled and a warning is printed once.

## Biomass HUD

`StarterPlayer/StarterPlayerScripts/Controllers/BiomassUIController.lua`, started from `ClientBootstrap.client.lua`, builds a small HUD in code (no Studio-authored assets) at the bottom center of the screen:

- `Biomass N / 100` text, `Stage N/3` text and a progress bar (the bar turns gold at 100).
- It reads only the server-set `Biomass` and `GrowthStage` Player attributes and redraws when either changes. It never writes them and uses no RemoteEvents. Missing attributes show as 0 biomass, stage 1.
- The `ScreenGui` has `ResetOnSpawn = false`, and the attributes live on the Player, so the HUD is unaffected by respawns.
- Layout: width is 30% of the screen, clamped to 240-420 px; text is scaled between 12 and 22 px. The bar fill is `Growth.GetProgressRatio(biomass, cap)` (tested in `tests/Growth.test.lua`).
- The attribute names are string literals in `PlayerDataService.lua` and `BiomassUIController.lua`; change both together.

## Life tracking (P1-02)

`LifeService` (started first in `Bootstrap.server.lua`) only detects when a life begins and ends. It does not reset or change anything itself and never spawns characters. The reset on death is done by `ResetService` (next section), and respawning by `RespawnService` (Controlled respawn section).

- A life is one character. It begins on `CharacterAdded` (`lifeId` + 1) and ends on the first of `Humanoid.Died`, `CharacterRemoving`, a replacement character, or the player leaving. A second signal for the same life is ignored, and a late signal from an older character cannot end a newer life.
- Server-only API: `LifeService.LifeBegan(player, lifeId)`, `LifeService.LifeEnded(player, lifeId, reason)` (reason: `HumanoidDied`, `CharacterRemoving`, `CharacterReplaced`, `PlayerRemoving`), `GetState(player)`, `GetLifeId(player)`, `IsAlive(player)`. The events are BindableEvents inside the module, not remotes.
- State lives in a server table. The `LifeState` Player attribute (`Alive` / `Ended`) is a debugging mirror only and must never be used for a decision. `lifeId` is not replicated.
- The transition rules are in `ReplicatedStorage/Shared/Life.lua` and are covered by `tests/Life.test.lua`. That file does not test the Roblox signal wiring, which needs the Studio checklist below.

## Reset on death (P1-03)

When a player's life ends, the Current Life resets exactly once. Server-only; no client request or value is involved.

What resets (per player, whose life ended):

| State | Owner | Reset by |
|---|---|---|
| Biomass (and the derived `GrowthStage`, `EvolutionAvailable`) | `PlayerDataService` | `ResetBiomass` sets it to `LifeReset.StartingBiomass` (0) and publishes |
| `EvolutionForm` | `EvolutionService` | `ResetForm` sets `Config.BaseForm` (`BABY_BUG`) and refreshes the attributes |
| Active Tank shell and Glider glide, their instances and pending expiry timers, both cooldowns (`ShellReadyAt`, `GliderReadyAt`) | `AbilityService` | `ResetLife` ends both effects (bumping their tokens) and zeroes the cooldowns |
| Growth visuals (running scale tweens and the applied target) | `GrowthService` | `ResetLife`; the next character, or the current one if alive, gets the stage 1 scale at once. A dead body is not rescaled |
| Discovery log (what the player found this life) | `DiscoveryService` | `ResetLife` keeps the finished life's log for its recap and starts the next life with nothing found; the `Discoveries` attribute returns to 0 |

Not reset on purpose: per-player rate-limit timestamps (anti-spam, not life state), food in the world (shared), `LifeState`/`lifeId` (owned by `LifeService`). Biomass cap (100), food reward, thresholds (30 / 60), forms, abilities and respawn behaviour are unchanged. There is no Legacy and no persistence.

Orchestration: `ResetService` (started last in `Bootstrap.server.lua`) subscribes to `LifeService.LifeEnded` and `LifeService.LifeBegan` and calls the reset functions above in a fixed order (biomass, form, abilities, growth, discoveries). There is no second death detection. Death is still detected only by `LifeService`.

Exactly once, duplicate and stale events (pure rules in `Shared/LifeReset.lua`, one tracker per player):

- The tracker remembers the highest `lifeId` already reset. A `LifeEnded` for that life or an older one is a **duplicate** and does nothing; the tracker is marked before the reset runs.
- `LifeService` events can arrive a moment after the change. A `LifeEnded` for a life that is no longer the player's current life is **stale** and does nothing, so a late event can never reset a newer life. The `LifeBegan` handler then performs that missed reset at the start of the new life, before it has any state of its own, so every new life starts clean.
- A player who left has no current life: the event is ignored, no tracker is created, and the tracker is removed on `PlayerRemoving`.
- Delayed ability timers are guarded by their per-effect token, which the reset bumps, so a timer from an ended life cannot end or modify a newer one. `AbilityService` does not know `lifeId`; the token is its stale-callback protection. Food collection and evolution requests are synchronous and require a living character, so they have no delayed callback to guard.

Out of scope here (respawn is the next section): Legacy, persistence, combat, new forms or stages, changes to the current temporary progression.

Tests: `tests/LifeReset.test.lua` covers the pure rules and replays event orderings (reset of biomass, form, growth stage and cooldown; exactly once; duplicates; two players; a late event after a new life; a missed reset; player removal; a clean and playable next life; unchanged progression before death). It uses plain tables as players and does **not** test the Roblox wiring. Run: `lune run tests/LifeReset.test.lua`.

### Manual Studio test checklist: reset on death (P1-03)

These are **manual tests; none has been performed**. Use Play Solo, then Test > Clients and Servers with 2 players. Watch the Output for errors and warnings. Use the server view to read Player attributes.

1. Play Solo. Expected: `LifeState = Alive`, `Biomass = 0`, `EvolutionForm = BABY_BUG`.
2. Collect food to 100 Biomass and evolve to TANK. Use `Q` once (shell and cooldown are active). Reset the character (or die), then press BEGIN NEW LIFE on the recap. Expected: `LifeState` goes `Ended` then `Alive`; after respawn `Biomass = 0`, `GrowthStage = 1`, `EvolutionForm = BABY_BUG`, `ShellReadyAt = 0`, no `DefensiveShell` on any character, the ability button is hidden, the character is at the stage 1 size.
3. Repeat as GLIDER: glide in the air, die during the glide. Expected: wings, `GlideForce` and `GlideAttachment` are gone, `GliderReadyAt = 0`, form is `BABY_BUG`, and a late 3 s timer does nothing to the new life.
4. Respawn and collect food again. Expected: Biomass rises by 10 per food, stage 2 at 30 and stage 3 at 60 with the normal growth tween, evolution is offered at 100, and TANK and GLIDER can be chosen again.
5. Die with the evolution panel open. Expected: the panel closes and does not reappear in the new life until Biomass is 100 again.
6. Two players: reset only one. Expected: the other keeps Biomass, form, cooldowns and effects.
7. Die twice in quick succession (reset right after respawning). Expected: each life ends once, Biomass is 0 each time, no errors.
8. Leave during a glide or shell and during the death. Expected: no errors in the server Output, and the other player is unaffected.
9. Verify duplicate or stale events do not reset a new life: after respawning and collecting a few foods, nothing changes your Biomass or form by itself. (Add a temporary local `print` in `ResetService.onLifeEnded`/`onLifeBegan` if you want to see the events; do not commit it. Expected: one reset per death, none while alive.)
10. Rapid deaths while another script respawns you: not applicable (only `RespawnService` spawns characters since P1-04).
11. Confirm no errors or warnings in the Output at any step.

## Controlled respawn and life recap (P1-04)

The player decides when the next life begins. **Status: implemented, not validated at runtime.** The pure rules have unit tests that have not been executed (Lune is unavailable where this was written), and nothing has been run in Roblox Studio.

> Since P1-04 nothing respawns a character by itself. Older checklist steps in this README that say "respawn", "reset the character" or "wait for respawn" now mean: die, then press **BEGIN NEW LIFE** on the recap.

Behaviour:

- `Bootstrap.server.lua` sets `Players.CharacterAutoLoads = false` before anything yields.
- `RespawnService` (initialised last) loads each player's **first** character when they join (decided by the server, not a request). If a character already existed (it spawned before the setting took effect), it is kept and its life recorded.
- When a life ends, `LifeService` fires `LifeEnded`, `ResetService` resets the Current Life (P1-03), and `RespawnService` stores the recap for that player (`lifeId`, `durationSeconds`, `highestForm`, and since TT-P3-02 a `discoveries` summary). The client subscribes to `LifeRecap` and then fires `LifeRecapReady`; the server sends the stored recap after this handshake. This avoids losing the recap if the client controller starts late. The dead character stays until the next spawn. There is no countdown and no automatic respawn.
- The recap (`LifeRecapController`) shows **Life duration**, **Highest form**, the life's exploration progress (**Discoveries: 3/6 (+13 Biomass)** and the **Most notable** discovery, TT-P3-02) and a **BEGIN NEW LIFE** button (at least 56 px high, scaled panel). It appears only when the server sends the recap and hides when the new character spawns. After pressing, the button shows "Starting..." and re-enables after 6 s if nothing happened.
- The button fires `Remotes.RequestBeginNewLife` with **no values**. The client never sends a duration, form, lifeId or state.

Server validation of `RequestBeginNewLife` (pure rules in `Shared/Respawn.lua`, silent rejection, no state change on failure): the player exists and is tracked; `LifeService` says the life is `Ended` (not `Alive`); a recap is awaiting and is for the **current** life; no spawn is already in progress; and `ResetService.IsResetDone` says the ended life's reset has run (so a new life never starts before the P1-03 reset). The first valid request marks its spawn operation in flight synchronously, so spam, duplicates and same-frame requests are rejected until that operation's `LoadCharacter` call returns (changed in P1-05; before, the flag cleared when the character was added). A failed `LoadCharacter` (logged with `warn`) releases the operation so the player can retry. Extra arguments are ignored; there is no separate rate limiter because the state checks reject repeats immediately.

Who owns what: `LifeService` stays the only authority on Alive/Ended and detects death; `RespawnService` only spawns characters (via `Player:LoadCharacter()`, never while a life is alive) and sends the recap; a life begins when `LifeService` sees the new character, and the Respawn record is cleared on `LifeBegan`. Recap statistics live in `RespawnService`: the start time (`workspace:GetServerTimeNow()` when the life began) and the highest form, updated from the new server-only `EvolutionService.FormChanged` event, which fires only after a valid selection. One evolution is allowed per life, so the first evolved form reached is the highest (no ranking between forms is invented).

Player removal: the entry is deleted on `PlayerRemoving`, no recap is sent to a leaving player, and a `LoadCharacter` still running for a player who left changes nothing.

Not included: death rewards or penalties, Legacy or persistent statistics, a death screen beyond this recap, combat or health, any change to Biomass tuning or evolution requirements.

Known limitations and risks:

- **Studio race:** if a character is created before the script sets `CharacterAutoLoads = false` (possible in Play Solo), `RespawnService` keeps that character; the recorded start time is then the moment the service started. Check step 1 below.
- Recap delivery is retained server-side until the next life begins and replayed after the client-ready handshake. The client-ready signal is per player; it does not authorize a respawn or alter life state.
- The dead character remains in the world until the player presses the button.
- `Player:LoadCharacter()` behaviour and failure modes could not be tested here.

Tests: `tests/Respawn.test.lua` covers the pure rules and replays player timelines through the real `Life`, `LifeReset` and `Respawn` rules: valid transition, request while alive, duplicates and spam, stale life id, spawn in progress, reset still pending, a failed spawn and retry, removal during the recap and during a spawn, exactly one new life per valid request over 8 cycles, never more than one living character, independent players, and the recap helpers (highest form, duration, formatting). It uses plain tables as players and does not test `CharacterAutoLoads`, `LoadCharacter`, the remotes, the UI or event delivery. Run: `lune run tests/Respawn.test.lua`. Since P1-05 the pure rules are in `tests/Respawn.test.lua` and the timelines in `tests/Lifecycle.test.lua`.

### Manual Studio test checklist: controlled respawn and recap (P1-04)

These are **manual tests; none has been performed**. Use Play Solo, then Test > Clients and Servers with 2 players. Watch Output for errors and warnings and read Player attributes in the server view.

1. Play Solo: the initial spawn works without any input and `LifeState = Alive`, `lifeId = 1` (check there is exactly one character).
2. Kill the character (reset, or set health to 0). Expected: the recap appears with a duration and the highest form; **no character appears by itself**; `LifeState = Ended`.
3. Click **BEGIN NEW LIFE**. Expected: exactly one new character, the recap hides, `LifeState = Alive`, `lifeId` increased by exactly 1.
4. The new character is Baby Bug with Biomass 0, `GrowthStage = 1`, no cooldowns, no shell or wings, stage 1 scale.
5. Evolve to TANK, die, check the recap shows **Tank** as highest form. Repeat as GLIDER, and with no evolution (**Baby Bug**). Die and respawn at least 5 times in a row.
6. Spam the button while dead (and with the command bar: `for i = 1, 100 do game.ReplicatedStorage.Remotes.RequestBeginNewLife:FireServer() end`). Expected: exactly one new character and no errors. Also fire it while alive and as a brand-new player: nothing happens.
7. Two players: one dies and respawns while the other keeps playing. Expected: the other keeps Biomass, form, cooldowns, effects and has no recap; only the dead player sees one.
8. Close a client while the recap is showing (and once right after pressing the button). Expected: no server errors and no character, tracker or state for that player afterwards.
9. Verify no duplicate characters, active lives or duplicate event handling after many cycles (count characters; check `lifeId` equals the number of spawns).
10. Mobile: in the Device emulator (phone) or on a real touch device, the recap is fully on screen and the button is easy to tap; tapping it does not also move the camera or character.
11. Rejoin: the first spawn works again, and a player who dies immediately (before evolving) still gets a recap with Baby Bug.
12. Confirm the recap never appears while the player is alive and never covers the Biomass HUD in a way that blocks the button.

## Lifecycle hardening (P1-05)

Hardening of the lifecycle built in P1-02 to P1-04 (including the recap handshake already in master). No gameplay, tuning, forms, abilities, persistence or recap UX changes. **Status: implemented in code; covered by pure tests that have been written but NOT executed (Lune is unavailable where this was written); NOT validated in Roblox Studio.** Nothing below is marked validated.

| Level | What |
|---|---|
| Implemented in code | the four fixes below, the `lifeId` on recaps, a local limit on handshake replays |
| Covered by automated tests (written, not run) | the pure rules and orderings in `tests/Respawn.test.lua` and `tests/Lifecycle.test.lua` |
| Requires Roblox Studio validation | everything that depends on `LoadCharacter`, event delivery order, remotes, the UI and real disconnects (checklist below) |
| Actually validated in Studio | **none** |

Defects found in the code of master at the start of P1-05 (each is a real path, not a hypothetical):

1. **A second `LoadCharacter` could start while the first was still yielding.** `Respawn.OnLifeBegan` cleared the spawning flag as soon as the new character was added, but `LoadCharacter` keeps yielding until the appearance loads. A death in that window plus another BEGIN NEW LIFE press started a second call, and the first call's return then cleared the flag of the second (`OnSpawnFailed`). Fix: the flag is a numbered spawn operation (`spawnSeq` / `inFlightSeq`), set when the request is accepted and released only by `Respawn.EndSpawn` when that operation's own call returns. A stale sequence changes nothing; a life beginning or ending never releases it. `OnSpawnFailed` was removed because it could clear the wrong operation.
2. **A failed first spawn left the player stuck with no character and no way to ask for one.** The first spawn is not a request and a failed one produced no recap. Now `retryInitial` is set when the first spawn ends with no life; the server stores and sends a `lifeId = 0` notice through the existing recap/handshake path (the client titles it "SPAWN FAILED", same button) and accepts one retry that needs no reset.
3. **Recaps had no ordering.** A recap that arrives late or is replayed by the handshake could appear after the new character spawned (the overlay then blocks clicks) or overwrite a newer one, because remote delivery and character replication are not ordered against each other. Each recap now carries the server's `lifeId`; the client ignores older, already dismissed and malformed ones (`Respawn.ShouldShowRecap`), and a replay of the recap already on screen does not undo a pending button press. The server clears its pending recap only when a newer life begins.
4. **A late `LifeEnded` of an older life could re-arm the recap wait.** After a newer life began, the pure record accepted the stale event again. It now remembers the newest life that began (`beganLifeId`) and ignores ended ids older than it.

Handshake (already in master, kept): the client subscribes to `LifeRecap`, then fires `LifeRecapReady`; the server holds the pending recap and sends it once the client is ready, replaying it on later ready messages. P1-05 adds only a local policy in `RespawnService`: ready messages closer than one second to the previous one are ignored. This is anti-spam; repeats only ever replay the same pending recap to the same player.

Audited and found correct, left unchanged:

- Per-player records are removed on `PlayerRemoving` (`PlayerDataService`, `EvolutionService`, `AbilityService`, `GrowthService`, `ResetService`, `RespawnService`, `LifeService`), and delayed paths re-check at the time of use: `loadCharacter` checks the entry is still the player's, ability timers use tokens that the reset bumps, `ResetService` creates a tracker only for a present player. Per-player connections die with the Player.
- `ResetService`: exactly once per `lifeId`, stale `LifeEnded` handled by the `LifeBegan` safety net, the next life gated by `IsResetDone`. Each service resets only its own state.
- `LifeService` ordering as read in the code: `LifeBegan` before an instant death's `LifeEnded`; the removal of a dead character by `LoadCharacter` is an idempotent no-op; a replaced character ends the old life first.
- Isolation: all lifecycle state is in tables keyed by Player; no shared mutable per-player state.

Invariants after P1-05 (rules in `Shared/Respawn.lua`, `Shared/Life.lua`, `Shared/LifeReset.lua`):

- At most one active life per player and at most one living character; a request is refused unless `LifeService` reports the life `Ended`.
- At most one spawn operation in flight per player; it ends only when its own `LoadCharacter` returns; a stale operation cannot release or modify a newer one.
- Each ended life is reset exactly once, and a new life cannot start before that reset ran.
- A stale or duplicate lifecycle event changes nothing.
- A failed spawn never locks the player: a failed later spawn leaves the recap awaiting and re-allows a request; a failed first spawn re-allows one retry.
- The recap the player waits on is held by the server until a newer life begins; the client shows each recap at most once per life and never an older one.
- A player who leaves has no state recreated by any late callback or `LoadCharacter` return.

Known limitations (not fixed, need Studio observation):

- A `LoadCharacter` that never returns would keep the player locked; Roblox gives no timeout and no arbitrary timer was added.
- If a reset function throws, the error is not swallowed and the tracker is already marked, so the next-life request would stay `ResetPending`. Not observed; no change was made.
- Event delivery order (deferred BindableEvents) is assumed as documented in `LifeReset`; the pure tests replay both orders.
- The one-second handshake limit is a server-local policy and is not covered by the pure tests.

Tests: `tests/Respawn.test.lua` (pure rules) and `tests/Lifecycle.test.lua` (timelines through the real pure `Life`, `LifeReset` and `Respawn` rules with plain tables). They cover: many requests for one life including the same frame; rapid ends and begins including a death while `LoadCharacter` still yields; an old spawn operation completing after a newer one started; duplicate and stale events; a failed later spawn and a failed first spawn each followed by a valid retry; player removal during a pending operation and during the recap; independent players; old-life callbacks after a new life began; recap delivery, the late-client handshake, repeated ready messages, old recaps never overwriting new ones and clearing across consecutive lives; reset gating the next life; cleanup and idempotency over 10 cycles. They do not test `LoadCharacter`, remotes, attributes, tweens, the UI or event timing. Run: `lune run tests/Respawn.test.lua` and `lune run tests/Lifecycle.test.lua`.

### Manual Studio test checklist: lifecycle hardening (P1-05)

These are **manual tests; none has been performed**. Use Test > Clients and Servers with 2 to 3 players, with Output and the server view open.

1. Die immediately after a new character appears (a few frames after BEGIN NEW LIFE). Expected: a recap, one life, one character, no errors.
2. While the new character is still loading its appearance (slow avatar or throttled network in the emulator), die and press BEGIN NEW LIFE again. Expected: no second character until the first `LoadCharacter` has finished; afterwards one press works.
3. Spam BEGIN NEW LIFE from the client and with `for i = 1, 100 do game.ReplicatedStorage.Remotes.RequestBeginNewLife:FireServer() end` on the dead player. Expected: exactly one new character and life.
4. Make the first spawn fail (for example `LoadCharacter` temporarily erroring on the server). Expected: the "SPAWN FAILED" notice with a working button, and one retry spawns one character.
5. Delay the recap UI (join, die before the controller connects). Expected: the recap still appears once the client is ready; extra `LifeRecapReady` messages (`game.ReplicatedStorage.Remotes.LifeRecapReady:FireServer()` repeatedly) do not duplicate, flicker or reset a pending button press.
6. Confirm an old recap never appears after a newer one or after the new character spawned (check right after pressing BEGIN NEW LIFE).
7. Two players: one dies, one fails to respawn, one leaves. Expected: the others' Biomass, form, ability state, cooldowns, `LifeState`, recap and spawn state are untouched.
8. Leave while dead, while recapping, and while `LoadCharacter` is running. Expected: no server errors, no new character, no state left behind.
9. Reset the character 10 or more times in a row. Expected: `lifeId` equals the number of spawns, never two living characters, resets exactly once per ended life, clean Biomass, form, growth, ability effects and cooldowns at every life start.
10. Output shows no errors or warnings other than the intentional `LoadCharacter` failure in step 4.

## Evolution choice

Server-owned, session-only. Players start as `BABY_BUG`; at 100 biomass they can choose `TANK` or `GLIDER` once.

| File | Responsibility |
|---|---|
| `ReplicatedStorage/Shared/CreatureDefinitions.lua` | P2-02: single frozen source of truth for stable form IDs, display metadata, per-form Biomass requirements and ability ID references; exposes `StarterFormId`, ordered `Forms`, `EvolvedForms`, `EvolvedFormIds`, `GetForm(id)` |
| `ReplicatedStorage/Shared/Evolution.lua` | Pure rules driven by the passed catalog: `IsValidForm(form, catalog)`, `IsAvailable(biomass, currentForm, catalog)`, `Validate(form, biomass, currentForm, catalog)`, `Select(...)`; each form requirement is checked |
| `ReplicatedStorage/Shared/Config.lua` | `BaseForm` and `EvolutionForms` are compatibility aliases from CreatureDefinitions. `EvolutionBiomassRequired` (100) is currently the Biomass cap, not evolution eligibility |
| `ServerScriptService/Services/EvolutionService.lua` | Owns each player's form, sets the attributes, creates `ReplicatedStorage.Remotes.RequestEvolution`, validates requests |
| `StarterPlayerScripts/Controllers/EvolutionUIController.lua` | Choice panel, form badge, overhead form tag. Cards, names and labels are generated from `CreatureDefinitions` / `AbilityDefinitions` (no per-form UI data) |
| `ReplicatedStorage/Shared/EvolutionPresentation.lua` | Pure helpers that turn the catalogs into card view-models (display name, role, description, ability names resolved through `AbilityDefinitions`, requirement text, locked flag). Unknown ability ids become a visible `Unknown ability (ID)` entry instead of an error |

Replicated Player attributes (visible to every client):

- `EvolutionForm` (string): `BABY_BUG`, `TANK` or `GLIDER`.
- `EvolutionAvailable` (bool): true while biomass has reached the threshold and the player has not evolved. The server recomputes it whenever biomass changes.

Server validation of `RequestEvolution(form)`. The client sends only a branch name. First, a per-player **rate limit** runs on the server: a request arriving less than `EvolutionRequestCooldown` (0.5 s) after that player's last *processed* request is dropped immediately, before any validation or state lookup. Every request that passes the limiter counts, including invalid ones, so bad requests cannot be used to bypass it. Dropped requests do not extend the cooldown, so a later legitimate request is never blocked for longer than 0.5 s. The timestamp is removed when the player leaves. The UI's 0.6 s click lock is only a convenience and is not relied on for security. After the limiter, the server ignores a request, changing nothing, unless all of these hold:

1. The player is tracked by the server and has a living character (`Humanoid.Health > 0`).
2. The player has not already evolved (current form is still `BABY_BUG`).
3. The server-side biomass has reached the requested form's own requirement in `CreatureDefinitions` (100 Biomass for both Tank and Glider today). Client-supplied biomass is never read.
4. The argument is exactly the ID of an evolved form in `CreatureDefinitions`, today `"TANK"` or `"GLIDER"` (case-sensitive; any other type or value is rejected).

Because the server handles requests one at a time and sets the form before anything else can run, a valid choice is recorded exactly once; repeats and spam are no-ops. A rejected request changes nothing. The UI state comes from the replicated attributes, and the requesting player (only) also receives `Remotes.EvolutionResult(reason)` (`Ok`, `ThresholdNotReached`, `AlreadyEvolved`, `InvalidForm` or `NoLivingCharacter`) so the UI can explain a rejection. Requests dropped by the rate limit get no reply. The pure transition is `Evolution.Select`, which returns the unchanged form on any rejection. State is per player, so one player's choice never changes another's biomass, form or availability. Form is kept across respawns and lost when the player leaves.

Client behaviour (`EvolutionUIController`):

- When the server sets `EvolutionAvailable`, an **EVOLUTION READY** panel shows one card per entry of `CreatureDefinitions.EvolvedForms` (today **Tank** and **Glider**): display name, role, description, ability name and Biomass requirement, all from the catalogs. Two columns for two or more forms (more forms add rows that scroll inside the card area), one column for a single form. A card whose requirement the replicated `Biomass` does not meet is dimmed and cannot be selected; this is feedback only and the server still validates every request. Adding an evolved form to the catalogs adds its card with no UI change.
- Choosing is two steps: tap a card (local highlight only, nothing is sent), then **Confirm**. This prevents accidental and double selection; the Confirm button is disabled until a card is picked and while a request is pending ("Evolving..."). The local pending state times out after 3 s with "No response. Please try again." This lock is a convenience, not security.
- On success the panel hides (driven by the attribute) and a short toast says `You evolved into <Form>!`. On rejection the panel stays and the status line shows a plain message from the server's reason.
- The panel scales with the screen (70% x 82%, clamped to 320x300 to 640x460 px) with scaled, size-limited, wrapped text. These sizes are untested guesses until checked in Studio.
- The overhead tag is attached only if, after waiting for the character's `Head`, that character is still the player's current character and the player is still in the game; stale characters are never tagged. A missing `Head` is skipped.
- A badge above the Biomass HUD shows `Form: <name>`.
- Evolved players get an overhead tag (the form's catalog display name) so other clients can see the choice. It is read from the replicated attribute.

Limitations:

- Evolution is recorded and displayed. TANK gets the visual-only Defensive Shell and GLIDER gets the bounded Air Glide (next sections). Neither form has stat or model differences, and there is no damage or combat.
- Biomass stays at 100 after evolving, so the Biomass HUD stays full and the player cannot gain more biomass.
- A player who disconnects loses their form (no persistence).
- TANK and GLIDER differ **only by their ability**. There are no stat, speed or health differences and no new models, because the project has no such systems and none were invented. Tank's shell has no combat effect until a damage system exists.
- Client-side changes to Player attributes (for example `EvolutionForm`) do not replicate to the server, which keeps its own form table and never reads those attributes for decisions.
- The success toast and the form badge follow the replicated attribute, so they can appear a moment after the server accepted the request.

## Tank Defensive Shell

First TANK ability. **Visual only**: there is no damage, health, knockback or combat system in the project, so the shell does **not** reduce damage, grant invulnerability, resist knockback or change movement speed. It only shows a protective bubble.

Behaviour (ability id, required form and tuning come from `AbilityDefinitions`, see below; none hardcoded elsewhere):

- Key `Q` (`AbilityKey`) or the on-screen **SHELL [Q]** button (mid-right of the screen, tappable on touch devices).
- Only players whose server-side form is `TANK` (`requiredForm` of the `SHELL` definition) can use it.
- The shell stays for 3 s (`durationSeconds`). The cooldown is 12 s (`cooldownSeconds`) and **runs from activation**, so the ability is usable again 9 s after the shell disappears.
- Repeated input can neither extend the shell nor shorten the cooldown. The cooldown is cleared when the life ends (death) and when the player leaves.

| File | Responsibility |
|---|---|
| `ReplicatedStorage/Shared/Ability.lua` | Pure rules: `Validate`, `IsActive`, `GetCooldownRemaining` |
| `ServerScriptService/Services/AbilityService.lua` | Creates `Remotes.RequestAbility`, validates, owns timing and state, builds and removes the shell |
| `StarterPlayerScripts/Controllers/AbilityController.lua` | `Q` input, button, status text |

Server authority:

- `RequestAbility(abilityId)` is shared by Tank and Glider. The client sends only the identifier string (`"SHELL"` or `"GLIDE"`, from `Config`). A missing, non-string or unknown identifier is ignored; extra arguments are ignored. The server uses the player from the remote, reads the form from `EvolutionService`, and sets all times itself. `"SHELL"` needs form `TANK`, `"GLIDE"` needs form `GLIDER`.
- A request is ignored, changing nothing, unless: the player is still in the game, the form is `TANK`, the character has a living Humanoid and a `HumanoidRootPart`, the shell is not already active, and the cooldown has expired.
- Timing uses `workspace:GetServerTimeNow()`. State is replicated as the Player attributes `ShellActiveUntil` and `ShellReadyAt` (timestamps, 0 = unused). The button is driven only by these attributes, so a rejected request changes nothing on screen. It ticks per frame only while a countdown is showing.
- A per-player **rate limit** runs first in the handler, before any form or character lookup: a request arriving less than `AbilityRequestInterval` (0.25 s, separate from the 3 s duration and 12 s cooldown) after that player's last *processed* request is dropped. Every request that passes the limiter counts, including rejected ones. Dropped requests do not extend the interval. The timestamp is removed when the player leaves, and requests from a player who already left are ignored. It uses `os.clock()` like the evolution limiter and does not change the gameplay cooldown.

Shell visual and lifecycle:

- A translucent blue ball `Part` (`ForceField` material) named `DefensiveShell`, created on the server and parented to the character, so all clients see it. It is welded to `HumanoidRootPart` with a `WeldConstraint`, sized 1.3x the character's largest bounding dimension at activation, with `CanCollide`, `CanTouch` and `CanQuery` off, `Massless` on and shadows off, so it cannot block movement or alter physics.
- It is removed when the timer ends, when the Humanoid dies, when the character is removed or replaced (`CharacterRemoving`), if the form stops being `TANK`, and when the player leaves. Each activation bumps a token so a stale expiry timer can never remove a newer shell, and at most one shell exists per player.

Limitations:

- No gameplay effect, as above. The shell size is fixed at activation; if the character grows during the 3 s the shell does not resize.
- The visual (size, material, readability) and button placement are untested guesses until checked in Studio.
- Rejections are silent.

## Ability definitions (P2-03)

`ReplicatedStorage/Shared/AbilityDefinitions.lua` is the single, frozen source of truth for ability ids, display names, the form each ability requires and ability-specific tuning. It is pure data (no Roblox services, no requires) and was created by moving the former `Config` values without changing any number or behaviour:

| Ability | `id` | `kind` | `requiredForm` | `durationSeconds` | `cooldownSeconds` | Other |
|---|---|---|---|---|---|---|
| Defensive Shell | `SHELL` | `Shell` | `TANK` | 3 | 12 | visual only |
| Air Glide | `GLIDE` | `Glide` | `GLIDER` | 3 (maximum) | 10 | `gravityCompensation` 0.9 (descending), `ascentCompensation` 0.65 (rising) |

API: `GetAbility(id)` (nil for unknown or malformed ids), `Abilities` (ordered), `AbilityIds`, `ShellId`, `GlideId`; the entry types are a narrow union discriminated by `kind`. `AbilityService` resolves every incoming id through `GetAbility`, selects the existing Shell or Glide implementation by `kind`, and checks the player's server-owned form against `requiredForm`. The specialised Shell and Glide code, the airborne check, cooldowns, rate limit and cleanup are unchanged. `Ability.lua` keeps its pure rules and still receives the required form and timings as arguments.

Relationship with `CreatureDefinitions`: a form lists the ability ids it owns (`TANK` -> `SHELL`, `GLIDER` -> `GLIDE`, `BABY_BUG` -> none) and each ability names the form that may use it. Neither module requires the other (no dependency cycle); `tests/AbilityDefinitions.test.lua` checks that the two references agree.

Still global in `Config` (not per-ability): `AbilityKey` (the shared input binding), `AbilityRequestInterval` (anti-spam, not a gameplay cooldown) and `AbilityDebugLogging` (diagnostics switch, default off). The old `TankShell*`, `Glider*`, `AbilityShellId` and `AbilityGlideId` keys were removed, with no aliases.

Shell is **visual only** (it does not mitigate damage) and Glide is a **bounded glide, not flight**. Run: `lune run tests/AbilityDefinitions.test.lua`.

## Glider Air Glide

Second form ability: a **bounded glide, not flight**. It is server-authorised and uses a simple temporary upward force; it adds no damage, stamina, combat or movement-setting changes.

Behaviour (values in the `GLIDE` entry of `AbilityDefinitions`):

- Key `Q` (`AbilityKey`, shared with the Tank shell) or the on-screen **GLIDE [Q]** button (same mid-right position as the Tank's **SHELL** button; only one of the two is ever shown, depending on the form).
- Only players whose server-side form is `GLIDER` (`requiredForm` of the `GLIDE` definition) can use it, and only while **airborne** (`Humanoid.FloorMaterial == Air`, read on the server).
- One press starts an automatic glide for up to 3 s (`durationSeconds`); no holding is needed. **Landing ends it immediately.**
- Cooldown 10 s (`cooldownSeconds`), measured from successful activation; it is cleared when the life ends (death) and when the player leaves.
- While gliding, a server-created `VectorForce` pushes up with a share of the character's weight (`AssemblyMass * Workspace.Gravity`): `ascentCompensation` (0.65) while the character is rising and the stronger `gravityCompensation` (0.9) otherwise, so the fall is slowed a lot but a glided jump keeps its designed apex. `AbilityService` re-evaluates the share from the vertical velocity on one bounded `Heartbeat` connection per active glide (removed when the glide ends); the force object only changes when rising turns into falling. Both shares are capped below 1 in `Ability.GetGlideForce`, so gravity always wins and the net vertical acceleration is always downward: it is not flight. No horizontal force is applied: steering is the normal Roblox character controls. `WalkSpeed`, jump settings and network ownership are not changed.
- Visual: two thin neon "wings" welded beside the torso, created on the server so all clients see them. They are massless and have no collision, touch or query. Removed when the glide ends.

How the state is shared:

| Piece | Responsibility |
|---|---|
| `Shared/Ability.lua` | Pure rules: `ValidateGlide`, `GetGlideForce` (ascent/descent share), `IsGlideLanding`, the glide session helpers, shared `IsActive` / `GetCooldownRemaining` / `IsRateLimited` |
| `Services/AbilityService.lua` | Same `RequestAbility` remote as Tank. Validates, owns timestamps and cooldown, creates and removes the force, attachment and wings, ends the glide on landing, death, character removal, form change and player leave |
| `Controllers/AbilityController.lua` | One shared controller: picks SHELL or GLIDE from the replicated `EvolutionForm`, sends only the identifier, shows `Ready`, `Gliding` or `Cooldown` from `GliderActiveUntil` / `GliderReadyAt` (server-time timestamps). It never shows `Gliding` before the server sets the attribute and ticks per frame only while a countdown is showing |

Server validation for `"GLIDE"`, after the existing per-player rate limit (`AbilityRequestInterval`, separate from the gameplay cooldown, counting rejected requests): the player is still connected, the server-owned form is `GLIDER`, the character exists with a living Humanoid and a `HumanoidRootPart`, `FloorMaterial` is `Air`, no glide is active, and the cooldown has expired. Stale expiry timers are invalidated with a per-player token.

Trust boundary (important): Roblox gives the player's client physics ownership of their own character, and this feature does not change that. The server decides when a glide may start and end and when the cooldown allows another, and the force object replicates to the owning client, but the server **cannot prevent a modified client from ignoring the force or moving the character however it likes**. That is true of all player movement in this game; no server-side movement validation (speed, height checks) was added. Landing detection uses the server's copy of `FloorMaterial` and `Humanoid.StateChanged`; the 3 s timer ends the glide regardless.

Jump height and the habitat (analytic estimate, **not a Studio test**): with default `Workspace.Gravity` (196.2) and `JumpHeight` 7.2, a normal jump rises about 7.2 studs and lasts only about **0.54 s** (0.27 s down from the apex). Activating the glide near the start of a jump leaves 35% of gravity while rising (`ascentCompensation` 0.65, unchanged), so the same jump rises to roughly 20 studs: it does not provide upward acceleration, but it does raise the jump apex, which is how the glider-only platforms are meant to be reached. The old arena's glider-only platforms were removed with the First Habitat: no pickup or route in the habitat needs the glide (the elevated decks have walkable ramps), and the only glider-oriented geometry is the optional 10-stud span between Leaf Platforms 1 and 2 (tops at Y = 10.5), which a glide from the first platform may or may not cross; that must be tested in Studio.

### Glide tuning and the "wings for half a second" report (TT-P2-05B)

Observed in Studio: after activating, the wings appeared for about 0.5 s and the glide ended, with the 10 s cooldown running. Root cause from the code and kinematics (the exact event that ended each glide still has to be confirmed in Studio with the new logging, see below): the previous single compensation of 0.65 applied to the whole glide, so from the apex of an ordinary jump the fall lasted 0.45 s (versus 0.27 s without a glide), about as long as the airtime of an ordinary jump. The wings vanished because the character really landed, and nothing could have kept it up longer: 3 s is only a maximum. It was a tuning problem, not a cleanup bug; the cooldown correctly runs from activation even when landing ends the glide early. A secondary risk was that three unconfirmed signals (`FloorMaterial`, the `Landed` and `Running` states, read from the server's copy of a client-owned Humanoid) each ended the glide immediately.

Changes:

| Change | Why |
|---|---|
| `gravityCompensation` 0.65 to 0.9, applied while descending; `ascentCompensation` 0.65 keeps the rising behavior | At 0.9 a fall from the apex of a normal jump lasts about 0.85 s (3.1x), a 20-stud drop 1.4 s (3.2x) and the landing speed is about 17 studs/s instead of 52. A jump glided from take-off lasts about 2.2 s, under the 3 s limit, with the same apex as before. Net acceleration is still downward at every step. |
| Landing needs confirmation (`Ability.IsGlideLanding`) | A `Landed`, `Running` or `FloorMaterial` event only ends the glide if the Humanoid reports a floor or a downward raycast (`HipHeight` + half the root height + 1 stud, ignoring the character) finds ground. A transient event in the air is ignored and logged. |
| Glide state rules moved into `Ability.lua` (`StartGlide`, `TryStartGlide`, `EndGlide`, `IsCurrentGlide`, `ResetGlide`) | They are shared by `AbilityService` and unit-tested: a rejected request never starts the cooldown, ending never changes the cooldown, and a stale expiry timer or event cannot end a newer activation (token check). |
| Diagnostics: `Config.AbilityDebugLogging` (default `false`) | Set it to `true` in Studio to print `[Glide]` lines: start (state, floor material, vertical velocity, height), the end `reason` (`Expired`, `Died`, `Landing:Landed`, `Landing:Running`, `Landing:FloorMaterial`, `CharacterRemoving`, `FormChanged`, `Reset`, `PlayerRemoving`, `Reactivate`), the elapsed time, and any ignored transient event. |

The simulated numbers use a 60 Hz integration of the same force rule (`tests/Ability.test.lua`); real Studio physics may differ, so the 0.9 value is a calculated starting point, configurable in `AbilityDefinitions`, not a validated feel. A glider-only platform reachability test is still required (checklist below).

Limitations:

- Untested in Studio: physics feel, wing look and the landing detection are unverified.
- Rejections are silent. The glide ends on landing, so the 3 s may not be used in full.
- If the character is scaled (growth) the force is computed at activation from the current `AssemblyMass`.

### Tests

`tests/Growth.test.lua` covers the pure helpers in `Growth.lua` (stages, scale, clamp, progress ratio) and sanity-checks `Config`. `tests/AbilityDefinitions.test.lua` covers the ability catalog, immutability and the cross-reference with creature forms. `tests/EvolutionPresentation.test.lua` covers the pure UI data preparation (catalog relationships, unknown ability ids, locked state; no Roblox GUI). `tests/CreatureDefinitions.test.lua` covers the creature catalog (IDs, requirements, ability references, immutability, Config aliases and growth milestones). `tests/Evolution.test.lua` covers the pure, definition-driven rules in `Evolution.lua` (valid and invalid branches, threshold, repeat requests, `Select` state transitions, two-player isolation, readiness at 99/100 biomass, cross-form ability checks, nil/NaN input, and the rate-limit check including a simulated 1000-request spam). The server wiring of the limiter and the tag lifecycle guard use Roblox APIs and are checked manually. `tests/Ability.test.lua` covers the pure shell and glide rules, the glide force bound, and the request rate-limit helper (only TANK may activate; BABY_BUG, GLIDER and bad input are rejected; dead character, already active, cooldown, available again after cooldown, early end keeps the cooldown). `tests/Multiplayer.test.lua` covers the pure multiplayer rules (see the next section). `tests/LifeReset.test.lua` covers the pure reset-on-death rules (see Reset on death). `tests/Respawn.test.lua` covers the pure controlled-respawn and recap rules (see Controlled respawn). Run each with `lune run tests/<name>.test.lua`. Server and client behaviour of the shell uses Roblox APIs and cannot be run in this test setup; it is checked manually. It is optional and outside the Rojo tree. Run it with [Lune](https://lune-org.github.io/docs): `lune run tests/Growth.test.lua`. Lune is not part of `rokit.toml`. The service modules depend on Roblox APIs and are tested manually in Studio. `tests/Life.test.lua` covers the pure rules in `Life.lua` (begin/end transitions, `lifeId`, duplicate and stale end requests, invalid input); it does not cover the Roblox signal wiring. `tests/Respawn.test.lua` covers the pure respawn/recap rules and `tests/Lifecycle.test.lua` replays lifecycle timelines through the real pure `Life`, `LifeReset` and `Respawn` rules (see Lifecycle hardening (P1-05)); both are optional, Lune-run and not Studio tests.

### Manual Studio test checklist

1. `rojo build default.project.json -o build.rbxlx`, open it in Studio (or use `rojo serve`) and confirm Avatar Type is R15.
2. Play Solo. Expected: character spawns small (scale 0.6); `Workspace.Food` holds 8 green balls above the green food markers; no output errors.
3. Walk into one ball. Expected: it disappears, and in Explorer `Players > <you>` attributes show `Biomass = 10`, `GrowthStage = 1`.
4. Collect 3 balls total. Expected: `Biomass = 30`, `GrowthStage = 2`, character visibly larger. Collect 6 total: `Biomass = 60`, `GrowthStage = 3`, normal size.
5. Wait 8 s after collecting. Expected: the ball reappears.
6. Collect until `Biomass = 100`. Expected: biomass stops at 100 and food is no longer consumed by you.
7. Reset the character (or die). Expected: you respawn as a new life at stage 1 size with Biomass 0 (see the P1-03 checklist).
8. Test > Clients and Servers, 2 players, both stand near the same ball. Expected: only one player gains biomass; the closer one if distances differ.
9. Check the elevated pickups (Great Stump top, clover hill, arch top, leaf platforms, fungus vantage): each is reachable on foot, and none needs the glide.
10. Check that the smaller character fits routes, jumps normally and the camera behaves at scale 0.6.

### Manual Studio test checklist: Biomass HUD

1. Play Solo. Expected: HUD at bottom center shows `Biomass  0 / 100`, `Stage 1/3`, empty bar, no output errors.
2. Collect one food. Expected: text becomes `Biomass  10 / 100`, the bar animates to 10%.
3. Collect to 30 and 60 biomass. Expected: stage text changes to `Stage 2/3` at 30 and `Stage 3/3` at 60, in step with the character growing; the bar fill matches biomass / 100 each time.
4. Collect to 100. Expected: `Biomass  100 / 100`, full gold bar, no overflow.
5. Reset the character. Expected: the HUD stays visible and unchanged, and still updates after the next food.
6. Test > Clients and Servers with 2 players. Expected: each client's HUD shows only its own biomass; collecting on one client does not change the other's HUD.
7. In the emulator (Test > Device) try a phone portrait, phone landscape, tablet and 1080p. Expected: the panel stays readable, centered, not clipped by the screen edge or the Roblox bottom bar, and does not cover the hotbar or touch controls.
8. In Explorer during play, change your own Player attributes on the client side (not the server) and confirm the server value is not affected. This confirms the HUD is display-only.

### Manual Studio test checklist: life tracking (P1-02)

Check `LifeState` on your Player in Explorer (server view while playing). To see `lifeId`, run in the server command bar: `print(require(game.ServerScriptService.Services.LifeService).GetLifeId(game.Players.YourName))`. If that does not match what you see, use a temporary local `print` in `LifeService.lua` instead and do not commit it.

1. Play Solo. Expected: the character spawns and `LifeState` is `Alive`.
2. Use Roblox Reset Character. Expected: `LifeState` becomes `Ended`.
3. Press BEGIN NEW LIFE on the recap (respawn is no longer automatic). Expected: `LifeState` is `Alive` again.
4. Repeat the death a few times. Expected: `lifeId` rises by exactly 1 per spawn and never on death.
5. Log `LifeEnded` for one death. Expected: exactly one event, even though `Humanoid.Died` and `CharacterRemoving` both occur.
6. Collect food, evolve, then die and respawn. Expected: the life ends once and the new life starts with Biomass 0 and `EvolutionForm = BABY_BUG` (see the P1-03 checklist).
7. Use Tank Shell and Glider before and after a death. Expected: both still work and existing cleanup is not broken.
8. Test > Clients and Servers with 2 players, reset one. Expected: the other player's `LifeState` and `lifeId` do not change.
9. Have a player leave during an active life. Expected: no errors; the lifecycle record and connections are cleaned up.
10. Expected throughout: no errors or warnings from `LifeService` in Output.

### Manual Studio test checklist: Evolution

Solo (Play Solo, Avatar Type R15):

1. At start: badge shows `Form: Baby Bug`; no choice panel; in Explorer the Player has `EvolutionForm = BABY_BUG`, `EvolutionAvailable = false`.
2. Collect food up to 90 biomass. Expected: still no panel, `EvolutionAvailable = false`.
3. Collect the next food (100). Expected: the `EVOLUTION READY` panel appears with TANK and GLIDER buttons and `EvolutionAvailable = true`.
4. Click TANK (or GLIDER). Expected: the panel hides, the badge shows the chosen form, `EvolutionForm` matches, `EvolutionAvailable = false`, and an overhead tag appears above your head.
5. Reset the character. Expected (since P1-03): the death ends the life, so the form returns to Baby Bug, the badge and tag follow, and the panel is closed.
6. Try to choose again (command bar on the client): `game.ReplicatedStorage.Remotes.RequestEvolution:FireServer("GLIDER")`. Expected: no change to `EvolutionForm`.
7. Reject checks, from a fresh server session before reaching 100 biomass, via the client command bar: `...RequestEvolution:FireServer("TANK")` (threshold not reached), then at 100 biomass `FireServer("FLY")`, `FireServer(nil)`, `FireServer("tank")`, `FireServer(123)`. Expected: all ignored, no errors in the server output, form stays `BABY_BUG`, and the panel stays open. Then a valid `FireServer("GLIDER")` works once.
8. Dead character: at 100 biomass, set the humanoid health to 0 and immediately fire a valid request. Expected: ignored while dead; works after respawn.

Two players (Test > Clients and Servers, 2 players):

9. Player A reaches 100 biomass and evolves to TANK. Expected on Player B's client: A's `EvolutionForm` attribute shows `TANK` on their Player and a `TANK` tag appears over A's head; B's own panel, biomass and form are unchanged.
10. Player B (still below 100) fires a valid request from their command bar. Expected: ignored.
11. B reaches 100 and picks GLIDER. Expected: A still shows TANK and B shows GLIDER, each seeing the other's tag.
12. A leaves and rejoins. Expected: the new session starts as Baby Bug (no persistence).
13. Rate limit (client command bar, at 100 biomass, before choosing): run `local r = game.ReplicatedStorage.Remotes.RequestEvolution; for i = 1, 1000 do r:FireServer("TANK") end`. Expected: no server errors or lag, and the form becomes `TANK` once (the first request is processed, the rest are dropped or rejected as already evolved).
14. Invalid requests count against the limit (fresh session, 100 biomass): `r:FireServer("FLY"); r:FireServer("TANK")` in the same frame. Expected: still `BABY_BUG`, because the second request fell inside the cooldown. Wait one second and fire `"TANK"` again: it now works.
15. Spam in a 2-player session: while Player A spams the remote, Player B can still evolve normally and sees no delay.
16. Leave and rejoin repeatedly: no server errors (per-player rate-limit state is cleaned up).
17. Tag lifecycle: evolve, then reset the character repeatedly and quickly (including right after spawning). Expected: each character has at most one `FormTag` under its `Head`, the tag follows the new character, and old characters do not keep or receive tags. On a second client, also check that a respawning player's tag does not appear on the previous character model.
18. Screen sizes (Test > Device: phone portrait, phone landscape, tablet, 1080p): the choice panel is readable and centered, the buttons are tappable, and the badge does not overlap the Biomass HUD.

### Manual Studio test checklist: Tank Defensive Shell

Prepare: Play Solo (R15) and get a TANK quickly, for example by raising biomass with the Studio server command bar, then choosing TANK. Use Test > Clients and Servers for the multiplayer items.

1. Tank, ready: the **SHELL [Q]** button appears (green, `Ready`). For BABY_BUG and GLIDER players it is hidden.
2. Press `Q` (or click the button). Expected: a translucent blue bubble appears around the character and the button turns blue with an `Active` countdown.
3. Second client: the bubble is visible around the Tank, moves with it, and does not push or block either player.
4. After 3 s the bubble disappears and the button shows `Cooldown` counting down.
5. Press `Q` repeatedly during the cooldown. Expected: nothing happens, no shell, no timer extension.
6. About 12 s after the first activation the button returns to `Ready` and `Q` works again.
7. GLIDER player: no button; from the client command bar run `game.ReplicatedStorage.Remotes.RequestAbility:FireServer("SHELL")`. Expected: no shell, no `ShellActiveUntil`/`ShellReadyAt` change.
8. BABY_BUG player: same as 7.
9. Spam: while the shell is up, run `for i = 1, 200 do game.ReplicatedStorage.Remotes.RequestAbility:FireServer("SHELL") end` on the client. Expected: duration stays 3 s and the cooldown is not shortened. Also try `FireServer("SHELL", 99)`, `FireServer()` and `FireServer("anything")`: extra arguments change nothing and a missing or unknown identifier does nothing.
10. Death: activate, then reset the character or set health to 0. Expected: the bubble disappears immediately and the button shows the remaining cooldown (not `Active`).
11. Respawn during and after activation: no stale bubble on the old or new character, and at most one `DefensiveShell` exists (check the character in Explorer on the server). The cooldown is cleared by the death (new life), so the shell can be used again only after re-evolving to TANK.
12. Touch: in the Device emulator (phone) or on a real touch device, tap the button. Expected: it activates, is not hidden behind the jump button or thumbstick, and tapping it does not also move the character.
13. Typing: focus a text box (for example the chat) and press `Q`. Expected: no activation.
14. Leave and rejoin: no server errors; the new session starts as Baby Bug with no button.
15. Walking through narrow gaps and over platforms with the shell up behaves exactly as without it (no snagging, no change in jump height or speed).
16. Rate limit: with the shell ready, `local r = game.ReplicatedStorage.Remotes.RequestAbility; r:FireServer("SHELL"); r:FireServer("SHELL")` in the same frame activates one shell only (the second request is dropped). After waiting 0.5 s the cooldown rules apply as before (still cooling down). A GLIDER or BABY_BUG player firing in a loop gets no shell and no server errors; their requests are throttled.

### Manual Studio test checklist: Glider Air Glide

These are **manual tests; none has been performed**. Use Play Solo (R15) and Test > Clients and Servers. Get a GLIDER by raising biomass to 100 with the Studio command bar, then choosing GLIDER.

1. Glider, ready: the **GLIDE [Q]** button appears (green, `Ready`). It is hidden for BABY_BUG, and TANK sees **SHELL [Q]** instead.
2. Airborne: jump, then press `Q` (or tap the button) in the air. Expected: two wings appear, the button turns blue with a `Gliding` countdown, the fall is clearly slower than a normal fall, and you can still steer with WASD or the thumbstick.
3. Ground: press `Q` while standing. Expected: nothing happens (no wings, no attribute change).
4. BABY_BUG: from the client command bar, `game.ReplicatedStorage.Remotes.RequestAbility:FireServer("GLIDE")` in the air. Expected: nothing. Same for a TANK (also confirm Tank's `Q` still raises the shell).
5. Identifier checks (as GLIDER): `FireServer()`, `FireServer("FLY")`, `FireServer(123)`, `FireServer("GLIDE", 99)` in the air. Expected: only a valid `"GLIDE"` works; extras are ignored.
6. Duration: jump from a high place (a hill top) and activate. Expected: it ends after about 3 s if you have not landed; you then fall normally. Gravity is never cancelled completely: you never rise or hover.
7. Cooldown: after activating, `Q` does nothing for 10 s from the activation. The button shows `Cooldown` and returns to `Ready`. Pressing `Q` repeatedly (or the spam loop `for i = 1, 200 do r:FireServer("GLIDE") end`) never extends the glide or shortens the cooldown.
8. Landing: activate, then land before 3 s. Expected: wings vanish immediately and the button shows `Cooldown` (not `Gliding`). Check `GliderActiveUntil` returns to 0 on the Player in the server view.
9. Death during a glide: reset the character mid-glide. Expected: wings and force gone at once, no `GlideForce`/`GlideAttachment` left under the old character, no glide state on the new one. In Explorer (server view) confirm they are removed.
10. Respawn during cooldown: the death ends the life, so the cooldown is cleared and the form is Baby Bug again; `Q` is rejected until you evolve to GLIDER in the new life.
11. Leaving during a glide: with 2 clients, one leaves mid-glide. Expected: no server errors, and the remaining client sees no stray wings.
12. Visual on other clients: with 2 or more clients, the wings and slow fall of the glider are visible to the others and disappear for everyone when the glide ends.
13. Glider span: as GLIDER, jump from Leaf Platform 1 toward Leaf Platform 2 (a 10-stud gap, tops at Y = 10.5) and activate in the air: record whether you can land on it, how reliably, and the apex compared with a normal jump. Both platforms are also reachable on foot. Record the result before tuning `ascentCompensation`.
13b. Diagnostics (TT-P2-05B): set `Config.AbilityDebugLogging = true`, jump, press `Q` at the top of the jump and again early in a jump. Expected `[Glide]` lines: `start` with the state and vertical velocity, then an `end reason=Landing:...` after roughly 0.8 s (from the apex) or 2 s (from take-off), never after about 0.5 s unless you land that fast. Report any `ignored` lines and any `end reason=Landing:Running` or `Landing:FloorMaterial` that fires while still clearly in the air. Also check the descent is visibly slower and the landing gentle, that pressing `Q` on the ground starts no cooldown, and that a second `Q` during an active glide does nothing.
14. Touch: on a phone emulator or real device, the button is tappable in the air and not covered by the jump button.
15. Typing: with a TextBox focused (chat), `Q` does not start a glide.
16. Tank regression: as TANK, repeat the shell checklist above (activation, 3 s duration, 12 s cooldown, death, respawn).

## Multiplayer hardening (TT-06)

Audit of the code as it exists in this repository, plus small fixes. No new gameplay, remotes or abilities.

Inventory:

- Client to server: only two RemoteEvents, both created by the server under `ReplicatedStorage.Remotes`: `RequestEvolution(form)` and `RequestAbility(abilityId)`. There are no RemoteFunctions and no server-to-client remotes. Food collection has no client request at all (server proximity checks).
- Server to client: Player attributes only: `Biomass`, `GrowthStage`, `EvolutionForm`, `EvolutionAvailable`, `ShellActiveUntil`, `ShellReadyAt`, `GliderActiveUntil`, `GliderReadyAt`. Instances created by the server: `Workspace.Food` (food balls), `DefensiveShell`, `GlideWing`, `GlideAttachment` and `GlideForce`.
- Per-player server state is in tables keyed by the `Player` object (`PlayerDataService` biomass, `EvolutionService` forms and rate-limit timestamps, `AbilityService` shell/glide state including its own wings table and connections, and its rate-limit timestamps). Each player's state record is created fresh in `PlayerAdded`; nothing mutable is shared between players. The only shared mutable tables are two scratch lists in `FoodService`, cleared at the start of every scan; that code never yields, so scans cannot interleave.
- Player identity always comes from `OnServerEvent`; no remote carries a Player, UserId, biomass, form, cooldown or timestamp.

Bugs found and fixed:

1. **Food could be lost without a reward.** `FoodService` consumed a food item first and ignored the result of `AddBiomass`. If the winner's record had vanished the item still disappeared for the respawn delay. It now restores the item when nothing was awarded.
2. **Evolution rate-limit entry could leak.** A `RequestEvolution` arriving after `PlayerRemoving` re-created that player's timestamp entry forever. `EvolutionService` now ignores requests from players who already left (the same guard the ability limiter already had).
3. **Infinite-yield warnings.** `GrowthService` waited for a character's `Humanoid` with no timeout; if the character was removed meanwhile the thread waited forever. The wait is now bounded (10 s).
4. **Possible duplicate tracking on the client.** `EvolutionUIController` could connect its tag listeners twice for a player if `PlayerAdded` and the initial loop overlapped. It now tracks each player once.

Small testability changes (behaviour preserved): food selection and consumption moved into the pure `Shared/Food.lua` (`PickClosest`, `TryConsume`, `Respawn`); biomass accounting into `Growth.AddBiomass`; ability identifier validation into `Ability.IsKnownAbilityId`. When several players are in range of a food item at the same time, the closest wins; an exact tie now goes to the first player in `Players:GetPlayers()` order (previously the last).

Verified by reading, no change needed:

- Food: one winner per scan, consumed once (`TryConsume`) before awarding, never yielding in between. Respawn only re-enables an inactive item, so no duplicates. Dead, missing or root-less characters and players at the biomass cap are skipped. Biomass is clamped to `EvolutionBiomassRequired`.
- Evolution: validated on the server against the player's own record (alive, not already evolved, threshold reached, exact `TANK`/`GLIDER` string), after a per-player rate limit.
- Abilities: identifier validated, must match the player's own form, cooldowns per player, effects only on the requesting player's character, `endShell`/`endGlide` idempotent and invalidate stale timers, run on death, `CharacterRemoving`, form change and `PlayerRemoving`.
- HUD: `ScreenGui`s use `ResetOnSpawn = false` and each controller initialises once, so respawning does not duplicate GUIs or connections.

Not changed (limitations):

- Every attribute above replicates to **all** clients, so other players can read your Biomass, stage and ability timestamps. The overhead tag and form display rely on this for `EvolutionForm`; hiding the rest would need a redesign (per-player remotes), which is out of scope.
- The glide trust boundary described in the Glider section is unchanged: the player's client owns character physics.
- A food item destroyed by some other script is not recreated. Late-arriving, malformed or spammed requests are dropped silently.

Automated tests: `tests/Multiplayer.test.lua` covers, with the pure rules only, independent biomass, one winner per food, no double payout across repeated scans, the biomass cap, independent evolution and eligibility, another form's ability, per-player cooldowns, spam against a cooldown, and malformed remote arguments. Scenarios that need Roblox objects (player cleanup, respawn duplicating effects or HUD connections) cannot be unit-tested in this setup and are covered by the manual checklist below. These tests do not prove runtime multiplayer correctness.

### Manual Studio multiplayer checklist

These are **manual tests; none has been performed**. Use Test > Start with 2 players (3 preferred) and watch the Output window on every client and the server.

Food:

1. Both players stand at the same food ball (a friend or two clients at the same spot). Expected: it disappears once and exactly one player's `Biomass` rises by 10 (the closer one).
2. Each player collects a different ball. Expected: each `Biomass` rises independently; the other's value does not change.
3. Run a player to 100 biomass and keep walking into food. Expected: biomass stays at 100 and food is not consumed by that player.
4. A player leaves while standing in a food ball's range. Expected: no server error and the food is still there or respawns once (never two balls at one marker).

Evolution:

5. Player A reaches 100 biomass, Player B does not. Expected: only A sees the choice panel. From B's command bar run `game.ReplicatedStorage.Remotes.RequestEvolution:FireServer("TANK")`. Expected: nothing changes.
6. A selects TANK, B (after reaching 100) selects GLIDER. Expected: each sees their own form; the other player's overhead tag shows the right form; neither affects the other's biomass or panel.
7. A fires `RequestEvolution:FireServer("GLIDER")` again after evolving, and `FireServer(nil)`, `FireServer(123)`, `FireServer("tank")`. Expected: A stays TANK, no errors.

Abilities:

8. A (Tank) presses `Q`, B (Glider) jumps and presses `Q`. Expected: A gets the shell, B gets wings and a slower fall; each button shows the right state and both work at the same time.
9. B spams `for i = 1, 200 do game.ReplicatedStorage.Remotes.RequestAbility:FireServer("GLIDE") end`. Expected: one glide only, cooldown not shortened. Check that A's shell and cooldown are unaffected.
10. As Tank, fire `RequestAbility:FireServer("GLIDE")` and as Glider `FireServer("SHELL")`. Expected: nothing happens. `FireServer()`, `FireServer("FLY")` and `FireServer(123)` also do nothing.

Lifecycle:

11. While B is gliding or has a shell up, A dies. Expected: B's effect continues unaffected; A's effects vanish.
12. B leaves during an active glide. Expected: no server errors; A sees no stray wings, force or attachment left on anything (check Explorer on the server).
13. A respawns while B keeps playing. Expected: B's HUD, cooldown and effects unchanged; A has exactly one HUD, no duplicate button, no stale shell/wings, and A starts a new life (form, biomass and cooldowns reset by the death) without affecting B.
14. Join and leave several players quickly (Test > Start with 3, close and re-run clients). Expected: no errors, no duplicate `Workspace.Food` folder, each new player starts as BABY_BUG with 0 biomass.

## Growth smoothing and ground contact (P0 audit)

Based on your Play Solo observations (HUD correct at 40/100, Stage 2/3; abrupt growth at 30 and 60; intermittent partial ground clipping after a jump). **None of the fixes below has been run in Studio.**

Root cause of abrupt growth (confirmed from the code): `GrowthService` wrote the new absolute scale straight into the four R15 scale values (`BodyHeightScale`, `BodyWidthScale`, `BodyDepthScale`, `HeadScale`), so the body jumped from 0.6 to 0.8 (and 0.8 to 1.0) in a single step.

Changes (`GrowthService.lua`, `Growth.ShouldUpdateScale`, two `Config` values):

- Crossing a stage threshold now tweens the four values to the new absolute target over `GrowthTweenSeconds` (0.8 s, `Sine InOut`). Targets are absolute scales from `GrowthStages`, never multipliers, so repeated updates cannot compound.
- At most one set of tweens exists per player. A new target cancels the previous tweens (tweening from wherever the values currently are), and an identical target is ignored, so collecting food inside a stage creates no tweens.
- A new character (spawn or respawn) is set to its stage's scale immediately, with no animation, and the per-character state is reset so nothing carries over from the previous character. State and tweens are cleared on `CharacterRemoving` and `PlayerRemoving`; delayed callbacks ignore players who left.
- Scale values are no longer created at `CharacterAdded` before the avatar appearance has loaded. The service uses the engine's own values and sets them after `CharacterAppearanceLoaded`; it creates missing values only after that event or after `AppearanceFallbackSeconds` (5 s) as a fallback. Reason: creating them early could leave two values with the same name on the Humanoid. Whether that actually happened in your runs is **unconfirmed**.
- Biomass values, thresholds (0 / 30 / 60), food reward, HUD, evolution and abilities are untouched.

Intermittent ground clipping: **root cause NOT confirmed.** I cannot run Studio, and static analysis does not establish it. Nothing in the project's own code sets `HipHeight`, collision groups, `CanCollide` on the character, character positioning, or any custom movement/physics for Baby Bug. Candidate causes, most to least likely:

1. **Fast landing vs a small body.** Jump height is an absolute 7.2 studs, so landing speed (about 53 studs/s) is the same at every scale, but at 0.6 or 0.8 the legs are shorter. Humanoid floor contact is resolved by a raycast and spring, so a fast landing can briefly pull the feet visibly into the floor, intermittently depending on frame timing. This would be worst at stage 1, better at stage 3. Not changed, because changing jump settings would alter jump height.
2. **Duplicate scale values** (fixed above, if it was happening): two `BodyHeightScale` values on the Humanoid would make the engine and our script disagree about the body size.
3. **Hip height not following the scale** after a runtime change. The engine normally adjusts it, but this is unverified here.
4. **A scale change while airborne**, if food was collected mid-jump (now a smooth tween rather than a jump).
5. **Habitat geometry:** `HabitatFloor` (top Y = 0.5) overlaps the Baseplate and the spawn pads add a 0.4 step. Both are anchored solid parts, so this is unlikely to cause it.

Decisive Studio procedure (do this before accepting or reopening the issue). Use Play Solo, then Test > Current: Server, and run in the command bar:

```lua
local p = game.Players:GetPlayers()[1]
local c = p.Character
local h = c.Humanoid
print("stage", p:GetAttribute("GrowthStage"), "rig", h.RigType, "hip", h.HipHeight, "root", c.HumanoidRootPart.Size)
for _, n in { "BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale" } do
    local copies = 0
    for _, ch in h:GetChildren() do
        if ch.Name == n then copies += 1 end
    end
    print(n, h[n].Value, "copies:", copies)
end
local foot = c.LeftFoot
print("foot bottom Y", foot.Position.Y - foot.Size.Y / 2) -- standing on the habitat floor this should be about 0.5
```

1. **Duplicates:** `copies` must be 1 for each value at spawn and after each growth. 2 means cause 2.
2. **Hip height vs scale:** record `hip` at each stage. It should shrink roughly in proportion to scale (about 0.6x, 0.8x, 1.0x). If it does not change, cause 3.
3. **Penetration:** jump repeatedly on the flat floor and run the last line right after landing while standing still; a value well under 0.5 means the feet are sunk. Record at which stage it happens and how often.
4. **A/B test:** temporarily set all three `Scale` values in `Config.GrowthStages` to 1.0, play, and repeat step 3. If clipping disappears, it is scale-related (causes 1 to 3); if it persists at scale 1.0, it is not caused by growth (look at the arena or the default Roblox character).
5. **Airborne growth:** collect food mid-jump across a threshold and check the result of the landing.

Report the printed values and I can narrow it down.

Limitations: the smoothness of the tween (server tweens replicate at network rate, so it may look slightly steppy on clients), absence of clipping, and landing behaviour at all three stages are unverified. The character still looks like a standard avatar (out of scope).

### Manual Studio test checklist: growth and ground physics

These are **manual tests; none has been performed**.

1. Fresh spawn at Biomass 0: the character spawns at 0.6 scale at once (no visible grow animation), `copies` = 1 for each scale value, HUD shows `Biomass  0 / 100`, `Stage 1/3`.
2. Around Biomass 30: collect the third food. Expected: the body grows smoothly over about 0.8 s, with no instant pop, the HUD changes to `Stage 2/3`, the character stays on the ground (no sinking or floating) and keeps moving normally while growing.
3. Around Biomass 60: same for the sixth food (`Stage 3/3`, scale 1.0).
4. Collect another food inside a stage (for example 30 to 40). Expected: no size change at all.
5. Collect two foods that cross a threshold in quick succession and mid-jump. Expected: no flicker, one smooth change, final scale equals the stage's target.
6. Repeated ordinary jumps and landings on flat floor at stage 1, 2 and 3 (about 20 each). Record any partial sinking using the procedure above and its frequency per stage.
7. Respawn after growth (reset at stage 2, then at stage 3): the new character appears at the stage's scale at once, never at 1.0 first, and a second reset does not shrink or enlarge it incorrectly.
8. Food collection after respawn works and growth still tweens when the next threshold is crossed.
9. Reach Biomass 100: the evolution panel appears and TANK/GLIDER can be chosen as before.
10. Abilities regression: as TANK press `Q` (shell appears and follows the scaled body, 3 s, 12 s cooldown); as GLIDER jump and press `Q` (wings, slower fall, landing ends it, 10 s cooldown). Check the shell/wings size after a growth tween (they are sized at activation).
11. Two players: one growing must not change the other's size; both HUDs stay correct.

### Manual Studio test checklist: evolution system (P0-02)

These are **manual tests; none has been performed**. Use Play Solo, then Test > Start with 2 players. Raise biomass with the Studio server command bar as needed.

1. Below 100 biomass there is no choice panel; the badge shows `Form: Baby Bug`. From the client command bar `game.ReplicatedStorage.Remotes.RequestEvolution:FireServer("TANK")` changes nothing.
2. At exactly 100 biomass the EVOLUTION READY panel appears with both cards and the `Choose a form` button disabled.
3. Tap TANK: highlighted, button reads `Evolve into Tank`, nothing sent yet. Tap GLIDER: highlight moves, only one card is ever selected.
4. Press Confirm. Expected: `Evolving...`, then the panel hides, the toast says `You evolved into ...!`, the badge and overhead tag show the form, `EvolutionAvailable` is false. Pressing Confirm repeatedly or quickly causes one evolution only.
5. After evolving, run `RequestEvolution:FireServer("GLIDER")` and `FireServer("TANK")`, `FireServer(nil)`, `FireServer(123)`. Expected: `EvolutionForm` is unchanged; no errors.
6. Rejection feedback: reach 100, then run (client command bar) `game.ReplicatedStorage.Remotes.RequestEvolution:FireServer("FLY")`. Expected: the panel stays, status text shows `That form is not available.`
7. Dead character: at 100 biomass, set health to 0 and press Confirm quickly. Expected: `Respawn first, then try again.` and no evolution.
8. Respawn after evolving: reset the character. Expected (since P1-03): the death ends the life; form returns to Baby Bug, the badge, tag and ability button follow, and there is no panel. The previous form never carries into the next life.
9. Correct ability only: as TANK `Q` raises the shell and the button says SHELL; as GLIDER `Q` in the air glides and the button says GLIDE. From the command bar a Tank firing `RequestAbility:FireServer("GLIDE")` or a Glider firing `FireServer("SHELL")` does nothing.
10. Two players: A reaches 100 and picks TANK, B (below 100) has no panel and cannot evolve. Then B reaches 100 and picks GLIDER. Expected: forms, panels, toasts and ability buttons stay independent, and each sees the other's tag.
11. Attribute tampering: on a client, `game.Players.LocalPlayer:SetAttribute("EvolutionForm", "TANK")` while Baby Bug. Expected: the local badge may change but the server form does not, and `Q` still does nothing on the server.
12. Leave and rejoin: the new session starts as Baby Bug with 0 biomass, and there are no server errors.
13. Layout: Device emulator (phone portrait, phone landscape, tablet, 1080p). Expected: the panel is fully on screen, text readable, cards and the button tappable, nothing overlaps the Biomass HUD or toast.
14. Reduced regression: collecting food, stage growth tweens, the Biomass HUD, and Tank and Glider cooldowns behave as before.

## Baby Bug visual character (P2-05)

Players in the `BABY_BUG` form look like a small custom insect instead of a Roblox avatar. **None of this has been run in Studio yet** (checklist below); only the pure spec and pose logic has Lune tests.

Approach: the R15 Humanoid stays the movement, physics, camera and lifecycle controller (`CharacterAutoLoads`, `RespawnService`, `LifeService` and `ResetService` are unchanged). The default avatar is made invisible and a cosmetic model is welded to the `HumanoidRootPart`. Food pickups measure distance from the `HumanoidRootPart`, so the visual cannot affect them.

| File | Responsibility |
|---|---|
| `Shared/BabyBugSpec.lua` | Pure data: every part (primitives only, no asset ids), its joint and colour; six legs, head with two eyes, rounded shell with seam and spots, two antennae; which joints are animated; `RootOffsetY` |
| `Shared/CreatureModelBuilder.lua` | Roblox-only, spec-driven: builds the Model (unanchored, massless, `CanCollide`/`CanTouch`/`CanQuery` off, one Motor6D per part) and the root joint. Reusable for future forms |
| `ServerScriptService/Services/CreatureAppearanceService.lua` | Server: per player and per character it hides the default avatar and attaches or removes the visual according to the server-owned `EvolutionForm`. A form-to-spec table holds only `BABY_BUG` |
| `Shared/BabyBugPose.lua` | Pure procedural pose maths (idle, walk with an alternating tripod gait, jump, fall) with blend weights |
| `StarterPlayerScripts/Controllers/BabyBugAnimationController.lua` | Client: one shared `RenderStepped` loop animates every tagged creature model (tag `TT_CreatureVisual`) through `Motor6D.Transform`, so each client sees everyone's animation. No remotes |

Lifecycle and rules:

- **One visual per character.** `evaluate` is idempotent; repeated `CharacterAppearanceLoaded` or attribute events cannot create a second model. State is per player and per character and checked after every yield, so an old character cannot modify a newer one. `CharacterRemoving` and `PlayerRemoving` clean up connections, the model and state.
- **Hiding.** All `BasePart`s and `Decal`s of the character get `Transparency = 1`; originals are remembered and restored if the form changes to one without a model. Parts added later by appearance loading are hidden as they arrive and again on `CharacterAppearanceLoaded`. Nothing is destroyed.
- **Growth.** The model follows the `BodyHeightScale` value that `GrowthService` already tweens (new `GrowthService.SubscribeScale` hook), so thresholds (`Config.GrowthStages`), `GrowthTweenSeconds` and the absolute-scale rule stay in one place. `Model:ScaleTo` is absolute, so it cannot compound. A new character starts at its stage's scale from `Growth.GetScale`. If `GrowthService` applied the scale before the visual existed, the visual catches up through `GrowthService.GetAppliedScaleValue`, so event order cannot make it miss the tween.
- **Death.** When the Humanoid dies the visual is destroyed (death breaks joints anyway) and the body stays hidden until `RespawnService` replaces the character. No death effect exists yet. `LifeService` remains the only death authority.
- **Tank and Glider** still use the normal avatar: their models do not exist yet. The service is structured so a spec can be added per form.
- Only R15 is supported (R6 keeps the default avatar and logs one warning).

Known limitations (all unverified until Studio): the legs and antennae use `Part` cylinders mapped from Y to X, and the angles and proportions were designed on paper; gait speed matching, how the Humanoid hip height of other avatar types lines up with the ground, and remote Humanoid state replication for the jump/fall pose need observation. The default Roblox animations still play on the invisible body. There is no death or evolve effect, and no sound. Collision still uses the scaled R15 body box, not the insect's shape.

Manual Studio checklist (all **pending**):

1. Play Solo: Baby Bug appears immediately.
2. No default avatar body, clothes, face or accessories are visible (also try an account with many accessories).
3. Walk, turn, jump and fall; the creature follows and animates.
4. Collect food and check all three visual growth stages (0.6, 0.8, 1.0) and the smooth growth.
5. Die and begin a new life.
6. The old model is gone and exactly one new Baby Bug appears (inspect the character in the Explorer: one `BabyBugVisual`).
7. With two players, each sees the other's creature and animation; one player's growth does not change the other's.
8. Evolve to Tank or Glider: the normal avatar returns and the shell and glide behave as before.
9. Check Output for errors and warnings (no asset warnings expected: no asset ids are used).

## Exploration loop (TT-P3-02)

The smallest meaningful exploration loop on top of the First Habitat: six **discoveries** (places) that reward going somewhere and looking, without combat, without a new currency and without any ability gate. **Not validated in Roblox Studio** (checklist below); the pure rules have Lune tests that were written but not run in the authoring environment, and the map side is checked offline by `tools/habitat/validate_habitat.py`.

| Discovery (`id`) | Where (map) | Biomass |
|---|---|---|
| Great Stump Lookout (`GREAT_STUMP`) | on top of the Great Stump (log ramp) | +4 |
| Mushroom Grove (`MUSHROOM_GROVE`) | the grove of giant caps, east Meadow | +4 |
| Rock Terrace (`ROCK_TERRACE`) | the terrace lookout in the Rock Garden | +4 |
| Foot of the Old Tree (`OLD_TREE`) | ground at the trunk's foot | +4 |
| Root Arch Top (`ROOT_ARCH`) | on the arch deck (the elevated route) | +5 |
| Dewdrop Glade (`DEWDROP_GLADE`) | the secret glade behind the crack | +8 |

All six together give 29 Biomass: about three food items out of the cap of 100, so food stays the main source. No discovery pays more than one food item (10). Every place is optional and optional-route only: none lies on a route that has to be walked.

**Behaviour.** The server checks every 0.25 s (`Config.DiscoveryCheckInterval`) whether a living player's `HumanoidRootPart` is inside a discovery's trigger volume. The first time per life: the discovery is marked found, the Biomass bonus is granted through `PlayerDataService.AddBiomass` (clamped to the cap; at the cap the discovery still counts and grants 0), and the player sees a toast ("DISCOVERED: Great Stump Lookout / +4 Biomass (1/6) / Next: ...clue...") and a "Discoveries 1/6" counter in the top-left corner. The next clue is the first undiscovered place in catalog order and never gives coordinates. The recap after death shows "Discoveries: 3/6 (+13 Biomass)" and "Most notable: ...".

**Multiplayer semantics: individual.** Each player has their own discoveries. Nobody can grant anything to anybody else, being near another player changes nothing, and solo play gets the whole loop. Two players standing at the same place each discover it for themselves. This was chosen as the simplest rule that is fair and cannot be abused remotely.

**Architecture.**

- `Shared/DiscoveryDefinitions.lua`: ids, display names, clues, rewards (frozen). `Shared/Discovery.lua`: pure rules, one `Tracker` per player holding the current life's log and the last finished life's log.
- Where each discovery happens is data in the map: `Workspace/Habitat/DiscoverySites` has one invisible, non-solid, non-queryable part per discovery, tag `DiscoverySite`, **part Name = discovery id**. `DiscoveryService` reads them at start (and when tagged parts are added or removed). No script lives in a map part, and a missing or unknown site only logs a warning.
- A volume is a region of space, so a trigger cannot fire through a wall or from a distance; the elevated volumes (stump top, terrace lookout, arch deck) sit exactly over the top surface of their solid landmark, so standing or jumping on the ground beside them does not reach them.
- Lifecycle: the log belongs to one `lifeId`. `ResetService` calls `DiscoveryService.ResetLife` with the other resets; the pure tracker keeps the finished life's log, so the recap reads the right numbers whether the reset or the recap runs first. Discoveries only count while the character is alive and for the current life id; a late event for an older life is rejected. `PlayerRemoving` drops the state. Nothing is persisted.
- Server to client: `Remotes.DiscoveryFound` (display only; the client sends nothing and the server ignores anything it receives), Player attributes `Discoveries` and `DiscoveryTotal` (display mirrors, never read for a decision), and the `discoveries` summary inside the existing `LifeRecap` payload. No new request remote.
- Anti-exploit: no client request exists; a discovery is marked found before its reward in one thread without yielding, so it cannot be found twice; rewards are small and capped; the stale-life check stops a late scan from touching a newer life. Like food, it trusts the server's copy of the character position, so a client that teleports its own character could reach a volume; that class of exploit is outside this task.
- Not implemented on purpose: new currency, quest panel, minimap or arrows, persistence or Legacy, shared or co-op rewards, new food, combat, a second habitat.

**Status against the approved v2.2 direction (read before extending).** This is the narrow "clue, arrival, feedback, record" slice; it is not the full vertical slice of the Gameplay Blueprint (sections 12-14). Specifically:

- **Per-life, not permanent.** Product Vision v2.0 and the Progression & Legacy addendum define a *Discovery* as a one-time permanent knowledge claim and a *Life Goal* as a goal scoped to one life. The implemented places are found once **per life** and are **not persisted** (no DataStore, no Naturalist XP, which TT-P3-02 must not add). Behaviourally they are closer to Life Goals. Whether to keep the name and the per-life semantics as an interim step, rename them, or add permanent one-time recording once persistence is approved is an **owner decision**; nothing here forecloses any of them.
- **Not implemented here (separate roadmap items):** the second discovery category (species/behaviour), the ecological before/after chain, an inspect/observe interaction beyond entering a place, a journal beyond the recap line, and the repeatable challenge.
- **Biomass reward:** a small Biomass bonus (29 in total) keeps the loop connected to existing growth; Biomass remains current-life growth and food remains the main source. Whether exploration should reward Biomass at all under v2.2 is part of the same owner decision.
- **Forms:** the Tank and Glider forms still exist in the code, so the checklist below still tests them; the v2.2 direction (one personal creature) may later remove them.

**Tests.** `lune run tests/Discovery.test.lua` covers the catalog (unique ids, modest rewards), once-per-life, malformed and stale life ids, rewards, death/reset/next life, recap order independence, player isolation, next clue, trigger-volume maths and recap formatting (client display). It does not cover the Roblox wiring.

**Manual Studio checklist (all pending).**

1. Spawn at the Nest: the counter shows "Discoveries 0/6" and nothing triggers at the Nest.
2. Climb the Great Stump by the log ramp: the toast appears, Biomass rises by 4, the counter shows 1/6 and the toast names a next clue. Leave and re-enter: nothing happens again.
3. Visit each other place (grove, terrace, Old Tree foot, arch top, glade): each rewards once. Check that standing next to a volume on the other side of a wall (for example the Rock Garden den walls and the glade ring) does not trigger it, and that jumping from the ground beside the stump or the arch does not trigger the elevated ones.
4. Reach the Biomass cap and then discover something new: it counts, the toast says there is no more Biomass to gain, and Biomass stays at 100.
5. Die with 2-3 discoveries: the recap shows the count, the Biomass they gave and the most notable one. Begin a new life: the counter is 0/6, and the same places reward again.
6. Die before discovering anything: the recap shows "Discoveries: 0/6". A spawn-failed notice shows no exploration line.
7. Two clients: each discovers independently (the second player still gets the reward for a place the first already found); one player's discovery does not change the other's counter.
8. Solo play: the whole loop works with one player.
9. Evolve to Tank or Glider: discoveries still work and nothing on a mandatory route changed.
10. Rejoin and respawn repeatedly: no duplicate toasts or counters, no leftover connections or Output errors or warnings (a warning means a discovery id and its site name do not match).

## Validate

```powershell
rojo build default.project.json -o build.rbxlx
```

Then connect Studio using the Rojo plugin. The project currently contains the First Habitat greybox, the exploration discoveries (TT-P3-02) and the food/growth loop. The Biomass HUD, life tracking, the reset on death, controlled respawn with a minimal life recap, and the evolution choice (TANK or GLIDER) are implemented. The TANK Defensive Shell (visual only) and the GLIDER Air Glide are implemented. The Baby Bug has a custom visual model (P2-05, Studio validation pending). Tank and Glider models, damage, combat and persistence are not implemented.

See the current product and architecture documents linked at the top of this README.
