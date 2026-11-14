# Tiny Titans — Progression & Legacy Architecture Addendum

**Version:** 2.0  
**Date:** 2026-11-15  
**Status:** Approved product model; technical implementation proposal, not implemented.  
**Companion to:** Evolution Sandbox Architecture  
**Product authority:** Product Vision & Top 1000 Strategy; Gameplay Blueprint & MVP Contract

This addendum updates the long-term progression model after the owner approved the Hybrid Creature Exploration RPG direction. It does not claim that persistent progression, quests, companions or Habitat systems exist in code.

## 1. Authority and compatibility

- README and source on master describe actual implementation.
- Product Vision defines the north star.
- Gameplay Blueprint defines the first playable game and MVP contract.
- Master Roadmap defines execution order.
- The original Evolution Sandbox Architecture remains a useful technical audit, but portions are historical snapshots. This addendum is the current product-level progression contract; it does not silently rewrite historical implementation observations.

## 2. State domains and ownership

| Domain | Lifetime | Owner | Persistence | Purpose |
|---|---|---|---|---|
| Current Life | One lifeId | Existing server gameplay services | Memory only; reset at life end | Biomass, growth stage, selected form, temporary objectives/effects and life stats |
| Evolution catalog | Static/shared definitions | Shared definitions; server validates selection | Versioned game data | Form identity, requirements, abilities and unlock policy |
| Naturalist progression | Player lifetime | Future NaturalistProgressService | Future LegacyService / PersistenceService | Accumulated Naturalist XP and derived Rank |
| Creature Mastery | Player × form | Future MasteryService | Future Legacy record | Meaningful mastery evidence per validated form |
| Legacy | Player lifetime | Future LegacyService | Future PersistenceService | Bestiary, discoveries, achievements, collections, cosmetics and life history |
| Habitat & Bonds | Player lifetime | Future dedicated services | Future versioned persistence | Home layout, upgrades, bonds and companion state |

Do not let a single service own every domain. Existing services retain ownership of existing fields; new services are introduced only when their roadmap phase begins.

## 3. Progression invariants

1. Biomass is a Current Life resource, not player XP, crafting material or premium currency.
2. Growth stage is derived from Biomass; never persist a duplicate independently mutable stage.
3. Evolution selection belongs to the current life. Form definitions are shared data; selected form is temporary.
4. Naturalist XP is the only proposed persistent general XP value. Naturalist Rank is derived from XP and is not separately incremented or spendable.
5. Mastery is per form and based on meaningful actions/challenges, not elapsed time or repeated ability spam.
6. Legacy is knowledge, identity, records and optional access—not permanent raw damage, health, speed, movement or resource multipliers.
7. Discovery/reward claims are idempotent and server-authoritative.
8. A client never supplies its own reward amount, XP total, discovery state, lifeId or final outcome.
9. All essential progression paths remain completable solo.
10. Do not add a new currency without a defined source, sink, cap/inflation plan and clear reason existing records cannot represent the concept.

## 4. Death boundary

At life end, snapshot the recap first, then reset Current Life exactly once for the ending lifeId.

**Reset:** Biomass; derived growth; selected form; current-life objective progress; temporary buffs/effects; life-local ability timers according to the approved lifecycle contract; temporary per-life counters after recap capture.

**Preserve when implemented:** Naturalist XP/Rank; Bestiary; permanent discoveries; achievements; collections; mastery; cosmetics; bounded life history; Habitat; creature bonds.

**Unresolved and not to be implemented by assumption:** inventory materials carried during an expedition, item drops on death, voluntary extraction, partial resource loss, companion behavior when the owner dies or disconnects, and paid recovery. These need explicit product decisions and tests.

The current code's actual reset behavior must be read from README and services. This addendum does not claim persistence is implemented.

## 5. XP and reward pipeline

Future server-side reward flow:

1. Gameplay service observes a validated event (landmark entered, challenge completed, species studied, cooperative contribution).
2. A pure rule module validates eligibility, stable event ID, player/life state and repeat limits.
3. Reward service resolves the event's configured reward class; it never accepts arbitrary reward values from a client.
4. Naturalist XP is awarded only for eligible learning/milestone events and recorded idempotently.
5. Permanent discovery/achievement records are written to Legacy.
6. Life-local rewards (for example Biomass) are routed to the owning Current Life service.
7. UI receives a presentation result for the owner; no client attribute becomes authoritative.

