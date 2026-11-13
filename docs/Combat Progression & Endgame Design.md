# Tiny Titans — Deferred Combat & Endgame Design Reference

**Document:** Combat and retention design direction  
**Version:** 0.1  
**Date:** November 2026  
**Status:** Deferred design reference — not approved MVP scope. Use only when the Master Roadmap reaches a validated need for combat depth or endgame systems.  
**Related:** Evolution Adventure Sandbox Roadmap v0.1; TT-P0-02R — Evolution Sandbox Architecture & Product Pivot; Tiny Titans Master Roadmap v0.1.

**Historical note:** Section 13 records an earlier progression/evolution design gate. The current product definition and implementation order are in Gameplay Blueprint & MVP Contract and Tiny Titans Master Roadmap.

---

## 1. Product intent

Tiny Titans should grow from a small creature evolution prototype into a multiplayer evolution adventure with a deep, readable combat system, meaningful long-term progression and activities that remain engaging after a player reaches the current level cap.

An exploratory long-term idea is **4–6 genuinely distinct evolution classes/forms**, not dozens of shallow variants. This is not an approved launch roster or a reason to add classes now. The player should have reasons to:
- learn the strengths, weaknesses and matchups of their form;
- improve through practice and meaningful progression over several days of play;
- explore, hunt, gather, defend, cooperate and compete;
- return after reaching the current progression cap;
- help friends who are newer or less progressed without trivialising their experience;
- take part in group encounters, challenges, contracts and world events.

This is a long-term product direction, not a request to implement all systems in the current prototype. The project should build and validate the combat foundation before expanding its scope.

**Design promise:** skill, decisions, teamwork and knowledge should matter more than simply having the highest level or the largest numbers.

## 2. Design principles

1. **Readable before complex.** Players must understand why an attack hit, missed, was blocked or interrupted.
2. **Skill before stat advantage.** Timing, positioning, stamina/energy management, telegraphs, spacing and counterplay should meaningfully affect outcomes.
3. **Distinct forms, shared rules.** Each form has a clear role and signature mechanics, but all forms participate in one coherent combat system.
4. **No universally dominant form.** Matchups and environments create situational strengths; no class should win every encounter.
5. **Progression adds options, not unchecked power.** New abilities, builds, cosmetics, mastery and access can deepen play without creating an insurmountable veteran advantage.
6. **PvE is a core activity; PvP is an optional expression of mastery.** Players must be able to enjoy and progress without being forced to fight other players.
7. **Cooperation is valuable at every level.** Helping a weaker friend should be useful and enjoyable for both players.
8. **Endgame is a loop, not a final number.** A level cap must lead into mastery, group goals, rotating challenges, discoveries and social activities.
9. **Fairness is measured.** “Perfect balance” is not a realistic one-time deliverable; balance must be iteratively tested using telemetry, playtests and matchup evidence.
10. **No monetised combat advantage.** Avoid paid damage, health, cooldown, progression or resurrection advantages.

## 3. Evolution roster: target 4–6 forms

The long-term target is a roster of **four to six forms**. Each form must be a complete gameplay identity with:
- a distinct combat and ecosystem role;
- at least one signature mechanic that creates decisions;
- a clear strength and a meaningful weakness;
- readable attack, defence, hit, recovery and ability feedback;
- viable solo play and a useful team contribution;
- at least one PvE use case and a considered PvP matchup;
- counters and counterplay that opponents can learn;
- accessible controls on keyboard, touch and gamepad.

### 3.1 Candidate role matrix

These are role directions for design exploration, not final class names, stats or approved implementation scope.

| Role direction | Combat identity | Strengths to explore | Trade-offs to explore |
|---|---|---|---|
| **Tank / Guardian** | Protect, withstand, hold space, peel threats away from allies | Defence, interruption resistance, protection and control of narrow routes | Lower chase potential, predictable commitment, vulnerable to repositioning or sustained kiting |
| **Glider / Skirmisher** | Reposition, evade, strike and disengage | Mobility, vertical routes, spacing and escape options | Fragile under pressure, limited control in confined spaces, punishable recovery |
| **Striker / Hunter** | Commit to accurate attacks and punish openings | Burst windows, tracking, pursuit or execution of exposed targets | Requires timing and commitment; vulnerable when attacks miss or are baited |
| **Support / Warden** | Sustain allies, create openings and improve team coordination | Protection, rescue, limited recovery or team utility | Lower solo burst; support effects need counterplay and clear limits |
| **Controller / Disruptor** | Deny routes, interrupt, slow or reshape the fight | Zone control, traps, debuffs or forced repositioning | Setup time, limited direct damage, counterable tools and cooldown windows |
| **Aqua / Burrow / Ambusher** | Exploit terrain and alternate routes to surprise or escape | Terrain-specific traversal, flanks, stealth-like approach or environmental advantages | Strongly dependent on habitat and readable detection/counterplay |

The final roster may combine or replace concepts. Do not force six forms into the game if only four can be made excellent. A smaller, balanced roster is better than a larger roster with redundant mechanics.

### 3.2 Release strategy

- **Prototype stage:** retain Tank and Glider as the first two forms and validate their basic identity. Do not interpret their current prototype abilities as finished combat kits.
- **First combat-ready roster:** target four complete forms, with at least two viable team compositions and no obvious dominant pick.
- **Expansion:** add a fifth or sixth form only when it creates a new tactical interaction, traversal option or team role that the existing roster cannot provide.
- Each new form must pass a design review, PvE test, PvP matchup test, accessibility test and regression test before release.

## 4. Combat system foundation

The combat system should feel responsive, intentional and learnable. It should not be reduced to repeatedly pressing an attack button while comparing health and damage values.

### 4.1 Core combat loop

A typical encounter should support the following decisions:

