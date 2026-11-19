# Review: Zelda Adventure Transformation Apply Package

**Status:** BLOCKED — do not apply the uploaded `apply_transformation.py` as-is.

**Reviewed against:** current `master` at the time of review, including the standard-avatar restoration in PR #41, and the uploaded 3,869-line package text containing the proposed apply script.

This review intentionally records findings only. It does not apply the transformation or delete/replace project source. The package is not ready to be treated as a working vertical slice.

## Blocking runtime defects

### 1. Circular ModuleScript dependency — startup blocker

- `CombatService.lua` requires `EnemyService.lua`.
- `EnemyService.lua` requires `CombatService.lua`.

Both are top-level `require` calls. Roblox ModuleScript recursive requires are not a supported dependency-injection mechanism and can fail module initialization. Break the cycle by moving shared combat callbacks behind an injected interface, or by making one service call the other only after both modules have loaded.

### 2. Invalid string-based requires — startup blockers

The generated shared modules contain:
- `InventoryRules.lua`: `require("ItemDefinitions")`
- `QuestRules.lua`: `require("QuestDefinitions")`
- `PersistenceSchema.lua`: `require("InventoryRules")`, `require("QuestRules")`, and `require("ProgressionRules")`

These are not valid Roblox ModuleScript references. Resolve dependencies through explicit ModuleScript instances under `ReplicatedStorage.Shared` (or inject the dependencies), and keep the pure-test/Lune loading strategy compatible with the repository's established module pattern.

### 3. No new automated tests are written

The apply script contains no `put("tests/…")` entries, despite the generated README and TESTING documentation describing a new suite of combat, puzzle, quest, inventory, enemy, party, reward and persistence tests.

At the same time, the script moves a number of existing tests into `.legacy_backup/` and removes them from their tracked paths. That backup directory is added to `.gitignore`, so those copies would not be included in the PR. The package therefore removes existing test coverage while claiming new coverage that it does not actually add.

### 4. Existing controlled respawn reliability is regressed

The current repository has a deliberately hardened `RespawnService` with single-in-flight `LoadCharacter` sequencing, spawn confirmation and a player-driven new-life flow. The proposed replacement removes those guarantees.

The replacement calls `player:LoadCharacter()` and only afterwards waits on `player.CharacterAdded:Wait()`, which can miss the event if the character was added before the wait begins. It also changes the established player-driven respawn flow to an automatic three-second respawn. Preserve and adapt the existing proven sequencing rather than replacing it with this simpler implementation.

## High-severity gameplay and state defects

### 5. Enemy AI uses a stale position

`EnemyAI.Step` calculates distance from `ai.position`, but `EnemyService` moves `enemy.position` and never updates `enemy.ai.position`. The AI state machine therefore reasons about the original spawn position while the visible enemy moves elsewhere. Keep one authoritative position or synchronize it every movement step.

### 6. Puzzle completion grants rewards to every online player

When the global puzzle becomes solved, `PuzzleService` loops over every player in the server and claims/grants the Briar Sigil, regardless of proximity, party, participation or quest stage. Define the intended world/party persistence boundary and validate eligibility before granting.

### 7. Boss encounter lifecycle is not controlled

The boss is started automatically whenever any player enters the arena. After the boss dies, `bossActive` is reset; a player remaining in the arena can cause another boss to spawn on the next tick. Echo Trial also creates a boss without a separate encounter lifecycle/lock. Add explicit encounter state, quest gating, trial isolation and replay rules.

### 8. Character auto-load protection is installed too late

The existing bootstrap sets `Players.CharacterAutoLoads = false` before loading/yielding through services. The proposed bootstrap delays this until `RespawnService.Init()`, after other service initialization. Restore the early bootstrap invariant.

## Documentation and scope mismatches

- The generated documentation describes a playable adventure foundation, but no automated tests or Studio run support that claim.
- The matrix status writer labels a broad set of mechanic families implemented even where the supplied code is only a placeholder or a partial interaction. Use evidence-based statuses: implemented, partial, planned and deferred.
- The replacement of the existing `Config.lua` and broad legacy cleanup should be performed only after every retained dependency and test has been mapped. The uploaded script's backup is ignored and is not a durable repository artifact.
- The proposed server-generated blockout region may be useful as a temporary greybox, but it is not a substitute for the approved vertical-slice contract or Studio validation.

## Recommended remediation order

1. Keep the current master source intact; do not run the uploaded script.
2. Preserve the existing 13-test baseline and run it with the repository's pinned Lune toolchain.
3. Define module dependency direction and remove the Combat/Enemy cycle and all string-based requires.
4. Adapt the current controlled respawn implementation rather than replacing its sequencing guarantees.
5. Fix enemy position/state ownership, encounter lifecycle, puzzle reward eligibility and server-side payload validation.
6. Add the promised pure tests before changing documentation status.
7. Only then apply the transformation in coherent, reviewable stages on one feature branch and one PR, with Studio validation clearly marked as pending.

## Verification limits

This review was a static inspection of the uploaded script and current GitHub source files. No Roblox Studio session, Luau/Lune test run, Rojo build or live multiplayer playtest was performed. No project source files were changed by this review.
