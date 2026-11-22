# TT-M1-FOUNDATION-AUDIT — Foundation Validation Report

**Task:** Phase 0 foundation validation preparation (documentation only)
**Target baseline:** master @ `896ffe036a077b91acbd50a08a525fb3b4474fe8` — **owner-reported, not verified**
**Document status:** CORRECTED DRAFT. Added in PR #47; not yet merged.
**Studio validation:** NOT PERFORMED. No checklist item is marked passed.

---

## 0. Provenance

Every claim carries one label. Labels are never promoted without actual inspection.

| Label | Meaning |
|---|---|
| **[V-4ab5ce4]** | Read verbatim from source/docs at commit `4ab5ce4` (pre-#44/#45/#46). Real observation, **older baseline**. |
| **[R]** | Owner-reported (target SHA `896ffe0`, PRs #44/#45/#46, CI #53). **Not independently verified.** |
| **[V-896ffe0]** | Verified against the target baseline. **NONE — no source at `896ffe0` was inspected for this report.** |
| **[H]** | Design hypothesis. Requires current-geometry inspection and/or Studio observation to confirm or reject. |
| **[A]** | Authored procedure. Not a test result. |
| **[P]** | Pending — must be verified before this report is treated as final. |

### 0.1 Execution limits of this revision

Repository access was unavailable in the authoring environment. Therefore:

- Working directory, `git status`, `git rev-parse HEAD`, ancestry of `896ffe0`, and file existence were **not** checked.
- No source or documentation at `896ffe0` was read.
- During the original audit, no report file was written, no branch created, no commit made, and no PR opened. The report was subsequently added in this documentation-only PR.
- Roblox Studio was not launched. No Play Solo / Start Server / Clients-and-Servers session was run.
- No Lune test, Habitat validator, or Rojo build was executed by this audit.

### 0.2 Re-verification required before this report is final [P]

```
git rev-parse --show-toplevel
git status --porcelain=v1 -b
git rev-parse HEAD
git merge-base --is-ancestor 896ffe036a077b91acbd50a08a525fb3b4474fe8 HEAD; echo $?
ls docs/
sed -n '1,200p' src/ServerScriptService/Bootstrap.server.lua
sed -n '1,200p' src/ServerScriptService/Services/ResetService.lua
sed -n '1,260p' src/ServerScriptService/Services/RespawnService.lua
sed -n '1,220p' src/ServerScriptService/Services/LifeService.lua
sed -n '1,60p'  src/StarterPlayer/StarterPlayerScripts/ClientBootstrap.client.lua
ls src/ServerScriptService/Services/ src/ReplicatedStorage/Shared/
ls src/StarterPlayer/StarterPlayerScripts/Controllers/ tests/
grep -rn 'Instance.new("Remote' src/
grep -rniE 'GrowthService|BodyHeightScale|ScaleTo|BabyBugVisual|CreatureAppearance' src/
python3 tools/habitat/validate_habitat.py
for f in tests/*.test.lua; do lune run "$f"; done
rojo build default.project.json -o build.rbxlx
```

---

## 1. Runtime architecture

All statements in §1 are **[V-4ab5ce4]** unless marked otherwise. They describe the *older* baseline
and must be re-confirmed at `896ffe0` **[P]**.

### 1.1 Composition root and initialisation order

`Bootstrap.server.lua` asserted `RunService:IsServer()`, then set `Players.CharacterAutoLoads = false`
**before any yielding call**, then required services from `script.Parent.Services` and initialised
them in a fixed order with explicit dependency injection. At `4ab5ce4`:

```
LifeService.Init()
PlayerDataService.Init()
FoodService.Init(PlayerDataService)
EvolutionService.Init(PlayerDataService)
DiscoveryService.Init(LifeService, PlayerDataService)
ResetService.Init(LifeService, PlayerDataService, EvolutionService, AbilityService, DiscoveryService)
RespawnService.Init(LifeService, EvolutionService, ResetService, DiscoveryService)
```

`AbilityService` was required but never `Init`'d. `CreatureAppearanceService` was never initialised.
`GrowthService` had already been removed from the bootstrap by PR #43.

**[R] + [P]** PRs #44/#45 are reported to have retired the legacy runtime and removed the legacy
prototypes. The expected surviving composition is `LifeService → ResetService → RespawnService`.
**Confirm the actual surviving service set, argument lists and order at `896ffe0`.**

**Invariant to confirm [P]:** `CharacterAutoLoads = false` is still assigned before any
`WaitForChild` or other yield.

### 1.2 LifeService — lifecycle ownership

- Pure rules in `Shared/Life.lua`: `Initial`, `Begin`, `End`, `IsAlive`, `IsCurrent`.
- One life = one character. `LifeBegan` on `CharacterAdded`; `LifeEnded` on the first of
  `Humanoid.Died`, `CharacterRemoving`, a replacement character, or `PlayerRemoving`.
- `EndReason`: `HumanoidDied`, `CharacterRemoving`, `CharacterReplaced`, `PlayerRemoving`.
- Per-character connections stored on the life record and **disconnected when the life ends**.
- `endLife` returns false unless the payload `lifeId` matches the current Alive life.
- A new character while the previous life is Alive ends the old life first (`CharacterReplaced`).
- Humanoid lookup uses a bounded `ChildAdded` listener scoped to the life; an already-dead
  Humanoid is handled immediately.
- `PlayerRemoving` ends the life, disconnects everything, drops the record.
- `LifeState` Player attribute is explicitly a **debug mirror**, never authority.
- Events are `BindableEvent`s held inside the service, not in ReplicatedStorage.

### 1.3 ResetService — exactly-once reset

- Per-player `Tracker` with `lastResetLifeId`; `Commit` never moves backwards.
- Outcomes: `Reset`, `Duplicate`, `Stale`, `NoPlayer`, `Invalid`, `None`.
- Tracker marked **before** the reset payload runs.
- `Stale` does nothing; the subsequent `LifeBegan` performs the missed reset before the new life
  has state of its own.
- Tracker only stored while `player.Parent == Players`; `PlayerRemoving` clears it.
- `IsResetDone(player, lifeId)` is the gate consumed by `RespawnService`.
- Malformed ids (`0`, negatives, non-integers, NaN, inf, strings, booleans, tables, nil) → `Invalid`.

**[R] + [P]** After legacy removal the reset payload is expected to be **intentionally empty**.
Confirm the payload, the `Init` signature, and that `IsResetDone` is still consumed and tested.
An empty payload is acceptable only if the gate is still enforced.

### 1.4 RespawnService — first spawn, player-driven respawn, single in-flight load

- **First spawn is server-decided** (`startFirstSpawn` → `Respawn.StartInitialSpawn`).
- **Player-driven respawn only.** `RequestBeginNewLife` carries no arguments; extras ignored.
  No timed automatic respawn exists.
- **Single in-flight LoadCharacter per player**, enforced by a numbered spawn operation
  (`spawnSeq` / `inFlightSeq`), released **only** by `Respawn.EndSpawn` when that operation's own
  `LoadCharacter` returns **and** its sequence number matches.
- **Spawn confirmation:** `waitForNewLife` polls `life.GetLifeId(player)` until it exceeds the
  previous id, bounded by `SPAWN_CONFIRM_TIMEOUT = 10` s at `0.05` s intervals.
- **Failure recovery:** `retryInitial` plus the **`lifeId = 0` "spawn failed" notice** through the
  same pending-recap handshake, with the same button → one retry needing no reset.
- **Reset gate:** `TryBegin` receives `resetDone = ResetService.IsResetDone(...)`.
- **Recap ordering:** recap carries the server `lifeId`; `pendingRecap` cleared when a newer life
  begins (`lifeId > pending.lifeId`).
- **Client-ready handshake:** recap stored, sent once the client announces readiness; each
  `LifeRecapReady` replays it, rate-limited to `READY_MIN_INTERVAL = 1` s.
- `Respawn.CanSendRecap(...)` gates sending; a leaving player gets no recap.
- Every async continuation re-checks `entries[player] == entry` and `player.Parent == Players`.
- `PlayerRemoving` drops the entry.

**Known limitation stated in the source itself [V-4ab5ce4]:** a `LoadCharacter` that *never returns*
would keep the player locked; Roblox offers no timeout. See R1.

### 1.5 Life recap contract

At `4ab5ce4` the payload was `{ lifeId, durationSeconds, highestForm, discoveries }`. The client used
`Respawn.ShouldShowRecap(recapLifeId, dismissedLifeId, shownLifeId)` to ignore older, dismissed and
malformed recaps, and hid the recap when a **new character spawned**, not on button press. The
button re-enabled after a timeout. `lifeId = 0` rendered as "SPAWN FAILED" with no exploration line.

**[R] + [P]** PR #44 is expected to have reduced this to `{ lifeId, durationSeconds }`. Confirm the
payload and that no fake form value is displayed.

### 1.6 Client bootstrap and active controllers

At `4ab5ce4`, `ClientBootstrap.client.lua` asserted `RunService:IsClient()` and started
`BiomassUIController`, `LifeRecapController`, `DiscoveryUIController`. Evolution / Ability /
BabyBugAnimation controllers were **not** started. The standard avatar and its built-in `Animate`
script were the active presentation.

**[R] + [P]** Expected after #44/#45: **`LifeRecapController` only**. Confirm no dormant controller
remains referenced and no removed module is still required.

### 1.7 Remotes and interaction infrastructure

Remotes created by `RespawnService` under `ReplicatedStorage.Remotes` [V-4ab5ce4]:

| Remote | Direction | Payload | Notes |
|---|---|---|---|
| `LifeRecap` | server → client | recap table | display only |
| `LifeRecapReady` | client → server | none | idempotent replay, ≥1 s apart |
| `RequestBeginNewLife` | client → server | none | all arguments ignored |

`DiscoveryService` created `DiscoveryFound` (server → client, display only). `EvolutionService`
created no remotes at that commit.

**[R] + [P]** Expect only the three lifecycle remotes to survive. Confirm by grepping
`Instance.new("Remote` across `src/`.

**Interaction infrastructure: none at `4ab5ce4`.** No generic interaction framework, combat,
inventory, enemy, dungeon, puzzle, quest, party, or DataStore persistence. Food pickup and discovery
were server-side proximity polls, not a reusable interaction system. **[P]** Confirm this still
holds — it defines the Phase 0 → Phase 1 boundary.

### 1.8 Project mapping and toolchain [V-4ab5ce4]

`default.project.json`: DataModel → `Workspace` (`$path src/Workspace`, `$ignoreUnknownInstances true`),
`ReplicatedStorage.Shared`, `ServerScriptService`, `StarterPlayer.StarterPlayerScripts`.
`rokit.toml`: `rojo 7.6.1`, `lune 0.8.9`.

`.github/workflows/ci.yml` runs on push to `master`, `pull_request`, `workflow_dispatch`:
`actions/checkout@v5` → `CompeyDev/setup-rokit@v0.1.2` → print `lune --version` / `rojo --version` →
loop `lune run` over every `tests/*.test.lua` (fails if none found) →
`python3 tools/habitat/validate_habitat.py` → `rojo build default.project.json -o build.rbxlx`.

**[P]** Confirm the workflow is unchanged and that CI #53 corresponds to `896ffe0`'s lineage.

---

## 2. Existing reusable infrastructure [V-4ab5ce4]

| Asset | Disposition | Why reusable |
|---|---|---|
| `LifeService` + `Shared/Life.lua` | Preserve | Generic character-life state machine, stale/duplicate protection, per-life connection scoping. No creature coupling. |
| `ResetService` + `Shared/LifeReset.lua` | Preserve | Exactly-once orchestration + gate. Payload-agnostic. |
| `RespawnService` + `Shared/Respawn.lua` | Preserve | Numbered single-in-flight spawn, bounded confirmation, retry notice, recap handshake, rate limit. Do not replace with a naive `LoadCharacter`. |
| `LifeRecapController` | Preserve, simplify | Generic "life ended → act" UI with stale-recap gating. |
| Pure-rule + dual-environment test pattern | Preserve | Rules testable under Lune without Roblox. |
| Habitat generator + offline validator | Preserve tooling | Declarative, reproducible, CI-enforced geometry with a walking-graph reachability model. |
| CI workflow | Preserve | Already gates tests + validator + build on every PR. |

**Not present at `4ab5ce4` and must not be scaffolded as placeholders:** interaction, combat,
inventory, enemies, dungeon, puzzle, quest, party, persistence.

---

## 3. First Habitat

### 3.1 Geometry facts [V-4ab5ce4] — NOT current-geometry verification

Read from `README.md` and `tools/habitat/validate_habitat.py` at `4ab5ce4`:

- Play area ±70 studs (140 × 140), floor top **Y = 0.5**, on a 512 × 512 Baseplate.
- Areas / part counts: Terrain 9, Nest 18, Meadow 101, RockGarden 32, GiantRoots 35,
  DiscoverySites 6, Secret 28 → **229 parts** (budget 260).
- Nest south-west; Old Tree north-east. Three **8-stud** Nest openings; three **7 × 7** neutral
  spawn pads, `Duration = 0`.
- Primary route ≈ **490 studs**, ~30 s at 16 studs/s, every part **≥ 6 studs** wide.
- **3-stud** steps: rock terrace, clover hill, stepping stones, fungus steps, Tank nook.
- Great Stump 22 wide / 9 tall with a log ramp; Old Tree 26 wide / **70 tall**; root arch 8 wide /
  7 high with walkable top; Leaf Platform 2 across a **10-stud gap**, tops Y = 10.5.
- Secret: **5-stud** crack, screened mouth, leading to a 22-stud Dewdrop Glade pocket.
- Boundary walls 50 studs high, inner faces ±70. Landmarks ≥ 15 studs.
- All parts `Anchored`, `Locked`, `CanTouch = false`; decoration `CanCollide/CanQuery = false`.

Validator constants: `STEP = 3.0`, `HEAD = 6.0`, `BODY = 5.5`, `R_WIDE = 3.0`, `R_NARROW = 1.5`,
`MAX_PARTS = 260`, `MAX_OPEN_RADIUS = 13.0`, `PICKUP_REACH = 3.0`. It rasterises collidable parts into
1-stud cells and builds narrow/wide walking graphs, asserting spawn safety, no traps, route waypoints
at wide radius, alternatives, elevated spots, the secret route at narrow radius, the 10-stud
LeafPlatform gap plus a ≥ 35-step walking detour, landmarks, ramps ≤ 32°, proper rotation matrices,
and (optionally, with numpy/scipy) no open circle wider than 13 studs.

**[R] + [P]** PR #45 is reported to have removed `FoodSpawn` markers, `DiscoverySites`, and the
`TankNook` / `FutureTankPush` / `FutureGliderSpan` tags, and to have updated the validator.
**Current part counts, tags and validator assertions at `896ffe0` are UNKNOWN.** Re-read the
generator, validator and generated JSON and record the actual current numbers.

**Caution:** the validator's walking graph is an offline approximation. It does not model Roblox
collision, Humanoid HipHeight, accessory bounds, camera collision, replication, or landing
behaviour. **A green validator is not proof of standard-avatar traversal.**

### 3.2 Design hypotheses [H] — unconfirmed, to be tested

These are **hypotheses derived from older geometry**, not findings. Each must be confirmed or
rejected against current geometry and Studio observation before it informs any redesign decision.

| # | Hypothesis | How to test |
|---|---|---|
| H1 | Oversized-prop scale fiction (22-stud stump, 70-stud tree, giant acorn/grass) may read as ordinary props rather than awe-inspiring landmarks with a standard avatar. | Studio walk-through; screenshot landmarks at default camera distance; subjective read. |
| H2 | The Nest rim and random pad selection may occlude the intended first-frame vista. | Spawn 5× and record pad + framing (B1). |
| H3 | Tall opaque walls, the den roof, the arch and the trunk may cause camera occlusion. | Camera orbit / walk-in test (A8). |
| H4 | 6-stud routes and 8-stud mouths may be marginal for 2–3 players passing. | Two/three-client passing test (D11). |
| H5 | The 5-stud secret crack may be impassable for a standard avatar with accessories. | Accessorised traversal + measured width (B7). |
| H6 | 3-stud steps may interact poorly with HipHeight / body-package variation on landing. | Repeated jump/landing sampling (B4, B6). |
| H7 | Retired-mechanic geometry (glider span, Tank nook) may now read as arbitrary rather than designed. | Current-geometry inspection + Studio read. |
| H8 | The region may lack spaces for a regional objective, NPC, puzzle, dungeon mouth, boss arena or tool-gated shortcut. | Current-geometry inspection against the vertical-slice design (separate task). |

### 3.3 Recommendation

> **Retain the current Habitat as a traversal testbed. Its suitability for the first adventure
> vertical slice remains undecided pending current-geometry inspection and standard-avatar
> validation.**

Rationale: the only geometry actually inspected is at `4ab5ce4`; current geometry at `896ffe0` is
unverified, and no Studio observation exists. A mandatory redesign cannot be justified on that
basis. Run the first-pass checklist (§4.1) against the Habitat as-is, then re-read current geometry,
then decide. **Do not delete or redesign the Habitat in this task.**

---

## 4. Manual Roblox Studio validation checklist

**Status: ALL ITEMS PENDING. Nothing here has been executed.** [A]

**Total regression items: 55** — Avatar 9 + Traversal 13 + Lifecycle 15 + Multiplayer 14 + Regression 4.
A short first-pass subset (§4.1) precedes the full regression reference (§4.2–§4.6).

### 4.0 Setup and evidence conventions

1. `rojo build default.project.json -o build.rbxlx` (pinned Rojo 7.6.1), open the place; or
   `rojo serve` + the Studio plugin.
2. Confirm toolchain: `lune --version` → 0.8.9, `rojo --version` → 7.6.1.
3. Multiplayer: **Test → Clients and Servers → 2 Players → Start**.
4. Record **PASS / FAIL / BLOCKED** per item, the observed behaviour, and the artefact.
5. Evidence: screenshot or short clip; **full Output log** (server *and* each client); Server-view
   Explorer where instance counts matter.
6. Device profiles: desktop; **Device Emulator → phone portrait** and **tablet**; gamepad.
7. Never treat the `LifeState` Player attribute as authority — it is a debug mirror.

**Read-only probes (server command bar):**

*Visible body parts (excludes HumanoidRootPart by design):*
```lua
local p = game.Players:GetPlayers()[1]
local c = p.Character
local h = c and c:FindFirstChildOfClass("Humanoid")
print("rig", h and h.RigType)
for _, d in ipairs(c:GetDescendants()) do
    if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
        print(d.Name, "transparency", d.Transparency, "parent", d.Parent.Name)
    end
end
```

*Rig type and scale values (R15 only; counts detect injected duplicates):*
```lua
local p = game.Players:GetPlayers()[1]
local c = p.Character
local h = c and c:FindFirstChildOfClass("Humanoid")
print("rig", h and h.RigType)
if h and h.RigType == Enum.HumanoidRigType.R15 then
    for _, n in {"BodyHeightScale","BodyWidthScale","BodyDepthScale","HeadScale"} do
        local count, v = 0, nil
        for _, ch in ipairs(h:GetChildren()) do
            if ch.Name == n then count += 1; v = ch.Value end
        end
        print(n, "value", v, "instances", count)
    end
else
    print("non-R15: body scale NumberValues not applicable")
end
```

---

### 4.1 First-pass checklist (7 items) [A]

Run these first. All PENDING.

| # | Check | Regression refs |
|---|---|---|
| **F1** | Standard avatar spawns correctly on the rig type configured in the game's Avatar settings. An additional rig type is tested only if the project explicitly supports it. | A1, A2, A3, A4, A5 |
| **F2** | Camera behaves correctly. | A8, A9 |
| **F3** | Walking, running and jumping work. | B2, B3, B4 |
| **F4** | Main route is traversable. | B2 |
| **F5** | Narrow and elevated routes are tested. | B7, B8 |
| **F6** | Death and manual respawn work. | C3, C5 |
| **F7** | No duplicate characters or lifecycle errors occur. | C6, C8, D2, E1 |

---

### 4.2 Avatar — 9 items (A1–A9) [A]

| # | Action | Expected | Evidence |
|---|---|---|---|
| A1 | Play Solo. Observe the spawned character. | The **standard Roblox avatar** is visible and recognisable. No insect/creature model replaces it. | Screenshot; Server-view Explorer tree of the character |
| A2 | Run the visible-body-part probe. Judge **visible body parts** (Head, torso segments, arms, legs) and face Decal. **Exclude `HumanoidRootPart`, which is normally `Transparency = 1` by design**; also exclude accessory handles that are legitimately invisible. | Visible body parts are **not** wholesale hidden; the avatar is not made invisible to host a replacement. **No `BabyBugVisual` or other creature model** welded under the character. Record any body part at `Transparency = 1` and justify it. | Probe output; Explorer screenshot |
| A3 | Run the rig/scale probe (§4.0). Record `Humanoid.RigType`. For R15, record **which** of `BodyHeightScale` / `BodyWidthScale` / `BodyDepthScale` / `HeadScale` are present, their values, and any name occurring more than once. For R6, record that these values do not apply. Compare the recorded values against **Game Settings → Avatar** (avatar type, scaling limits) and the test account's own body package/proportions. Re-sample after spawn, after 60 s of play, and after any interaction. | Recorded values are consistent with the configured avatar settings and the account's avatar. **Non-1 values are legitimate; absent values are not themselves a failure.** Duplicate or runtime-injected values are a finding **only** where they indicate an actual conflict (e.g. competing values driving the same scale) or forced scaling by a retired runtime system. No retired system rescales or replaces the avatar at spawn, on appearance load, or over time. | Rig type; present values and occurrence counts at two samples; Avatar settings screenshot; note of any actual conflict or forced scaling observed |
| A4 | Read **Game Settings → Avatar** to determine the rig type the game configures and supports. Repeat A1–A3 on **that** rig type. Test an additional rig type **only if the project explicitly supports it** (documented setting or code path); otherwise record it as "not supported — not tested". | The configured/supported rig type spawns, moves and animates correctly. Any explicitly supported additional rig type also behaves correctly. Record any rig-specific warning. | Avatar settings screenshot; screenshot + Output per rig type actually tested; explicit note of which rig types are in scope |
| A5 | Test an account with **many accessories** (layered clothing, hair, hats, back/waist items). Repeat A1–A2. | Accessories render; none hidden or detached by game code. | Screenshot + probe output |
| A6 | Walk, run, jump, fall, idle, climb a ramp. | The **default `Animate` script** drives idle/walk/run/jump/fall. No custom creature animation. | Clip |
| A7 | Type `/e wave` and one other emote. | Emote plays; avatar not replaced or hidden. | Clip |
| A8 | Orbit the camera at min and max zoom around the standing avatar; then walk into the Nest rim, rock S-curve, den and root arch. | Camera does not enter geometry or clip through walls; avatar stays readable. Record every occlusion. | Clip + list of problem spots |
| A9 | Device Emulator → phone portrait. Repeat A1 and A8. | Avatar and HUD readable; camera usable; touch controls not obscured. | Screenshot |

### 4.3 Traversal — 13 items (B1–B13) [A]

| # | Action | Expected | Evidence |
|---|---|---|---|
| B1 | Spawn. Note pad, facing, and what is on screen. Repeat 5×. | Avatar stands **on** a pad, not inside geometry. Record whether the intended vista is visible; sample random pad selection. | 5 screenshots + pad ids |
| B2 | Walk the full primary route: Nest east → Meadow trail → Great Stump → Rock Garden gate → S-curve → north exit → north lane → Roots → under the arch → back to Nest. | Continuous walking; no snagging, invisible blockers or stuck spots. Time the loop. | Clip + timing + snag list |
| B3 | Run the same loop. | No tunnelling or wedging at speed. | Clip |
| B4 | Jump each **3-stud step present in current geometry**, 5 attempts each. **The step list is PENDING VERIFICATION** against current `src/Workspace/Habitat/`. The previously observed list (rock terrace, clover hill, stepping stones, fungus steps) is **[V-4ab5ce4]** and must be re-derived before this item can be executed. The retired Tank-nook side door is **not** a required step and must not be assumed to exist. | Every 3-stud step actually present in current geometry is cleared with the configured avatar rig. Record failures per step. | Re-derived step list + per-step tally + clip. **Status: step list PENDING VERIFICATION** |
| B5 | Walk every ramp: stump log, fallen leaf, root ramps, leaf ramp. Ascend and descend. | Walkable without sliding back or being launched. | Clip |
| B6 | After a normal jump, stand still on flat floor. Select the foot part **for the configured rig**: R15 → `LeftFoot` (or another valid foot part); R6 → `Left Leg`. If no expected foot part exists, record **BLOCKED** and do **not** compute a measurement. Otherwise measure the foot bottom with the guarded probe below. | For the measured part, foot bottom ≈ **0.5** (floor top). Record values well below 0.5 and their frequency. A missing expected part yields **BLOCKED**, not a number. | 20 landing samples with rig type and part name, **or** a BLOCKED note naming the missing part |

| B7 | Traverse the **5-stud secret crack** with a heavily-accessorised avatar. | Passes without snagging. **If it fails, measure the narrowest passable width.** | Clip + measured width |
| B8 | Traverse every elevated route: arch top, root bridge, Leaf Platform 1, ramp down north, Leaf Platform 2 via east ramp, fungus vantage. | All reachable **on foot**; no ability required. | Clip |
| B9 | **If** a ~10-stud horizontal gap between elevated platforms exists in current geometry, attempt to cross it with an ordinary jump. Gap existence and dimensions are **PENDING VERIFICATION**; the previously observed LeafPlatform1 / LeafPlatform2 pair at Y ≈ 10.5 is **[V-4ab5ce4]**. | Record whether the gap is crossable by ordinary jump, and whether an on-foot alternative route exists. **No ability is required or implied.** If the gap is not present in current geometry, record "not present — not tested". | Clip + measured gap + result, **or** a not-present note. **Status: PENDING VERIFICATION** |
| B10 | Jump off the Great Stump, arch, both Leaf Platforms, fungus vantage. | Lands on solid floor; no void, fall-through or death from a normal fall. | Clip |
| B11 | Walk into every boundary wall; try to leave the play area. | Cannot escape; no invisible-wall surprises; no void. | Clip |
| B12 | Device Emulator (phone) + gamepad: repeat B2 and B4. | Equivalent traversal; jump button not obscured. | Clip per device |
| B13 | Studio **Stats** panel during B2. | Record FPS, memory, instance count on a low-end profile. | Stats screenshot |

**B6 guarded, rig-aware probe:**

```lua
local p = game.Players:GetPlayers()[1]
local c = p and p.Character
local h = c and c:FindFirstChildOfClass("Humanoid")
if not (c and h) then print("BLOCKED: no character or Humanoid") return end

local candidates
if h.RigType == Enum.HumanoidRigType.R15 then
    candidates = { "LeftFoot", "RightFoot" }   -- R15: LeftFoot or another valid foot part
else
    candidates = { "Left Leg" }                -- R6
end

local foot
for _, name in ipairs(candidates) do
    local part = c:FindFirstChild(name)
    if part and part:IsA("BasePart") then foot = part break end
end

if not foot then
    print("BLOCKED: no valid foot part for rig", h.RigType,
          "tried", table.concat(candidates, ", "))
    return
end

print("rig", h.RigType, "part", foot.Name,
      "foot bottom Y", foot.Position.Y - foot.Size.Y / 2)
```

### 4.4 Lifecycle — 15 items (C1–C15) [A]

| # | Action | Expected | Evidence |
|---|---|---|---|
| C1 | Play Solo from cold start. Watch Output + Explorer. | **Exactly one** character, server-decided. No engine auto-spawn. | Output + Explorer |
| C2 | Server view: confirm `Players.CharacterAutoLoads == false`. | `false`. | Command-bar output |
| C3 | Kill the character (`Humanoid.Health = 0`). | `LifeEnded` once. **No automatic respawn.** Recap appears with duration and BEGIN NEW LIFE. No form/discovery lines. | Clip + Output |
| C4 | Inspect the recap payload received by the client. | `lifeId`, `durationSeconds`. **No `highestForm`, no `discoveries`.** | Client log |
| C5 | Press **BEGIN NEW LIFE**. | Exactly one new character. Recap hides **on the new character spawning**, not on press. | Clip |
| C6 | Press BEGIN NEW LIFE **10× rapidly**. | **One** spawn. No duplicate characters. | Explorer count + Output |
| C7 | Client: `RequestBeginNewLife:FireServer()` ×200 in one frame; then `FireServer("x")`, `FireServer(123)`. | One spawn at most; extras change nothing; no server error. | Output |
| C8 | Repeat C3–C5 **10 consecutive cycles**. | Each cycle: one death, one recap, one respawn. No leaked connections, accumulating instances or stuck state. | Output + Explorer per cycle |
| C9 | Die, leave the recap open, idle 60 s. | No auto-respawn. Recap persists; button usable. | Clip |
| C10 | Die, press BEGIN NEW LIFE, die again mid-spawn. | No duplicate character; no permanent lock; next recap is for the **newer** life. | Output |
| C11 | Client: `LifeRecapReady:FireServer()` ×200. | Replay at most ~1/second; no spam or error. | Output |
| C12 | Replay an **old** recap payload (or observe a late one). | Client ignores older / dismissed / malformed recaps. | Client log |
| C13 | **Failed-spawn recovery.** Attempt to observe the `lifeId = 0` "SPAWN FAILED" notice and its retry. | Notice with the same button; one retry succeeds without a reset. **See R3 — cannot be reliably forced without a temporary harness.** Mark **BLOCKED** if not observable; do not fabricate a pass. | Output or BLOCKED note |
| C14 | Reset character via the Studio menu mid-life. | Treated as a life end; recap flow as C3. | Clip |
| C15 | Device Emulator + gamepad: repeat C3–C5. | Recap readable; button tappable / gamepad-selectable on every device. | Screenshot per device |

### 4.5 Multiplayer — 14 items (D1–D14) [A]

| # | Action | Expected | Evidence |
|---|---|---|---|
| D1 | Start 2 players. | Both spawn on pads, each with its own standard avatar; neither inside geometry nor inside the other. | Both screenshots + Server Explorer |
| D2 | Server view: count characters and `HumanoidRootPart`s. | **Exactly one character per player.** | Explorer |
| D3 | Each client looks at the other. | Correct avatar, accessories and animations visible both ways. | Both screenshots |
| D4 | A dies; B keeps walking. | A gets a recap; **B unaffected** — no recap, respawn or state change. | Both Outputs |
| D5 | A presses BEGIN NEW LIFE while B is mid-jump. | A respawns once; B uninterrupted. | Clip |
| D6 | Both die within the same second, then both press BEGIN NEW LIFE. | Two independent lifecycles, recaps, respawns; no cross-talk or duplicates. | Both Outputs + Explorer |
| D7 | A dies and **leaves** with its recap open. | No server error; B unaffected; A's instances cleaned up. | Server Output + Explorer |
| D8 | A leaves **during** its `LoadCharacter`. | No server error; no orphaned character; B unaffected. | Server Output |
| D9 | B leaves while A is mid-life. | A's lifecycle, HUD and recap unaffected. | A Output |
| D10 | Stop/restart the 2-player session **3×**, joining/leaving quickly. | No duplicates, stuck spawn states, leaked instances or Output errors. | Output per run |
| D11 | Both walk the primary route, passing in **6-stud** sections and **8-stud** Nest mouths. | Record every chokepoint where two avatars cannot pass comfortably. | Clip + chokepoint list |
| D12 | Both attempt the **5-stud secret crack** simultaneously. | Record whether they block each other. | Clip |
| D13 | A spam-fires `RequestBeginNewLife` while B plays normally. | A's spawn lock holds; **B unaffected**. | Both Outputs |
| D14 | Add a **3rd** client; repeat D1, D6, D11. | Same guarantees at 3 players. | Outputs |

### 4.6 Regression sweep — 4 items (E1–E4) [A]

| # | Action | Expected |
|---|---|---|
| E1 | Read the **full Output** of server and every client. | **Zero** errors and zero unexpected warnings. Any warning is a finding. |
| E2 | Server Explorer: `Workspace` characters, `ReplicatedStorage.Remotes`. | Only expected instances; no leftovers or duplicates. |
| E3 | Confirm no `Food`, `DefensiveShell`, `GlideWing`, `GlideForce`, `BabyBugVisual` instances exist. | None. |
| E4 | Confirm no legacy Player attributes are set (`Biomass`, `GrowthStage`, `EvolutionForm`, `EvolutionAvailable`, `Discoveries*`, `Shell*`, `Glider*`). | None. |

---

## 5. Known risks and unresolved questions

| id | Risk / question | Basis | Severity |
|---|---|---|---|
| **R1** | A `LoadCharacter` that never returns leaves the player permanently locked; Roblox provides no timeout. | Source comment [V-4ab5ce4] | **High** — needs Studio observation and an owner decision on a watchdog |
| **R2** | The offline validator does not model camera, HipHeight, accessory bounds or real collision. Green ≠ traversable. | Validator source [V-4ab5ce4] | **High** |
| **R3** | The failed-spawn path (`retryInitial`, `lifeId = 0`) cannot be reliably forced in Studio without a temporary harness. Test design unresolved. | [A] | Medium — **owner decision needed**; do not fabricate a pass |
| **R4** | Current Habitat geometry, part counts, tags and validator assertions at `896ffe0` are unknown. | [R] + [P] | **High** — blocks any suitability decision |
| **R5** | Hypotheses H1–H8 (§3.2) are unconfirmed. | [H] | Medium |
| **R6** | `onPlayerAdded` handles `life.IsAlive` and `Character == nil`; a character existing while the life is not Alive would take neither branch. Appears guarded by `LifeService` initialising first — confirm at `896ffe0`. | [V-4ab5ce4] + [P] | Low–Medium |
| **R7** | Doc filenames: this task cites `GDD v4.0 — Zelda-style Adventure.md` and `Product Vision v4.0 — Zelda-style Adventure for Roblox.md`; at `4ab5ce4` that content lived in v2.0/v2.2-named files. Confirm which exist and that links resolve. | [R] + [V-4ab5ce4] | Low |
| **R8** | Whether any dormant controller, remote, attribute, tag or Config field survived #45. | [P] | Medium |
| **R9** | Whether the reset payload is now intentionally empty **and** the `IsResetDone` gate is still enforced and covered by tests. | [R] + [P] | **High** — an empty payload without the gate would be a silent regression |

### Recommended corrections (documentation / process only)

1. Re-verify every [P] item at `896ffe0` using §0.2 before this report is accepted.
2. Record the **current** Habitat part counts, tags and validator assertions in the architecture baseline.
3. Re-derive validator body constants (`STEP`, `HEAD`, `BODY`, `R_*`) from standard-avatar
   measurements taken during §4.3, and record the measurement method.
4. Add an explicit "validator ≠ traversal" caveat wherever the validator is cited as evidence.
5. Decide R3 (failed-spawn harness) and R1 (spawn watchdog) before Phase 0 sign-off.
6. Confirm the v4.0 doc filenames and fix broken cross-links (R7).
7. Do **not** mark Phase 0 complete until §4 has been executed and every FAIL/BLOCKED is resolved
   or explicitly accepted by the owner.

---

## 6. Validation ledger — strict separation

### 6.1 Source-verified facts
- Verified by reading source/docs **at `4ab5ce4`**: §1.1–§1.8, §2, §3.1.
- Verified at **`896ffe0`**: **NONE.** Repository access was unavailable.

### 6.2 Offline CI evidence
- **CI #53 on PR #45 — all Lune tests, Habitat validator, Rojo build passing: owner-reported [R].**
  Not reproduced here. Does not establish Roblox runtime behaviour.
- Executed by this audit: **no command was run.** No `git` command, no `lune run`,
  no `validate_habitat.py`, no `rojo build`.

### 6.3 Pending Studio validation
**All 55 regression items (A1–A9, B1–B13, C1–C15, D1–D14, E1–E4) and all 7 first-pass items
(F1–F7) are PENDING.** Roblox Studio was not launched. No statement in this document asserts that
avatar, camera, physics, animation or multiplayer behaviour was tested.

---

## 7. Conclusion

The lifecycle trio (`LifeService` / `ResetService` / `RespawnService`) is the project's most valuable
existing asset and should be preserved unchanged through Phase 0.

**Retain the current Habitat as a traversal testbed. Its suitability for the first adventure vertical
slice remains undecided pending current-geometry inspection and standard-avatar validation.**

Phase 0 cannot be signed off from static inspection alone. Run the first-pass checklist (§4.1),
re-verify the [P] items at `896ffe0`, resolve R1/R3/R4/R9, then execute the full 55-item regression
reference.

**No gameplay implementation is proposed or started here.**
```

---

## Final report

**1. Was the target repository accessible?**
**No.** `code_interpreter` and `web_extractor` both returned `Tool ... does not exists`. I could not check the working directory, confirm the repository identity, run `git status` or `git rev-parse HEAD`, test whether `896ffe0` is an ancestor, or confirm that any source/doc file exists. I stopped rather than clone into an ephemeral workspace.

**2. Was the report saved?**
**No.** The corrected document exists only in this response. No file was written, no branch created, no commit made, no PR opened. Nothing in the repository was changed, so no existing changes were disturbed.

**3. Which corrections were made?**

| Correction | Applied |
|---|---|
| **A — count** | Total changed from 61 to **55** (9 + 13 + 15 + 14 + 4), stated in §4 header and §6.3. |
| **B — transparency** | A2 rewritten: judge **visible body parts**, explicitly **exclude `HumanoidRootPart`** (normally `Transparency = 1`) and legitimately-invisible accessory handles; failure condition is a hidden/replaced avatar or a creature model, not any single transparency value. Probe script updated. |
| **C — scaling** | A3 rewritten: record rig type, inspect **Game Settings → Avatar** and the account's body package; **non-1 values are legitimate**; R6 has no such values. Failure conditions are **duplicate value injection** and **runtime forcing** by a retired system, sampled at spawn and after 60 s. Probe script updated. |
| **D — Habitat** | Mandatory redesign removed. §3.3 now uses your exact wording. §3.1 geometry explicitly labelled **[V-4ab5ce4], not current**; §3.2 recast as **eight labelled hypotheses [H]** with test methods; current geometry flagged unknown (R4). |
| **E — checklist** | Full **55-item** regression reference retained (§4.2–§4.6); new **7-item first-pass** checklist added (§4.1) mapped to regression IDs. No item marked passed. |

**4. Which source facts remain unverified?**
Everything at `896ffe0`. Specifically: current Bootstrap composition and Init order; surviving services/controllers/remotes; the reset payload and whether `IsResetDone` is still enforced; the recap contract; `CharacterAutoLoads` ordering; **current Habitat geometry, part counts, tags and validator assertions**; the v4.0 doc filenames; CI #53's correspondence to this baseline; and the existence of the report file itself. All §1/§2/§3.1 facts remain labelled at `4ab5ce4`; PRs #44/#45/#46 and CI #53 remain owner-reported.

**5. Do a commit and PR exist?**
**No.** No branch `docs/tt-m1-foundation-validation`, no commit, no PR. To deliver once the repo is reachable:

```bash
git rev-parse --show-toplevel && git status --porcelain=v1 -b
git merge-base --is-ancestor 896ffe036a077b91acbd50a08a525fb3b4474fe8 HEAD; echo $?
git switch -c docs/tt-m1-foundation-validation      # never on master
# save the document above to docs/TT-M1-Foundation-Validation-Report.md
git add docs/TT-M1-Foundation-Validation-Report.md
git commit -m "docs: correct TT-M1 foundation validation report (55-item checklist, avatar checks, Habitat recommendation)"