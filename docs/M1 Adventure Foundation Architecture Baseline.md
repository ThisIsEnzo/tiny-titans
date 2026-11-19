# M1 — Adventure Foundation Architecture Baseline

**Status:** In progress  
**Baseline:** `master` at `f89b9a9f90313dd3e023178b78f998bca29bf309`  
**Scope of this checkpoint:** retire runtime avatar scaling without disturbing the existing life/respawn guarantees.

## Product constraints

- The standard Roblox avatar is the only player character.
- Solo and co-op are first-class; essential progression must remain solo-completable.
- Tiny Titans is an original Zelda-style action-adventure. Existing creature/evolution systems are prototype history, not product requirements.
- Do not build empty service placeholders. A service boundary is introduced when a concrete vertical-slice use case needs it.

## Dependency and lifecycle rules

1. `Bootstrap.server.lua` is the composition root. It is the only place that wires server services together.
2. Shared modules contain pure rules/data where practical; Roblox services own engine interaction and authoritative state.
3. A server service must not top-level-require another server service. Cross-service collaboration is passed through explicit `Init` dependencies from Bootstrap. This prevents service dependency cycles and makes initialization order reviewable.
4. `Players.CharacterAutoLoads = false` remains set before any service initialization can yield.
5. `LifeService` owns character-life transitions. `ResetService` owns exactly-once per-life reset orchestration. Owning services reset only their own state.
6. `RespawnService` retains its single-in-flight character-load sequencing, spawn confirmation, client-ready recap handshake and player-driven new-life request. Do not replace it with a timed automatic respawn.
7. Client attributes and RemoteEvents are presentation/intent channels, never authority for consequential game state.

## Current service ownership after this checkpoint

| Area | Current owner | M1 disposition |
|---|---|---|
| Character-life state | `LifeService` | Preserve |
| Per-life reset orchestration | `ResetService` | Preserve; remove obsolete avatar-scaling dependency |
| Character spawn/respawn | `RespawnService` | Preserve unchanged |
| Session Biomass prototype | `PlayerDataService` | Transitional; retire with dependent Food/Discovery prototype as a coordinated step |
| Food pickups | `FoodService` | Transitional legacy; not a target adventure reward system |
| Per-life location discoveries | `DiscoveryService` | Transitional exploration prototype; not permanent adventure progression |
| Evolution compatibility record | `EvolutionService` | Transitional adapter; remove after recap/reset consumers are migrated |
| Avatar scale presentation | `GrowthService` | Retired from runtime; source retained temporarily for dependency-safe cleanup |

## Checkpoint M1-A — retire miniature avatar scaling

- Removed `GrowthService` from server bootstrap.
- Removed `GrowthService.ResetLife` from `ResetService`.
- Kept the pure `Shared/Growth.lua` module and its tests because the existing session Biomass prototype still uses its pure progression helpers. Removing those helpers before migrating PlayerData/Discovery would break the current prototype.
- Kept the `GrowthService.lua` source temporarily as unreferenced legacy code; deleting it is a later cleanup after a full dependency scan.
- Did not change `LifeService`, `RespawnService`, the controlled respawn handshake, or any existing tests.

## Remaining M1 work

1. Run and record the existing 13 Lune tests and Rojo build on the branch.
2. Migrate recap/reset contracts away from the retired Evolution/Form model.
3. Retire the Food/Biomass/Discovery per-life prototype as one dependency-aware change; do not leave dangling calls or delete tests without replacement.
4. Establish concrete Adventure service contracts only alongside the first implemented interaction/combat/tool use case.
5. Audit and either redesign or retire First Habitat after standard-avatar traversal validation in Roblox Studio.
6. Remove dead creature presentation/evolution/ability modules and their obsolete tests only after references and CI are updated.
7. Keep Studio-only checks explicit: avatar proportions, camera, collision, animation, input, replication and multiplayer.

## Validation policy

CI is configured to run every `tests/*.test.lua` file with pinned Lune, run the offline Habitat validator and build the place with pinned Rojo. This GitHub edit session can read and write repository content but cannot execute those local tools or Roblox Studio. A successful PR CI run is required before merge; Studio checks remain pending until actually performed.
