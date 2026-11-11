# Tiny Titans — Evolution Adventure Sandbox Roadmap

**Document:** Product direction and milestone roadmap  
**Version:** 0.1  
**Date:** November 2026  
**Status:** Proposed direction; architecture decisions are to be formalized in TT-P0-02R.

---

## 1. Product vision

Tiny Titans is a multiplayer evolution adventure sandbox about being a small creature in a large, living world.

Players explore a miniature ecosystem, forage and survive, adapt their bodies, discover new species and places, and choose how to evolve. The experience combines:

- **Sandbox:** freedom to explore, experiment with abilities and interact with the ecosystem.
- **Adventure:** landmarks, secrets, hazards, challenges, events and progressively more demanding areas.
- **Evolution:** meaningful changes to traversal, survival and interaction—not just larger numbers or cosmetic skins.
- **Legacy:** discoveries and knowledge that give long-term meaning to many individual lives.

The target is a distinctive, replayable Roblox experience with strong first-session clarity, multiplayer moments and a sustainable content model. Top 1000 is an ambition, not a forecast or a substitute for player evidence.

### Product principle

**A player may lose the current life, but should never feel that their time in Tiny Titans was wasted.**

## 2. Core gameplay loop

`Begin Life → Explore → Forage & Survive → Grow → Evolve → Discover → Die / End Life → Begin Again`

The loop should produce interesting decisions at every stage:
- Where should I explore, and how much risk should I take?
- Which resources or discoveries are worth pursuing?
- Which evolution best fits the route or challenge ahead?
- Should I continue pushing this life or secure a new discovery?
- What new option or knowledge did this life add to my Legacy?

The loop must remain enjoyable without daily-login pressure, artificial waiting or paid protection from failure.

## 3. Three progression layers

The game should distinguish three concepts clearly. The exact data model and service boundaries are a deliverable of **TT-P0-02R**.

### 3.1 Current Life — temporary run state

A life begins as the base creature (currently named **Baby Bug**). During that life, the player grows, gathers resources, evolves and explores.

On death, the following are reset:
- Current form and current-life evolution path.
- Biomass / growth progress accumulated during the life.
- Temporary abilities, upgrades and effects.
- Current-run resources and temporary objectives.
- Any other explicitly designated run-only state.

The player returns to the base form and starts a new life. Death should be readable, fair and telegraphed—not a random punishment.

### 3.2 Evolution — choices within a life

Evolution changes what the player can do. A form should create a distinct gameplay role through movement, survival, traversal, environmental interaction or access to meaningful routes.

Initial branches:
- **Tank:** defensive / resilient playstyle. The current Shell is only a visual prototype and does not yet prove this role.
- **Glider:** aerial traversal / mobility playstyle. The current bounded glide is an early prototype and needs stronger control and world use cases.

Future concepts such as Volt, Aqua, Venom, Phantom or Burrow are placeholders for design exploration, not approved implementation scope. Each future form must justify itself with a distinct gameplay verb and a testable use case.

### 3.3 Legacy — persistent account-level knowledge

Legacy survives death and gives the player long-term goals without making veteran players numerically stronger.

Candidate persistent records:
- Bestiary entries and species discoveries.
- Discovered territories, landmarks and secrets.
- Achievements, collections and milestones.
- Cosmetics, markings and creature identity options.
- History of previous lives and notable discoveries.
- Permanent unlocks that expand the set of available evolution choices or reveal new knowledge.

Legacy unlocks should primarily grant **choices, knowledge, identity and access opportunities**, not permanent raw damage, health, speed or resource multipliers.

A discovered territory may be recorded permanently without granting free teleportation or bypassing its traversal requirements. The player may still need an appropriate current-life form or ability to reach it.

## 4. Death and rebirth experience

Death is a transition between lives, not deletion of the player's long-term progress.

### Expected flow

1. The player dies or otherwise ends the current life.
2. The game summarizes the life.
3. Current-Life state is cleared.
4. The player returns to the safe starting area as the base creature.
5. Legacy records and permanent unlocks remain available.
6. The player chooses a new direction and begins another life.

### Death recap

The recap should be concise and rewarding. Potential fields:
- Life duration.
- Highest form reached.
- Areas or landmarks discovered.
- New species / bestiary entries.
- New Legacy or evolution memories unlocked.
- A clear **BEGIN NEW LIFE** action.

Do not interrupt the player with a long report. New discoveries should be highlighted; repeated information should be compact.

### Fairness requirements

- The starting area should be relatively safe and easy to understand.
- Riskier areas should communicate danger and offer proportionally better discoveries or rewards.
- Abilities should provide meaningful survival or escape options.
- Avoid cheap deaths, invisible hazards and unavoidable spawn deaths.
- Do not monetize resurrection, death protection or preservation of current-life power.

## 5. World direction — The First Habitat

The first world should be a compact, dense, readable ecosystem—not a huge empty open world.

