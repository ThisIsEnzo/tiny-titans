# Tiny Titans — Progression & Legacy Architecture Addendum

**Version:** 2.1 | **Date:** 2026-11-15  
**Status:** Approved product model; technical implementation proposal, not implemented.  
**Companion to:** Player Identity & Adaptation Architecture  
**Product authority:** Product Vision v2.1; Gameplay Blueprint.

## 1. Authority

README/source describe implementation. Product Vision defines the north star; Gameplay Blueprint the first playable game; Master Roadmap execution order; Player Identity & Adaptation Architecture stable identity/adaptation boundaries. Former Evolution Sandbox Architecture is a superseded historical prototype audit.

## 2. State domains

| Domain | Lifetime | Purpose |
|---|---|---|
| Creature Identity / Appearance | Player lifetime | One personal Tiny Titan and selected visual identity |
| Current Life | One lifeId | Biomass, derived growth, temporary objectives/effects and life stats |
| Naturalist progression | Player lifetime | Naturalist XP and derived Rank |
| Legacy | Player lifetime | Bestiary, discoveries, achievements, collections, cosmetics and life history |
| Adaptation records | Future, if justified | Optional capabilities and meaningful authored progress |
| Habitat & Bonds | Future | Home, relationships and optional companion state |

Introduce services only when their roadmap phase begins.

## 3. Invariants

1. Biomass is Current Life resource, not player XP, crafting material or premium currency.
2. Growth stage is derived from Biomass.
3. One stable Tiny Titan identity; life reset does not select another class.
4. Naturalist XP is the only proposed persistent general XP value; Rank is derived and not spendable.
5. Adaptations are optional and solve authored world problems; no separate playable forms or mandatory gates.
6. Mastery is deferred; if introduced, it tracks meaningful authored skill, not elapsed time or button spam.
7. Legacy is knowledge, identity, records and optional access — not permanent raw stats.
8. Discovery/reward claims are idempotent and server-authoritative.
9. Client never supplies reward amount, XP total, discovery state, lifeId or final outcome.
10. Essential progression remains solo-completable.
11. No new currency without source, sink, cap/inflation plan and reason records cannot represent it.

## 4. Death boundary

At life end, snapshot recap first, then reset Current Life exactly once.

**Reset:** Biomass, derived growth, current-life objective progress, temporary buffs/effects, life-local timers per lifecycle contract and temporary per-life counters after recap capture.

**Preserve when implemented:** Creature Identity and Appearance, Naturalist XP/Rank, Bestiary, permanent discoveries, achievements, collections, cosmetics, bounded life history, Habitat and bonds.

**Unresolved:** carried materials, item drops, voluntary extraction, partial resource loss, companion behavior on owner death/disconnect and paid recovery. Require explicit decisions and tests.

Current reset behavior must be read from README/services. This addendum does not claim persistence exists.

## 5. XP and reward pipeline

Future server flow: gameplay service observes a validated event; pure rules validate eligibility, stable event ID, player/life state and repeat limits; reward service resolves configured reward class; Naturalist XP is awarded idempotently; permanent records go to Legacy; life rewards route to Current Life service; UI receives owner-facing presentation. Never accept arbitrary client reward values or double-pay the same discovery.

## 6. Activity contract

- **Discovery:** one-time permanent knowledge claim.
- **LifeGoal:** objective scoped to lifeId; resets at life end.
- **WorldChallenge:** authored repeatable activity with repeat policy, contribution rules and solo completion.

Do not introduce a generic quest framework during TT-P3-02.

## 7. Naturalist progression

Store accumulated XP and derive Rank from a versioned threshold curve. Threshold changes must not reduce earned XP. First-time discovery XP is one-time; repeatable activity XP has authored limits. Rank rewards knowledge, titles, cosmetics, optional challenge variants and non-power access. No permanent combat/traversal multipliers. XP curve/amounts remain unspecified until playtests.

## 8. Mastery boundary

Per-form Mastery is retired. Do not track mastery for Baby Bug, Tank or Glider. A future activity/adaptation proficiency record may be considered only after an authored activity demonstrates a meaningful skill ceiling. Rewards are cosmetic/identity or horizontal optional choices; basic functionality never requires mastery grind.

## 9. Legacy and persistence

Future conceptual fields: schemaVersion; creatureIdentity/selectedAppearance (versioned validated IDs); naturalistXp; discoveries; bestiary; achievements; collections; optional approved adaptation records; cosmetics; bounded lifeHistory; optional Habitat/bonds.

Do not persist Biomass, current growth stage, temporary quest progress or raw power bonuses. Before DataStore, specify migrations, bounded history, idempotent merge, retry/backoff, dirty state, failure UX, shutdown flush, overlapping-session behavior and recovery tests. PersistenceService remains the only DataStore caller.

## 10. Bonds, Habitat and ecosystem encounters

Creature bonds are relationship/trust progression through meeting, studying and helping, not disposable capture inventory. Companions are optional, personality-rich and limited in utility; they do not replace player identity or automate the core loop. Habitat is a modest personal Nest with curated decoration and a few useful stations, not factories or passive resource printing. Ecosystem encounters support observe, avoid, hide, distract, escape, help or environmental solutions. Combat is not assumed and needs a separate product decision.

These are post-MVP hypotheses, not current implementation scope.

## 11. Security and privacy

Server validates progression triggers. Keep private Legacy/inventory/quest details out of public attributes. Remotes carry identifiers/intent only. Rate-limit, reject malformed IDs, make claims idempotent, validate proximity/current life, and define contribution rules to prevent remote claims and AFK farming.

## 12. Implementation sequence

Phase 1: exploration loop with temporary/session-safe discovery feedback. Phase 2: Legacy schema/persistence, Naturalist XP/Rank, Bestiary and activity categories. Phase 3: foraging and living species. Phase 4: bonds/companions and Habitat. Phase 5: ecosystem encounters, co-op events and biome expansion.

No part of this addendum expands TT-P3-02.
