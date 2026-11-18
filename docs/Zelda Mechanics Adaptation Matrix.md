# Tiny Titans — Zelda Mechanics Adaptation Matrix v1.0

**Date:** 2026-11-19  
**Status:** Strategic inventory approved as a design target; individual implementations remain subject to vertical-slice design and playtest.  
**Companion documents:** Product Vision v4.0, GDD v4.0, Gameplay Blueprint v4.0 and Master Roadmap v4.0.

## 1. Purpose

This document inventories the major gameplay mechanic families that make Zelda-style adventures deep and memorable. Tiny Titans intends broad coverage of these families, adapted into an original Roblox adventure designed for solo play, co-op and replayability.

This is a design inventory, not a promise to implement every item in the first release. It is also not a license to reproduce Zelda's protected expression. Use original world fiction, names, characters, art, music, maps, item designs, UI, puzzle layouts, enemy designs and encounter choreography.

**Design target:** combine open-world freedom and systemic interactions with authored dungeons, meaningful tools, structured regional adventures, memorable bosses and long-term secrets.

## 2. Priority definitions

- **P0 — Vertical-slice proof:** needed to demonstrate the Tiny Titans adventure identity. Implement only the smallest coherent version.
- **P1 — Core adventure expansion:** important for a full adventure campaign; add after the vertical slice proves its loop.
- **P2 — Long-term / optional:** useful where it improves replayability, social play or world depth; do not build without evidence.
- **Decision gate:** a design choice that must be resolved before implementation. A mechanic can remain deferred even if its category is part of the long-term vision.

## 3. Mechanic family inventory

