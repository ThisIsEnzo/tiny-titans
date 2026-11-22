# M1 — Adventure Foundation Architecture Baseline

**Status:** Batch 1 and Batch 2 are merged into `master`; current source baseline checked at `59db0e4eca571e55a1730a33236c5b26de8739d5` (PR #45, 2026-11-20). Automated CI passed for the merged Batch 2 head. Roblox Studio validation remains pending.  
**Completed milestones:** PR #41 standard-avatar restoration; PR #43 legacy avatar-scaling retirement; PR #44 legacy runtime retirement; PR #45 legacy prototype cleanup.  
**Scope:** preserve the life, controlled-respawn and retained Habitat geometry contracts after retiring the superseded creature/Biomass prototype.

## Product constraints

- The standard Roblox avatar is the canonical player character.
- Tiny Titans is an original Zelda-inspired action-adventure: exploration, traversal, combat, environmental puzzles, useful tools, items, dungeons, bosses, quests, secrets and progression.
- Solo is a complete first-class path. The first vertical slice targets co-op parties of up to 4; 5–8 player support remains a future scale-up decision requiring separate validation.
- Co-op should add coordination, tactical variety and shared stories, not mandatory party gates or health-only scaling.
- Do not add empty service placeholders. Introduce a service boundary only with a concrete vertical-slice use case.

## Active runtime ownership

| Area | Owner | Contract |
|---|---|---|
| Character-life state | `LifeService` | Sole authority for Alive/Ended state, life IDs and lifecycle events |
| Per-life reset orchestration | `ResetService` | Exactly-once reset tracking; handles duplicate and stale event ordering; gates the next life |
| Character spawn/respawn | `RespawnService` | Controlled first spawn, player-driven respawn, one in-flight spawn operation, spawn confirmation and recap handshake |
| Character presentation | Roblox standard avatar | Default avatar and built-in animation; no custom creature replacement |
| Life recap | `LifeRecapController` | Display-only title and server-derived life duration; sends no state with the new-life request |

`Bootstrap.server.lua` is the composition root. It sets `Players.CharacterAutoLoads = false`, initializes `LifeService`, then `ResetService`, then `RespawnService`. The latter is initialized last because it can spawn a character and trigger a new life.

## Lifecycle and respawn invariants

1. `LifeService` is the only authority on whether a life is Alive or Ended.
2. `ResetService` tracks the highest life ID whose reset has been recorded for each player.
3. A current `LifeEnded` is reset at most once. Duplicate or stale events cannot erase state belonging to a newer life.
4. If `LifeEnded` is delivered after a newer `LifeBegan`, the `LifeBegan` handler records the missed previous-life reset before new-life state is created.
5. `RespawnService` does not begin a new life until `IsResetDone` confirms the previous life has been recorded.
6. A spawn operation remains in flight until its own `LoadCharacter` call returns and the new life is observed. A stale completion cannot unlock a newer operation.
7. Recap delivery is retained until the client-ready handshake. The recap contract contains only `lifeId` and `durationSeconds`.

The reset payload is intentionally empty: no active adventure gameplay system currently owns per-life state. Future systems add their own reset API only when that system is implemented.

## Legacy prototype retirement — completed

PR #44 retired the old creature/Biomass gameplay dependencies from the active runtime. PR #45 completed the cleanup:

- Retired server services and client controllers were deleted.
- Retired shared rules/catalogs and prototype-only tests were deleted.
- `LifeReset.lua` no longer carries a starting Biomass value.
- `Respawn.lua` no longer tracks or ranks a highest form; the recap remains duration-only.
- The obsolete shared `Config.lua` was removed because it contained only prototype tuning and had no remaining active consumers.
- The Habitat generator no longer creates the 24 pickup markers or 6 discovery trigger volumes. The validator no longer depends on the deleted discovery catalog or checks retired pickup/discovery behavior.
- Exactly 30 legacy marker parts were removed. The other 199 Habitat parts retain their original names, sizes, CFrames, tags and properties.

No new adventure gameplay system was introduced by these cleanup milestones.

## Tests and validation

The merged Batch 2 CI run passed:
- Lune test suite.
- Offline Habitat validator.
- Rojo place build.

These checks verify the automated Luau/geometry/build pipeline only. They do not prove Roblox engine behavior, player experience or multiplayer quality.

## Remaining M1 validation and next work

1. In Roblox Studio, verify standard-avatar proportions, camera, animation, collision, jump/step traversal, routes, nook, elevated route and secret path.
2. Verify first spawn, death, recap, player-driven respawn and repeated lifecycle cycles in Studio.
3. Verify multiplayer joins, independent spawn/respawn, death and leave behavior with multiple clients.
4. Audit whether the retained First Habitat greybox is suitable for the new adventure direction; it is not yet an approved first region.
5. Approve the first concrete adventure vertical-slice design before implementing combat, tools, enemies, puzzles, dungeon or boss systems.

Do not mark Studio checks complete until they have actually been performed and evidence is recorded.