1. Read the opponent, NPC behaviour, terrain and telegraphs.
2. Choose whether to engage, evade, block, reposition or retreat.
3. Manage attack commitment, recovery, defensive windows and ability cooldowns.
4. Create or exploit an opening using timing, positioning or a form-specific ability.
5. Respond to the opponent's counterplay.
6. Resolve the encounter and award rewards appropriate to its risk and context.

### 4.2 Combat building blocks to design

The architecture and later combat design milestone should define:
- basic attacks and form-specific attacks;
- wind-up, active and recovery windows;
- hit detection and server-authoritative damage resolution;
- hit reactions, interruption and stagger rules;
- defensive actions such as block, dodge, parry or guard-break where justified;
- stamina/energy or another clearly defined combat resource;
- cooldowns and ability state transitions;
- range, line of sight, facing and terrain rules;
- crowd control limits and diminishing returns;
- death, defeat, escape and respawn interactions;
- clear audio, visual and UI telegraphs;
- accessibility and input parity across devices.

Do not implement every possible mechanic by default. Choose a compact set that produces depth through interaction. Avoid unavoidable chain-stuns, invisible damage, excessive screen effects and long periods where a player cannot act.

### 4.3 Server authority and exploit resistance

All consequential combat outcomes must be validated by the server. The client may request an action and present immediate cosmetic feedback, but it must not decide:
- whether a hit landed;
- damage, healing or status duration;
- attack range, line of sight or valid target;
- cooldown completion or resource availability;
- kill credit, rewards or progression;
- whether a player is alive, defeated, protected or in a safe zone.

The server must validate player state, action identifiers, timing, cooldowns, distance, direction/line of sight where relevant, target validity and rate limits. Remote spam, fabricated targets, impossible attack cadence and client-side stat changes must not create rewards or damage.

## 5. Balance framework

Balance should be treated as a continuous process with evidence, not as a claim that the game is “perfectly balanced”.

### 5.1 What must be balanced

- Form matchups and win rates, segmented by player skill and progression.
- Time-to-defeat and time-to-escape.
- Damage, defence, mobility, control and utility trade-offs.
- Solo effectiveness versus team contribution.
- PvE threat difficulty and reward efficiency.
- Resource and cooldown economy.
- Terrain and map advantages.
- New-player survival and veteran-versus-new-player encounters.
- Input/device differences, especially mobile versus keyboard/gamepad.

### 5.2 Balance rules

- No form should dominate across all maps, modes and opponent types.
- A counter must be learnable and realistically executable; “counterplay” cannot exist only on paper.
- Mobility must not become permanent immunity or an effortless escape from every fight.
- Defensive builds must not create endless stalemates.
- Crowd control must have limits and opportunities to respond.
- Support abilities must be useful without making teams unkillable.
- High burst must require a readable setup, commitment or vulnerability.
- Environmental advantages should create decisions, not guaranteed wins.
- Level differences should not decide every encounter before player skill matters.

### 5.3 Validation loop and telemetry

For each form and combat update, collect:
- pick rate and matchup win rate;
- encounter duration and outcome;
- damage dealt/received and healing/mitigation;
- ability usage, success, interruption and rejection reasons;
- deaths, escapes and repeated rematches;
- performance by progression bracket, skill proxy, team size and device;
- PvE completion/failure rates and reward-per-minute;
- qualitative player reports of unfairness, confusion and satisfying counterplay.

Investigate outliers rather than reacting to one match. Use controlled playtests and staged releases. Tune one or a small number of variables at a time, keep a record of changes, and re-test regressions. Do not set arbitrary numeric balance targets until baseline data exists.

## 6. Progression designed for multiple days

Progression should offer meaningful goals over several days of normal play, without artificial waiting, forced daily logins or an exhausting grind.

A player should not reach the meaningful end of progression in one short session. At the same time, progression must respect different play schedules: progress should come from playing well and choosing activities, not from waiting for a timer to expire.

### 6.1 Separate progression tracks

Use several complementary tracks rather than one endlessly increasing level:

1. **Current Life growth:** temporary Biomass/growth and current-life evolution. Resets on death according to the Life contract.
2. **Account / Legacy progression:** persistent discoveries, bestiary, achievements, collections, cosmetics, life history and access to new choices.
3. **Form mastery:** progress earned by learning and using a particular form. It should unlock sidegrades, alternate ability choices, visual identity and mastery challenges—not unlimited raw stat scaling.
4. **Combat skill:** player knowledge and execution. This is primarily demonstrated through play, not automatically granted by level.
5. **World and activity progression:** habitat discoveries, quest chains, boss/event records and cooperative accomplishments.

The architecture milestone must explicitly distinguish these from temporary Current-Life state and determine which records persist through death, disconnect and rejoin.

### 6.2 Multi-day progression shape

Design the progression curve around several layers:
- **First session:** understand movement, gathering, survival, first growth milestones and the first meaningful evolution choice.
- **Early days:** learn the first form, complete introductory quests, discover habitat routes and meet basic NPC threats.
- **Mid progression:** unlock additional forms/choices, develop form mastery, encounter more demanding NPCs and participate in cooperative activities.
- **Advanced progression:** build and test alternative loadouts, tackle elite encounters, complete longer quest chains, contribute to group objectives and enter optional PvP activities.
- **Current cap:** shift emphasis from raw level increases to mastery, collection completion, challenge tiers, social goals, seasonal/rotating activities and skill expression.

Exact levels, XP amounts, session counts and time-to-cap must be set only after playtests and progression-economy modelling. Do not use arbitrary multi-day timers as a substitute for content.

### 6.3 Reward quality

Rewards should have a clear purpose:
- new tactical choices or sidegrades;
- form mastery milestones;
- new challenges, routes or encounters;
- bestiary and discovery completion;
- cosmetics, markings, emotes and visual identity;
- titles, badges and visible accomplishments;
- contribution records and social recognition.

