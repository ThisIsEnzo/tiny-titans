# Tiny Titans — Master Roadmap

**Version:** 2.0  
**Date:** 2026-11-15  
**Status:** Active execution roadmap; Hybrid Creature Exploration RPG direction approved by owner.  
**Repository:** ThisIsEnzo/tiny-titans  
**Default branch:** master

This is the single execution roadmap. Product Vision defines why and the long-term ambition; Gameplay Blueprint defines the game and MVP contract; Evolution Sandbox Architecture plus the Progression & Legacy Architecture Addendum define technical boundaries. A future idea in any document is not implementation approval unless it appears in the active phase scope below.

## 1. Product outcome

Build a co-op-friendly **Hybrid Creature Exploration RPG** in which the player is a tiny creature in an oversized living ecosystem. Exploration, traversal, creature evolution and meaningful discoveries are the foundation. Light RPG progression, Bestiary, companions and a personal Habitat deepen the experience only after the core loop is proven.

The ambition is a commercially sustainable, high-quality Roblox experience with a credible path toward Top 1000. This is an ambition, not a forecast or guarantee.

## 2. Current verified baseline

As of the master state inspected for this roadmap:

- master contains the merged product direction and MVP documents (PR #35).
- First Habitat greybox is merged (PR #36): Nest, Meadow, Rock Garden, Giant Roots and Secret route; generated Rojo model data and offline validator.
- Existing systems include lifecycle tracking/reset, controlled respawn and minimal life recap, Biomass/growth, data-driven creature and ability definitions, evolution UI, Baby Bug visual and the Glider Air Glide prototype.
- Current forms: Baby Bug, Tank and Glider. Tank's Defensive Shell is visual-only; Glider is a bounded three-second air-glide prototype and is not yet an accepted traversal role.
- Food remains identical FoodSpawn pickups that grant Biomass. The current README describes exact cap, respawn and life behavior.
- Persistent Legacy, Naturalist XP, Mastery, quests, foraging variety, companions, Habitat building, combat/PvE encounters, DataStore and monetization are not implemented.
- First Habitat Studio validation remains pending. CI, static validation or merged PRs do not prove collision correctness, fun, balance or player retention.

Treat README and source on current master as implementation truth. This snapshot must be refreshed when work is resumed; do not carry statuses forward blindly.

## 3. Non-negotiable delivery rules

- One independent task = one feature branch = one PR.
- Default branch is master; never work directly on it.
- Claude Code must not merge PRs.
- Keep one outcome per PR and update the roadmap only with evidence.
- Run Lune tests and Rojo build where available; report what was actually executed.
- Roblox Studio validation is required for runtime physics, camera, collision, input, mobile/gamepad and multiplayer behavior.
- Never equate code merged, CI green or an offline validator passing with a fun or validated game.
- Prefer direct documentation/code changes by the project owner or assistant where possible; use Claude Code for repository-local implementation.
- Keep the scope of TT-P3-02 unchanged by this vision update.

## 4. Active pre-MVP phases

### Phase 0 — Foundation and uncertainty reduction

**Outcome:** know what works and remove critical technical uncertainty.

- Keep lifecycle, reset, recap, Biomass, growth and evolution behavior stable.
- Run existing automated checks and build in the available development environment.
- Complete deferred Studio checks for spawn, camera, Baby Bug visuals, growth, lifecycle and multiplayer isolation.
- Record Glider activation/physics limitations and Tank's visual-only status honestly.
- Observe new players and capture friction, confusion, fun moments and reasons to continue.

**Exit gate:** no launch-blocking lifecycle/input defect; limitations documented; a real player can enter and control the creature.

### Phase 1 — Exploration and form identity vertical slice

**Outcome:** First Habitat becomes a small adventure worth exploring more than once.

Active work:
1. TT-P3-01 First Habitat greybox — merged PR #36; physical Studio validation pending.
2. TT-P3-02 Exploration Gameplay Loop — implement a small discovery/landmark loop using existing systems only; keep the approved scope narrow.
3. Define a compact repeatable exploration activity or route challenge after discovery.
4. Prove Baby Bug as the baseline and give Tank/Glider meaningful, testable world use cases. Ability implementation remains separately scoped and must meet the ability design contract.
5. Tune onboarding, camera, movement, navigation and reward feedback based on observation.

Do not add Naturalist Rank, persistent quests, Mastery, new currencies, companions or Habitat building in this phase.

**Exit gate:** a first-time player understands the immediate goal, discovers multiple points of interest, completes a meaningful activity, can explain the role choices and wants another exploration pass. This requires observed playtests, not code completion alone.

### Phase 2 — RPG and Legacy foundation

**Outcome:** provide understandable long-term goals without power creep or grind.

Only start after Phase 1 passes its product gate.

- Define and implement the versioned Legacy data model and safe DataStore lifecycle.
- Add Naturalist XP and derived Naturalist Rank (one XP track, not a second currency).
- Add Bestiary and permanent discovery records.
- Add the three activity categories: Discoveries, Life Goals and World Challenges.
- Add bounded life history and recap integration.
- Add per-form Creature Mastery only after each form's gameplay role is validated.
- Build idempotent server-authoritative reward claims, persistence retries, migrations and failure recovery.
- Keep Legacy rewards focused on knowledge, identity, cosmetics and optional access—not permanent raw stats.

**Exit gate:** players understand what resets and what persists; data survives death/rejoin and recoverable failures; goals are meaningful without repetitive farming.

### Phase 3 — Living ecosystem and Foraging

**Outcome:** make resources and species feel native to each micro-biome.

- Replace identical visual food balls with real, readable food/resource interactions (for example berries, mushrooms, nectar, seeds and acorns) while preserving clear resource purposes.
- Give each resource a biome/location identity, interaction pattern, availability rule and economy sink/source.
- Add a small number of species with distinct readable behaviors.
- Expand Bestiary with observation/discovery conditions.
- Add a limited set of environmental events or changing resource opportunities.
- Avoid hunger/thirst meters and survival chores unless playtests prove they improve the core fantasy.
- Do not introduce Research Samples as another currency unless a real spend/sink justifies it.

**Exit gate:** players choose routes for resource variety and species discoveries; no single pickup cluster dominates; the ecosystem feels distinct without requiring a huge map.

### Phase 4 — Creature Bonds and Personal Habitat

**Outcome:** create attachment, self-expression and a meaningful home loop.

- Prototype meeting/studying/helping/bonding with a small number of species.
- Companions are optional relationships and utility/support, not a replacement for the player's form.
- Add a modest personal Nest/Habitat with curated modular upgrades and decoration.
- Add only a few meaningful stations or uses; no factory chains or passive automation that replaces play.
- Define ownership, permissions, multiplayer visits and data safety before release.
- Companion utility may reveal resources, assist a small garden or react to clues; it must never be mandatory for progression.

**Exit gate:** players value their Habitat and bonds for attachment and expression, while the main adventure remains enjoyable without owning or optimizing them.

### Phase 5 — Expanded PvE and biome adventures

**Outcome:** add new situations and social stories, not just more map acreage.

- Add Alpha/territorial creatures with readable behaviors and multiple responses (avoid, distract, escape, environmental solution; combat only where designed).
- Add cooperative challenges with complementary roles and a complete solo route.
- Add short World Events that do not punish players for missing a schedule.
- Expand one dense biome at a time, each with new traversal, resources, species and challenges.
- Consider advanced crafting or equipment only when it adds meaningful choices and does not overwhelm the creature identity.

**Exit gate:** each new biome/activity introduces a distinct gameplay verb or decision and supports replayability with measured performance and player value.

### Phase 6 — Public-quality MVP and launch operations

**Outcome:** ship a coherent, polished, safe and measurable first public product.

- Finalize first-session onboarding and UI.
- Polish Baby Bug, Tank and Glider presentation, animation, sound and VFX to the accepted scope.
- Validate touch, keyboard/mouse and gamepad; test low-end mobile performance.
- Complete server-authority, exploit, data safety and Roblox policy reviews.
- Run external playtests and instrument the first-session funnel, activity completion, form choice, return intent and retention.
- Prepare icon, thumbnails, store description, moderation/reporting, support, release and rollback plans.
- Introduce only cosmetic-first monetization after economy and product value are demonstrated.

**Exit gate:** external players understand the game, enjoy the loop, voluntarily return and can name meaningful goals; no launch-blocking technical, security, policy, moderation or performance issue remains.

## 5. Post-MVP live development

After a stable MVP and evidence of audience fit:

- Expand collections, cosmetic expression and seasonal chapters.
- Add more companions and Habitat decoration in sustainable increments.
- Add new forms only when a new gameplay verb is needed and validated.
- Add biomes and Alpha creatures one dense slice at a time.
- Add social visits and cooperative events with safe permissions and solo alternatives.
- Grow creator/community outreach, localization and update cadence from player data.

Deferred and not approved for implementation: breeding/genetics, player trading/marketplace, factories/production chains, guilds, forced PvP, ranked progression, large MMO zones, paid power, paid death protection and mandatory companion systems.

## 6. MVP release gates

| Gate | Current evidence/status |
|---|---|
| Lifecycle/reset/respawn code | Implemented; Studio validation pending |
| Biomass/growth/evolution | Implemented; Studio validation and pacing validation pending |
| Baby Bug visual | Implemented; Studio validation pending |
| Tank gameplay role | Not validated; current shell is visual-only |
| Glider gameplay role | Not validated; Air Glide prototype only |
| First Habitat | Greybox merged in PR #36; Studio validation pending |
| Exploration discovery loop | Planned as TT-P3-02; not yet evidenced as fun |
| Repeatable activity | Not implemented/accepted |
| Naturalist XP, Rank, Bestiary and Legacy persistence | Not implemented |
| Foraging variety and living species | Not implemented |
| Companions and personal Habitat | Deferred post-MVP |
| External playtests and retention evidence | Not established |
| Public launch operations | Not started |

Do not calculate a single overall MVP percentage from merged PR count. Report gate evidence and blockers.

## 7. PR and branch workflow

- Default branch: master.
- One independent task = one feature branch = one PR.
- Claude Code must not work directly on master and must not merge PRs.
- Every PR has one outcome, narrow scope, tests, acceptance criteria and a Studio checklist where runtime behavior is involved.
- Record exactly what ran; do not fabricate checks.
- Product design approval precedes implementation.
- The project owner reviews and merges.

## 8. Decision log

- **2026-11-13:** Product direction consolidated as a co-op-friendly PvE creature-evolution exploration/survival adventure in a miniature living ecosystem.
- **2026-11-14:** First Habitat greybox merged as PR #36; physical Studio validation remains pending.
- **2026-11-15:** Owner approved the long-term identity **Hybrid Creature Exploration RPG**.
- **2026-11-15:** Naturalist XP is the one persistent general XP track; Naturalist Rank is derived from it, not a separate currency.
- **2026-11-15:** Progression layers are Biomass/Growth (Current Life), Evolution (form choice), Naturalist XP/Rank, per-form Mastery and Legacy.
- **2026-11-15:** Palworld-inspired creature bonds/companions and personal Habitat are long-term post-MVP hypotheses; factories, breeding, trading and MMO scale remain deferred.
- **2026-11-15:** TT-P3-02 remains a narrow exploration loop task and is not expanded by this vision update.
