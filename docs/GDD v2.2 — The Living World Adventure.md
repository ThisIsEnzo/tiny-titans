# Tiny Titans — Game Design Document v4.0
## A replayable Zelda-style adventure for Roblox

**Date:** 2026-11-19  
**Status:** Approved high-level direction; individual story, world and system details remain design proposals until separately reviewed and playtested.  
**Genre:** Action-adventure RPG / open-world dungeon adventure  
**Platform:** Roblox  
**Modes:** Solo and cooperative multiplayer

## 1. High concept

Tiny Titans is an original Roblox adventure game built around the breadth of Zelda gameplay: open-world exploration, traversal, combat, environmental puzzles, tools, equipment, dungeons, bosses, quests, secrets and layered progression.

Players explore an original fantasy world as their standard Roblox avatars. They discover new routes and tools, learn enemy behaviors, solve environmental problems, help characters, complete regional adventures and overcome memorable dungeons and bosses. They can experience the essential adventure alone or share it with friends.

**Player fantasy:** “I am an adventurer in a huge mysterious world. I can explore in my own way, discover useful tools, become more capable, overcome clever challenges and share unforgettable adventures with my friends.”

The project is not a creature simulator or an ecological restoration game. The title Tiny Titans does not require tiny characters, miniature geography or insect protagonists. The world and art direction are original and remain to be designed.

Zelda is the gameplay reference, not an IP template. Tiny Titans must create original characters, story, names, world, art, music, maps, puzzle expression, item designs, UI and encounter choreography.

## 2. Design pillars

1. **Explore:** a connected world with distinct regions, landmarks, secrets, routes, caves, ruins, settlements and optional locations.
2. **Traverse:** satisfying movement and a growing set of ways to reach places, including jumping, climbing, swimming, gliding and authored tools where justified.
3. **Fight:** readable enemies, attack/defense choices, equipment, enemy behaviors, elites and bosses.
4. **Solve:** environmental logic, physical interactions, mechanisms, switches, elemental/environmental rules, multi-step puzzles and dungeon-specific systems.
5. **Acquire and master:** tools, weapons, armor, consumables and upgrades that create new options rather than only larger numbers.
6. **Adventure:** regional stories, NPCs, side quests, dungeons, mini-bosses, bosses and world-changing outcomes.
7. **Play together:** shared exploration, combat, puzzle coordination and optional co-op activities; essential progression remains solo-completable.
8. **Return:** replayable challenges, rematches, alternate tactics, collections, mastery and new adventure chapters.

## 3. Experience structure

The target is a **hybrid open-world + classic dungeon adventure**.

Modern open-world structure contributes freedom, systemic interaction, multiple routes, traversal and discovery. Classic Zelda structure contributes authored dungeons, key-and-lock progression, unique dungeon rules, meaningful tools, mini-bosses, bosses and strong regional arcs.

The world is not required to be fully seamless at all times. Roblox technical constraints, matchmaking and session flow may justify region streaming, portals, dungeon instances or party-owned sessions, provided transitions are understandable and preserve the adventure.

### World layers

- **World map:** connected or logically connected regions with distinct identities, landmarks and routes.
- **Region:** a local story, NPCs, enemies, secrets, side quests, traversal challenges and a major dungeon or equivalent signature challenge where appropriate.
- **Dungeon:** a handcrafted multi-room challenge with a clear internal logic, progressive mastery of its rules, optional secrets, a major encounter and a meaningful reward.
- **Challenge spaces:** optional trials, combat arenas, traversal routes, puzzle rooms and repeatable activities.
- **Social spaces:** settlements, hubs and safe meeting points where players can regroup, trade, prepare and choose goals.

## 4. Core gameplay loops

**Moment-to-moment:** Move → Observe → Choose a route/tool/tactic → Act → Receive readable feedback → Adapt.

**Exploration:** travel → notice a landmark or clue → investigate → solve a traversal or environmental problem → discover a reward or new lead → mark progress.

**Combat:** read enemy behavior → choose positioning and equipment → attack, defend, dodge or use the environment → exploit an opening → recover/reposition → earn a fair reward.

**Dungeon:** enter → learn the dungeon's visual/mechanical language → solve rooms → acquire or use a key/tool → revisit earlier spaces with new understanding → defeat mini-boss or major boss → claim reward → unlock a new possibility.

**Regional adventure:** arrive → meet characters and learn the local problem → explore routes and optional content → complete a main challenge/dungeon → resolve the regional arc → unlock further world opportunities.

