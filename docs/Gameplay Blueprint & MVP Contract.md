# Tiny Titans — Gameplay Blueprint & MVP Contract

**Status:** Product direction approved by owner; MVP contract remains active  
**Version:** 2.0  
**Date:** 2026-11-13  
**Authority:** This document defines what game we are building and what the first playable product must prove. The Product Vision defines the ambition and principles; the Master Roadmap defines execution order.

---

## 1. The game in one sentence

**Tiny Titans is a multiplayer creature-evolution adventure about exploring a dangerous, oversized miniature ecosystem, adapting into creatures with genuinely different traversal and survival abilities, and bringing discoveries from each life into the next.**

The intended experience is a **co-op-friendly PvE exploration/survival adventure sandbox**. Solo play must remain viable. Friendly competition can emerge around routes, discoveries and limited resources, but forced PvP is not part of the first release.

This is not:
- a generic food-collection simulator where the main reward is a larger number;
- a class-selection lobby with abilities that have no meaningful world use;
- a pure arena brawler or ranked PvP game;
- a huge empty open world;
- an MMO with a large roster and progression grind before the first fun moment.

The distinctive hook is **being tiny in a world that feels enormous**. A leaf is a bridge, a root is a climbing route, a puddle is a hazard, a crack is a secret passage, and a harmless-looking garden creature can become a serious encounter.

## 2. The player fantasy

I am a small creature trying to survive and understand a living world. I explore places that feel huge, find food and unusual life, grow during this life, adapt into a form suited to the challenges ahead, and discover things worth remembering. Other players make the ecosystem feel alive: we can help each other, race for opportunities, explore together or choose different routes.

The emotional beats we want:
1. **Wonder:** ordinary objects feel enormous and interesting.
2. **Agency:** I choose where to go and how to approach a challenge.
3. **Transformation:** evolution changes what I can do, not just my stats.
4. **Tension:** risky routes and encounters create stakes, with readable counterplay.
5. **Discovery:** I find something I did not know existed.
6. **Legacy:** even when a life ends, a meaningful discovery or achievement remains.

## 3. Core gameplay loop

### Moment-to-moment

**Move → Notice an opportunity or threat → Choose a route/action → Execute → Receive clear feedback → Decide what to do next.**

The player should regularly make small decisions. Long stretches of running toward identical pickups are not acceptable.

### One life / expedition

1. Begin at a safe Nest in the habitat as Baby Bug.
2. Notice a clear nearby objective plus optional discoveries.
3. Explore and forage through varied interactions to gain Biomass and grow.
4. Encounter a route choice, environmental hazard, creature or challenge.
5. Reach an evolution milestone and choose a form based on the route, objective or preferred playstyle.
6. Use the form's signature ability to solve a meaningful traversal/survival problem.
7. Complete an activity, discover something, cooperate or take a greater risk for a better opportunity.
8. The life ends through a fair, understandable failure or voluntary end-of-expedition flow if that is later proven useful.
9. See a concise Life Recap. Current Life resets; eligible discoveries, records and identity progress enter Legacy.
10. Begin another life with a new goal, a new route or a newly available possibility.

**Important:** the exact session length and evolution timing are playtest questions, not arbitrary promises. The first-session goal is to deliver a meaningful action quickly, then a first evolution and a branch-specific activity in one coherent experience.

## 4. The first release: deliberately small

### World

One polished **First Habitat**, not a giant open world. It should contain:
- a safe Nest / onboarding pocket;
- 3 distinct micro-areas with clear silhouettes and landmarks;
- multiple connected routes, including ground, elevated and narrow routes;
- a few food/resource interaction types;
- one or two environmental hazards with clear warnings and counterplay;
- one simple PvE creature encounter only after its behavior is designed and tested;
- optional secrets and short traversal/discovery challenges;
- enough route variation that a second life is not identical.

The world must be built around the scale and abilities of the creatures. Do not add a form ability unless the habitat gives it a reason to exist.

### Activities

For the first playable vertical slice, prioritize only:
1. **Forage & grow:** varied resource interactions placed along meaningful routes, not a field of identical touch pickups.
2. **Explore & discover:** landmarks, hidden paths and a small bestiary/discovery reward.
3. **Survive & overcome:** one readable hazard or PvE encounter that tests movement and at least one evolution role.

Co-op objectives and friendly competitions come after the solo loop is already enjoyable. Solo players must never be forced to wait for a second player.

### Forms and roles

Baby Bug is the starter identity, not a class. The first two evolved forms remain prototypes until their gameplay roles are proven.

