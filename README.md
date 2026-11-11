# TINY TITANS

Roblox prototype: a multiplayer creature evolution arena.

## Direction and architecture documents

The game is moving toward an Evolution Adventure Sandbox: a **Current Life** (temporary, reset on death), **Evolution** (the form and abilities of the current life) and **Legacy** (permanent discoveries that survive death). This README documents the code as it is today. In the current implementation death ends the life and resets the Current Life (Biomass, growth stage, form and ability state; see *Reset on death (P1-03)*), and the player begins the next life as Baby Bug from the life recap (controlled respawn, see *Controlled respawn and life recap (P1-04)*). There is no persistence and no Legacy yet.

Current implementation versus target: today there are three forms (`BABY_BUG`, `TANK`, `GLIDER`), with no damage, combat, PvE or PvP. The target (provisional) is the Baby Bug starter, which is not a class, plus four evolved classes (Tank / Guardian, Glider / Skirmisher, Striker / Hunter, Support / Controller); Striker / Hunter and Support / Controller are not implemented. "Biomass" is the name of the Current Life growth resource (approved by the project owner as the final player-facing name).

- [Evolution Sandbox Architecture v0.1](docs/Evolution%20Sandbox%20Architecture%20v0.1.md): audit of the current code and proposed architecture.
- [TT-P0-02R Implementation Migration Plan](docs/TT-P0-02R%20Implementation%20Migration%20Plan.md): proposed engineering sequence (P1–P7, including the proposed P3.5 combat-design gate); it does not replace the product roadmap.
- [Evolution Adventure Sandbox Roadmap v0.1](docs/Evolution%20Adventure%20Sandbox%20Roadmap%20v0.1.md): product progression model and product phases P0–P7.
- [Combat Progression & Endgame Design v0.1](docs/Combat%20Progression%20%26%20Endgame%20Design%20v0.1.md): proposed combat, progression and endgame direction, including P3.5.
- [Product Vision & Top 1000 Strategy](docs/Product%20Vision%20%26%20Top%201000%20Strategy.md): product north star and separate P0–P8 strategy roadmap.
- [Tiny Titans Master Roadmap v0.1](docs/Tiny%20Titans%20Master%20Roadmap%20v0.1.md): unified roadmap from prototype through MVP/public launch and post-launch phases, with explicit scope, gates and estimated progress.

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
| `ReplicatedStorage/Shared/Life.lua` | Pure life transition rules (no Roblox services) |
| `ReplicatedStorage/Shared/Config.lua` | Tuning: `FoodBiomass`, `FoodRespawnDelay`, `FoodPickupRange`, `FoodHoverHeight`, `FoodCheckInterval`, `GrowthStages` |

How it works:

1. On server start, `FoodService` spawns a neon ball 2 studs above each `FoodSpawn` marker (8 in the arena), under `Workspace.Food`.
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

Not reset on purpose: per-player rate-limit timestamps (anti-spam, not life state), food in the world (shared), `LifeState`/`lifeId` (owned by `LifeService`). Biomass cap (100), food reward, thresholds (30 / 60), forms, abilities and respawn behaviour are unchanged. There is no Legacy and no persistence.

Orchestration: `ResetService` (started last in `Bootstrap.server.lua`) subscribes to `LifeService.LifeEnded` and `LifeService.LifeBegan` and calls the four reset functions above in a fixed order (biomass, form, abilities, growth). There is no second death detection. Death is still detected only by `LifeService`.

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
- When a life ends, `LifeService` fires `LifeEnded`, `ResetService` resets the Current Life (P1-03), and `RespawnService` stores the recap for that player (`lifeId`, `durationSeconds`, `highestForm`). The client subscribes to `LifeRecap` and then fires `LifeRecapReady`; the server sends the stored recap after this handshake. This avoids losing the recap if the client controller starts late. The dead character stays until the next spawn. There is no countdown and no automatic respawn.
- The recap (`LifeRecapController`) shows **Life duration**, **Highest form** and a **BEGIN NEW LIFE** button (at least 56 px high, scaled panel). It appears only when the server sends the recap and hides when the new character spawns. After pressing, the button shows "Starting..." and re-enables after 6 s if nothing happened.
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
| `StarterPlayerScripts/Controllers/EvolutionUIController.lua` | Choice panel, form badge, overhead form tag |

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

