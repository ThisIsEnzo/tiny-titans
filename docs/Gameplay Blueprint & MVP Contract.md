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


## 12. Unified goal and signature discovery loop (v2.2)

The unified long-term goal is to **explore, understand and gradually reconnect the world's ecosystems while creating a personal legacy within them**. Exploration is the primary activity; discoveries and visible ecological change give it purpose; one personal Tiny Titan is the emotional anchor; Bestiary/Discoveries/Legacy preserve knowledge; Nest and co-op deepen attachment later.

The signature loop is:

**Clue → Observation → Hypothesis → Test/Interaction → Visible World Response → Record.**

A meaningful ecological activity needs a readable before-state, clues, a small player action, an observable after-state and a record of what was learned. Restoration must not be only a progress bar. The exact world mystery and lore remain proposals, not locked canon.

## 13. First Habitat vertical-slice contract

Use the existing Nest, Meadow, Rock Garden, Giant Roots and Secret/Dewdrop Glade greybox as the first compact adventure. It is still a greybox; Studio movement, camera, collision and device validation remain separate gates.

**Required vertical-slice experience:**
- First point of interest discoverable quickly without a forced waypoint trail.
- Three memorable landmarks/points of interest and at least two discovery categories (place/landmark and species/behavior).
- One short ecological story chain with a visible before/after world state.
- One optional secret rewarding observation.
- One repeatable route/observation challenge with a small number of controlled variants.
- A lightweight discovery journal/recap and immediate feedback.
- A small authored cast (one featured species and one or two supporting ambient behaviors), not a large roster.
- Every essential interaction completable solo; co-op adds contribution/coordination but no mandatory role.
- Existing Biomass pickups may be incidental, but cannot dominate the loop or become its main objective.

**Recommended example — “The Quiet Glade” (proposal, not locked lore):** the player notices a flower that no longer blooms and the absence of its pollinator; follows clues toward the roots; discovers a blocked shallow water channel; clears the obstruction through a simple server-validated interaction; sees water reach the glade, the flower open and the pollinator return; records the species and ecological relationship. Keep this to two or three interaction states, not a generic quest framework.

**Provisional playtest hypotheses (not launch promises):** first point of interest within 60–90 seconds; first meaningful discovery within roughly three minutes; players can explain the ecological problem/action/result; a meaningful share voluntarily chooses a second discovery or repeatable activity. Establish a baseline before locking numeric thresholds.

## 14. MVP scope clarification

**Must-have for the vertical slice:** Studio-validated movement/routes; onboarding; observe/inspect interaction; two discovery categories; one ecological chain with visible response; clear feedback/journal; one repeatable activity; solo completion; server-authoritative state/reward validation; input plan for touch, keyboard/mouse and gamepad.

**Should-have:** a few visual appearance presets/palette choices; ambient creature behaviors; optional co-op contribution feedback; a second side discovery; Nest presentation polish.

**Out of scope:** separate forms/classes; Agility/Brace/Glide adaptations; combat; full Naturalist XP/Rank/DataStore before the loop is proven; generic quest framework; full character creator; companions; customizable Habitat; crafting/trading; multiple large biomes; hunger chores, daily streaks or paid power.

A region qualifies for future expansion only if it introduces a distinct ecological identity, new player decision/verb, species behavior or environmental relationship, local story chain, optional discoveries, repeatable activity, visible outcome and solo-completable core route. More acreage alone is not content.

Detailed design and open decisions are recorded in [GDD v2.2 — The Living World Adventure](GDD%20v2.2%20%E2%80%94%20The%20Living%20World%20Adventure.md).