| Form | Intended role | Signature player verb | Must be useful for |
|---|---|---|---|
| **Baby Bug** | Agile baseline / access | Squeeze, scurry, explore | Narrow passages, basic routes, safe onboarding and discovering small spaces |
| **Tank** | Resilience / space control | Brace, withstand, push | Crossing or holding hazardous ground, protecting an interaction, moving a heavy obstacle |
| **Glider** | Aerial traversal / route mastery | Launch, steer, dive, glide | Crossing meaningful gaps, reaching elevated routes, scouting and collecting rewards on aerial paths |

These are **design targets, not claims about current implementation**. Tank currently has a visual shell only. Glider's current Air Glide implementation is a physics prototype and has not yet been accepted as a satisfying gameplay ability.

Do not commit to Striker, Support, Controller or a four-to-six-class launch roster yet. A new form is justified only when a validated activity needs a new gameplay verb that existing forms cannot provide.

## 5. Ability design contract — mandatory

An ability is not justified because it is technically possible or looks cool. Before implementation, its design must answer:

1. **Purpose:** What player problem or opportunity does it solve?
2. **World use case:** Name at least two concrete places/situations in the First Habitat where it matters.
3. **Unique verb:** What can this form do that the other forms cannot do as well?
4. **Trade-off:** What does the player give up (durability, speed, control, recovery, range, commitment or opportunity)?
5. **Counterplay:** What can the environment, NPC or another player do in response?
6. **Limits:** Define activation state, duration, cooldown/resource, cancel rules and server validation.
7. **Feedback:** Input acknowledgement, activation, active state, failure reason, end state and cooldown must be readable.
8. **Cross-platform:** Keyboard/mouse, touch and gamepad must all support the same intent.
9. **Validation:** Define a measurable playtest and compare against Baby Bug and the other form.

### Glider: approved design direction to prototype, not yet implementation approval

The Glider must become an **aerial traversal specialist**, not a character that merely falls more slowly for three seconds.

Prototype this experience:
- The player jumps or launches from a meaningful height.
- The player deploys wings and gets clear directional steering.
- Forward momentum and diving trade altitude for speed/distance.
- Updrafts or air currents can extend a route but cannot create unlimited free flight.
- Landing is predictable; the player cannot hover indefinitely or escape every threat.
- Aerial routes lead to optional resources, shortcuts, viewpoints or discoveries.
- Ground-level and narrow routes remain useful, so Glider is not the best answer to every situation.

**Trade-offs to test:** lower durability than Tank; no ability to break/brace heavy obstacles; glide requires height or a launch opportunity; poor choices can lead to a bad landing or loss of momentum. Do not lock numeric values until Studio playtests.

**Why the current Glide is insufficient:** gravity compensation alone has little agency, no meaningful horizontal steering and no reason to choose the form outside a specially placed platform. A working VectorForce is not a finished ability.

### Tank: intended design direction

Tank should be able to **brace against a hazard / impact and control physical space**, with a second use such as pushing or moving a clearly designated heavy obstacle. It should not simply receive a permanent health multiplier. It must have commitment or mobility trade-offs and readable windows where it is vulnerable.

### Balance principles

- No form is best in every route, encounter and activity.
- Every form has at least one clear strength, one meaningful weakness and a learnable counter.
- Abilities create options; they do not bypass all risk or make other players irrelevant.
- A route may reward a form but must not hard-lock solo progression behind a specific class.
- Balance is evaluated by route completion, time, failure/recovery, ability usefulness and player understanding—not only cooldown numbers or win rates.
- Numeric tuning follows playtests; do not invent final stats in advance.

## 6. Progression and the meaning of death

Keep the three-layer model:

- **Current Life:** Biomass, growth, selected form, temporary upgrades, objectives and life statistics. Resets when the life ends.
- **Evolution:** the available forms and the selected form/ability set for the current life.
- **Legacy:** discoveries, bestiary, achievements, collections, cosmetics, life history and carefully gated access to new choices.

Legacy should provide knowledge, identity and new options—not permanent raw damage, health or movement power. Death must create a meaningful recap and a reason to try another route, not a monetized punishment.

Do not add DataStore persistence until the Legacy schema, migration, failure and recovery behavior are designed and tested.

## 7. Multiplayer direction

- The game is multiplayer and co-op-friendly, but every MVP activity must work solo.
- Players should be able to explore together, help with encounters and share discoveries.
- Friendly competition may arise around routes, resource hotspots and short challenges.
- Forced PvP, ranked modes, guild systems and PvPvE are deferred.
- Server owns progression, discovery claims, ability eligibility, encounter outcomes and rewards.
- Protect onboarding and recovery from spawn camping, griefing and veteran farming.

