# Tiny Titans — Master Roadmap

**Version:** 3.0  
**Date:** 2026-11-19  
**Status:** Active execution roadmap; Zelda-inspired hybrid adventure and standard Roblox avatar approved by owner.  
**Repository:** ThisIsEnzo/tiny-titans  
**Default branch:** master

This is the single execution roadmap. Product Vision v3.0 defines the north star; GDD v3.0 defines the detailed adventure contract; Gameplay Blueprint defines the first playable product; Player Identity & Adaptation Architecture defines the Roblox-avatar boundary.

## 1. Product outcome

Build a **Zelda-inspired living-world adventure** in an original miniature ecosystem. Players explore as their standard Roblox avatars, observe natural clues, solve ecological puzzles, discover secrets and compact challenges, and see the world respond. The same adventure must be complete solo and equally enjoyable in co-op. Regional progression, Bestiary, collections and future RPG systems deepen the experience only after the first adventure is proven.

The game does not require combat. Danger may come from environmental conditions and living creatures, with non-combat responses such as observation, avoidance, hiding, distraction and escape.

The ambition is a commercially sustainable, high-quality Roblox experience with a credible path toward Top 1000. This is an ambition, not a forecast or guarantee.

## 2. Current verified baseline

As of the master state inspected for this roadmap:
- First Habitat greybox is merged (PR #36): Nest, Meadow, Rock Garden, Giant Roots and Secret route; generated Rojo model data and offline validator.
- Existing systems include lifecycle tracking/reset, controlled respawn and minimal life recap, Biomass/growth, data-driven creature and ability definitions, evolution UI, Baby Bug visual prototype and Glider Air Glide prototype. The Baby Bug visual is retired as the player character; standard Roblox avatar presentation is now canonical.
- Current code still contains the prototype form model (BABY_BUG, TANK, GLIDER), Baby Bug appearance replacement and related UI/abilities. **This is implementation history, not the approved product model.** Approved direction is the standard visible Roblox avatar with its normal animation stack. Runtime restoration is a separate implementation task and is not yet complete.
- Tank Defensive Shell is visual-only; Glider is a bounded three-second air-glide prototype. Neither is currently an approved player ability.
- Food remains identical FoodSpawn pickups that grant Biomass.
- Persistent Legacy, Naturalist XP, Mastery, quests, foraging variety, companions, Habitat, combat/PvE encounters, DataStore and monetization are not implemented.
- First Habitat Studio validation remains pending. Roblox-avatar movement, camera, collision, animation and accessory compatibility must be validated after avatar restoration. CI, static validation or merged PRs do not prove runtime correctness, fun or retention.

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
- TT-P3-02 is merged. TT-P3-03 is the next planned slice: a compact, server-authoritative ecological observation and interaction chain in Meadow. Implement it as the first authored puzzle-like adventure interaction, not as a generic quest framework.

## 4. Active pre-MVP phases

### Phase 0 — Foundation and uncertainty reduction

**Outcome:** know what works and remove critical technical uncertainty.
- Keep lifecycle, reset, recap and Biomass/growth stable while product-facing form/evolution assumptions are reassessed.
- Run existing automated checks and build in the available environment.
- Restore the standard Roblox avatar (visible body and standard animation stack); complete Studio checks for spawn, camera, avatar movement, collision, accessories, growth, lifecycle and multiplayer isolation.
- Record current prototype limitations honestly; Tank and Glider are not accepted product roles.
- Observe new players and capture friction, fun moments and reasons to continue.

**Exit gate:** no launch-blocking lifecycle/input defect; limitations documented; a real player can enter and control the current prototype. This does not prove the future character direction.

### Phase 1 — First Adventure Vertical Slice

**Outcome:** First Habitat becomes a compact Zelda-inspired adventure worth exploring more than once, played as a standard Roblox avatar in solo or co-op.

1. TT-P3-01 First Habitat greybox — merged PR #36; physical Studio validation pending.
2. **TT-P3-02 Exploration Gameplay Loop:** *Merged in PR #38 on 2026-11-17* (merge commit `7e0fc39de32770076bce2f5b7df716b53141223d`). The first technical slice is implemented: clue → location arrival → feedback → per-life record. Six **Expedition Discoveries** (places in First Habitat; each found by entering an invisible server-checked trigger volume, once per life, with a small repeatable-per-life Biomass bonus), a persistent clue hint and counter, a toast and a recap line. These are temporary per-life objectives, **not** permanent Legacy Discoveries (nothing is persisted; the unqualified term "Discoveries" stays reserved for the future permanent knowledge system). This is **not yet the full signature exploration loop**: observation and interaction with objects, species and behavior discovery (item 4), the ecological chain with a visible world response (item 3) and the repeatable exploration challenge (item 5) remain separate future work. Studio validation pending.
3. Build one short ecological story chain with a visible before/after world response (the GDD's “Quiet Glade” is a proposal to validate, not locked lore).
4. Add at least two discovery categories (landmark/place and species/behavior) with clear player feedback; persistent Bestiary/Legacy remains Phase 2 unless a minimal persistence decision is separately approved.
5. Add one compact repeatable route/observation challenge with controlled variants and solo completion.
6. Restore and validate standard Roblox avatar presentation, animation, camera and traversal. No Baby Bug replacement, full creator or adaptation/loadout system.
7. Add a small authored adventure challenge with an optional secret/alternate route; prove the Notice → Observe → Interpret → Experiment → Act → World Response loop.
8. Tune onboarding, camera, movement, navigation, interaction prompts and feedback through observed playtests.

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
| Player character | Standard Roblox avatar is approved; runtime restoration and Studio validation pending |
| Roblox avatar presentation | Standard avatar restoration not yet implemented/Studio-validated |
| Adaptations | Not approved for MVP; old Tank/Glider abilities are prototypes only |
| First Habitat | Greybox merged PR #36; Studio validation pending |
| Exploration discovery loop | TT-P3-02 merged in PR #38: per-life Expedition Discoveries (clue → arrival → feedback → per-life record); not the full signature loop; Studio validation pending; not evidenced as fun |
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
- **2026-11-15:** Owner approved Creature Exploration RPG as the interim product direction; superseded by the 2026-11-19 adventure direction.
- **2026-11-19:** Owner approved a Zelda-inspired hybrid living-world adventure with original ecological puzzles, secrets, regional adventures and compact challenges. Zelda is inspiration only; no copying of protected expression or signature content.
- **2026-11-19:** Owner selected complete solo play and equally supported co-op. Essential progression must always have a solo solution.
- **2026-11-19:** Owner selected the standard Roblox avatar as the canonical playable character. Baby Bug custom visual is retired due to poor proportions/animation quality. Runtime restoration is pending a separate code task and Studio validation.
- **2026-11-19:** The miniature fantasy must be communicated primarily by oversized environments, props, creatures and camera framing; do not replace or arbitrarily scale the Roblox avatar as a shortcut.
- **2026-11-15:** Combat is not required for danger, replayability or MVP; environmental and creature threats should support non-combat responses.
- **2026-11-15:** Naturalist XP is the one persistent general XP track; Rank is derived, not a separate currency.
- **2026-11-15:** Progression layers are Biomass/Growth, Naturalist XP/Rank, Legacy, and future optional adaptations/mastery.
- **2026-11-15:** Bonds/companions and personal Habitat are post-MVP hypotheses; factories, breeding, trading and MMO scale remain deferred.
- **2026-11-17:** TT-P3-02 merged as PR #38 (merge commit `7e0fc39de32770076bce2f5b7df716b53141223d`). The merged slice is per-life Expedition Discoveries only; it does not complete the signature exploration loop.
- **2026-11-19:** Unified adventure goal: explore, understand and gradually reconnect ecosystems while uncovering the mysteries that connect regions.
- **2026-11-15:** “The Quiet Glade” is a proposed first ecological story example, not locked world canon.
- **2026-11-17:** TT-P3-03 initial ecological interaction slice is scoped to the existing Meadow puddle area: a blocked channel and nearby wilted flower, two deliberate observations, one server-validated clearing interaction, and a shared visible water/flower response. Dewdrop Glade remains a separate secret area; no Biomass reward or persistence is included by default.
- **2026-11-15:** Restoration must produce visible local world feedback; a progress bar alone is insufficient.