**Co-op:** form or join a party → select an activity → coordinate traversal, puzzle actions and combat → share the experience and eligible rewards → continue together or split without corrupting progress.

**Return loop:** choose a new region, side quest, challenge variant, boss rematch, collection goal or co-op activity.

## 5. Player character

The canonical player character is the player's standard Roblox avatar.

- Keep the Roblox avatar visible and recognizable.
- Preserve supported body packages, clothing, accessories and standard character movement/animation.
- No Baby Bug player model, selectable creature forms, Tank/Glider classes or mandatory role selection.
- Do not introduce custom rigging, arbitrary scaling or camera/collision overrides without a separate design and Studio validation gate.
- Any future abilities are player verbs/tools, not character classes. Each must solve a real world or combat problem and have clear limits, cross-platform input and solo alternatives.

The world, equipment, animation polish, effects and camera framing establish the fantasy. The player does not need to become a custom creature.

## 6. Traversal and world interaction

The target mechanic families are listed in the Zelda Mechanics Adaptation Matrix. Candidate systems include:
- responsive walk/run/jump and contextual movement;
- climbing and stamina or another fair traversal limiter;
- swimming, diving and water hazards;
- gliding/falling control;
- ladders, ropes, lifts, moving platforms and authored traversal tools;
- environmental physics and movable objects;
- weather, time-of-day or other world conditions when they create meaningful decisions;
- stealth, hiding and enemy awareness where they support the adventure.

Do not implement every traversal verb as an isolated feature. Each should connect to regions, puzzles, combat or secrets and be validated on touch, keyboard/mouse and gamepad.

## 7. Combat

Combat is a core planned pillar, not an excluded future possibility.

Design goals:
- responsive attacks and defensive actions;
- readable hit feedback, telegraphs, hit reactions and recovery windows;
- multiple enemy archetypes with distinct behaviors and counterplay;
- weapon/tool choices that alter tactics;
- dodge, block/parry or equivalent defensive decisions where controls permit;
- ranged options and environmental opportunities;
- elite encounters, mini-bosses and multi-phase bosses;
- solo and co-op scaling based on encounter behavior, not only inflated health.

Combat must be server-authoritative for consequential hits, damage, drops and boss state. Client prediction/presentation may improve responsiveness but cannot decide rewards or final outcomes. Anti-cheat, latency, ownership and exploit resistance are architectural requirements.

## 8. Puzzles and dungeons

Puzzles should teach a readable rule, invite experimentation and produce a clear response. Candidate families include:
- switches, pressure plates, levers and timed mechanisms;
- movable/rotatable objects, weights and physics;
- light, shadow, sound, wind, water, heat, cold or electricity-like environmental rules;
- sequence, pattern, spatial and observation puzzles;
- keys, locked doors, shortcuts and layered dungeon navigation;
- tools that change how the player interacts with objects;
- optional hidden rooms and alternate solutions;
- co-op coordination puzzles with solo equivalents.

A dungeon should have a coherent identity, a learnable mechanical language, escalating combinations, useful shortcuts, optional secrets, a memorable climax and a reward that changes what the player can do or where they can go.

Do not copy exact Zelda dungeon layouts, puzzle solutions, item silhouettes or boss designs.

## 9. Items, equipment and progression

The long-term design should consider:
- weapons and weapon categories;
- defensive equipment/armor/shields;
- tools and traversal/puzzle items;
- ranged tools/projectiles;
- consumables, healing and preparation;
- recipes/cooking or another preparation system if it supports meaningful choices;
- crafting, repair or upgrade systems if they avoid grind and duplicate currencies;
- equipment upgrades and cosmetic customization;
- inventory organization, quick slots and platform-friendly controls.

Each item must have an authored purpose and more than one meaningful use where possible. Avoid a large inventory of near-identical stat sticks. Durability, breakage, crafting costs, trading and item loss are not locked decisions; test their impact on co-op friction and player trust before approval.

Progression should unlock options, routes, tactics and content. Avoid permanent stat inflation that trivializes old content or makes party balance difficult.

## 10. NPCs, story and quests

The world should contain memorable NPCs, settlements, merchants, regional characters and optional narrative discoveries.

Quest design:
- clear intent and readable next steps without mandatory waypoint dependence;
- authored side quests with exploration, puzzle, combat or social outcomes;
- meaningful rewards and world responses;
- optional stories that can be discovered out of order where practical;
- co-op party participation rules that are clear and fair.

Do not build a generic quest framework before several real quests prove the required abstractions. Avoid long mandatory dialogue and checklist-only errands.

## 11. Solo and co-op contract

