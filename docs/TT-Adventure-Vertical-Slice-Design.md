# TT-Adventure-Vertical-Slice-Design — "The Slack Line"

**Status:** PROPOSAL — design only. No implementation. Awaiting owner review.
**Task:** TT-M2 Adventure Vertical Slice Design
**Target baseline:** `master` — not independently verified when drafted.
**Implementation prerequisite:** M1 foundation validation (TT-M1) must complete first.

## 0. Provenance and verification limits

Every factual claim carries a label. Nothing is promoted without inspection.

| Label | Meaning |
|---|---|
| **[V-4ab5ce4]** | Read verbatim from source/docs at commit `4ab5ce4` earlier in this work stream. Real observation, older baseline. |
| **[R]** | Owner-reported: baseline `896ffe0`, PR #44 (M1 runtime cleanup), #45 (legacy removal), #46 (docs alignment), CI #53 green. Not independently verified at drafting time. |
| **[U]** | Unknown — could not be inspected in the drafting session. |
| **[P]** | Proposed system. Does not exist. |
| **[D]** | Design decision made by this document. |

### 0.1 Could not be verified

- Current `master` HEAD and whether it moved past `896ffe0`. [U]
- PR #47 (TT-M1 Foundation Validation Report): state unknown at drafting time. Its findings are not assumed present on `master`, and none of its conclusions are treated as established. [U]
- Post-#44/#45 runtime shape (which services survive, whether `Config.lua` was removed). [R]
- Whether #46 renamed the v4.0 documents (at `4ab5ce4` the v4.0 content lived in files named `Product Vision v2.0 …` and `GDD v2.2 …`). [U]
- Current Habitat geometry, part counts and validator assertions. [U]

### 0.2 Established constraints this design respects

- Standard Roblox avatar is canonical; no creature forms, no arbitrary body scaling. [V-4ab5ce4]
- Solo must complete every essential step; co-op additive, never a gate. [V-4ab5ce4]
- Server owns consequential state; client sends intent only. [V-4ab5ce4]
- No DataStore until schema, migration, retry, failure UX and recovery are designed (Progression Addendum §3.10). [V-4ab5ce4]
- Original IP; Zelda is a genre reference, not a template. [V-4ab5ce4]
- All 46 mechanic families remain in the long-term matrix. [V-4ab5ce4]
- Lifecycle trio (`LifeService` / `ResetService` / `RespawnService`) is preserved infrastructure: `CharacterAutoLoads = false`, player-driven respawn, single in-flight `LoadCharacter`, exactly-once reset gate, recap handshake. [V-4ab5ce4]

## 1. Purpose and design principles

### 1.1 Purpose

Define the smallest adventure that proves Tiny Titans' identity: **a place that stopped mid-breath, and a player who makes it move again.** Not a feature demo — a short, complete experience with a beginning, a turn, and a payoff.

### 1.2 Principles

1. **One verb, many uses.** A single tool verb taught once, then reused in traversal-adjacent, puzzle and combat contexts. Depth from combination, not from button count.
2. **Legible rules, free experimentation.** Every mechanism's rule is stateable in one sentence and visible from one vantage. Wrong attempts cost nothing and teach.
3. **Solo-complete, co-op-additive.** Co-op changes how a step is solved, never whether it can be.
4. **Reward is capability and access, not statistics.** No damage/health inflation as progression.
5. **Geometry-agnostic until validated.** This document specifies space requirements, not coordinates. Habitat suitability is pending M1 validation (§12.1).
6. **Original fiction.** Quarry, tally marks, counterweights, slag. No borrowed names or layouts.
7. **No artificial retention.** No dailies, streaks, energy, timers or grind.
8. **Smallest honest MVP.** Anything not needed to prove the identity is explicitly deferred.

## 2. Player experience overview

### 2.1 Fiction

**Tallystone Draw** is a terraced quarry where a crew cut banded pale stone and carved a tally mark for every block they raised. The crew left mid-shift — a meal still sits at the rim camp. The machinery never stopped holding tension. The gate they lowered is still lowered, and the waste-rock pile behind it has been slowly bound by cable and rust into something that moves.

No lore dumps. The story is told by tally marks, abandoned tools, and one wrong detail any quarry worker would notice: **the counterweight is resting.**

### 2.2 First 60 seconds

