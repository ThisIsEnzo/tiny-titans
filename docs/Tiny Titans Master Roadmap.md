# Tiny Titans — Master Roadmap v4.0

**Date:** 2026-11-19  
**Status:** Active strategic roadmap; product direction approved, new scope requires task-level design and evidence.  
**Repository:** ThisIsEnzo/tiny-titans  
**Default branch:** master

This is the single execution roadmap. Product Vision v4.0 defines the product north star; GDD v4.0 defines the experience; Zelda Mechanics Adaptation Matrix inventories the intended mechanic families; Gameplay Blueprint defines the first vertical slice; this document controls execution order.

## 1. Product outcome

Build an original Roblox action-adventure with the breadth and depth of Zelda gameplay, designed from the beginning for replayability and playing with friends.

The game includes exploration, traversal, combat, puzzles, tools, items, equipment, dungeons, bosses, NPCs, quests, secrets and progression. It combines open-world freedom with authored classic-style dungeons and regional adventures.

The player uses their standard Roblox avatar. Solo and co-op are first-class; every essential progression step must have a solo solution. Co-op should add coordination and shared stories, not merely more enemy health.

This is not a small-creature simulator or ecological restoration game. No miniature ecosystem requirement remains. The world, scale, fiction and visual identity are original design choices.

## 2. Current verified implementation baseline