Avoid permanent damage/health multipliers that make older players strictly stronger. Avoid making the only efficient progression path PvP kills or repetitive farming of the weakest NPC.

## 7. Endgame: what happens at the current level cap?

Reaching the current cap should change the player's goals, not end the game. Endgame should combine repeatable skill challenges, group activities, collection goals, social contribution and optional competition.

### 7.1 Repeatable PvE challenges

- **Elite hunts:** stronger versions of known NPCs with distinct mechanics, telegraphs and counterplay.
- **Boss encounters:** multi-stage fights with team roles, environmental mechanics and rewards for participation.
- **Hunt contracts:** rotating targets, tracking clues, optional modifiers and clear completion conditions.
- **Survival trials:** defend an area, escort a creature, survive escalating threats or hold a location.
- **Habitat challenges:** traversal races, time trials, resource routes and form-specific challenges.
- **Discovery expeditions:** hidden paths, rare species observations, environmental puzzles and multi-step exploration.
- **Remixed encounters:** rotate modifiers or objectives so familiar content asks for different decisions.

Rewards should include mastery, cosmetics, discoveries and useful sidegrades. Avoid making one repeatable activity the only rational source of progression.

### 7.2 Cooperative play and helping weaker friends

Helping a newer or lower-progress friend should be a first-class activity, not charity that wastes the veteran's time.

Design options:
- **Mentor / guide objectives:** a veteran helps a friend learn movement, survive a hunt, discover a landmark or complete a first evolution.
- **Party-scaled encounters:** NPC health, mechanics, objectives and reward contribution adapt to party size and capability without simply inflating enemy health.
- **Downed-player rescue:** allies can protect, revive or escort a defeated teammate where the mode rules allow it; rescue must have risk and counterplay.
- **Co-op contracts:** objectives that require different roles, such as one player holding a threat while another activates an environmental mechanism.
- **Shared discovery:** party members can cooperate to reveal clues and complete an expedition, while each player receives appropriate personal credit.
- **Mentor rewards:** cosmetic recognition, titles, contribution records or capped mentor currency—not repeatable power farming.
- **Friend catch-up:** give a newer player a fair way to participate in relevant encounters, while preserving their own meaningful choices and progression.

Anti-abuse requirements:
- no unlimited reward for repeatedly helping the same account with trivial tasks;
- diminishing or capped mentor rewards for repeated identical runs;
- rewards tied to genuine participation and objective completion;
- avoid letting high-level players complete every objective while the new player passively receives full credit;
- preserve the newer player's agency and learning experience.

### 7.3 PvP and competitive activities

PvP should be optional and introduced after the combat foundation is validated.

Potential modes:
- consensual duels and practice arenas;
- opt-in contested areas or objectives;
- structured team events;
- limited-time tournaments or ranked trials only when matchmaking and balance data support them.

Fairness requirements:
- safe starting areas and clear PvP state/zone indicators;
- no surprise attacks in protected spaces;
- no excessive rewards for killing substantially weaker players;
- no repeatable farming of the same opponent;
- rewards based on fair participation, objective contribution and opponent/context strength;
- separate competitive rewards (cosmetics, titles, rating or event points) from raw power;
- consider level or power brackets, normalized stats or other fair-play rules if progression gaps overwhelm skill.

Do not make PvP mandatory for core progression. A player should be able to reach meaningful account progression through PvE, exploration, gathering, quests and cooperative play.

### 7.4 PvPvE and world events

A distinctive longer-term direction is shared encounters where players cooperate against a dangerous NPC or environmental threat while competing for objectives or optional rewards.

Examples:
- a roaming predator that threatens multiple players and resource routes;
- a boss whose mechanics reward different forms working together;
- a contested resource event where players can cooperate, negotiate or compete;
- an expedition in which teams race to complete objectives while managing shared NPC threats.

The rules must be explicit: when cooperation is expected, when PvP is permitted, how rewards are attributed and how griefing is prevented. Do not mix unrestricted PvP into a cooperative event without clear consent and signalling.

## 8. Death, defeat and reward integrity

Combat must fit the existing Current Life / Evolution / Legacy model.

Proposed rules:
- Losing a fight may end the current life, but should not erase persistent Legacy.
- Current-life Biomass, temporary upgrades and the current-life evolution path reset according to the Life Reset contract.
- Discoveries, bestiary entries, achievements and earned account-level records remain.
- The player receives a concise recap explaining meaningful progress and the cause/context of defeat where possible.
- Do not grant large amounts of Biomass for ordinary player kills.
- PvP rewards should be limited, context-aware and resistant to farming.
- PvE rewards should reflect encounter risk, contribution and completion, not merely tagging an enemy once.
- Avoid death loops in which a new player repeatedly loses progress to a much stronger player.

Exact reward tables and defeat rules remain design decisions for the combat/economy milestone.

## 9. Proposed roadmap placement

This document extends the existing roadmap; it does not replace its milestones.