The player spawns on a safe rim ledge. In one frame they can see: the **Tally Gate** (closed), the **Hanging Weight** above the pit, and a **slack cable** between them. **Brack**, a salvager, says one line: *"Crew left the weight sitting. Gate's been down since."*

That is the entire onboarding. The objective — **open the Tally Gate** — is legible from the geometry, not from a quest log.

### 2.3 What motivates exploration

- **A visible wrongness.** Slack cable + resting weight is a puzzle stated in the environment.
- **Two descents, different character.** One forgiving, one tighter and shorter, leading somewhere the main path does not.
- **Colour language.** Rust-red = *you can operate it*. Brass = *your tool works on it*. Nothing else uses those hues. This is the whole visual tutorial.
- **A secret that is findable, not obscure.** Glowing markers and a sightline, not a pixel hunt.

### 2.4 Accomplishment and ending

The payoff is causal: the player's own puzzle solution becomes the encounter's resolution. When the gate opens, the world is permanently different, a tally mark is added, and the player can see a further space they cannot yet reach — the next objective, stated by a vista rather than text.

## 3. Core gameplay loop

**Moment-to-moment:** notice rust-red/brass → choose a verb → read the tell → commit → read feedback → reposition.

**Slice loop:** descend → find machinery that refuses → learn its rule → change world state → a new space opens → meet what was behind it.

**Return loop:** rematch the encounter with a modifier, or find the secret missed on the first run.

## 4. Adventure structure and progression

### 4.1 Space requirements (geometry-agnostic) [D]

These are functional requirements for a future region-authoring task, not instructions to modify the existing Habitat. Whether the current Habitat can satisfy them is pending M1 validation and is explicitly not decided here.

| ID | Space | Functional requirement |
|---|---|---|
| **S1** | Arrival ledge | Safe spawn. Single sightline containing gate and counterweight and slack cable. NPC within ~15 studs. No threat. Checkpoint. |
| **S2** | Primary descent | Forgiving traversal, standard avatar, no tool required. Width allowing two avatars to pass. One enemy cluster. Leads to S4. |
| **S3** | Optional descent | Tighter or longer than S2. No tool required. Leads to S7. Solo-safe. |
| **S4** | Tool cache | Reachable from S2. Contains the Drawline and an iron bar. No threat. |
| **S5** | Puzzle platform | One vantage showing weight, shelf, cable, drum and gate simultaneously. Rail for the shelf block. A movable crate usable as a step. Drum with brake lever + jam socket. |
| **S6** | Gate chamber | Enclosed arena, ~20-stud radius, two plate-anchor points, entry checkpoint. |
| **S7** | Secret alcove | Off S3. Cosmetic reward. Solo-reachable without any tool verb. |
| **S8** | Return path | Walk-back or shortcut. Must not require a verb absent from MVP. |

### 4.2 Progression shape

```
S1 arrival ──► S2 primary descent ──► S4 tool cache ──► S5 puzzle ──► gate opens ──► S6 encounter ──► S8 return
        └────► S3 optional descent ──► S7 secret ─────────┘ (rejoins S4/S5)
```

Progression is **world state**, not levels: `gate closed → gate open`. The tool is the capability gate; the puzzle is the knowledge gate; the encounter is the skill gate.

### 4.3 The environmental challenge — "Weight & Drum" [D]

> **Rule:** the gate rises only while the weight hangs free and the drum is locked.

Both halves are visible from S5. The difficulty is order, not discovery of a hidden switch.

**Elements:** weight resting on a stone shelf; shelf is a rail block (Yankable) pinned by a **rust clamp**; drum with a **brake lever** (hold) and a **jam socket** (insert iron bar); the gate.

**Solution:** break the clamp → lock the drum → Yank the shelf free → weight drops → gate rises and stays.

**Wrong order:** gate rises ~3 s then falls. No damage, no cost, instant retry. This is the teaching moment, not a failure state.

**Clamp access — two authored solutions:** reachable directly from S3, or Yank the crate into a step from S5. Neither requires a party.

### 4.4 Discovery / secret

**Tally Wall cache** (S7): a slab of tally marks that breaks open, containing a **lantern charm** (cosmetic) and one line of crew story. Signposted by glow markers and a sightline from S3.

### 4.5 Reward

- **Mid-slice:** the **Drawline** itself — a new capability.
- **End:** the gate stays open (permanent world state), a **tally mark** record, the **rematch** unlocked, and a vista of the next space.
- **Secret:** lantern charm (cosmetic).