## 8. MVP acceptance gates

We do not call the MVP ready because the planned PRs are merged.

A first public-quality MVP requires evidence that:
- a first-time player understands what to do without coaching;
- the first meaningful interaction happens quickly;
- movement, camera and core inputs feel reliable on mobile, keyboard/mouse and gamepad;
- the habitat is interesting to explore for more than one pass;
- Baby Bug, Tank and Glider have understandable, useful and different roles;
- at least one repeatable activity is fun without daily rewards or purchase pressure;
- death/rebirth is fair and Legacy makes a previous life feel valuable;
- multiplayer creates positive moments without breaking solo play;
- performance, exploit resistance, moderation and data safety are acceptable;
- external players voluntarily want another life/session and can explain why.

Track the first-session funnel, meaningful activity completion, evolution choices, ability use/rejections, route choice, challenge replay, D1/D7 retention, device performance and qualitative player feedback. Establish numeric targets only after baseline playtests.

## 9. Scope guardrails

Until the first habitat vertical slice is validated, do not build:
- additional classes or a large creature roster;
- full PvP, ranked combat or complex combat progression;
- breeding, pets, trading, marketplace or crafting trees;
- multiple large biomes or an open-world streaming system;
- premium currency, paid revives, power boosts or pay-to-win products;
- daily chores, punitive streaks or artificial waiting.

Cosmetics and optional supporter products may be considered only after the core loop is enjoyable and the economy is understood.

## 10. Decision rule for every new feature

Before a task enters the roadmap, write:
- player-facing problem/fantasy;
- the moment in the core loop it improves;
- new decision or gameplay verb;
- smallest testable prototype;
- expected player outcome and measurement;
- risks, trade-offs and counterplay;
- what existing task will be delayed or removed.

If these answers are unclear, the task is not ready for implementation.

---

## Current product decision

**Build a compact, multiplayer creature-evolution PvE exploration/survival adventure in a miniature living ecosystem. Prove one excellent habitat and a few meaningful activities before expanding classes, combat depth, persistence breadth or monetization.**

Top 1000 is the ambition. Player value, replayability, fairness and evidence are the operating standard.

---

## 11. Approved Hybrid RPG direction (Product Vision v2.0)

**Owner approval:** 2026-11-15. The long-term identity is a **Hybrid Creature Exploration RPG**. This is approval of product direction, not approval to implement every future system immediately.

The existing MVP contract remains intentionally narrow: prove an enjoyable miniature-world exploration loop, meaningful form roles and a repeatable activity before building long-term RPG breadth.

### Progression boundaries

- **Biomass / Growth:** Current Life only. Biomass is the existing growth resource; growth stage is derived from it. It is not Player XP or crafting currency.
- **Evolution:** selected form for the current life. Baby Bug is the agile baseline; Tank and Glider remain role prototypes until playtested.
- **Naturalist XP / Rank:** future persistent player progression. XP is the only value; Rank is derived from XP and is not a second currency. Rewards should be knowledge, cosmetics, optional challenges and access—not permanent raw power.
- **Creature Mastery:** future per-form record of meaningful skill/use. It must not be a grind multiplier or prerequisite for an ability to function.
- **Legacy:** future persistent Bestiary, discoveries, achievements, collections, life history, Naturalist progression, mastery and cosmetics. It is not implemented by this contract.
- **Habitat / Bonds:** future persistent home and creature relationship systems, explicitly post-MVP.

### Activity model

- **Discoveries:** permanent first-time knowledge claims.
- **Life Goals:** temporary objectives for one life.
- **World Challenges:** authored repeatable activities with clear solo completion and anti-farm rules.

Rewards must have one clear purpose: Biomass advances the current life; Naturalist XP advances persistent learning; Legacy records permanent knowledge; cosmetics express identity. Do not add multiple currencies or grant every reward type for every task.

### Death contract

On life end, Current Life state is reset according to the existing lifecycle contract. Future Legacy state must survive death and rejoin. Inventory/material carry-over, item drops, extraction and companion safety are unresolved design questions and must not be implemented by assumption. The actual current implementation is described in README/source; persistent Legacy and DataStore are not yet implemented.

### MVP boundary

No Naturalist XP/Rank, Mastery, persistent quests, DataStore, foraging catalogue, companions, Habitat building, creature utility automation, breeding, trading, factories, bosses or new biomes are added to TT-P3-02. The current task remains a small exploration loop using existing systems only.

For the technical progression contract and future service/data boundaries, see **Progression & Legacy Architecture Addendum**. The Master Roadmap remains the sole execution plan.
