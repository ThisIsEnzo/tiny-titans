# Tiny Titans — Gameplay Blueprint & MVP Contract

**Status:** Product direction approved by owner; MVP contract active  
**Version:** 3.0  
**Date:** 2026-11-19  
**Authority:** This document defines the game and first playable product. Product Vision defines ambition; Master Roadmap defines execution order.

## 1. The game

**Tiny Titans is a Zelda-inspired living-world adventure built around an original miniature ecosystem, ecological puzzles, exploration, secrets and compact challenges.** The player uses their standard Roblox avatar. The game supports complete solo play and equally supported co-op.

Zelda is a design inspiration for adventure structure, environmental puzzle craft, secrets and regional progression—not a template to copy. Tiny Titans' identity comes from miniature scale, natural systems, observation, creature behavior and visible ecosystem change.

Not a generic food simulator, class-selection lobby, arena brawler, forced PvP game, empty open world or MMO grind.

## 2. Player fantasy

“I explore a world that feels enormous as my Roblox avatar. I notice things others miss, discover how the ecosystem works, solve environmental problems, uncover hidden places and see the world respond to my actions.”

Emotional beats: wonder, agency, curiosity, mastery, readable tension, discovery, social cooperation and the satisfaction of changing a living place.

## 2A. Character contract — Roblox avatar

The standard Roblox avatar is the canonical playable character.

- Keep the player's Roblox avatar visible and recognizable.
- Preserve standard Humanoid/Animate behavior, movement and supported animations.
- Preserve clothing, body packages and accessories wherever supported.
- Do not hide the avatar or replace it with the current Baby Bug visual.
- Do not introduce custom rigs, arbitrary scaling, collision proxies or camera overrides in the initial restoration.
- The miniature fantasy comes from oversized environments, props, plants, creatures and readable camera framing.
- Validate movement, collision, camera, animation, accessories, touch, keyboard/mouse and gamepad in Studio.

Baby Bug is a retired player-character prototype. Tank and Glider are retired form concepts. Existing code may remain temporarily for compatibility, but it is not a product requirement. Any useful abilities must be reconsidered later as optional world interactions with at least two use cases and solo alternatives.

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

## 5. Character, movement and world interaction

The player uses their normal Roblox avatar. The first playable slice must validate comfortable movement through the First Habitat with standard Roblox character dimensions and animation behavior.

Do not build a custom creature rig, character creator, form-selection system or adaptation loadout for MVP. The world itself creates the tiny-scale fantasy.

Future optional abilities are considered only when an authored puzzle or route needs a distinct player verb. Each candidate requires two or more meaningful use cases, clear limits/trade-offs, server validation, cross-platform controls and solo-completable alternatives. No mandatory ability gates.

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

**Build a compact Zelda-inspired living-world adventure played as the standard Roblox avatar. Prove exploration, observation, ecological puzzles, visible world change, secrets and repeatable adventure activities in both solo and co-op before adding broad RPG progression or monetization.**

Top 1000 is the ambition. Player value, replayability, fairness and evidence are the operating standard.

## 11. RPG direction and boundaries

Owner approval: 2026-11-19. Zelda is a high-level adventure-design inspiration only. The standard Roblox avatar is the canonical player character. Solo and co-op are equally supported. Naturalist XP/Rank, Bestiary persistence, companions and Habitat remain later systems; Biomass remains incidental current-life growth, not the adventure's central goal.

TT-P3-03 is the next ecological interaction slice in Meadow. Keep it narrow and server-authoritative. Do not introduce persistent XP, DataStore, a generic quest framework, custom Baby Bug player visuals, form selection, combat, companions, Habitat building or a new currency.


## 12. Unified goal and signature adventure loop (v3.0)

The unified long-term goal is to **explore, understand and gradually reconnect the world's ecosystems while creating a personal legacy within them**. Exploration is the primary activity; discoveries and visible ecological change give it purpose; the standard Roblox avatar is the player's identity anchor; Bestiary/Discoveries/Legacy preserve knowledge; Nest and co-op deepen attachment later.

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

**Should-have:** a few Roblox-avatar-compatible cosmetic options; ambient creature behaviors; optional co-op contribution feedback; a second side discovery; Nest presentation polish.

**Out of scope:** separate forms/classes; Agility/Brace/Glide adaptations; combat; full Naturalist XP/Rank/DataStore before the loop is proven; generic quest framework; full character creator; companions; customizable Habitat; crafting/trading; multiple large biomes; hunger chores, daily streaks or paid power.

A region qualifies for future expansion only if it introduces a distinct ecological identity, new player decision/verb, species behavior or environmental relationship, local story chain, optional discoveries, repeatable activity, visible outcome and solo-completable core route. More acreage alone is not content.

Detailed design and open decisions are recorded in [GDD v3.0 — The Living World Adventure](GDD%20v2.2%20%E2%80%94%20The%20Living%20World%20Adventure.md).