**No damage, health or stat increases.** [D] Rationale: Progression Addendum forbids raw-stat inflation; capability and access are the intended progression currency.

### 4.6 Final milestone — "The Slagbound" (mini-boss) [D]

A small accretion of slag and cable, ~1.5× avatar height, armoured by **two slag plates**.

| Attack | Telegraph | Counter |
|---|---|---|
| Overhead slam | Rises, shadow grows, **1.0 s** | Step out; recovery glows the plate anchors |
| Sweep | Arm drags low, dust trail, **0.8 s** | Dodge through or jump |

**Weakness:** plates cannot be damaged. During post-slam recovery, **Yank** a plate → core exposed **6 s** → strike. The player must bait a slam, survive it, then commit the tool — a three-beat decision using movement, dodge and the verb.

**Resolution:** both plates stripped and core depleted → the far door opens → S8.

This is a **mini-boss, not a full boss.** No phases, no adds, no arena mechanics beyond the two attacks. A full multi-phase boss is deferred (§12).

## 5. Key gameplay moments

| # | Beat | Player sees | Player does | Learns | Hook |
|---|---|---|---|---|---|
| 1 | Arrival | Gate, weight, slack cable; Brack | Listens to one line | The goal | Two descents visible |
| 2 | Descent | Rust-red hand winch | Holds interact; a grate rises | Rust-red responds to me | Machinery is the language |
| 3 | First enemy | Slagling crouch + glow | Strikes, dodges | Telegraph → punish | Combat has rhythm |
| 4 | Tool | Cache: Drawline + bar | Equips | Brass = tool target | World is full of brass |
| 5 | Wrong order | Gate rises… then falls | Retries | Order matters | The drum brake |
| 6 | Solve | Cable taut, gate holds | Jam → Yank | Load + tension = state | Something is behind it |
| 7 | Encounter | Slagbound, two plates | Bait → dodge → Yank → strike | Everything, at once | Far door |
| 8 | Return | Tally mark added; vista | Leaves | I changed this place | Rematch / next space |

**Onboarding budget:** one NPC line, one hold-interaction, one enemy tell. No pop-up tutorials, no forced camera, no text walls. [D]

## 6. Required systems and dependencies

Existence is stated honestly. **Nothing below is claimed implemented.**

| System | Player-facing purpose | Exists? | MVP | Notes |
|---|---|---|---|---|
| **Lifecycle** (Life / Reset / Respawn) | Spawn, death, player-driven respawn, checkpoints | **Exists** [V-4ab5ce4]; post-#44/#45 shape [R] | **Required — reuse unchanged** | Do not replace. Extend checkpoint selection only. |
| **Interaction** | Operate rust-red objects (winch, lever, socket, cache) | **[P]** | Required | Server validates distance, LoS, cooldown, eligibility. |
| **Drawline — Yank** | Pull rail-constrained objects | **[P]** | Required | Server-owned object motion. **Object movement only — never character movement.** |
| **Mechanism state** | Weight / drum / gate state machine | **[P]** | Required | Idempotent transitions; auto-reset when idle and unsolved. |
| **Combat (minimal)** | Strike + dodge | **[P]** | Required | Server computes hits/damage. No block, no stamina, no lock-on. |
| **Enemy behaviour** | Slagling + Slagbound tells | **[P]** | Required | Two hand-authored state machines. No generic framework. |
| **Objective flags** | Track slice progress | **[P]** | Required | Server-derived only. |
| **NPC dialogue** | Brack, 3 states | **[P]** | Required | Before tool / after tool / after encounter. |
| **HUD + prompts** | Objective, interact prompt, health, boss plates | **[P]** | Required | Presentation only. |
| **Records (session)** | Tally, rematch unlock, charm ownership | **[P]** | Required, session-only | No DataStore (§12.2). |
| **Party + credit** | 2–4 players, shared world, personal rewards | **[P]** | Required for co-op | Disconnect-safe. |
| **Health recovery** | Stay in the loop | **[P]** | Required | Full restore at checkpoint; slow out-of-combat regen. No consumable inventory — see §12.3. |
| Persistence | Cross-session progress | Not implemented | **Deferred** | Design-gated by Addendum §3.10. |
| Inventory / equipment | Slots, loadouts | Not implemented | **Deferred** | Single auto-equipped tool; no slot UI in MVP. |
| **Drawline — Ride / Strip** | Traversal / armour-strip verbs | **[P]** | **Deferred (Tier 2)** | Ride moves the character → highest authority risk. |
| Dungeon, full boss | Larger authored structure | **[P]** | **Deferred (Tier 3)** | Required by Blueprint for the public slice (§15.1). |
| Economy, crafting, trading | — | Not designed | **Out of scope** | |