Solo and co-op are first-class.

**Solo requirements**
- Every essential region, dungeon, story gate and boss has a solo solution.
- No mandatory class, fixed role, exact player count or waiting for another player.
- Bosses and puzzles may change behavior or provide alternate mechanisms in solo.
- All core controls and UI work for one player on supported devices.

**Co-op requirements**
- Friends can explore, fight, solve and progress together.
- Co-op mechanics should create coordination and shared stories: simultaneous actions, complementary tools, rescue/revive interactions, divided objectives, timing and optional secret routes.
- Co-op difficulty adapts through behavior, enemy composition, attack patterns or additional objectives; do not only multiply health.
- Shared session state is server-authoritative. Personal inventory and records remain protected.
- Late joiners receive correct world state and an understandable route into active content.
- Disconnects, party splits, death and rejoin must not permanently block or corrupt essential progress.
- No griefable permanent switches, resource theft or intentional party lockouts.

**Progress ownership is an open design gate:** decide which story flags belong to the party/session, which belong to each player, how guests retain rewards, and what happens when party members leave. Do not silently choose a persistence model in code.

## 12. Replayability and endgame

Replayability is required, but the game must not become a repetitive grind loop.

Potential layers:
1. **Exploration completion:** secrets, optional caves, collectibles, lore, hidden routes and region mastery.
2. **Combat mastery:** enemy variants, elite encounters, boss rematches and optional challenge rules.
3. **Dungeon replay:** challenge versions, optional modifiers, alternate routes, score/time goals or curated remixes.
4. **Build variety:** meaningful equipment and tool combinations that change approach without creating mandatory power gaps.
5. **Co-op activities:** party challenges, optional coordination puzzles, cooperative boss variants and social expeditions.
6. **World activities:** curated rotating events or region activities only when sustainable and non-punitive.
7. **Long-term content:** new regions, story chapters, dungeons, enemies, bosses and seasonal cosmetic themes.

Main story content remains handcrafted. Replay variants may change constraints, enemy groups, routes, objectives or modifiers, but should not randomize away the authored identity of every dungeon.

New Game Plus or a full campaign reset is a later hypothesis, not an MVP requirement. If introduced, it must preserve player choice, party fairness and a meaningful reason to replay.

## 13. Death, recovery and fairness

Death should create understandable stakes without becoming a monetization lever. Decide and document:
- respawn location and timing;
- what happens to active party members;
- boss/dungeon checkpoint behavior;
- consumable and equipment loss, if any;
- revive/rescue rules;
- disconnect recovery;
- anti-griefing protections.

No paid revive, paid death protection or punitive loss designed to sell relief. Do not port the old per-life Biomass reset model into the adventure without a new design decision.

## 14. Roblox-specific product constraints

- Touch, keyboard/mouse and gamepad are supported design targets from the start.
- Use server authority for combat, progression, puzzle completion, item grants and shared world state.
- Keep UI readable on phone screens; avoid mouse-only interactions and tiny inventory controls.
- Respect Roblox avatar variability and character respawn behavior.
- Use streaming/instance boundaries where needed for performance and social sessions.
- Build scalable enemy, boss and puzzle systems without overengineering a generic framework.
- Plan safe late join, disconnect, rejoin and party lifecycle behavior.
- Performance and replication budgets are design constraints, not late polish.

## 15. First vertical slice — proof of the game

The first vertical slice must prove the identity of the game, not merely demonstrate a greybox.

Target components:
- one polished adventure region with recognizable landmarks and at least two routes;
- a small but expressive enemy roster and one combat encounter;
- one authored puzzle chain using at least two environmental/tool interactions;
- one compact dungeon or dungeon-like challenge with escalating rooms;
- one memorable boss or mini-boss encounter;
- a useful reward/tool that opens a new route or changes an interaction;
- one NPC/quest hook and optional secret;
- complete solo path and a co-op version that creates genuine coordination;
- persistent/party progress semantics defined for the slice;
- touch, keyboard/mouse and gamepad validation.

This is a target design gate, not a claim that current First Habitat already contains these features.

## 16. Evidence gates

A feature is not accepted because it compiles. Require:
- automated pure-rule and server-service tests where practical;
- Studio tests for physics, animation, camera, UI, input, replication and performance;
- one-player and multi-player tests;
- late-join, disconnect, death and rejoin tests;
- external playtests that check comprehension, fun, difficulty, replay intent and willingness to invite friends.

The first vertical slice is successful only when players understand the goal, enjoy the core loop, want to continue and can describe why playing with a friend is better.
