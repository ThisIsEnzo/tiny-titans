# M1 — Adventure Foundation Architecture Baseline

**Status:** Batch 2 implementation on `feature/m1-batch-2-legacy-removal`; Lune tests, Habitat validation and Rojo build passed in CI; PR review and Studio checks pending.  
**Baseline:** `master` at `18274699e97040d1f1c06ccbd66c6b27506882b5` (Batch 1 merged).  
**Scope:** retire the superseded creature/Biomass prototype while preserving the life, controlled-respawn and Habitat geometry contracts.

## Product constraints

- The standard Roblox avatar is the only player character.
- Tiny Titans is an original Zelda-style action-adventure; the old small-creature prototype is historical, not a product requirement.
- Solo and co-op are first-class. Essential progression must remain solo-completable.
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

The reset payload is intentionally empty at this stage: no active gameplay system currently owns per-life state. Future systems add their own reset API only when that system is implemented.

## Batch 2 — legacy prototype retirement

The old Biomass/Food/Growth, Evolution, form ability, per-life discovery and Baby Bug presentation prototype is removed from active source:

- Retired server services and client controllers are deleted.
- Retired shared rules/catalogs and their prototype-only tests are deleted.
- `LifeReset.lua` no longer carries a starting Biomass value.
- `Respawn.lua` no longer tracks or ranks a highest form; the recap remains duration-only.
- The obsolete shared `Config.lua` is removed because it contained only prototype tuning and has no remaining active consumers.
- The Habitat generator no longer creates the 24 pickup markers or 6 discovery trigger volumes. The validator no longer depends on the deleted discovery catalog or checks retired pickup/discovery behavior.
- Exactly 30 legacy marker parts are removed. The other 199 Habitat parts retain their original names, sizes, CFrames, tags and properties.

No new gameplay system is introduced by this cleanup.

## Tests and validation

CI must run:

- All remaining Lune tests, including the focused `LifeReset` decision/effect suite and the unchanged lifecycle timeline suite.
- The offline Habitat validator.
- The Rojo place build.

A green run proves only these automated checks. It does not prove Roblox engine behavior.

## Remaining M1 work

1. Perform the standard-avatar Studio traversal audit: proportions, camera, collision, jump/step limits, routes, nook, elevated route and secret path.
2. Verify first spawn, death, recap, player-driven respawn and repeated lifecycle cycles in Studio.
3. Verify multiplayer joins, independent spawn/respawn, death and leave behavior with multiple clients.
4. Begin the first concrete adventure vertical slice only after its gameplay contract and architecture are agreed.