**Dependency order:** Interaction → Drawline(Yank) → Mechanism → Combat → Enemy → Objective/HUD → Party. Lifecycle is a prerequisite, already present.

**Architecture boundary [V-4ab5ce4]:** Bootstrap remains the composition root; explicit `Init` dependency injection; no service top-level-requires another service; no empty placeholder services — each lands with its first concrete use.

## 7. Solo experience

Every essential step has an authored solo path. [D]

| Step | Solo solution |
|---|---|
| Descent | Either route; both tool-free |
| Tool cache | Walk in |
| Rust clamp | Yank crate into a step from S5 |
| Drum lock | Insert the iron bar into the socket |
| Free the weight | Yank the shelf |
| Slagbound | Bait slam → dodge → Yank plate → strike. Two plates, sequential. |
| Secret | Reachable from S3 without any verb |
| Return | Walk-back / shortcut |

Death returns the player to the last checkpoint with **full health and no loss of items, flags or puzzle progress**. The gate, once open, stays open. [D]

## 8. Co-op experience (2–4 players)

Co-op changes **method and texture**, never availability. [D]

| Step | Co-op behaviour |
|---|---|
| Descent | May split; both routes reconverge |
| Drum | A partner **holds the brake lever** — no bar needed. Faster, and opens a small co-op alcove. |
| Weight | Second player Yanks while the first holds |
| Slagbound | One baits and dodges, one Yanks and strikes. **HP identical to solo.** |
| Secret | Each player claims their own charm |

**Contract:**

- **Shared:** gate, drum, weight, clamp, encounter state, arena.
- **Personal:** tool, charm, tally record, checkpoint.
- **No player-count gate.** The co-op alcove's cosmetic is also obtainable solo via S3 — co-op is faster, never exclusive.
- **No HP scaling.** Difficulty adds behaviour (a second simultaneous sweep), not health.
- **Disconnect:** lever auto-releases; the bar remains available; Yank pins release; no softlock.
- **Late join:** receives current world state (gate/drum/clamp/encounter) and spawns at the region checkpoint.
- **Griefing:** no permanent switches, no consumable world resources, no player-owned locks. Unsolved mechanisms auto-reset when idle.

## 9. Replayability and retention

### 9.1 What makes a second run interesting [D]

1. **Rematch with a modifier.** The Slagbound returns with **three plates** and a shorter recovery window. Same arena, same verbs, tighter execution. Unlocked by first clear.
2. **The missed secret.** Most first runs take S2 and never see S3/S7.
3. **A different descent.** S3 changes the clamp solution and the pacing.
4. **Co-op re-texturing.** Holding the lever instead of fetching the bar is a genuinely different solve.

### 9.2 Progression motivation

- **Short-term:** open the gate (one session, ~10–15 min).
- **Medium-term:** clear the rematch; find the charm.
- **Long-term (deferred):** the vista beyond the far door is the next region — capability growth (Ride, Strip) rather than stat growth.

### 9.3 Anti-grind rules [D]

No dailies, streaks, energy, login rewards, timers, or repeatable currency. Records reward **mastery and discovery**, not repetition. The rematch is a challenge, not a farm.

## 10. Monetization considerations

**Not implemented. Design guidance only.** [D]

**Acceptable future directions:**
- Cosmetic lantern charms and tool skins (visual only).
- Emotes / expression.
- Optional supporter badge.
- Convenience that does not touch fairness (e.g. cosmetic loadout presets).

**Explicitly excluded:**
- Paid damage, health, defence, or tool range.
- Paid revives or death protection.
- Paid puzzle solutions, gate skips, or region access.
- Paid records, tally marks, or rematch unlocks.
- Anything that makes a solo player's essential path worse.

**Principle:** monetization must never be the reason a mechanic is frustrating. Player trust is worth more than short-term conversion, and is a precondition for the Top-1000 ambition.

## 11. Scope exclusions