| # | Zelda mechanic family | Tiny Titans adaptation target | Priority | Solo / co-op contract | Replayability contribution |
|---:|---|---|---|---|---|
| 1 | Open-world exploration | Original regions with landmarks, routes, caves, ruins, settlements and hidden areas | P0 | All essential routes solo; co-op exploration shares clues and discoveries | Optional routes, secrets and alternate approaches |
| 2 | World map and navigation | Discoverable map, region names, landmarks, player markers and optional navigation aids | P1 | Party map sharing optional; personal discovery state protected | Completion, route planning and hidden map details |
| 3 | Vertical exploration | Layered spaces, heights, caves, towers, cliffs and connected interiors | P0 | No essential route requires another player to boost/carry | New routes and revisiting places with new tools |
| 4 | Core movement | Responsive walk/run/jump, contextual movement and polished camera | P0 | Consistent movement in solo and multiplayer | Skill expression and traversal mastery |
| 5 | Climbing | Climbable authored surfaces, limits and readable stamina/effort rules | P1 | Solo route always exists; co-op may assist but cannot be mandatory | Alternate routes and time/challenge variants |
| 6 | Gliding / falling control | A deliberate aerial traversal verb with clear start, steering and landing rules | P1 | No class lock; solo-compatible routes | Shortcut routes, aerial challenges and secrets |
| 7 | Swimming / diving | Water traversal, underwater spaces, breath or environmental constraints if fun | P1 | Required water routes have solo-safe solutions | Hidden underwater spaces and optional challenges |
| 8 | Mounts / vehicles | Original rideable or controllable transport only if the world needs it | P2 | Party access and passenger rules must be fair | Faster traversal, races and social exploration |
| 9 | Stamina / exertion | Resource that creates traversal/combat choices without frustrating basic movement | P1 | Same rules for all players; no paid stamina advantage | Route planning and challenge mastery |
| 10 | Physics interactions | Push, pull, carry, rotate, stack, roll, launch and weight-based object logic | P0 | Every required physics puzzle has a solo solution; co-op adds parallel handling | Alternate solutions and emergent moments |
| 11 | Environmental systems | Original interactions involving wind, water, heat, cold, light, electricity-like forces and moving elements | P0/P1 | Rules readable in solo; co-op may coordinate multiple systems | System combinations create varied solutions |
| 12 | Weather and time | Weather/time changes only when they alter routes, enemies, puzzles or NPC behavior meaningfully | P2 | Shared world conditions must be synchronized and fair | Changed encounters and optional opportunities |
| 13 | Stealth and awareness | Enemy sight, sound, cover, distraction and readable alert states | P1 | Solo stealth path; co-op can distract or coordinate | Alternate encounter approaches |
| 14 | Combat controls | Responsive attack, defense, dodge/evade and contextual actions | P0 | Combat remains fair in solo and co-op; no mandatory roles | Skill mastery and varied tactics |
| 15 | Weapons | Distinct weapon families with meaningful reach, speed, risk and use cases | P0/P1 | Personal equipment; no forced shared weapon ownership | Build variety and enemy matchup choices |
| 16 | Shields / blocking / parry | Defensive choices with readable timing and counterplay | P1 | Co-op protection/support may be optional | Mastery challenges and tactical depth |
| 17 | Ranged tools | Bows, thrown tools or original ranged equivalents with ammo/cooldown rules | P1 | Solo access to required ranged interactions | Precision challenges and alternate combat |
| 18 | Elemental / utility tools | Original tools that manipulate the world, solve puzzles and create combat options | P0/P1 | Required gates need a solo tool path; avoid class-specific locks | New uses in old regions and puzzle remixes |
| 19 | Enemy archetypes | Distinct enemy families with readable telegraphs, weaknesses, behaviors and counters | P0 | Solo viable; co-op changes behavior/roles, not just health | Matchup mastery and curated variants |
| 20 | Elite enemies / field encounters | Optional high-risk encounters and roaming threats | P1 | Optional or solo-balanced; avoid blocking main route | Rematches, rare rewards and world tension |
| 21 | Bosses | Multi-phase signature encounters with readable patterns, arenas and meaningful rewards | P0 for slice; P1 campaign | Solo behavior authored; co-op adds coordination and fair scaling | Rematches, mastery and challenge modifiers |
| 22 | Health / healing | Clear health model, recovery, checkpoints and consumable use | P0 | Co-op rescue/revive rules plus solo recovery | Challenge modes and preparation choices |
| 23 | Consumables | Healing, temporary utility and preparation items with clear inventory rules | P1 | Personal ownership by default; no resource theft | Different preparation strategies |
| 24 | Cooking / preparation | Optional recipe/preparation system only if ingredients create meaningful tactical choices | P2 | Shared cooking can be social; personal buffs must be fair | Experimentation and loadout variety |
| 25 | Crafting / repair | Optional crafting or repair if it supports exploration and avoids grind/currency bloat | P2 | No mandatory party resource bottlenecks | Long-term goals and equipment expression |
| 26 | Inventory and quick slots | Readable inventory, equipment slots and fast access across mobile/controller/PC | P0 minimal; P1 full | Personal inventory; party sharing is a separate explicit design | Loadout choices and experimentation |
| 27 | Armor / equipment upgrades | Defensive and utility trade-offs, set bonuses only if balanced and readable | P1 | Avoid required roles and power gaps | Builds, collection and optimization |
| 28 | Dungeon structure | Authored multi-room spaces with a coherent mechanic, map logic, shortcuts and escalating mastery | P0 | Complete solo; optional co-op interactions add alternate solutions | Challenge variants and revisits |
| 29 | Keys / locked doors / dungeon tools | Keys, gates, switches and tools that change dungeon navigation | P0/P1 | No permanent party lockout; solo route required | Optional rooms and alternate routing |
| 30 | Dungeon map / compass / hints | Diegetic or UI navigation aids that help without solving the dungeon | P1 | Party map sharing optional; individual readability | Completion and route mastery |
| 31 | Mini-bosses | Skill checks that test the dungeon's rules and reward a useful option | P1 | Solo-balanced; co-op behavior adds coordination | Rematches and mastery |
| 32 | Shrines / compact trials | Original short-form puzzle, combat and traversal trials | P1 | Every trial solo-completable; optional co-op variants | Repeatable bite-sized sessions |
| 33 | NPCs and settlements | Memorable characters, safe hubs, merchants, services and local stories | P0/P1 | Shared spaces and party-friendly interaction | Side stories, social return and world attachment |
| 34 | Main quests / regional arcs | Clear regional goals with environmental, combat and dungeon milestones | P0 | Shared party story rules; solo path remains complete | Story replay and new chapters |
| 35 | Side quests | Optional authored quests with exploration, combat, puzzle and character outcomes | P1 | Guest credit and party eligibility defined | Completion goals and discovery |
| 36 | Collectibles / secrets | Hidden items, lore, cosmetic finds, optional upgrades and completion records | P0/P1 | Personal claim by default; co-op discovery may notify party | Exploration completion and revisits |
| 37 | Economy / merchants | Small, understandable economy with meaningful sinks and no mandatory grind | P1 | No theft or exploitative trading; party purchases explicit | Optional collection and preparation |
| 38 | Progression / unlocks | New tools, routes, regions and story options; avoid raw-stat inflation | P0 | Essential unlocks cannot be blocked by party membership | New possibilities in previously visited areas |
| 39 | Journal / bestiary / records | Optional record of characters, enemies, clues, quests and discoveries | P1 | Personal records; shared clues can be surfaced | Completion and world knowledge |
| 40 | Audio / music / atmosphere | Original music, environmental sound, enemy cues and puzzle feedback | P0 polish; P1 depth | Spatial cues remain understandable in multiplayer | Recognition, immersion and encounter mastery |
| 41 | Camera / targeting / lock-on | Comfortable camera, target selection and optional lock-on where it helps combat | P0 | Stable in crowded co-op fights and on touch/controller | Combat mastery and readability |
| 42 | Death / checkpoints / recovery | Fair respawn, dungeon checkpoints, rescue and rejoin behavior | P0 | Co-op rescue plus solo fallback; no paid revive | Challenge attempts without punitive loss |
| 43 | Party / social systems | Party formation, invite/join, activity ownership, late join and leave behavior | P0 foundation | Core co-op reliability | Friend sessions and repeat visits |
| 44 | Repeatable challenge modes | Boss rematches, dungeon variants, combat/traversal trials and curated modifiers | P0 one slice; P1 expansion | Solo version plus optional co-op rules | Direct replay loop |
| 45 | New Game Plus / campaign replay | Optional campaign replay with altered constraints or retained knowledge | P2 | Party save compatibility must be designed first | Full adventure replay |
| 46 | Photo / emotes / social expression | Optional camera, emotes, titles and social celebration tools | P2 | Shared social expression | Memories and friend engagement |