- When the server sets `EvolutionAvailable`, an **EVOLUTION READY** panel shows two cards: **TANK** (Defensive; Shell [Q], protective bubble, visual only for now) and **GLIDER** (Mobility; Air Glide [Q], slow your fall in the air). The descriptions are deliberately honest: the forms differ only by ability, and the shell has no combat effect yet.
- Choosing is two steps: tap a card (local highlight only, nothing is sent), then **Confirm**. This prevents accidental and double selection; the Confirm button is disabled until a card is picked and while a request is pending ("Evolving..."). The local pending state times out after 3 s with "No response. Please try again." This lock is a convenience, not security.
- On success the panel hides (driven by the attribute) and a short toast says `You evolved into <Form>!`. On rejection the panel stays and the status line shows a plain message from the server's reason.
- The panel scales with the screen (50% x 62%, clamped to 320x240 to 560x340 px) with scaled, size-limited text.
- The overhead tag is attached only if, after waiting for the character's `Head`, that character is still the player's current character and the player is still in the game; stale characters are never tagged. A missing `Head` is skipped.
- A badge above the Biomass HUD shows `Form: <name>`.
- Evolved players get an overhead tag (`TANK` / `GLIDER`) so other clients can see the choice. It is read from the replicated attribute.

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
| Air Glide | `GLIDE` | `Glide` | `GLIDER` | 3 (maximum) | 10 | `gravityCompensation` 0.65 |

API: `GetAbility(id)` (nil for unknown or malformed ids), `Abilities` (ordered), `AbilityIds`, `ShellId`, `GlideId`; the entry types are a narrow union discriminated by `kind`. `AbilityService` resolves every incoming id through `GetAbility`, selects the existing Shell or Glide implementation by `kind`, and checks the player's server-owned form against `requiredForm`. The specialised Shell and Glide code, the airborne check, cooldowns, rate limit and cleanup are unchanged. `Ability.lua` keeps its pure rules and still receives the required form and timings as arguments.

Relationship with `CreatureDefinitions`: a form lists the ability ids it owns (`TANK` -> `SHELL`, `GLIDER` -> `GLIDE`, `BABY_BUG` -> none) and each ability names the form that may use it. Neither module requires the other (no dependency cycle); `tests/AbilityDefinitions.test.lua` checks that the two references agree.

Still global in `Config` (not per-ability): `AbilityKey` (the shared input binding) and `AbilityRequestInterval` (anti-spam, not a gameplay cooldown). The old `TankShell*`, `Glider*`, `AbilityShellId` and `AbilityGlideId` keys were removed, with no aliases.

Shell is **visual only** (it does not mitigate damage) and Glide is a **bounded glide, not flight**. Run: `lune run tests/AbilityDefinitions.test.lua`.

## Glider Air Glide

Second form ability: a **bounded glide, not flight**. It is server-authorised and uses a simple temporary upward force; it adds no damage, stamina, combat or movement-setting changes.

Behaviour (values in the `GLIDE` entry of `AbilityDefinitions`):