**This task excludes:** all Luau source changes; adding/removing gameplay systems; Habitat geometry, generator or validator changes; avatar/lifecycle architecture changes; project configuration or dependency changes; any claim that M1 validation passed; any claim that Roblox Studio or a live session was tested.

**The designed MVP excludes:** Ride and Strip verbs; a dungeon; a full multi-phase boss; a second enemy type; consumables and inventory UI; equipment slots; armour; stamina; block/parry; lock-on; persistence; economy; crafting; trading; a second region; procedural generation; live-ops.

### 11.1 MVP scope (explicit)

**IN:** 1 region shape (S1–S8) · 1 NPC · 1 tool with **Yank only** · 1 two-step order puzzle · 1 enemy type · 1 mini-boss (2 attacks, 2 plates) · 1 secret + 1 cosmetic · 1 permanent gate world-state · 1 rematch modifier · session records · solo + 2–4 co-op.

**Target length:** 10–15 min first clear. **Target build:** small, dependency-ordered PRs.

**Tier 2 (next):** Ride verb · Strip verb · second enemy type · shortcut traversal.
**Tier 3 (public slice):** compact dungeon · full multi-phase boss · persistence (after schema design).

## 12. Risks and unresolved questions

### 12.1 Habitat suitability — **blocking for geometry decisions**

Current Habitat geometry is **unverified** in the drafting session. At `4ab5ce4` it was authored as *a tiny creature in an oversized world* (22-stud stump, 70-stud tree, 5-stud secret crack, 3-stud steps, validator constants `STEP=3.0 / HEAD=6.0 / BODY=5.5`). [V-4ab5ce4] Whether it can satisfy §4.1 with a standard avatar is **pending M1 validation**.

**This document therefore prescribes no Habitat modification.** S1–S8 are requirements for a future authoring task, to be satisfied either by re-authoring or by validated reuse — a decision that belongs to M1's outcome, not here.

### 12.2 Other risks

| Risk | Severity | Mitigation |
|---|---|---|
| Yank network ownership / jitter | **High** | Server-owned rail-constrained motion; `SetNetworkOwner(nil)`; prototype before content |
| Slagbound readability on mobile | **High** | ≥0.8 s telegraphs, strict colour discipline, ≤1 simultaneous threat; device playtest |
| Scope creep back toward a full boss | Medium | §11.1 is the contract; Tier 3 exists for the larger ambition |
| Puzzle too obscure | Medium | One-vantage requirement (S5); wrong order is a free teaching beat |
| Co-op lever griefing | Medium | Auto-release, bar redundancy, idle reset |
| No persistence → progress lost on rejoin | Medium | Accept for MVP; session-only records; schema design is a separate task |
| Softlock via carried bar | Low | Bar returns to cache when dropped/lost |

### 12.3 Unresolved questions (owner decision required)

1. **PR #47 state and findings** — unknown at drafting time. Does M1 validation exist, and what did it conclude about Habitat and the post-cleanup runtime? [U]
2. **Current `master`** — has it moved past `896ffe0`? [U]
3. **Region concept** — approve Tallystone Draw / The Slack Line as the slice identity?
4. **Yank-only MVP** — approve deferring Ride and Strip to Tier 2?
5. **Mini-boss, not full boss** — approve for the internal MVP, with the Blueprint's dungeon+boss gate still governing the public slice (§15.1)?
6. **No consumables/inventory in MVP** — approve health regen + checkpoint restore instead?
7. **Session-only records** — confirm persistence stays deferred per Addendum §3.10?
8. **Cosmetic parity** — confirm the co-op alcove cosmetic must also be solo-obtainable?

## 13. Acceptance criteria for the future implementation phase

**Not claims about current state.** These are gates for a later implementation task.

### 13.1 Functional

- [ ] A first-time player reaches the tool cache and equips the Drawline **without reading a tutorial**.
- [ ] Both descents complete solo with a standard avatar and **no tool**.
- [ ] Weight & Drum solvable solo (bar) and co-op (lever); wrong order gives legible feedback and a free retry.
- [ ] Rust clamp has **two** authored solutions, neither requiring a party.
- [ ] Gate opens and **stays** open; state survives player death and rejoin within the session.
- [ ] Slagbound requires bait → dodge → Yank → strike; **HP identical for 1 and 4 players**.
- [ ] Secret reachable solo; cosmetic granted once per player.
- [ ] Rematch unlocks on first clear and applies its modifier.
- [ ] Full loop completes solo in 10–15 min with no softlock.

