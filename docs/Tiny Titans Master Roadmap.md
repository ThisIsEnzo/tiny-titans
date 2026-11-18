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

The following are historical repository facts, not evidence that the new adventure is already playable:
- First Habitat greybox exists (PR #36): Nest, Meadow, Rock Garden, Giant Roots and Secret route; generated Rojo model data and offline validator.
- Existing prototype systems include lifecycle/reset, controlled respawn and life recap, Biomass/growth, discoveries, food pickups, evolution/form code, Baby Bug appearance and Glider ability code.
- The approved player direction is the standard Roblox avatar. PR #41 is the separate runtime restoration change; until merged and Studio-validated, README/source and live PR state must be checked before claiming avatar restoration is complete.
- TT-P3-02 Exploration Gameplay Loop was previously merged as a per-life location discovery prototype. It is not the new adventure progression system and should not be expanded automatically.
- Current First Habitat, Biomass, GrowthService, life recap and discovery features are prototype implementation. They may be reused, replaced or retired only after dependency and product review.
- There is no verified full combat system, enemy roster, dungeon framework, boss framework, adventure inventory, equipment progression, quest system or replayable co-op activity in the described baseline.
- No claim is made that the existing greybox or new avatar direction has passed Roblox Studio validation. Check the live repository and PR state before execution.

Refresh this baseline from master and current PRs before starting each new task. Never treat this roadmap as proof of implementation.

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

**Outcome:** a reliable Roblox-avatar foundation and an honest understanding of the current prototype.

Tasks:
1. Resolve PR #40 documentation direction and PR #41 avatar runtime restoration in the correct order; verify current live state first.
2. Studio-test standard Roblox avatar visibility, animation, clothing/accessories, spawn/respawn, camera, collision and multiplayer visibility.
3. Review GrowthService scale stages and legacy Biomass/life systems against the new adventure direction. Retain, redesign or retire them deliberately; do not assume they belong in the final game.
4. Audit First Habitat geometry and routes with standard Roblox avatar dimensions and target devices. The old habitat was built for a different product premise; do not preserve it merely because it exists.
5. Identify reusable interaction, lifecycle, networking and UI infrastructure. Mark creature/evolution/legacy systems as prototype until approved.

**Exit gate:** the standard avatar is reliable in Studio; current prototype dependencies and reusable systems are documented; a player can enter and control the experience on target devices. No claim of fun or product validation yet.

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
- solo completion and meaningful co-op coordination;
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

Do not continue TT-P3-03 or the old ecological interaction chain automatically. That task was designed for the superseded creature/ecosystem product premise.

Immediate sequence:
1. Complete/review the documentation direction update and ensure PR #40 no longer describes a miniature ecosystem as the core product.
2. Resolve PR #41 and perform the standard-avatar Studio validation; do not claim it is complete until evidence exists.
3. Audit current source and First Habitat against the new Zelda-style adventure contract.
4. Produce a concrete vertical-slice design: region, player verbs, first enemies, combat loop, puzzle, dungeon, boss, reward/tool and co-op behavior.
5. Break the approved slice into small dependency-ordered implementation PRs.

## 11. Scope and quality rules

- Design the broad Zelda mechanic landscape, implement in deliberate slices.
- Do not attempt to ship every mechanic in one release.
- Do not create a giant empty world before the first region is fun.
- Do not turn co-op into mandatory party gates or health-sponge scaling.
- Do not add currencies, crafting, trading, procedural generation or live-ops without proven need.
- Do not confuse a Roblox prototype, green CI or a merged PR with a validated adventure.
- Every essential feature must have a solo path and cross-platform controls.