## 4. Cross-system design rules

A mechanic should not exist as an isolated checklist item. Prefer systems with multiple authored uses.

- A traversal tool should appear in exploration, at least one puzzle and ideally combat or a secret route.
- A weapon family should create distinct tactical decisions, not only different damage numbers.
- An environmental rule should be taught safely, combined later and used in an optional challenge.
- A dungeon tool should matter beyond one door where practical.
- A boss should test skills the player has learned, then reward a new option or meaningful progress.
- A repeatable challenge should remix known rules rather than introduce arbitrary difficulty.
- A co-op mechanic should create coordination, not mandatory waiting or a solo dead end.

## 5. Solo/co-op adaptation checklist

For every required mechanic, document:
1. What is the solo solution?
2. What changes with two players?
3. What changes with a larger party?
4. Does co-op create a new decision or only increase health/damage?
5. What happens if a player dies, disconnects, leaves or joins late?
6. Who owns the resulting progress: player, party, session or campaign?
7. Can one player grief or permanently block another?
8. Are touch, keyboard/mouse and gamepad interactions all supported?

No required mechanic passes design review without a solo answer.

## 6. Replayability checklist

For every major activity, document:
- Is it enjoyable the first time?
- What changes on a second run?
- Can players use different tools/equipment/tactics?
- Is there a mastery or optional completion goal?
- Is co-op meaningfully different from solo?
- Does replay reward skill/discovery rather than repetitive farming?
- Can content be repeated without breaking progression or economy?

Main story dungeons remain handcrafted. Replay variants may remix routes, enemy compositions, constraints or objectives; procedural generation is optional and not a substitute for authored design.

## 7. Implementation order

The matrix does not override the Master Roadmap. The expected order is:
1. Roblox avatar, input, camera and interaction reliability.
2. A coherent traversal + combat + puzzle foundation.
3. One region, one enemy set, one dungeon/challenge, one boss and one useful tool.
4. Solo/co-op parity, party state, late join and recovery.
5. One replayable activity and external playtest evidence.
6. Expand regions, equipment, quests, dungeon variety and longer-term systems based on evidence.

## 8. Decisions deliberately left open

Do not silently lock: weapon durability, crafting, trading, stamina values, mounts, cooking, weather/time simulation, inventory capacity, shared versus personal campaign saves, consumable loss, revive rules, New Game Plus, procedural generation, live events or exact economy. Each requires a use case, a solo/co-op contract and a test plan.