Avoid double-paying a discovery through both a quest and a landmark trigger. Use a stable claim key such as player ID + reward event ID, with lifeId included only for intentionally life-scoped rewards.

## 6. Quest data contract

Three categories:

- **Discovery:** one-time permanent knowledge claim.
- **LifeGoal:** objective scoped to a lifeId; resets on life end.
- **WorldChallenge:** repeatable authored activity with a defined repeat policy, contribution rules and solo completion path.

A quest definition should eventually include a stable ID and category; trigger/progress contract; solo completion conditions; optional cooperative contribution semantics; repeat policy and reset scope; reward class and reward event IDs; server validation requirements; presentation text and hint policy; and tests for duplicate, stale and invalid events.

Do not introduce a generic quest framework during TT-P3-02. Add the smallest model only when Phase 2 starts and actual activities are known.

## 7. Naturalist progression contract

- Store accumulated XP; derive Rank from a versioned threshold curve.
- Threshold changes must not reduce already-earned XP or silently demote a player.
- Award first-time discovery XP once; repeatable activity XP must have authored limits. Do not set arbitrary XP amounts before playtests.
- Rank rewards: cosmetics, titles, optional challenge variants, knowledge and non-power access.
- No permanent combat/traversal multipliers.
- XP curve and award amounts are intentionally unspecified until first-session and return-session data exist.

## 8. Mastery contract

- Track mastery separately for Baby Bug, Tank and Glider only after their role is accepted.
- Award from successful use in authored situations and optional mastery challenges.
- Do not award from simply holding a form, idling, repeatedly activating into empty space or farming a single trivial trigger.
- Rewards are cosmetic/identity or horizontal optional choices with trade-offs.
- Baseline form ability must be fully useful without mastery grind.

## 9. Legacy and persistence contract

Future conceptual Legacy record fields:

- schemaVersion
- naturalistXp
- discoveries: landmarks, secrets, species
- bestiary
- achievements
- collections
- mastery by form
- cosmetics
- bounded lifeHistory
- optional habitat and bonds records in later phases

This is a conceptual schema, not a committed Luau data definition. Do not persist Biomass, current growth stage, selected form, temporary quest progress or raw power bonuses in Legacy.

Before DataStore implementation, specify migrations, bounded history, idempotent merge, retry/backoff, dirty state, failure UX, shutdown flush, overlapping-session behavior and recovery tests. PersistenceService remains the only DataStore caller; LegacyService owns in-memory semantics.

## 10. Palworld-inspired extension boundaries

**Creature bonds:** relationship and trust progression from meeting, studying and helping; no disposable capture inventory as the central loop.

**Companions:** optional, personality-rich, limited active utility. They may help reveal resources/clues or participate in small Habitat activities. They do not replace the player's form, grant mandatory power or automate the main loop.

**Habitat:** personal nest with curated modular decoration and a few useful stations. Start small; avoid unrestricted construction, raids, factories and passive resource printing.

**Alpha creatures/world events:** authored ecosystem encounters with multiple responses and readable counterplay. Combat is optional unless a specific activity is explicitly designed around it.

These are post-MVP product hypotheses, not current implementation scope.

## 11. Security and privacy

- Server validates all progression triggers against authoritative state.
- Owner-private Legacy, inventory and quest details must not be exposed through public Player attributes.
- Remote payloads contain identifiers/intent only; the server resolves rewards.
- Rate-limit requests, reject malformed IDs and make claims idempotent.
- Validate proximity/line-of-sight and current life state for discoveries; never trust a client-reported position as proof.
- Shared rewards require explicit contribution/proximity rules to prevent remote claiming and AFK farming.

## 12. Implementation sequence

1. Phase 1: exploration loop with temporary/session-safe discovery feedback; no persistent RPG progression.
2. Phase 2: Legacy schema and persistence, Naturalist XP/Rank, Bestiary, quest categories and recap.
3. Phase 3: foraging/resource variety and living species.
4. Phase 4: bonds/companions and personal Habitat.
5. Phase 5: Alpha creatures, co-op PvE events and biome expansion.

No part of this addendum expands TT-P3-02.
