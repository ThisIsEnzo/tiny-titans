# Tiny Titans — Gameplay Blueprint & MVP Contract

**Status:** Product direction approved by owner; MVP contract active  
**Version:** 2.1  
**Date:** 2026-11-15  
**Authority:** This document defines the game and first playable product. Product Vision defines ambition; Master Roadmap defines execution order.

## 1. The game

**Tiny Titans is a co-op-friendly Creature Exploration RPG about inhabiting one personal tiny creature, exploring an oversized living ecosystem, making discoveries and building a lasting identity in that world.**

This is an exploration-first, non-combat-required PvE adventure. Solo play must remain viable. Threats may exist, but combat is not a prerequisite for danger, progression or replayability.

Not a generic food simulator, class-selection lobby, arena brawler, forced PvP game, huge empty open world or MMO grind.

## 2. Player fantasy

“I have my own small creature. I explore places that feel huge, notice things others may miss, learn about the ecosystem, grow and customize my creature, and gradually build a collection and a place in this world.”

Emotional beats: wonder, agency, personal identity, readable tension, discovery and lasting legacy.

## 3. Core loop

**Moment-to-moment:** Move → Notice an opportunity, clue or risk → Choose a route/action → Execute → Receive feedback → Decide what to explore next.

**One expedition / life:** begin at a safe Nest; explore landmarks, secrets and resource opportunities; interact with the world and optionally gain Biomass; choose routes or solve traversal/discovery challenges; observe or overcome world interactions through movement, timing, hiding, distraction or cooperation; complete a discovery/activity; end only through fair failure or a separately validated voluntary-return flow; view recap; begin another expedition with a new goal.

The first meaningful interaction must happen quickly. Evolution, combat and death are not mandatory first-session activities.

## 4. First playable product

One polished **First Habitat**, not a giant open world:
- safe Nest / onboarding pocket;
- distinct micro-areas and memorable landmarks;
- connected primary and alternative routes;
- ground, elevated and narrow paths;
- meaningful discovery interactions;
- one repeatable route or exploration challenge;
- optional secrets and traversal challenges.

Every essential route is solo-completable. No route requires a particular adaptation or class.

Prioritize Explore & Discover, Traverse & Master, and Notice & Interact using existing Biomass/food interactions only where useful. Do not build a full foraging catalogue yet.

A creature encounter or environmental hazard is optional and needs a separate design gate. Combat, health/damage, bosses and enemy progression are not MVP prerequisites.

## 5. Character identity and adaptations

### One personal Tiny Titan

The player does not choose Baby Bug, Tank or Glider as separate playable forms/classes. Each player inhabits one personal Tiny Titan with consistent identity across lives.

Target appearance is a purpose-built, expressive small creature with meaningful customization. This is not a commitment to simply scale down a standard R15 avatar. Rig, collision, animation, accessories, avatar integration and mobile readability require technical validation.

Customization may eventually include palette, markings, eyes, shell/wings, antennae, accessories, animations, trails and emotes. Do not build a large character creator before the basic creature is convincing and performant.

### Adaptations, not forms

Baby Bug / Tank / Glider are retired as product-level forms. Their useful verbs survive only as candidate ideas: agility/squeeze, brace/shell and glide/wings. These are not an approved MVP roster.

Each future adaptation needs at least two real world use cases, a distinct verb, trade-offs, counterplay, server validation, readable feedback, cross-platform input and playtest evidence. No mandatory gates. Do not implement per-form Mastery.

## 6. Progression and death

- **Current Life:** Biomass, derived growth, temporary objectives/effects and life stats; resets at life end.
- **Naturalist XP / Rank:** future persistent learning progression; Rank is derived.
- **Legacy:** future Bestiary, discoveries, achievements, collections, cosmetics and bounded life history.
- **Adaptations:** future optional choices only where the world proves their value.
- **Habitat / Bonds:** post-MVP hypotheses.

Legacy provides knowledge, identity and optional access, not permanent raw power. Death is not a monetization lever. No paid revives/protection or punitive loss. Do not add DataStore until schema, migration, failure and recovery are designed and tested.

## 7. Multiplayer

Multiplayer and co-op-friendly, but every MVP activity works solo. Players can explore together, help each other and share discoveries. Forced PvP, ranked modes, guilds and PvPvE are deferred. Server owns progression, discovery claims and rewards. Protect onboarding and recovery from spawn camping, griefing and veteran farming.

## 8. MVP acceptance gates

Evidence must show:
- first-time players understand what to do;
- first meaningful interaction happens quickly;
- movement, camera and inputs work on mobile, keyboard/mouse and gamepad;
- habitat is interesting for more than one pass;
- players understand and care about their Tiny Titan;
- discoveries and a repeatable activity are enjoyable without daily rewards or purchase pressure;
- life end/rebirth is fair and future Legacy makes an expedition valuable;
- multiplayer creates positive moments without breaking solo;
- performance, exploit resistance, moderation and data safety are acceptable;
- external players voluntarily want another life/session and can explain why.

Track first-session funnel, activity completion, route choice, discovery rate, challenge replay, customization engagement, D1/D7 retention, device performance and qualitative feedback. Set numeric targets only after baseline playtests.

## 9. Scope guardrails

Until the First Habitat vertical slice is validated, do not build separate playable forms/classes, per-form Mastery, a large character creator, a full adaptation/loadout framework, combat, ranked PvP, breeding, trading, marketplace, crafting trees, multiple large biomes, premium currency, paid revives, power boosts, daily chores or punitive streaks.

## 10. Feature decision rule

Before a feature enters the roadmap, define player problem/fantasy, core-loop moment, new decision/verb, smallest testable prototype, expected outcome/measurement, risks/trade-offs/counterplay and what existing task will be delayed or removed.

## Approved product decision

**Build a compact Creature Exploration RPG about one personal, customizable Tiny Titan in a large-feeling living world. Prove exploration, discovery, character attachment and a repeatable activity before adding adaptations, combat, persistence breadth or monetization.**

Top 1000 is the ambition. Player value, replayability, fairness and evidence are the operating standard.

## 11. RPG direction and boundaries

Owner approval: 2026-11-15. Naturalist XP is the single persistent general XP track; Rank is derived. Discoveries, Life Goals and World Challenges have distinct one-time, per-life and repeatable semantics. Biomass remains Current Life growth. Natural Materials are a future hypothesis; Research Samples are not approved currency. Companions and Habitat are post-MVP.

TT-P3-02 remains a narrow exploration-loop task using existing systems only. It must not introduce persistent XP, DataStore, a generic quest framework, character creator, adaptations, combat, companions, Habitat building or a new currency.
