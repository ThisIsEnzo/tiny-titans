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

- There are **no RemoteEvents and no client scripts for the food loop itself** (the evolution choice below adds one RemoteEvent). The client never sends a pickup request, so there is nothing to spoof. Pickup validation uses the character position as the server sees it, and the range check is a distance check only (a movement-speed or teleport check is not implemented).
- The technical plan mentions a client pickup request; this milestone deliberately uses server proximity checks instead to avoid adding a remote.
- Food variety is not implemented. The `Energy` / `GrowthStage` Player attributes are the source for the Energy HUD below.
- Growth uses R15 body scale values. The place's Avatar Type must be R15 (Game Settings > Avatar). R6 characters are not scaled and a warning is printed once.

## Energy HUD

`StarterPlayer/StarterPlayerScripts/Controllers/EnergyUIController.lua`, started from `ClientBootstrap.client.lua`, builds a small HUD in code (no Studio-authored assets) at the bottom center of the screen:

- `Energy N / 100` text, `Stage N/3` text and a progress bar (the bar turns gold at 100).
- It reads only the server-set `Energy` and `GrowthStage` Player attributes and redraws when either changes. It never writes them and uses no RemoteEvents. Missing attributes show as 0 energy, stage 1.
- The `ScreenGui` has `ResetOnSpawn = false`, and the attributes live on the Player, so the HUD is unaffected by respawns.
- Layout: width is 30% of the screen, clamped to 240-420 px; text is scaled between 12 and 22 px. The bar fill is `Growth.GetProgressRatio(energy, cap)` (tested in `tests/Growth.test.lua`).
- The attribute names are string literals in `PlayerDataService.lua` and `EnergyUIController.lua`; change both together.

## Evolution choice

Server-owned, session-only. Players start as `BABY_BUG`; at 100 energy they can choose `TANK` or `GLIDER` once.

| File | Responsibility |
|---|---|
| `ReplicatedStorage/Shared/Evolution.lua` | Pure rules: `IsValidForm`, `IsAvailable`, `Validate` (returns `ok, reason`) |
| `ReplicatedStorage/Shared/Config.lua` | `BaseForm = "BABY_BUG"`, `EvolutionForms = { "TANK", "GLIDER" }`; the threshold is the existing `EvolutionEnergyRequired` |
| `ServerScriptService/Services/EvolutionService.lua` | Owns each player's form, sets the attributes, creates `ReplicatedStorage.Remotes.RequestEvolution`, validates requests |
| `StarterPlayerScripts/Controllers/EvolutionUIController.lua` | Choice panel, form badge, overhead form tag |

Replicated Player attributes (visible to every client):

- `EvolutionForm` (string): `BABY_BUG`, `TANK` or `GLIDER`.
- `EvolutionAvailable` (bool): true while energy has reached the threshold and the player has not evolved. The server recomputes it whenever energy changes.

Server validation of `RequestEvolution(form)`. The client sends only a branch name. First, a per-player **rate limit** runs on the server: a request arriving less than `EvolutionRequestCooldown` (0.5 s) after that player's last *processed* request is dropped immediately, before any validation or state lookup. Every request that passes the limiter counts, including invalid ones, so bad requests cannot be used to bypass it. Dropped requests do not extend the cooldown, so a later legitimate request is never blocked for longer than 0.5 s. The timestamp is removed when the player leaves. The UI's 0.6 s click lock is only a convenience and is not relied on for security. After the limiter, the server ignores a request, changing nothing, unless all of these hold:

1. The player is tracked by the server and has a living character (`Humanoid.Health > 0`).
2. The player has not already evolved (current form is still `BABY_BUG`).
3. The server-side energy has reached `EvolutionEnergyRequired`. Client-supplied energy is never read.
4. The argument is exactly the string `"TANK"` or `"GLIDER"` (case-sensitive; any other type or value is rejected).

Because the server handles requests one at a time and sets the form before anything else can run, a valid choice is recorded exactly once; repeats and spam are no-ops. Rejections are silent. The client learns the result only from the attributes. State is per player, so one player's choice never changes another's energy, form or availability. Form is kept across respawns and lost when the player leaves.

Client behaviour:

- The choice panel is visible exactly while `EvolutionAvailable` is true and hides when the server sets it false after a valid choice. Buttons have a 0.6 s local click lock to avoid spamming; this is not a security measure.
- The overhead tag is attached only if, after waiting for the character's `Head`, that character is still the player's current character and the player is still in the game; stale characters are never tagged. A missing `Head` is skipped.
- A badge above the Energy HUD shows `Form: <name>`.
- Evolved players get an overhead tag (`TANK` / `GLIDER`) so other clients can see the choice. It is read from the replicated attribute.

Limitations:

- Evolution is recorded and displayed. The TANK form has the visual-only Defensive Shell (next section). GLIDER has **no ability**, and neither form has stat or model differences or a gameplay advantage. The choice panel notes this.
- Energy stays at 100 after evolving, so the Energy HUD stays full and the player cannot gain more energy.
- A player who disconnects loses their form (no persistence). Rejections give no on-screen error.