**Repository snapshot checked:** `master` at `59db0e4eca571e55a1730a33236c5b26de8739d5` (PR #45, 2026-11-20).

The following are verified repository facts, not evidence that the adventure is already playable:
- PR #40 (product direction), #41 (standard Roblox avatar restoration), #43 (retire legacy avatar scaling), #44 (legacy runtime retirement) and #45 (legacy prototype cleanup) are merged into `master`.
- The active runtime retains the lifecycle/reset, controlled respawn and life recap foundation. The old Biomass/growth, food pickup, discovery, evolution/form and Baby Bug presentation prototype has been retired from active source.
- The standard Roblox avatar is the canonical player character in product direction and active runtime source. This is a source-level statement, not a claim of Studio validation.
- First Habitat remains a legacy greybox with 199 retained parts and an offline geometry validator. It is not an approved first adventure region.
- No complete adventure combat loop, authored enemy roster, dungeon, boss, adventure tool progression, quest chain or replayable co-op activity is established by the current implementation baseline.
- Roblox Studio checks for avatar presentation, camera, collision, traversal, respawn and multiplayer remain pending unless separately evidenced.

Refresh this baseline from `master` and current PRs before starting each new task. Never treat this roadmap as proof of implementation.

## 3. Delivery rules

- One independent task = one feature branch = one PR.
- Default branch is master; never work directly on master.
- Claude Code works only in the local workspace/archive. It must not perform GitHub authentication, create branches, push, open PRs or merge.
- The assistant may perform repository documentation/GitHub operations directly when appropriate.
- User reviews and merges PRs. Assistant does not merge.
- Keep each PR narrowly scoped, update docs when decisions change, and report exactly what validation ran.
- Lune tests, static checks and Rojo build do not prove Roblox Studio behavior.
- Studio validation is mandatory for physics, camera, animation, UI, input, replication, multiplayer and performance.
- Do not start dependent work until its prerequisite is merged or explicitly available in the task workspace.

## 4. Phase 0 — Stabilize the Roblox foundation

**Outcome:** a reliable Roblox-avatar foundation and an honest understanding of the retained runtime and greybox.

**Completed in source/history:** PR #40 product direction, #41 standard-avatar restoration, #43 avatar-scaling retirement, #44 legacy runtime retirement and #45 legacy prototype cleanup are merged. The active code no longer depends on the retired creature/Biomass prototype.

**Remaining validation tasks:**
1. In Roblox Studio, verify standard avatar appearance, animation, clothing/accessories, spawn/respawn, camera, collision and multiplayer visibility.
2. Audit First Habitat geometry and routes with standard Roblox avatar dimensions and target devices. Treat it as a legacy greybox; retain or replace it based on the audit, not sunk cost.
3. Identify reusable interaction, lifecycle, networking and UI infrastructure from current source. Do not recreate systems that already exist.
4. Record Studio findings and any required corrections before treating the foundation as validated.

**Exit gate:** standard avatar and lifecycle behavior are verified in Studio on representative devices; the retained foundation and greybox decisions are documented. This gate is not complete merely because PRs are merged or CI is green.

## 5. Phase 1 — Adventure foundation

**Outcome:** establish the technical and gameplay foundations required by the Zelda-style design without prematurely building a giant world.

Design and implement in dependency order:
1. Player input and interaction foundation across touch, keyboard/mouse and gamepad.
2. Camera and traversal baseline with responsive movement and consistent Roblox avatar behavior.
3. Server-authoritative interaction framework for world objects, tools and puzzle mechanisms.
4. Combat foundation: target/aim model, attacks, defensive actions, hit validation, feedback and enemy state.
5. Item/tool data model and minimal inventory/equipment UX.
6. Enemy archetype framework with readable state/telegraph/counterplay patterns.
7. Shared activity/party state model, solo fallback rules, late join and disconnect recovery.
8. Automated tests and Studio test harnesses for the foundations above.

Do not create generic frameworks for systems that have no authored use case. Each foundation task must support a concrete vertical-slice feature.

## 6. Phase 2 — First adventure vertical slice

**Outcome:** one compact, polished adventure that demonstrates why Tiny Titans is a Zelda-style Roblox game and why friends want to play it together.

Target slice:
- one original region with a strong visual identity, landmarks, at least two routes and optional secrets;
- one NPC/quest hook and a readable regional objective;
- a small roster of distinct enemies and one satisfying combat encounter;
- one authored multi-step environmental puzzle;
- one compact dungeon/challenge with a coherent mechanical language;
- one mini-boss or boss with readable phases and solo/co-op behavior;
- one useful reward/tool that changes how the player traverses, fights or solves;
- solo completion and meaningful co-op coordination for a target party of 1–4 players;
- party architecture that avoids hard-coded assumptions where practical, with 5–8 player support treated as a later scale-up target requiring dedicated encounter, UI, replication and performance validation;
- one repeatable challenge, boss rematch or optional activity;
- cross-platform input, UI and multiplayer validation.

**Exit gate:** external playtesters understand the adventure, enjoy traversal/combat/puzzles, can finish solo or with friends, and express a concrete desire to return or invite someone. Studio validation and performance checks pass on representative devices.

## 7. Phase 3 — Expand the adventure

**Outcome:** turn the vertical slice into a coherent world.

- Add regions with distinct traversal rules, enemies, stories and secrets.
- Add handcrafted dungeons with unique mechanical identities, tools, keys, shortcuts and bosses.
- Expand weapons, tools, equipment, consumables and upgrade choices.
- Add NPCs, settlements, side quests, merchants and world events.
- Expand traversal verbs only where they unlock authored routes and puzzle/combat interactions.
- Add optional collections, challenge variants and boss rematches.
- Maintain solo parity and meaningful co-op behavior in every region.
- Validate content cadence and production cost before increasing world size.

## 8. Phase 4 — Replayability and long-term progression

**Outcome:** create durable reasons to return without relying on grind.

Candidate systems, gated by playtest evidence:
- repeatable dungeon/challenge variants;
- boss rematches, mastery challenges and optional modifiers;
- meaningful equipment/loadout variety;
- optional region completion and collections;
- curated rotating activities or world events;
- persistent adventure records and achievements;
- account progression that rewards exploration/mastery without permanent power creep;
- party goals and social activities;
- New Game Plus or campaign replay only if the base campaign supports it.

Define persistence ownership, party progress, inventory, guest rewards, death/loss and disconnect recovery before DataStore implementation.

## 9. Phase 5 — Live game and sustainable growth

**Outcome:** operate a high-quality Roblox adventure with a sustainable content and monetization model.

- Cosmetic-first monetization and transparent supporter products.
- No paid combat power, mandatory access, paid revives or artificial frustration.
- Instrument onboarding, goal comprehension, activity completion, voluntary return, party formation and friend invites.
- Use D1/D7/D30 and qualitative playtest evidence; do not optimize session time alone.
- Release new regions, dungeons, bosses, quests and challenge variants at a sustainable pace.
- Build moderation, exploit response, support and live-ops processes appropriate to actual scale.

## 10. Immediate next actions

Do not continue TT-P3-03 or the old ecological interaction chain; that work belongs to the superseded creature/ecosystem premise.

Immediate sequence:
1. Complete the standard-avatar and lifecycle Studio validation; do not claim it is complete until evidence exists.
2. Audit current source and First Habitat against the Zelda-style adventure contract and decide whether the greybox is reusable.
3. Produce/review the first vertical-slice design: region, player verbs, enemies, combat loop, puzzle, dungeon, boss, reward/tool and solo/co-op behavior.
4. Keep the first slice focused on solo plus 1–4 player co-op. Evaluate 5–8 player support as a separate scalability decision after encounter and performance evidence.
5. Break the approved slice into small dependency-ordered implementation PRs.

## 11. Scope and quality rules

- Design the broad Zelda mechanic landscape, implement in deliberate slices.
- Do not attempt to ship every mechanic in one release.
- Do not create a giant empty world before the first region is fun.
- Do not turn co-op into mandatory party gates or health-sponge scaling.
- Do not add currencies, crafting, trading, procedural generation or live-ops without proven need.
- Do not confuse a Roblox prototype, green CI or a merged PR with a validated adventure.
- Every essential feature must have a solo path and cross-platform controls.