Candidate sub-areas:
- **Meadow:** safe introduction, basic forage and orientation.
- **Rock Garden:** obstacles, crevices, elevated routes and shelter.
- **Giant Roots:** vertical traversal, narrow passages and hidden spaces.
- **Pond:** water-edge resources and a future aquatic opportunity.
- **Mushroom Grove:** distinctive visual identity, unusual resources and environmental hazards.
- **Underground:** a higher-risk discovery layer with constrained routes and special access requirements.

These are design targets, not a requirement to build all areas immediately. Start with one polished vertical slice and validate whether it is fun.

## 6. Evolution design rules

Every evolution proposal must define:
1. Player fantasy and role.
2. Unique gameplay verb or decision it introduces.
3. Activation controls, including touch and gamepad equivalents.
4. Valid states, duration, cooldown and cancellation rules.
5. Movement, physics and server-authoritative bounds.
6. Environmental interactions and routes it enables.
7. Trade-offs, risks and counterplay.
8. Visual, audio and UI feedback.
9. A small playtest that can prove or disprove its value.

Do not add forms simply to increase the count. A new form should change the way a player approaches the world.

## 7. Product roadmap

The roadmap is outcome-driven. The sequence may change when audits and playtests provide evidence. The current immediate priority is **P0**, not automatic continuation of the old ability milestone sequence.

### P0 — Product foundation and architecture

**Outcome:** The team has one consistent product model and understands how the existing prototype maps to it.

- Define Current Life, Evolution and Legacy.
- Specify death, reset and rebirth semantics.
- Audit the existing codebase and data ownership.
- Decide how current Energy / GrowthStage relates to the proposed Biomass model.
- Define a configurable evolution model and migration path from the current Tank / Glider implementation.
- Separate confirmed implementation facts from assumptions and future design.
- Record architecture decisions and unresolved questions.

**Exit gate:** Product rules and architecture boundaries are documented, internally consistent and traceable to the current implementation. No gameplay rewrite is implied by the documentation alone.

### P1 — Core life cycle

**Outcome:** A complete, understandable life can begin, progress, end and restart.

- Base form and safe spawn.
- Biomass / growth progression.
- Food/resource types and meaningful collection choices.
- Death handling and full Current-Life reset.
- Explicit separation of Legacy from temporary run state.
- Clear life recap and new-life transition.

**Exit gate:** Repeated life cycles work without losing Legacy or carrying unintended temporary state across death.

### P2 — Evolution system

**Outcome:** Evolution choices create meaningful playstyle differences.

- Establish a data-driven/configurable evolution definition.
- Make Tank and Glider reliable and distinct.
- Give each branch at least one meaningful world activity.
- Add clear ability feedback and cancellation behavior.
- Keep progression and ability validation server-authoritative.
- Add future evolution branches only after the initial branches are validated.

**Exit gate:** Players can explain why they chose a form and demonstrate a meaningful difference in play.

**Task sequence (P2-01 update).** Design precedes implementation:

| Task | Title | Scope |
|---|---|---|
| P2-01 | Progression & Evolution Design Gate | **Documentation only.** Defines the progression layers, the one-life loop, Biomass versus growth versus evolution, Tank and Glider roles, activities, anti-grind and retention principles and the playtest plan (design in `Combat Progression & Endgame Design v0.1.md`, section 13). No code, remotes, services, DataStore, forms, abilities or monetization |
| P2-02 | Creature Definitions | Data-driven forms and per-form requirements; today's behavior and values unchanged |
| P2-03 | Ability Definitions | Data-driven abilities with the existing handlers |
| P2-04 | Data-driven Evolution UI | Selection cards generated from definitions |
| P2-05 | Tank gameplay validation and iteration | Playtests, a Tank world interaction or a recorded dependency |
| P2-06 | Glider gameplay validation and iteration | Playtests, platform reachability, glide tuning through data |
| P2-07 | Progression UX and balance validation | Measure pacing; implement the approved Biomass model only after owner approval |

**P2-01 completion criteria:** the roadmap, the master roadmap, the architecture, the combat and progression design and the migration plan agree on this scope and sequence; implemented behavior and proposed design are labelled apart; the owner approves, changes or rejects the decisions in section 13.11 of the combat design document. The additional initial roles (Striker / Hunter, Support / Controller) are not P2 tasks; they stay gated by P3.5 and a validated PvE loop.

### P3 — First Habitat vertical slice

**Outcome:** One compact area feels like a place worth exploring.

- Replace the empty-feeling prototype arena with a coherent first habitat.
- Add vertical routes, landmarks, safe and risky spaces.
- Place resources and discoveries to create route decisions.
- Include at least one secret and one traversal challenge.
- Ensure the habitat supports the initial evolution branches.

**Exit gate:** A new player can navigate, discover and replay the area without relying on developer explanation.

### P4 — Adventure and survival

**Outcome:** The ecosystem creates memorable situations beyond collecting food.

- A small number of neutral creatures and understandable behaviors.
- Threats and hazards with clear telegraphs and counterplay.
- Resource competition and simple food-chain interactions where useful.
- World events, challenges, secrets and small boss-like encounters.
- Activities that reinforce exploration and evolution.