## Tank Defensive Shell

First TANK ability. **Visual only**: there is no damage, health, knockback or combat system in the project, so the shell does **not** reduce damage, grant invulnerability, resist knockback or change movement speed. It only shows a protective bubble.

Behaviour (values in `Config.lua`, none hardcoded elsewhere):

- Key `Q` (`AbilityKey`) or the on-screen **SHELL [Q]** button (mid-right of the screen, tappable on touch devices).
- Only players whose server-side form is `TANK` (`TankShellForm`) can use it.
- The shell stays for 3 s (`TankShellDuration`). The cooldown is 12 s (`TankShellCooldown`) and **runs from activation**, so the ability is usable again 9 s after the shell disappears.
- Repeated input can neither extend the shell nor shorten the cooldown. The cooldown persists across death and respawn within the session and resets when the player leaves.

| File | Responsibility |
|---|---|
| `ReplicatedStorage/Shared/Ability.lua` | Pure rules: `Validate`, `IsActive`, `GetCooldownRemaining` |
| `ServerScriptService/Services/AbilityService.lua` | Creates `Remotes.RequestAbility`, validates, owns timing and state, builds and removes the shell |
| `StarterPlayerScripts/Controllers/AbilityController.lua` | `Q` input, button, status text |

Server authority:

- `RequestAbility` takes **no arguments**; extra arguments are ignored. The server uses the player from the remote, reads the form from `EvolutionService`, and sets all times itself.
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

### Tests