| Phase | Combat and progression responsibility |
|---|---|
| **P0 — Product & architecture** | Record the 4–6 form target, combat design principles, progression tracks, server-authority requirements, Current Life/Legacy boundaries and future endgame intent. No combat implementation. |
| **P1 — Core life cycle** | Ensure growth, death and rebirth can support multiple activity sources and cleanly separate temporary and persistent progress. |
| **P2 — Evolution system** | Make the initial forms distinct and configurable. Prepare extension points for 4–6 forms without implementing the full roster. Task sequence: P2-01 design gate (documentation only; section 13 of this document), then P2-02 creature definitions, P2-03 ability definitions, P2-04 data-driven evolution UI, P2-05 Baby Bug visual character, P2-06 first creatures and AI, P2-07 combat and interaction (P2-06 and P2-07 are the limited prototypes of the P3.5 design gate, run in the greybox arena), P2-08 Baby Bug, Tank and Glider gameplay validation against mobs, then P2-09 progression UX and balance validation (see the Migration Plan). |
| **P3 — First Habitat** | Build safe and risky spaces, readable routes, NPC encounter locations and traversal opportunities for the first forms. |
| **P3.5 — Combat & Ecosystem Design** | Dedicated design and prototype milestone: combat rules, first PvE encounter, damage/defence/cooldown model, telegraphs, counterplay, reward economy, PvP boundaries and balance test plan. |
| **P4 — Adventure & Survival** | Implement the first polished PvE loop: a small number of NPC behaviours, hunt/defence encounters, survival threats and rewards. Validate fun before scaling. |
| **P5 — Legacy & persistence** | Persist discoveries, bestiary, achievements, form mastery and long-term progression with versioned data and safe migration. |
| **P6 — Multiplayer experiences** | Add co-op contracts, mentor/helping-friends loops, group events and only then controlled PvP/PvPvE tests. |
| **P7 — Retention, identity & launch readiness** | Expand challenge rotation, endgame, cosmetics, accessibility, analytics, balance iteration and launch quality. |

Phase P3.5 is a proposed roadmap addition. Its scope and acceptance criteria should be formalized after P0 architecture review; it is not authorization to skip the existing audit or begin combat implementation now.

## 10. MVP boundaries and explicit non-goals

Do not implement all of the following in the current prototype:
- a complete six-form roster;
- a large competitive PvP mode;
- ranked matchmaking or esports-style systems;
- complex boss raids and many NPC species;
- a full mentor economy or elaborate guild/clan system;
- dozens of progression currencies;
- permanent combat power purchased with Robux;
- long artificial timers designed only to force daily returns.

The first combat vertical slice should be small and excellent: a small set of combat actions, one or two readable NPC encounters, clear rewards, meaningful form differences and repeatable tests.

## 11. Acceptance criteria for future design and implementation

Before calling the combat system ready for broad release, demonstrate that:
- each released form has a clear role, strength, weakness and counterplay;
- players can explain why they won or lost an encounter;
- server validation prevents clients from deciding combat outcomes or rewards;
- PvE offers meaningful growth/progression without requiring PvP;
- PvP is clearly optional and protected by fair-play rules;
- new players can participate with experienced friends without being carried passively or farmed;
- the progression curve has meaningful goals across multiple days of normal play;
- the current level cap has repeatable mastery, cooperative, discovery and challenge activities;
- rewards do not create runaway permanent power gaps;
- balance decisions are based on playtests and telemetry, not intuition alone;
- mobile and gamepad players have viable controls and readable feedback.

## 12. Open decisions

The following should be decided through design reviews and playtests, not guessed in advance:
- final four-to-six form roster and whether roles are classes, species or evolution branches;
- exact combat resource model and defensive mechanics;
- whether PvP uses zones, opt-in modes, duels or a combination;
- how defeat interacts with current-life evolution and party rescue;
- exact level/mastery structure, progression pace and reward currencies;
- how party scaling and mentor credit are calculated;
- whether competitive modes normalize stats or use progression brackets;
- which endgame activities are sustainable with the team's content capacity.

The P2-01 gate adds the progression-specific questions Q-P2-1 to Q-P2-6 in section 13.11 (growth-stage access, milestone and ceiling values, the value of food at the ceiling, a Tank world interaction before combat, deferring evolution, first-habitat discoveries).

---

## 13. P2-01 — Progression & Evolution Design Gate

**Status:** PROPOSED design, documentation only. This section is the output of task P2-01. No code, remote, service, DataStore, form, ability or monetization was added or changed by it, and no playtest was run to write it: every number below is a **hypothesis**, and no observed data is recorded here.

Decisions the product owner has already stated in earlier briefs are marked **APPROVED DESIGN**. Everything else is a recommendation that still needs owner approval and, where marked, a playtest.

### 13.1 Status labels used in this section

| Label | Meaning |
|---|---|
| **IMPLEMENTED** | Exists in the code of the audited baseline (read from the source, not from older documents). Not the same as validated in Roblox Studio |
| **APPROVED DESIGN** | Stated by the product owner; the documents must not contradict it |
| **PROPOSED** | A reasoned recommendation that needs owner approval |
| **FUTURE** | Intended direction, assigned to a later phase; not committed |
| **OUT OF SCOPE** | Deliberately not part of P2-01 or of the first release |
| **REQUIRES PLAYTEST** | A hypothesis or number that must be measured before it is relied on |

### 13.2 What exists today (IMPLEMENTED, verified in code)

Verified against the repository source at the start of P2-01 (the merged baseline plus the P1-05 lifecycle hardening work). Where an older document disagrees with the code, the code is the source of truth.

| Area | Current behavior | Where |
|---|---|---|
| Forms | `BABY_BUG` (starter), `TANK`, `GLIDER` | `Config.BaseForm`, `Config.EvolutionForms` |
| Biomass | Gained only from food: 10 per item. Capped at the evolution requirement | `Config.FoodBiomass`, `PlayerDataService`, `Growth.AddBiomass` |
| Evolution requirement | 100 Biomass (`EvolutionBiomassRequired`); this constant is also the Biomass cap | `Config`, `PlayerDataService.CanGainBiomass` |
| Growth | Three stages derived from Biomass: 0, 30, 60 (scale 0.6, 0.8, 1.0), tweened over 0.8 s. Independent of the evolution requirement | `Config.GrowthStages`, `GrowthService` |
| Food | 8 fixed markers, one pickup type, respawn 8 s after collection, pickup range 5 studs | `FoodService`, `Config`, `Workspace/Arena/FoodSpawns` |
| Evolution | Explicit two-step choice, offered when Biomass reaches the requirement; the server accepts a request only while the character is alive; one-time per life; server-validated and rate-limited | `EvolutionService`, `Evolution.lua`, `EvolutionUIController` |
| Tank | Defensive Shell: key Q, 3 s, cooldown 12 s from activation. **Visual only**: no damage reduction, no effect on anything | `AbilityService`, `Config` |
| Glider | Air Glide: key Q, only while airborne, up to 3 s, cooldown 10 s, cancels 65% of gravity while rising and 90% while descending (TT-P2-05B), landing ends it. Real movement effect | `AbilityService`, `Config` |
| Death and reset | Death ends the life; Biomass, form, ability state and cooldowns, growth visuals reset exactly once; the player begins the next life from a recap | `LifeService`, `ResetService`, `RespawnService` |
| Recap | Shows life duration and highest form only | `LifeRecapController` |
| Environment | One greybox arena; 3 glider-only platforms (tops at Y 16 and 20) | `Workspace/Arena` |
| Not present | Damage, health, hazards, NPCs, PvE, PvP, a second resource, rare resources, discoveries, Legacy, persistence, telemetry | n/a |