**Exit gate:** Players encounter varied, readable situations that create stories and meaningful choices.

### P5 — Legacy and persistent progression

**Outcome:** Discoveries survive across lives and give players long-term goals.

- Bestiary and discovery records.
- Territory and secret discovery.
- Achievements and collections.
- Cosmetic identity and history of lives.
- Permanent evolution-choice unlocks.
- DataStore persistence with schema versioning, safe retries, failure handling and migration.

**Exit gate:** Progress survives rejoining and death without granting unfair permanent power.

### P6 — Multiplayer experiences

**Outcome:** Other players make the ecosystem more interesting.

- Cooperative discoveries and events.
- Complementary evolution abilities.
- Friendly competition and shared challenges.
- Fair resource rules, anti-griefing and safe areas.
- Solo play remains viable.

**Exit gate:** Multiplayer creates positive interactions without making solo players feel excluded or helpless.

### P7 — Identity, polish and launch readiness

**Outcome:** Tiny Titans is recognizable, accessible and reliable.

- Distinct creature models, silhouettes and animations.
- Sound, VFX, responsive UI and clear feedback.
- Onboarding and first-session guidance.
- Mobile and gamepad usability.
- Performance, security, moderation and analytics.
- Cosmetic-first monetization only after the core loop is validated.
- Soft launch, playtest cohorts and iterative improvements.

**Exit gate:** A stable release candidate demonstrates a compelling first session, repeatable gameplay, meaningful progression and healthy player feedback.

## 8. Metrics and validation

Do not invent numerical targets before collecting a baseline. Establish targets from early playtests and comparable Roblox experiences.

Track:
- First-session completion and time to first meaningful action.
- Time to first growth milestone and first evolution.
- Evolution selection and branch distribution.
- Ability activation success, rejection reasons and repeat use.
- Life duration, death/restart rate and recap engagement.
- New discoveries per life and Legacy unlock rates.
- D1 / D7 retention by cohort.
- Session length, interpreted alongside satisfaction (not optimized in isolation).
- Mobile usability, performance and error rates.
- Qualitative feedback: fun, clarity, fairness and intent to return.

A useful north-star candidate is **players who complete a meaningful activity and return in a later session**. Validate the definition when analytics exist.

## 9. Explicit non-goals for the early MVP

Avoid:
- Implementing many evolution forms at once.
- Building a huge open world before one habitat is fun.
- Complex AI for dozens of species.
- Trading, breeding, pets, clans or large PvP systems before the core loop works.
- Monetization before retention and economy fundamentals are understood.
- Permanent raw stat bonuses from Legacy.
- Paid death protection or resurrection.
- Rewriting working systems solely for architectural elegance.
- Adding content volume to compensate for weak core gameplay.

## 10. Current prototype versus target

The current project is an early prototype foundation, not a finished implementation of this vision.

Known starting point before the architecture pivot:
- A greybox arena, food pickups, Energy / GrowthStage and an Energy HUD.
- Baby Bug as the base form and Tank / Glider evolution choices.
- Server-owned evolution selection and ability requests.
- Tank Shell is currently visual-only.
- Glider is an early bounded air-glide prototype.
- Player progression is session-only; there is no durable Legacy / DataStore progression yet.
- Evolution state and some ability cooldowns currently have session/respawn semantics that must be reconciled with the new life-reset rules.
- The current character presentation relies on standard Roblox avatars rather than a complete creature identity system.

Treat this list as an audit starting point. Confirm the current state against the repository and Roblox Studio before making implementation claims. The architecture milestone must update this section if the merged implementation has changed any detail.

> **Status note (P2-01):** sections 10 and 11 describe the starting point and the first milestone of the architecture pivot and are kept as history. TT-P0-02R and P1 (Biomass naming, life state, reset on death, controlled respawn with a recap, lifecycle hardening) have since been implemented in code, with Studio validation outstanding. The current next milestone is **P2-01 — Progression & Evolution Design Gate** (documentation only). The current verified behavior is tabulated in `Combat Progression & Endgame Design v0.1.md`, section 13.2.

## 11. Immediate next milestone

**TT-P0-02R — Evolution Sandbox Architecture & Product Pivot**

Documentation and architecture audit only. It should:
- Integrate this product direction with the existing Product Vision & Top 1000 Strategy.
- Map current systems, attributes, remotes and persistence to Current Life / Evolution / Legacy.
- Define the intended death/reset contract.
- Resolve or explicitly defer Energy versus Biomass terminology and migration.
- Define configurable evolution data and compatibility strategy for Tank / Glider.
- Identify required code changes and risks for later implementation milestones.

This milestone must not implement gameplay changes or start P1. It should produce a reviewable architecture proposal and migration plan first.

---

## 12. Guiding principle

Build **one interesting mechanic, one responsive control scheme and one beautiful, replayable habitat** before scaling content.

The long-term promise is not that a creature becomes permanently stronger. It is that each life teaches the player something, unlocks new possibilities and makes the next exploration more interesting.
