# Tiny Titans — Combat, Long-Term Progression & Endgame Design

**Document:** Combat and retention design direction  
**Version:** 0.1  
**Date:** November 2026  
**Status:** Proposed product design; implementation scope must be approved through the roadmap and architecture milestones.  
**Related:** Evolution Adventure Sandbox Roadmap v0.1; TT-P0-02R — Evolution Sandbox Architecture & Product Pivot.

---

## 1. Product intent

Tiny Titans should grow from a small creature evolution prototype into a multiplayer evolution adventure with a deep, readable combat system, meaningful long-term progression and activities that remain engaging after a player reaches the current level cap.

The target is **4–6 genuinely distinct evolution classes/forms**, not dozens of shallow variants. The player should have reasons to:
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
| **P2 — Evolution system** | Make the initial forms distinct and configurable. Prepare extension points for 4–6 forms without implementing the full roster. |
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

---

## Guiding principle

**Build a combat system players want to master, progression players want to pursue for days, and endgame activities that give experienced players a reason to bring their friends along.**

Depth should come from distinct forms, readable mechanics, counterplay, cooperation and changing challenges—not from endless stat inflation or grind.