### 13.2 Multiplayer

- [ ] 2–4 players complete the slice; no player-count gate anywhere.
- [ ] Disconnect during lever-hold, mid-Yank and mid-encounter leaves no softlock.
- [ ] Late joiner receives correct gate/drum/clamp/encounter state.
- [ ] Personal rewards cannot be taken or overwritten by another player.
- [ ] No player can permanently block another's progression.

### 13.3 Technical

- [ ] All consequential state server-validated; remotes carry intent + stable IDs only.
- [ ] Lifecycle guarantees unchanged: `CharacterAutoLoads=false` before any yield, player-driven respawn, single in-flight load, exactly-once reset gate, recap ordering.
- [ ] No DataStore introduced.
- [ ] No empty placeholder services.
- [ ] Lune tests, Habitat validator and Rojo build green in CI.

### 13.4 Quality

- [ ] An external tester states the puzzle rule unprompted after solving.
- [ ] An external tester names the gate opening as the highlight.
- [ ] An external tester voluntarily attempts the rematch or invites a friend.
- [ ] Studio validation performed on desktop, mobile and gamepad, with 2-player replication.

## 14. Relationship to the long-term matrix

MVP coverage against the 46-family matrix [V-4ab5ce4]: open-world exploration (compact), core movement, physics interactions, environmental systems, combat controls, weapons (one tool), enemy archetypes (one), health/healing, NPCs, main quest, collectibles/secrets, progression/unlocks, death/checkpoints, party foundation, repeatable challenge (rematch).

**Partial:** mini-boss (not a full boss), vertical exploration (none in MVP), audio/atmosphere.

**Deferred, still in the matrix:** map/navigation, climbing, gliding, swimming, mounts, stamina, weather, stealth, elites, dungeons, keys/dungeon tools, dungeon map, shrines, side quests, economy, journal, armour, consumables, cooking, crafting, NG+, photo/emotes, procedural generation, live-ops.

**No family is removed from the long-term inventory by this document.**

## 15. Documentation consistency

Existing documents are **not rewritten** by this task. Conflicts and required future updates:

### 15.1 Blueprint v4.0 — first *public* vertical slice

Blueprint §4 requires the first public-facing slice to include a compact dungeon and a memorable mini-boss or boss, plus ≥2 routes, a tool reward and a replayable layer. [V-4ab5ce4]

**This MVP is smaller** (no dungeon; mini-boss only). [D] Resolution proposed: treat "The Slack Line" as an **internal MVP stepping stone** that proves the identity and the verb, with Tier 3 delivering the Blueprint-compliant public slice. **The Blueprint's acceptance gate still governs the public release.** Owner approval required (§12.3 Q5). If the owner instead wants full Blueprint compliance immediately, Tier 3 must be pulled into scope and the MVP enlarged accordingly.

### 15.2 Roadmap v4.0

Roadmap Phase 2 targets the full slice. This document inserts an intermediate MVP milestone. **Future update:** add the MVP tier and its dependency order to the Roadmap once approved. Not edited here.

### 15.3 Habitat description in README

README describes the First Habitat as a habitat "for a tiny creature in an oversized world" and marks it a historical prototype. [V-4ab5ce4] §4.1's standard-avatar requirements may be incompatible. **Future update:** belongs to M1's outcome, not this document.

### 15.4 Document naming

At `4ab5ce4`, v4.0 content lived in files named `Product Vision v2.0 …` and `GDD v2.2 …`. [V-4ab5ce4] Whether #46 renamed them is **unknown [U]**. **Future update:** confirm filenames and repair cross-links; do not assume either naming here.

### 15.5 Terminology preserved

"Vertical slice", "MVP contract", "mechanic family", "Player Identity", "Current Life", "LifeBegan/LifeEnded", "exactly-once reset", "player-driven respawn" — all retained as-is.

## 16. Summary

**The Slack Line** is a 10–15 minute quarry adventure: descend into a place that stopped mid-shift, recover a cable tool, learn that *the gate rises only while the weight hangs free and the drum is locked*, open the gate, and put down what was behind it. One verb, one legible rule, one causal payoff. Solo-complete, co-op-additive, replayable through a rematch and a missed secret. No stats, no grind, no monetization in the core.

**Nothing here is implemented.** M1 foundation validation remains the prerequisite.