Validation status: pure unit tests exist for the shared rules; they were not executed in the authoring environment. The only Studio evidence on record is the owner's reported Play Solo observations (spawn, walking, jumping, food, HUD, growth). No Studio validation of the abilities, evolution flow, lifecycle or multiplayer is recorded in the repository.

Gaps against the intended design (these motivate the rest of this section):

1. **Progression is one meter.** Ten identical pickups reach evolution; milestones come at pickups 3 and 6; because the cap equals the requirement, a player at 100 Biomass can collect nothing more, so after evolving there is nothing left to earn.
2. **One activity.** Collecting pickups is the only source of progress, and the 8-second respawn makes waiting for markers part of the loop.
3. **Tank has no world interaction** (its shell is visual). Glider has one: the glider-only platforms, whose reachability is an analytic estimate, not a Studio result.
4. **No risk.** Without damage, hazards or threats, a life in practice only ends when the player resets the character, so death carries no information.
5. **Nothing carries over.** There are no discoveries and no Legacy, so a new life has no reason to differ from the last.

### 13.3 Progression layers

**APPROVED DESIGN (boundary):** death resets the current life, not all player progress. Legacy never grants permanent raw combat power. Baby Bug is the starter form, not one of the four target classes.

| Layer | What it is | Resets on death? |
|---|---|---|
| **A. Current Life** | Temporary state of one life | Yes |
| **B. Evolution** | The catalog of forms, which of them may be offered now, and the form selected in this life | The selection resets; the catalog does not |
| **C. Legacy** | Persistent knowledge, identity and access | No |

**A. Current Life (what resets and why).** The principle: the player loses the creature, not themselves.

| State | Resets? | Reason |
|---|---|---|
| Biomass | Yes (IMPLEMENTED) | It is the run's growth; keeping it would erase the stakes of dying |
| Growth stage and body scale | Yes (IMPLEMENTED) | Derived from Biomass |
| Selected form | Yes, to `BABY_BUG` (IMPLEMENTED) | A form is a decision made in a life |
| Ability cooldowns and active effects | Yes (IMPLEMENTED) | A new life must start from a clean, predictable state |
| Temporary upgrades, current objectives | Yes (FUTURE) | Run-scoped by definition |
| Life statistics for the recap (start time, highest form, later discoveries made) | Cleared after the recap is built (partly IMPLEMENTED) | They describe a finished life |
| Anti-spam rate-limit timestamps | No (IMPLEMENTED) | Connection-scoped, not life state |

**B. Evolution.**