`tests/Growth.test.lua` covers the pure helpers in `Growth.lua` (stages, scale, clamp, progress ratio) and sanity-checks `Config`. `tests/Evolution.test.lua` covers the pure rules in `Evolution.lua` (valid and invalid branches, threshold, repeat requests, nil/NaN input, and the rate-limit check including a simulated 1000-request spam). The server wiring of the limiter and the tag lifecycle guard use Roblox APIs and are checked manually. `tests/Ability.test.lua` covers the pure shell rules and the request rate-limit helper (only TANK may activate; BABY_BUG, GLIDER and bad input are rejected; dead character, already active, cooldown, available again after cooldown, early end keeps the cooldown). Run each with `lune run tests/<name>.test.lua`. Server and client behaviour of the shell uses Roblox APIs and cannot be run in this test setup; it is checked manually. It is optional and outside the Rojo tree. Run it with [Lune](https://lune-org.github.io/docs): `lune run tests/Growth.test.lua`. Lune is not part of `rokit.toml`. The service modules depend on Roblox APIs and are tested manually in Studio.

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

### Manual Studio test checklist: Energy HUD

1. Play Solo. Expected: HUD at bottom center shows `Energy  0 / 100`, `Stage 1/3`, empty bar, no output errors.
2. Collect one food. Expected: text becomes `Energy  10 / 100`, the bar animates to 10%.
3. Collect to 30 and 60 energy. Expected: stage text changes to `Stage 2/3` at 30 and `Stage 3/3` at 60, in step with the character growing; the bar fill matches energy / 100 each time.
4. Collect to 100. Expected: `Energy  100 / 100`, full gold bar, no overflow.
5. Reset the character. Expected: the HUD stays visible and unchanged, and still updates after the next food.
6. Test > Clients and Servers with 2 players. Expected: each client's HUD shows only its own energy; collecting on one client does not change the other's HUD.
7. In the emulator (Test > Device) try a phone portrait, phone landscape, tablet and 1080p. Expected: the panel stays readable, centered, not clipped by the screen edge or the Roblox bottom bar, and does not cover the hotbar or touch controls.
8. In Explorer during play, change your own Player attributes on the client side (not the server) and confirm the server value is not affected. This confirms the HUD is display-only.

### Manual Studio test checklist: Evolution

Solo (Play Solo, Avatar Type R15):

1. At start: badge shows `Form: Baby Bug`; no choice panel; in Explorer the Player has `EvolutionForm = BABY_BUG`, `EvolutionAvailable = false`.
2. Collect food up to 90 energy. Expected: still no panel, `EvolutionAvailable = false`.
3. Collect the next food (100). Expected: the `EVOLUTION READY` panel appears with TANK and GLIDER buttons and `EvolutionAvailable = true`.
4. Click TANK (or GLIDER). Expected: the panel hides, the badge shows the chosen form, `EvolutionForm` matches, `EvolutionAvailable = false`, and an overhead tag appears above your head.
5. Reset the character. Expected: the form, badge and tag persist; the panel does not reappear.
6. Try to choose again (command bar on the client): `game.ReplicatedStorage.Remotes.RequestEvolution:FireServer("GLIDER")`. Expected: no change to `EvolutionForm`.
7. Reject checks, from a fresh server session before reaching 100 energy, via the client command bar: `...RequestEvolution:FireServer("TANK")` (threshold not reached), then at 100 energy `FireServer("FLY")`, `FireServer(nil)`, `FireServer("tank")`, `FireServer(123)`. Expected: all ignored, no errors in the server output, form stays `BABY_BUG`, and the panel stays open. Then a valid `FireServer("GLIDER")` works once.
8. Dead character: at 100 energy, set the humanoid health to 0 and immediately fire a valid request. Expected: ignored while dead; works after respawn.

Two players (Test > Clients and Servers, 2 players):

9. Player A reaches 100 energy and evolves to TANK. Expected on Player B's client: A's `EvolutionForm` attribute shows `TANK` on their Player and a `TANK` tag appears over A's head; B's own panel, energy and form are unchanged.
10. Player B (still below 100) fires a valid request from their command bar. Expected: ignored.
11. B reaches 100 and picks GLIDER. Expected: A still shows TANK and B shows GLIDER, each seeing the other's tag.
12. A leaves and rejoins. Expected: the new session starts as Baby Bug (no persistence).
13. Rate limit (client command bar, at 100 energy, before choosing): run `local r = game.ReplicatedStorage.Remotes.RequestEvolution; for i = 1, 1000 do r:FireServer("TANK") end`. Expected: no server errors or lag, and the form becomes `TANK` once (the first request is processed, the rest are dropped or rejected as already evolved).
14. Invalid requests count against the limit (fresh session, 100 energy): `r:FireServer("FLY"); r:FireServer("TANK")` in the same frame. Expected: still `BABY_BUG`, because the second request fell inside the cooldown. Wait one second and fire `"TANK"` again: it now works.
15. Spam in a 2-player session: while Player A spams the remote, Player B can still evolve normally and sees no delay.
16. Leave and rejoin repeatedly: no server errors (per-player rate-limit state is cleaned up).
17. Tag lifecycle: evolve, then reset the character repeatedly and quickly (including right after spawning). Expected: each character has at most one `FormTag` under its `Head`, the tag follows the new character, and old characters do not keep or receive tags. On a second client, also check that a respawning player's tag does not appear on the previous character model.
18. Screen sizes (Test > Device: phone portrait, phone landscape, tablet, 1080p): the choice panel is readable and centered, the buttons are tappable, and the badge does not overlap the Energy HUD.

### Manual Studio test checklist: Tank Defensive Shell

Prepare: Play Solo (R15) and get a TANK quickly, for example by raising energy with the Studio server command bar, then choosing TANK. Use Test > Clients and Servers for the multiplayer items.

1. Tank, ready: the **SHELL [Q]** button appears (green, `Ready`). For BABY_BUG and GLIDER players it is hidden.
2. Press `Q` (or click the button). Expected: a translucent blue bubble appears around the character and the button turns blue with an `Active` countdown.
3. Second client: the bubble is visible around the Tank, moves with it, and does not push or block either player.
4. After 3 s the bubble disappears and the button shows `Cooldown` counting down.
5. Press `Q` repeatedly during the cooldown. Expected: nothing happens, no shell, no timer extension.
6. About 12 s after the first activation the button returns to `Ready` and `Q` works again.
7. GLIDER player: no button; from the client command bar run `game.ReplicatedStorage.Remotes.RequestAbility:FireServer()`. Expected: no shell, no `ShellActiveUntil`/`ShellReadyAt` change.
8. BABY_BUG player: same as 7.
9. Spam: while the shell is up, run `for i = 1, 200 do game.ReplicatedStorage.Remotes.RequestAbility:FireServer() end` on the client. Expected: duration stays 3 s and the cooldown is not shortened. Also try `FireServer("anything", 99)`: extra arguments change nothing.
10. Death: activate, then reset the character or set health to 0. Expected: the bubble disappears immediately and the button shows the remaining cooldown (not `Active`).
11. Respawn during and after activation: no stale bubble on the old or new character, and at most one `DefensiveShell` exists (check the character in Explorer on the server). Cooldown is still counting after respawn.
12. Touch: in the Device emulator (phone) or on a real touch device, tap the button. Expected: it activates, is not hidden behind the jump button or thumbstick, and tapping it does not also move the character.
13. Typing: focus a text box (for example the chat) and press `Q`. Expected: no activation.
14. Leave and rejoin: no server errors; the new session starts as Baby Bug with no button.
15. Walking through narrow gaps and over platforms with the shell up behaves exactly as without it (no snagging, no change in jump height or speed).
16. Rate limit: with the shell ready, `local r = game.ReplicatedStorage.Remotes.RequestAbility; r:FireServer(); r:FireServer()` in the same frame activates one shell only (the second request is dropped). After waiting 0.5 s the cooldown rules apply as before (still cooling down). A GLIDER or BABY_BUG player firing in a loop gets no shell and no server errors; their requests are throttled.

## Validate

```powershell
rojo build default.project.json -o build.rbxlx
```

Then connect Studio using the Rojo plugin. The project currently contains the greybox arena and the food/growth loop. The Energy HUD and the evolution choice (TANK or GLIDER) are implemented. The TANK Defensive Shell (visual only) is implemented. The GLIDER ability, form models, damage, combat and persistence are not implemented.

See `docs/Game Design Document v0.1.md` and `docs/Technical Design & Implementation Plan v0.1.md`.
