# Tiny Titans — Player Identity & Adaptation Architecture

**Version:** 1.0 | **Date:** 2026-11-15  
**Status:** Approved product boundaries; future technical design, not implemented.  
**Product authority:** Product Vision v2.1 and Gameplay Blueprint. **Execution:** Master Roadmap.

## 1. Purpose

Defines technical boundaries for a player inhabiting one personal Tiny Titan rather than selecting Baby Bug, Tank or Glider forms. It does not claim the current prototype has this architecture. Current implementation facts remain in README/source. The former Evolution Sandbox Architecture is superseded and retained in Git history as a prototype audit.

## 2. Core invariants

1. A player has one persistent creature identity across lives/sessions once persistence is implemented.
2. A life reset does not replace the player's identity with a different class/form.
3. Appearance and gameplay capability are separate domains.
4. Cosmetics grant no hidden gameplay power.
5. Adaptations are optional world-interaction capabilities, not separate characters/classes.
6. No adaptation without at least two concrete world use cases, trade-off, counterplay, server validation and cross-platform input.
7. Essential routes/progression remain solo-accessible; no mandatory adaptation gates.
8. No permanent raw power from Rank, Legacy, cosmetics or monetization.
9. Server-authoritative gameplay state is separate from client presentation.
10. Tiny-creature visuals must treat collision, movement, camera and Humanoid behavior as explicit technical constraints.

## 3. Character identity model

| Domain | Lifetime | Responsibility |
|---|---|---|
| Creature Identity | Player lifetime | Stable identity/profile for the player's Tiny Titan |
| Appearance | Player lifetime | Body style, palette, markings, facial details and cosmetics |
| Current Life | One lifeId | Biomass, derived growth, temporary activity progress and life stats |
| Adaptation Loadout | Future; exact scope TBD | Optional capabilities under authored rules |
| Legacy | Player lifetime | Bestiary, discoveries, achievements, collections, Naturalist XP/Rank and history |
| Habitat & Bonds | Future | Personal space and relationships with ecosystem creatures |

Do not introduce all services/persisted records in one task. The roadmap determines when each domain is justified. A new life may reset Biomass, temporary objectives and life stats, but must not silently reset chosen appearance or identity. Temporary growth may affect visual scale only if camera, collision, readability and multiplayer behavior are validated.

The exact relationship between player identity and Roblox account avatar customization remains an open technical decision. Target is a purpose-built Tiny Titan visual, not an assumption that standard R15 scaled down is final.

## 4. Appearance architecture

Future appearance pipeline separates:
- stable appearance definition (validated IDs/values, not arbitrary client assets);
- server-owned selected appearance/profile;
- reusable creature visual builder or rig;
- client-side animation/presentation;
- collision and movement representation, not inferred from decorative geometry.

Cosmetic components need compatible slots/tags or authored presets. Avoid unrestricted combinations until clipping, scale, rig, performance, replication and mobile readability are tested. Server validates owned/allowed cosmetic identifiers.

## 5. Adaptation architecture

Adaptations are future optional capabilities, not a form catalog.

Candidate verbs inherited from old prototypes:
- **Agility / Squeeze:** traverse a designated narrow passage or improve a specific traversal interaction.
- **Brace / Shell:** resist a bounded environmental force, hold position or protect an interaction for a limited window.
- **Glide / Wings:** steer a controlled descent or traverse a designed aerial route.

These are examples, not implementation approval. Each proposal must define player problem and exact world use; two authored locations; unique verb/readable activation; limits, cost, cooldown and cancellation; trade-off/counterplay; server validation; cross-platform input; measurable Studio/external playtest criteria.

Number of simultaneous adaptations, unlock policy, swap timing and whether they are equipment, biological traits or learned abilities remain open. Do not create a general loadout framework before a concrete activity needs it.

## 6. Current prototype migration boundary

Current code still contains the historical form model:
- BABY_BUG, TANK and GLIDER;
- form-selection/evolution UI and server rules;
- Tank Defensive Shell (visual-only prototype);
- Glider Air Glide (three-second physics prototype);
- Baby Bug custom visual model attached to an R15 Humanoid.

These are prototype implementation facts, not approved product model. This documentation change does not remove or rewrite runtime code. Future migration must be separately scoped, tested and reviewed. Do not delete working lifecycle, growth or appearance code merely because product model changed.

The Baby Bug visual can inform art direction, but is not automatically the final customizable character. Its R15 collision representation and pending Studio validation must be considered.

## 7. Server authority and persistence

Server owns identity selection, allowed cosmetic IDs, adaptation eligibility/activation and consequential rewards. Client owns input and local presentation. Remotes carry intent and stable identifiers, never arbitrary appearance data, reward values or claimed outcomes. Validate life state, proximity, cooldowns, ownership and rate limits. Keep private identity/Legacy data out of public Player attributes when not intended for others.

Persistence requires versioned schema, migrations, retry/backoff, idempotent writes, failure UX and recovery tests. No DataStore implementation is approved here.

## 8. Implementation order

1. Prove First Habitat exploration with current prototype and existing systems.
2. Evaluate personal Tiny Titan visual direction and technical constraints; no large creator yet.
3. Define one concrete adaptation only if observed gameplay needs it.
4. Add stable appearance persistence only with a designed Legacy schema and recovery behavior.
5. Expand customization/adaptations only after external players demonstrate attachment and repeated use.

The Master Roadmap controls execution.