- Key `Q` (`AbilityKey`, shared with the Tank shell) or the on-screen **GLIDE [Q]** button (same mid-right position as the Tank's **SHELL** button; only one of the two is ever shown, depending on the form).
- Only players whose server-side form is `GLIDER` (`requiredForm` of the `GLIDE` definition) can use it, and only while **airborne** (`Humanoid.FloorMaterial == Air`, read on the server).
- One press starts an automatic glide for up to 3 s (`durationSeconds`); no holding is needed. **Landing ends it immediately.**
- Cooldown 10 s (`cooldownSeconds`), measured from successful activation; it is cleared when the life ends (death) and when the player leaves.
- While gliding, a server-created `VectorForce` pushes up with `gravityCompensation` (0.65) of the character's weight (`AssemblyMass * Workspace.Gravity`). The compensation is capped below 1 in `Ability.GetGlideForce`, so gravity always wins and the net vertical force is always downward. No horizontal force is applied: steering is the normal Roblox character controls. `WalkSpeed`, jump settings and network ownership are not changed.
- Visual: two thin neon "wings" welded beside the torso, created on the server so all clients see them. They are massless and have no collision, touch or query. Removed when the glide ends.

How the state is shared:

| Piece | Responsibility |
|---|---|
| `Shared/Ability.lua` | Pure rules: `ValidateGlide`, `GetGlideForce`, shared `IsActive` / `GetCooldownRemaining` / `IsRateLimited` |
| `Services/AbilityService.lua` | Same `RequestAbility` remote as Tank. Validates, owns timestamps and cooldown, creates and removes the force, attachment and wings, ends the glide on landing, death, character removal, form change and player leave |
| `Controllers/AbilityController.lua` | One shared controller: picks SHELL or GLIDE from the replicated `EvolutionForm`, sends only the identifier, shows `Ready`, `Gliding` or `Cooldown` from `GliderActiveUntil` / `GliderReadyAt` (server-time timestamps). It never shows `Gliding` before the server sets the attribute and ticks per frame only while a countdown is showing |

Server validation for `"GLIDE"`, after the existing per-player rate limit (`AbilityRequestInterval`, separate from the gameplay cooldown, counting rejected requests): the player is still connected, the server-owned form is `GLIDER`, the character exists with a living Humanoid and a `HumanoidRootPart`, `FloorMaterial` is `Air`, no glide is active, and the cooldown has expired. Stale expiry timers are invalidated with a per-player token.

Trust boundary (important): Roblox gives the player's client physics ownership of their own character, and this feature does not change that. The server decides when a glide may start and end and when the cooldown allows another, and the force object replicates to the owning client, but the server **cannot prevent a modified client from ignoring the force or moving the character however it likes**. That is true of all player movement in this game; no server-side movement validation (speed, height checks) was added. Landing detection uses the server's copy of `FloorMaterial` and `Humanoid.StateChanged`; the 3 s timer ends the glide regardless.

Jump height and arena (analytic estimate, **not a Studio test**): with default `Workspace.Gravity` (196.2) and `JumpHeight` 7.2, a normal jump rises about 7.2 studs. Activating the glide near the start of a jump leaves 35% of gravity, so the same jump would rise to roughly 20 studs, and activating later gives less. This is a direct consequence of the specified 65% compensation: it does not provide upward acceleration, but it does raise the jump apex. The existing `GliderPlatform1/3` tops are at Y = 16 and `GliderPlatform2` at Y = 20, while a Baby Bug jumping from the highest jumpable surface (`HillTier2`/`LedgeB`, top 6.5) reaches about 13.7, so by calculation they are out of an ordinary jump's reach. No arena geometry was changed. Whether the glide actually reaches them reliably must be tested in Studio; if the apex gain is too large or too small, tune `GliderGravityCompensation` (or later add a rule about when the glide may start).

Limitations:

- Untested in Studio: physics feel, wing look and the landing detection are unverified.
- Rejections are silent. The glide ends on landing, so the 3 s may not be used in full.
- If the character is scaled (growth) the force is computed at activation from the current `AssemblyMass`.

### Tests

`tests/Growth.test.lua` covers the pure helpers in `Growth.lua` (stages, scale, clamp, progress ratio) and sanity-checks `Config`. `tests/AbilityDefinitions.test.lua` covers the ability catalog, immutability and the cross-reference with creature forms. `tests/CreatureDefinitions.test.lua` covers the creature catalog (IDs, requirements, ability references, immutability, Config aliases and growth milestones). `tests/Evolution.test.lua` covers the pure, definition-driven rules in `Evolution.lua` (valid and invalid branches, threshold, repeat requests, `Select` state transitions, two-player isolation, readiness at 99/100 biomass, cross-form ability checks, nil/NaN input, and the rate-limit check including a simulated 1000-request spam). The server wiring of the limiter and the tag lifecycle guard use Roblox APIs and are checked manually. `tests/Ability.test.lua` covers the pure shell and glide rules, the glide force bound, and the request rate-limit helper (only TANK may activate; BABY_BUG, GLIDER and bad input are rejected; dead character, already active, cooldown, available again after cooldown, early end keeps the cooldown). `tests/Multiplayer.test.lua` covers the pure multiplayer rules (see the next section). `tests/LifeReset.test.lua` covers the pure reset-on-death rules (see Reset on death). `tests/Respawn.test.lua` covers the pure controlled-respawn and recap rules (see Controlled respawn). Run each with `lune run tests/<name>.test.lua`. Server and client behaviour of the shell uses Roblox APIs and cannot be run in this test setup; it is checked manually. It is optional and outside the Rojo tree. Run it with [Lune](https://lune-org.github.io/docs): `lune run tests/Growth.test.lua`. Lune is not part of `rokit.toml`. The service modules depend on Roblox APIs and are tested manually in Studio. `tests/Life.test.lua` covers the pure rules in `Life.lua` (begin/end transitions, `lifeId`, duplicate and stale end requests, invalid input); it does not cover the Roblox signal wiring. `tests/Respawn.test.lua` covers the pure respawn/recap rules and `tests/Lifecycle.test.lua` replays lifecycle timelines through the real pure `Life`, `LifeReset` and `Respawn` rules (see Lifecycle hardening (P1-05)); both are optional, Lune-run and not Studio tests.

### Manual Studio test checklist

1. `rojo build default.project.json -o build.rbxlx`, open it in Studio (or use `rojo serve`) and confirm Avatar Type is R15.
2. Play Solo. Expected: character spawns small (scale 0.6); `Workspace.Food` holds 8 green balls above the green food markers; no output errors.
3. Walk into one ball. Expected: it disappears, and in Explorer `Players > <you>` attributes show `Biomass = 10`, `GrowthStage = 1`.
4. Collect 3 balls total. Expected: `Biomass = 30`, `GrowthStage = 2`, character visibly larger. Collect 6 total: `Biomass = 60`, `GrowthStage = 3`, normal size.
5. Wait 8 s after collecting. Expected: the ball reappears.
6. Collect until `Biomass = 100`. Expected: biomass stops at 100 and food is no longer consumed by you.
7. Reset the character (or die). Expected: you respawn as a new life at stage 1 size with Biomass 0 (see the P1-03 checklist).
8. Test > Clients and Servers, 2 players, both stand near the same ball. Expected: only one player gains biomass; the closer one if distances differ.
9. Check the platform food: the ball on `HillTier2` is reachable by jumping, and the one on `GliderPlatform2` is not reachable yet (needs the future glide ability).
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
13. Reachability: from ground level, a Baby Bug cannot reach `GliderPlatform1` (top Y = 16) with ordinary jumps. Then, as GLIDER, jump toward it and activate in the air: record whether you can land on it, how reliably, and how high the apex gets compared with a normal jump. Record the result before tuning `GliderGravityCompensation`.
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
5. **Arena geometry:** `ArenaFloor` (top Y = 0.5) overlaps the Baseplate and the plaza adds a 0.3 step. Both are anchored solid slabs, so this is unlikely to cause it.

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
print("foot bottom Y", foot.Position.Y - foot.Size.Y / 2) -- standing on the arena floor this should be about 0.5
```

1. **Duplicates:** `copies` must be 1 for each value at spawn and after each growth. 2 means cause 2.
2. **Hip height vs scale:** record `hip` at each stage. It should shrink roughly in proportion to scale (about 0.6x, 0.8x, 1.0x). If it does not change, cause 3.
3. **Penetration:** jump repeatedly on flat arena floor and run the last line right after landing while standing still; a value well under 0.5 means the feet are sunk. Record at which stage it happens and how often.
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

## Validate

```powershell
rojo build default.project.json -o build.rbxlx
```

Then connect Studio using the Rojo plugin. The project currently contains the greybox arena and the food/growth loop. The Biomass HUD, life tracking, the reset on death, controlled respawn with a minimal life recap, and the evolution choice (TANK or GLIDER) are implemented. The TANK Defensive Shell (visual only) and the GLIDER Air Glide are implemented. Form models, damage, combat and persistence are not implemented.

See `docs/Game Design Document v0.1.md` and `docs/Technical Design & Implementation Plan v0.1.md`.
