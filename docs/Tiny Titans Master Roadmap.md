# Tiny Titans — Master Roadmap

**Version:** 2.2  
**Date:** 2026-11-15  
**Status:** Active execution roadmap; personalized Tiny Titan direction approved by owner.  
**Repository:** ThisIsEnzo/tiny-titans  
**Default branch:** master

This is the single execution roadmap. Product Vision v2.2 defines the north star; GDD v2.2 defines the detailed experience contract; Gameplay Blueprint defines the first playable product; Player Identity & Adaptation Architecture defines future character/adaptation technical boundaries.

## 1. Product outcome

Build a co-op-friendly **Creature Exploration RPG** in which each player inhabits one personal Tiny Titan in an oversized living ecosystem. Exploration, traversal, discovery, collection and attachment to the player's creature are the foundation. RPG progression, adaptations, companions and a personal Habitat deepen the experience only after the core loop is proven.

The game does not require combat. Danger may come from environmental conditions and living creatures, with non-combat responses such as observation, avoidance, hiding, distraction and escape.

The ambition is a commercially sustainable, high-quality Roblox experience with a credible path toward Top 1000. This is an ambition, not a forecast or guarantee.

## 2. Current verified baseline

As of the master state inspected for this roadmap:
- First Habitat greybox is merged (PR #36): Nest, Meadow, Rock Garden, Giant Roots and Secret route; generated Rojo model data and offline validator.
- Existing systems include lifecycle tracking/reset, controlled respawn and minimal life recap, Biomass/growth, data-driven creature and ability definitions, evolution UI, Baby Bug visual and Glider Air Glide prototype.
- Current code still contains the prototype form model (BABY_BUG, TANK, GLIDER) and related UI/abilities. **This is implementation history, not the approved product model.** Approved direction is one persistent player identity; adaptations are not yet designed or approved for implementation.
- Tank Defensive Shell is visual-only; Glider is a bounded three-second air-glide prototype and is not an accepted adaptation.
- Food remains identical FoodSpawn pickups that grant Biomass.
- Persistent Legacy, Naturalist XP, Mastery, quests, foraging variety, companions, Habitat, combat/PvE encounters, DataStore and monetization are not implemented.
- First Habitat Studio validation remains pending. CI, static validation or merged PRs do not prove collision correctness, fun or retention.

Treat README and source on current master as implementation truth. Refresh this snapshot when work resumes.

## 3. Delivery rules

- One independent task = one feature branch = one PR.
- Default branch is master; never work directly on it.
- Claude Code must not merge PRs.
- Keep one outcome per PR and update the roadmap only with evidence.
- Run Lune tests and Rojo build where available; report exactly what ran.
- Studio validation is required for runtime physics, camera, collision, input, device and multiplayer behavior.
- Never equate merged code, green CI or offline validation with fun or a validated game.
- Prefer direct documentation/code changes by the project owner or assistant where possible; use Claude Code for repository-local implementation.
- TT-P3-02 remains narrowly scoped to the exploration loop using existing systems only.

## 4. Active pre-MVP phases

### Phase 0 — Foundation and uncertainty reduction

**Outcome:** know what works and remove critical technical uncertainty.
- Keep lifecycle, reset, recap and Biomass/growth stable while product-facing form/evolution assumptions are reassessed.
- Run existing automated checks and build in the available environment.
- Complete deferred Studio checks for spawn, camera, current creature visual, growth, lifecycle and multiplayer isolation.
- Record current prototype limitations honestly; Tank and Glider are not accepted product roles.
- Observe new players and capture friction, fun moments and reasons to continue.

**Exit gate:** no launch-blocking lifecycle/input defect; limitations documented; a real player can enter and control the current prototype. This does not prove the future character direction.

### Phase 1 — Exploration and personal creature vertical slice

**Outcome:** First Habitat becomes a small adventure worth exploring more than once, and players begin to care about their own Tiny Titan.

1. TT-P3-01 First Habitat greybox — merged PR #36; physical Studio validation pending.
2. **TT-P3-02 Exploration Gameplay Loop:** implement the signature loop (clue → observation → interaction → feedback/record) using the smallest set of authored interactions; no generic quest framework. *Status:* the first technical slice is implemented in PR #38 (open, not merged): clue → location arrival → feedback → per-life record. Six **Expedition Discoveries** (places in First Habitat; each found by entering an invisible server-checked trigger volume, once per life, with a small repeatable-per-life Biomass bonus), a persistent clue hint and counter, a toast and a recap line. These are temporary per-life objectives, **not** permanent Legacy Discoveries (nothing is persisted; the unqualified term "Discoveries" stays reserved for the future permanent knowledge system). This is **not yet the full signature exploration loop**: observation and interaction with objects, species and behavior discovery (item 4), the ecological chain with a visible world response (item 3) and the repeatable exploration challenge (item 5) remain separate future work. Studio validation pending.
3. Build one short ecological story chain with a visible before/after world response (the GDD's “Quiet Glade” is a proposal to validate, not locked lore).
4. Add at least two discovery categories (landmark/place and species/behavior) with clear player feedback; persistent Bestiary/Legacy remains Phase 2 unless a minimal persistence decision is separately approved.
5. Add one compact repeatable route/observation challenge with controlled variants and solo completion.
6. Evaluate current Baby Bug visual only as a temporary presentation prototype; define requirements for one consistent personal Tiny Titan. No full creator or adaptation/loadout system.
7. Tune onboarding, camera, movement, navigation, interaction prompts and feedback through observed playtests.

Do not add Naturalist Rank, persistent quests, Mastery, new currencies, companions, Habitat, combat or a generic adaptation/loadout system in this phase.

**Exit gate:** first-time players understand the immediate goal; discover multiple points of interest; complete the ecological chain; notice and explain its visible outcome; try a second discovery or repeatable activity voluntarily; and navigate the habitat solo. Studio movement/camera/device validation and external playtests are required.

### Phase 2 — RPG and Legacy foundation

**Outcome:** understandable long-term goals without power creep or grind. Start only after Phase 1 passes its product gate.

- Define versioned Legacy data and safe DataStore lifecycle.
- Add Naturalist XP and derived Naturalist Rank.
- Add Bestiary and permanent discovery records.
- Add Discoveries, Life Goals and World Challenges.
- Add bounded life history and recap integration.
- Design adaptation unlocks only if Phase 1 proves a concrete need for new player verbs; do not recreate separate form classes.
- Consider mastery only for meaningful authored activities/adaptations after validation; no per-form Mastery.
- Build idempotent server-authoritative reward claims, persistence retries, migrations and recovery.
- Keep Legacy rewards to knowledge, identity, cosmetics and optional access, not permanent raw stats.

**Exit gate:** players understand reset/persistence; data survives death/rejoin and recoverable failures; goals are meaningful without repetitive farming.

### Phase 3 — Living ecosystem and Foraging

**Outcome:** resources and species feel native to each micro-biome.
- Replace identical food balls with readable food/resource interactions (berries, mushrooms, nectar, seeds, acorns) with distinct purposes.
- Give each resource a biome identity, interaction, availability and economy sink/source.
- Add a small number of species with distinct readable behaviors.
- Expand Bestiary with observation/discovery conditions.
- Add limited environmental events or changing resource opportunities.
- Consider non-combat interactions: observe, avoid, hide, distract, follow tracks, help or safely approach.
- Avoid hunger/thirst chores unless playtests prove they improve the fantasy.
- Do not introduce Research Samples as another currency without a justified sink.

**Exit gate:** players choose routes for resource variety and species discoveries; no pickup cluster dominates; ecosystem feels distinct without a huge map.

### Phase 4 — Creature Bonds and Personal Habitat

**Outcome:** attachment, self-expression and a meaningful home loop.
- Prototype meeting/studying/helping/bonding with a small number of species.
- Companions are optional relationships and utility, not a replacement for the player's Tiny Titan and never mandatory.
- Add a modest personal Nest/Habitat with curated modular upgrades and decoration.
- Add only a few meaningful stations; no factories or passive automation replacing play.
- Define ownership, permissions, multiplayer visits and data safety.
- Companion utility may reveal resources/clues or react to the world, but cannot be mandatory.

**Exit gate:** players value Habitat and bonds for attachment/expression while the main adventure remains enjoyable without them.

### Phase 5 — Expanded ecosystem, encounters and biomes

**Outcome:** new situations and social stories, not just more map acreage.
- Add territorial creatures and authored encounters with non-combat responses (observe, avoid, distract, hide, escape, environmental solution).
- Add cooperative challenges with complementary contributions and a complete solo route.
- Add short World Events that do not punish players for missing a schedule.
- Expand one dense biome at a time, each with new traversal, resources, species and challenges.
- Combat is **not assumed**. Consider it only if playtests reveal a compelling need that non-combat interaction cannot serve; this requires a separate product decision.
- Add crafting/equipment only when it creates meaningful choices without overwhelming creature identity.

**Exit gate:** each new biome/activity introduces a distinct verb or decision and supports replayability with measured player value.

### Phase 6 — Public-quality MVP and launch operations

**Outcome:** ship a coherent, polished, safe and measurable public product.
- Finalize first-session onboarding and UI.
- Polish personal Tiny Titan presentation, animation, sound and VFX.
- Validate touch, keyboard/mouse and gamepad; test low-end mobile performance.
- Complete server-authority, exploit, data safety and Roblox policy reviews.
- Run external playtests and instrument first-session funnel, discovery/activity completion, customization engagement, return intent and retention.
- Prepare icon, thumbnails, store description, moderation/reporting, support, release and rollback plans.
- Introduce cosmetic-first monetization only after player value and economy are demonstrated.

**Exit gate:** external players understand the game, enjoy the loop, voluntarily return and can name meaningful goals; no launch-blocking technical, security, policy, moderation or performance issue remains.

## 5. Post-MVP live development

After stable MVP and evidence of audience fit:
- Expand collections, cosmetic expression and seasonal chapters.
- Add companions and Habitat decoration incrementally.
- Add adaptations only when a new gameplay verb is needed and validated.
- Add biomes and ecosystem encounters one dense slice at a time.
- Add social visits and co-op events with safe permissions and solo alternatives.
- Grow creator/community outreach, localization and update cadence from player data.

Deferred: breeding/genetics, player trading/marketplace, factories, guilds, forced PvP, ranked progression, large MMO zones, paid power, paid death protection and mandatory companions.

## 6. MVP release gates

| Gate | Current evidence/status |
|---|---|
| Lifecycle/reset/respawn | Implemented; Studio validation pending |
| Biomass/growth | Implemented; Studio and pacing validation pending |
| Current creature visual | Baby Bug visual prototype exists; not accepted as final identity; Studio validation pending |
| Personal Tiny Titan customization | Direction approved; not implemented |
| Adaptations | Not approved for MVP; old Tank/Glider abilities are prototypes only |
| First Habitat | Greybox merged PR #36; Studio validation pending |
| Exploration discovery loop | First technical slice in PR #38 (open): per-life Expedition Discoveries (clue → arrival → feedback → per-life record); not the full signature loop; Studio validation pending; not evidenced as fun |
| Repeatable activity | Not implemented/accepted |
| Naturalist XP, Rank, Bestiary, Legacy | Not implemented |
| Foraging variety and living species | Not implemented |
| Companions and personal Habitat | Post-MVP |
| External playtests and retention evidence | Not established |
| Public launch operations | Not started |

Do not calculate a single overall MVP percentage from merged PR count. Report evidence and blockers.

## 7. PR and branch workflow

Default branch master; one independent task per feature branch and PR; Claude Code must not work directly on master or merge PRs. Every PR has one outcome, narrow scope, tests, acceptance criteria and a Studio checklist where runtime behavior is involved. The project owner reviews and merges.

## 8. Decision log

- **2026-11-13:** Product direction consolidated as co-op-friendly PvE creature exploration in a miniature living ecosystem.
- **2026-11-14:** First Habitat greybox merged as PR #36; physical Studio validation pending.
- **2026-11-15:** Owner approved **Creature Exploration RPG** centered on one personal Tiny Titan per player.
- **2026-11-15:** Separate Baby Bug / Tank / Glider playable forms are retired as product direction. Their useful ideas may be reconsidered as optional adaptations after real world use cases are proven.
- **2026-11-15:** Combat is not required for danger, replayability or MVP; environmental and creature threats should support non-combat responses.
- **2026-11-15:** Naturalist XP is the one persistent general XP track; Rank is derived, not a separate currency.
- **2026-11-15:** Progression layers are Biomass/Growth, Naturalist XP/Rank, Legacy, and future optional adaptations/mastery.
- **2026-11-15:** Bonds/companions and personal Habitat are post-MVP hypotheses; factories, breeding, trading and MMO scale remain deferred.
- **2026-11-15:** TT-P3-02 remains a narrow exploration-loop task using existing systems only; its detailed discovery/eco-story vertical-slice contract is in GDD v2.2 and Gameplay Blueprint v2.2.
- **2026-11-15:** Owner selected the hybrid direction with one unified long-term goal: explore, understand and gradually reconnect ecosystems while building a personal legacy.
- **2026-11-15:** “The Quiet Glade” is a proposed first ecological story example, not locked world canon.
- **2026-11-15:** Restoration must produce visible local world feedback; a progress bar alone is insufficient.