| Question | Recommendation |
|---|---|
| Forms available | Starter `BABY_BUG` plus the evolved forms. Today two (Tank, Glider); target four in the first combat-ready roster (section 3). **FUTURE:** Striker / Hunter and a Support / Controller role; they are not designed or committed. No fifth or sixth form before validation |
| Requirements | A form is offered when its requirement is met. Today the requirement is one Biomass number shared by both forms. **PROPOSED:** keep one explicit requirement per form in data (P2-02), so requirements can later differ or combine with discovery |
| Selection rules | Explicit choice, two steps, validated by the server, once per life (**IMPLEMENTED**; recommended to keep) |
| Permanent for the life? | **Yes**, for the first release (IMPLEMENTED; PROPOSED to keep). Changing form mid-life would invalidate the trade-offs that make the choice meaningful |
| Further evolution or specialization | **PROPOSED:** no multi-stage evolution tree in the first release. Added depth should come from form mastery sidegrades (section 6.1, **FUTURE**) rather than a second evolution step. Re-evaluate only with playtest evidence that one choice is too shallow |
| Discovered vs available vs selected | Three different things: **discovered** (Legacy knowledge), **available** (may be offered in this life), **selected** (this life's form). Seeing a form never makes it available |

**C. Legacy (design concept only).**

| Candidate feature | Purpose | Placement |
|---|---|---|
| Creature encyclopedia (forms and species seen) | Curiosity, a reason to try the other form | **First playable release (MVP), small**: forms plus a handful of habitat species (**PROPOSED**) |
| Discovered territories and landmarks | Reward exploration; feeds the recap | **MVP, small** (PROPOSED) |
| Life history (last N lives: duration, highest form) | A sense of a story across lives | **MVP, small** (PROPOSED); uses what the recap already computes |
| A few achievements | Short-term goals across lives | **MVP, very few** (PROPOSED) |
| Secrets and exploration records | Replayable discovery | MVP only if the first habitat contains them (P3) |
| Collections, cosmetic unlocks | Identity | **Later (P7)** |
| Form mastery sidegrades | Depth per form without a tree | **Later (P5 or after validation)** |
| Permanent unlocks of new evolution options | Expand future choices | **Later**, only once more than two evolved forms exist; must unlock options, never power |

Rules for Legacy: it records knowledge, options and identity; it must not grant permanent combat power or resource multipliers; a new player must never be fundamentally weaker than a veteran; a discovery must not teleport the player or bypass traversal. Persistence (DataStore) is **OUT OF SCOPE** for P2-01 and belongs to P5.

### 13.4 The one-life gameplay loop

**PROPOSED; REQUIRES PLAYTEST.** The loop avoids "collect food, wait for respawn, collect food, evolve" by giving every phase a decision and a different kind of reward. Items marked FUTURE depend on later phases (habitat P3, combat design P3.5, adventure P4, Legacy P5); the loop is the target, not a description of the current build.

| # | Phase | Player activity | Immediate goal | Decision or risk | Reward or feedback | Why it is not repetitive |
|---|---|---|---|---|---|---|
| 1 | Spawn as Baby Bug | Move, jump, see the first pickup (IMPLEMENTED) | Learn controls and the first resource | Which direction to explore first | First Biomass and a visible growth change | Short, taught by doing, no waiting |
| 2 | Explore | Move through a habitat with several zones (FUTURE, P3) | Find resource clusters and landmarks | Which route; safe versus risky areas | Discoveries (Legacy candidates), new vantage points | Different routes and zones, not a single circuit |
| 3 | Collect resources | Common food (IMPLEMENTED) plus rarer sources in riskier spots (FUTURE) | Fill the growth curve | Safe common food versus risky rare food | Larger Biomass steps, a discovery record for new sources | Sources differ in risk and place, so one farming spot does not dominate |
| 4 | Grow through milestones | Reach growth milestones (3 stages IMPLEMENTED; a longer curve PROPOSED) | The next milestone | When to push on versus explore | Visible change; **hypothesis:** later stages also give access (for example fitting or not fitting through gaps), never raw power | Milestones arrive between other activities, not only at the end of a meter |
| 5 | Evolution decision | Choose Tank or Glider (IMPLEMENTED flow) | Pick a form | A permanent choice for this life, made with both forms previewed and ideally after the player has seen what each can do in the world | Identity change, toast, new ability | One clear decision with real trade-offs (13.6) |
| 6 | New opportunities | Use the form's ability and world interactions (Glider: partly IMPLEMENTED; Tank: FUTURE) | Do something only this form does well | Where and when to use a cooldown ability | Access to places or routes the other form handles worse | The two forms play differently, so a second life invites the other choice |
| 7 | Risk and consequences | Meet hazards or threats (FUTURE, P3.5 and P4) | Survive and collect | Fight, avoid or retreat; risk a rare resource | Reward for risk | Risk makes decisions matter; without it the loop collapses to grind |
| 8 | Die or end the life | The life ends (today only by reset; FUTURE: threats and hazards) | Learn why | None | A clear reason | Death is information, not just a reset |
| 9 | Life Recap | Read a short summary (IMPLEMENTED: duration, highest form; FUTURE: cause, discoveries, new Legacy entries, a suggested next goal) | Understand what happened and what to try next | Begin a new life now | A useful summary and a next goal | The recap shows what is new (discoveries), so each life differs on paper |
| 10 | Another life | Begin again as Baby Bug (IMPLEMENTED) | A goal the last life left open | Which form, route or undiscovered thing to try | Progress on Legacy goals without extra power | Reasons to return: an unseen form, undiscovered entries, a risky resource, friends |

Design checks for the loop (REQUIRES PLAYTEST): a meaningful decision about every one to three minutes of active play; no single activity above an agreed share of active time; the player can say why they chose their form; the second life is not a copy of the first.

### 13.5 Biomass, growth and evolution

These are three separate systems and must not be treated as one meter:

| System | What it is | Today |
|---|---|---|
| **Biomass** | A resource: a server-owned quantity gained from activities | One number, from food only; capped at the evolution requirement |
| **Growth** | Character progression and its representation: a stage derived from Biomass with visual (and possibly access) consequences | Three stages (0, 30, 60), scale only |
| **Evolution** | A form-selection mechanic: an explicit decision once a requirement is met | One choice at 100 Biomass |

Recommended conceptual model (**PROPOSED**; values are illustrations only):

| Question | Recommendation | Trade-off |
|---|---|---|
| Does Biomass keep accumulating after evolution? | **Yes.** The life's progression continues in the chosen form | Today's code stops at the cap; changing it is a gameplay change that must be approved and tuned (scheduled for P2-09, not P2-02) |
| Is there a cap? | A per-life **ceiling at the final growth milestone**, not at the evolution requirement | Without any ceiling, long lives snowball. With the ceiling at the evolution requirement (today), progress ends at evolution |
| Can growth continue after evolution? | **Yes.** Growth milestones are independent of the evolution requirement; the requirement may sit in the middle of the curve | Needs a longer curve than today's three stages (a Master Roadmap P2 goal) |
| Are milestones independent from evolution requirements? | **Yes.** Two separate sets of data | Slightly more configuration; avoids the "one meter" problem |
| Can Biomass be spent or consumed? | **No** for the first release. Biomass is progress, not a currency; abilities cost cooldowns, not Biomass | Spending would add an economy and more systems for little proven value |
| What happens when the requirement is reached? | Evolution becomes **available**; it is not forced and may be deferred while the player keeps growing | A deferred choice must not block the player; no timeout is proposed |
| Automatic or explicit evolution? | **Explicit** (IMPLEMENTED) | Explicit choice is what makes it a decision |
| What happens to excess Biomass? | At the ceiling, further pickups give no Biomass and the activity's value shifts to discovery or other rewards (a design question, Q-P2-3) | Ignoring excess is simple; an overflow resource would be a second system (not recommended) |

Illustration (hypothesis, not balance): milestones at four Biomass values with the evolution requirement at the second one would let a player evolve early in the curve and keep growing as Tank or Glider for the rest of the life. The current 30/60/100 values are a test progression, not a design.

How to measure pacing (the method is proposed; no measurement exists yet):

| Metric | Definition | Hypothesis (REQUIRES PLAYTEST) | How to measure today |
|---|---|---|---|
| Time to first growth milestone | From the start of a life to the first stage change | One to three minutes | Stopwatch in Studio multi-client tests; later a server-side life log |
| Time to evolution | From the start of a life to the moment evolution becomes available / is chosen | Reached in the first session, in the order of minutes (not hours) | Same |
| Collect versus explore | Share of active time spent collecting versus moving between zones | No single activity dominates (hypothesis: below about two thirds) | Observation sheet; later an activity log |
| Time between meaningful decisions | Gaps between route, source, evolution and risk decisions | Roughly one to three minutes | Observation of recorded sessions |
| Continuation after evolution | Fraction of players who keep playing after evolving, and how long | Most players keep playing for a further stretch rather than quitting at evolution | Observation now; telemetry later (P7) |

No telemetry exists in the project; adding event logging is **OUT OF SCOPE** for P2-01.

### 13.6 Creature roles and evolution identity

Current scope: `BABY_BUG`, `TANK`, `GLIDER`. The "intended" rows are PROPOSED design; the "current" rows are IMPLEMENTED. The prototype abilities are foundations, not finished roles.

| | **Baby Bug** (starter) | **Tank / Guardian** | **Glider / Skirmisher** |
|---|---|---|---|
| Gameplay fantasy | A small, vulnerable newcomer growing up | The one who holds ground and protects | The one who reads the terrain and moves above it |
| Core role | Learn and gather; not a class | Defence, holding space, protecting (future allies) | Mobility, scouting, repositioning, escape |
| Main strength | Smallness (hypothesis: access to narrow places) | Resilience and presence once combat and hazards exist | Reach and route freedom; arrives where others cannot |
| Main weakness | No ability, weakest in every contest | Slow to reposition; predictable; no vertical access | Fragile; the glide is short (3 s) with a 10 s cooldown, air-only and ends on landing; weak in confined spaces |
| Unique gameplay opportunity | Learning the habitat | Holding a position or hazard others avoid (FUTURE) | Vertical routes, shortcuts and scouting |
| Environmental interactions | None | None today. **Gap:** needs at least one real interaction; candidates depend on hazards or threats (P3 or P4) | The 3 glider-only platforms (IMPLEMENTED; reachability not validated in Studio) |
| Prefer this form when | n/a | The area punishes movement or the player wants to stand firm | The player wants to explore, scout, cross gaps or escape |
| Prefer the other form when | Always evolve when ready | Terrain requires vertical traversal or escape | The fight or hazard must be endured, not avoided |
| Current implementation | Starter form, no ability | Shell: visual bubble, 3 s, 12 s cooldown, no effect | Glide: real, bounded, 3 s, 10 s cooldown |

Neither evolved form may be universally superior: the Tank trades mobility and access for resilience that only matters when something can hurt it, the Glider trades resilience for reach. Because no damage system exists yet, the Tank's trade-off cannot be tested today; P2-08 must therefore either define and validate a Tank world interaction that does not need combat, or record that the Tank's identity depends on P3 and P4.

**FUTURE role directions (not committed):** Striker / Hunter and a combined Support / Controller. They are gated by the P3.5 combat design and a validated PvE loop; the target is four roles in the first combat-ready roster, and a fifth or sixth form needs a new tactical role plus design, PvE, PvP and accessibility review (section 3.2).

### 13.7 Resources and activities

Prefer a few high-quality activities over many shallow ones.

| Category | Purpose | Contributes to | Placement |
|---|---|---|---|
| Basic food collection | The baseline loop and the first growth | Biomass | **IMPLEMENTED**; stays in the first release |
| Rare resources | Risk-for-reward choices and variety | Biomass (larger steps) and a discovery record | **PROPOSED** for the first habitat (P3), one or two types at most |
| Exploration and discovery | Reward curiosity; fill the recap | Legacy (primarily) | **PROPOSED**, first habitat (P3); first-time rewards, not repeatable |
| Environmental interactions | Make each form matter in the world | Access to resources and routes (indirect Biomass) | **PROPOSED**, at least one per initial form (P3 and P2-08) |
| Challenges | Skill-based goals (for example a traversal route) | Legacy; optionally Biomass | **PROPOSED**, one traversal challenge in the first habitat (matches the roadmap) |
| Cooperative activities | Playing together | Biomass and Legacy (to be designed) | **FUTURE** (P6); OUT OF SCOPE for the first release |

### 13.8 Anti-grind and fair progression

| Principle | Rule | How it can later be evaluated (REQUIRES PLAYTEST) |
|---|---|---|
| Progress is not only waiting for respawns | Several Biomass sources with different risk and place; no source is the only efficient path | Share of Biomass by source; time idle near respawn markers |
| One spot must not dominate | Rewards depend on zone and risk, not a single best marker | Biomass per minute by area; heat map of where lives are spent |
| Exploration and decisions matter | Discoveries and route choices change what the player gains | Discovery rate; whether players leave the starting area |
| PvP is never required | PvE gives meaningful growth; PvP rewards are optional and limited (section 8) | Share of players progressing with zero PvP |
| Death matters without wasting everything | The life resets, but the recap and Legacy keep the learning | Share who start a second life; sentiment after a first death |
| No permanent combat multipliers from Legacy | Legacy unlocks knowledge and options only | Review of every Legacy reward against this rule |
| Server authority | Every Biomass source is validated on the server (IMPLEMENTED for food) | Exploit review per new source |
| No death-farming | Discovery rewards are first-time, not per life | Check that repeated lives do not repeat the same reward |
| Monetization boundary | No sales of combat advantages, immunity from death or mandatory progression skips | Release checklist |

### 13.9 Retention and monetization principles

Retention should come from reasons to return (an unseen form, undiscovered entries, a risky resource, friends), not from forced daily logins or timers.

Ethical monetization at a conceptual level (PROPOSED; **no products are designed or implemented here**):

- **Cosmetic creature appearances** and markings, cosmetic effects and animations (for example the look of a shell or wings), without changing stats or hitboxes.
- **Non-power progression presentation:** recap styles, titles, profile display of Legacy.
- **Optional customization** such as colors.
- **Convenience** only where it does not affect balance or progression.

Not allowed: paid combat stats, paid exclusive power, paid protection against death, paid resurrection, paid skips of mandatory progression, or selling forms that carry power.

Legacy plus cosmetic identity can support long-term engagement fairly: earned discoveries and achievements unlock identity options, so a veteran can look different but is not stronger.

### 13.10 Playtest and validation plan

Proposed targets are hypotheses. **Observed data: none.** "Runnable today" tells whether the current build can run the scenario at all (the build has no hazards, threats or Legacy).

| # | Scenario | Setup | Actions | Expected result | Observe | Design-failure signals | Runnable today |
|---|---|---|---|---|---|---|---|
| 1 | New player completes a first life | New player, no briefing | Play until the life ends | They find pickups, grow, reach the evolution choice and understand the recap | Where they hesitate; what they say they are doing | They do not know the goal; they idle; they quit before evolution | Partly (no risk or end except reset) |
| 2 | First growth milestone | Fresh life | Collect until the first stage change | The change is noticed and felt as progress | Time to first milestone; reaction | Not noticed; feels like a delay; the time exceeds the target | Yes |
| 3 | Reaching evolution | Continue the same life | Collect until evolution is offered | The player understands what changed and what the choice means | Time to evolution; hesitation | Boredom while collecting; pickups feel identical | Yes |
| 4 | Choosing Tank | At the choice | Choose Tank and play on | The player can say why and sees a role | Whether the player finds something Tank-specific to do | "Nothing changed"; no interaction to use the shell on | Yes, but the shell is visual only |
| 5 | Choosing Glider | At the choice | Choose Glider; try platforms and glides | Different play; reaches places Tank cannot | Use of the glide; platform reach | Glide unused; ledges trivially reachable or unreachable | Yes |
| 6 | Dying before evolution | Early life | Reset the character | A short recap and a quick, willing restart | Time to the next life; reaction | Frustration out of proportion to the time lost | Reset only |
| 7 | Dying after evolution | After the choice | Reset the character | The next life starts as Baby Bug; the player knows what they lost and what to try | Whether they pick the other form next | Feels pointless; the recap is uninformative | Reset only |
| 8 | Starting another life | After a recap | Begin a new life | Clean start; a reason to continue | Choice of form or route; whether they continue | Immediate quit; same path every time | Yes |
| 9 | Repeating the loop | Three or more lives | Keep playing | Lives differ by choices and discoveries | Variety between lives; stated goals | Same path every life; "grind" comments | Limited (few sources of variety) |
| 10 | Two or more players at once | 2 to 3 clients | Progress simultaneously, die and evolve at different times | Independent progress; each sees the other's form | Any cross-talk of state; respawn races | State leaks; stolen pickups feel unfair | Yes |

Signals: qualitative (think-aloud, can the player explain their choice, did they want another life) and quantitative (the metrics in 13.5 and the evaluation signals in 13.8). Quantitative values stay proposals until measured. Studio multi-client runs can time the metrics manually; automated telemetry is FUTURE (P7).

### 13.11 Decision record

| ID | Decision | Status |
|---|---|---|
| D-P2-1 | P2-01 is a documentation-only design gate; creature-definition engineering moves to P2-02 | APPROVED DESIGN |
| D-P2-2 | Death resets the current life, not all progress; Legacy never grants permanent combat power; Baby Bug is not a class | APPROVED DESIGN |
| D-P2-3 | No monetization of combat advantage, death protection, resurrection or mandatory progression skips | APPROVED DESIGN |
| D-P2-4 | Evolution is explicit, server-validated and once per life | IMPLEMENTED; PROPOSED to keep for the first release |
| D-P2-5 | No multi-stage evolution tree in the first release; depth later through mastery sidegrades | PROPOSED |
| D-P2-6 | Biomass keeps accumulating after evolution, with a per-life ceiling at the final growth milestone; growth milestones are independent from the evolution requirement | PROPOSED; REQUIRES PLAYTEST; engineering in P2-09 only after approval |
| D-P2-7 | Biomass is not spent or consumed in the first release | PROPOSED |
| D-P2-8 | Biomass comes from several sources of different risk; no single farming source | PROPOSED |
| D-P2-9 | First-release Legacy is small: encyclopedia, territories, life history, a few achievements | PROPOSED |
| D-P2-10 | Tank must gain a real world interaction before it counts as a validated role | PROPOSED (P2-08) |

Open questions needing owner approval or playtest data:

| ID | Question |
|---|---|
| Q-P2-1 | Should higher growth stages grant access (fitting through gaps, moving objects) or only visuals? |
| Q-P2-2 | What are the milestone values, the evolution requirement and the ceiling? (playtest) |
| Q-P2-3 | What is the value of food once the ceiling is reached? |
| Q-P2-4 | Which Tank world interaction can be validated before combat exists, or does Tank wait for P3 and P4? |
| Q-P2-5 | May a player defer evolution indefinitely, or should the choice expire? |
| Q-P2-6 | Which discoveries ship in the first habitat? |

---

## Guiding principle

**Build a combat system players want to master, progression players want to pursue for days, and endgame activities that give experienced players a reason to bring their friends along.**

Depth should come from distinct forms, readable mechanics, counterplay, cooperation and changing challenges—not from endless stat inflation or grind.
