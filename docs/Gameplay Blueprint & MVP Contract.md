# Tiny Titans — Gameplay Blueprint & MVP Contract v4.0

**Date:** 2026-11-19  
**Status:** Strategic direction approved; vertical-slice scope is a design contract pending detailed task breakdown.  
**Authority:** Product Vision defines the north star; GDD defines the experience; Zelda Mechanics Adaptation Matrix inventories systems; Master Roadmap defines execution order.

## 1. The game

**Tiny Titans is a Zelda-style action-adventure for Roblox, built to be replayed and enjoyed with friends.**

We are building our own adventure world and implementing the broad gameplay language of Zelda: exploration, traversal, combat, puzzles, tools, items, equipment, dungeons, bosses, NPCs, quests, secrets and progression.

This is not a small-creature simulator, ecological restoration game, generic simulator, arena brawler, forced-PvP game, empty open world or MMO grind. The title Tiny Titans does not impose a miniature-world setting.

The player uses their standard Roblox avatar. Solo and co-op are first-class. Every essential progression step must be completable solo; co-op should add meaningful coordination, tactics and shared moments.

## 2. Player fantasy

“I explore a mysterious world as my Roblox avatar. I discover new places and tools, learn how its puzzles and enemies work, become a more capable adventurer, defeat memorable challenges and share the journey with my friends.”

Emotional beats: wonder, curiosity, agency, mastery, tension, triumph, surprise, friendship and the desire to return.

## 3. Core loops

**Moment-to-moment:** Explore → notice → choose route/tool/tactic → act → read feedback → adapt.

**Adventure:** discover a region → investigate its story → overcome traversal, puzzle and combat challenges → complete a dungeon or signature challenge → defeat its major encounter → gain a new option → uncover more of the world.

**Co-op:** party up → choose a shared goal → explore/coordinate/fight/solve → earn fair rewards → choose another activity.

**Replay:** revisit regions, secrets, challenges and bosses with new equipment, tactics, modifiers or friends; pursue optional completion goals and new chapters.

## 4. MVP versus vertical slice

Do not confuse a technical MVP with the intended first public experience.

The first internal MVP may validate movement, interaction, combat or a small puzzle independently. The first public-facing vertical slice must prove the complete adventure promise.

### First vertical slice target

- One compact but polished original adventure region.
- Standard Roblox avatar with reliable movement, camera and animation.
- At least two meaningful exploration routes and optional secrets.
- A small enemy roster with readable behaviors and counterplay.
- A responsive basic combat loop with attack and defensive decisions.
- An authored multi-step puzzle using environmental interaction and at least one useful tool.
- A compact dungeon/challenge with a coherent mechanical identity.
- A memorable mini-boss or boss.
- A reward/tool that changes traversal, combat or puzzle options.
- At least one NPC/quest hook and a clear regional goal.
- Solo completion and a co-op path with real coordination value.
- Defined shared-versus-personal progress and safe late join.
- Touch, keyboard/mouse and gamepad support.

The exact region, lore, enemies, items and boss are not locked by this document.

## 5. Player character and controls

- Standard Roblox avatar is canonical; no Baby Bug, Tank or Glider playable forms.
- Preserve standard Roblox character behavior wherever supported.
- Do not arbitrarily scale or replace the avatar as a shortcut.
- Controls must be designed for touch, keyboard/mouse and gamepad.
- Important actions need readable contextual prompts and remappable/accessible input patterns where Roblox permits.
- Combat and traversal must not depend on a mouse-only cursor.
- Camera framing must preserve awareness of the avatar, nearby threats and puzzle clues.

## 6. System scope

The full system inventory is in Zelda Mechanics Adaptation Matrix. The vertical slice should implement only the smallest coherent subset that proves:
1. exploration and traversal;
2. combat and enemy readability;
3. puzzle/environment interaction;
4. dungeon/challenge progression;
5. item/tool reward and a new capability;
6. solo/co-op parity;
7. a reason to replay or continue.

Do not build a full inventory, crafting economy, procedural world, generic quest engine, trading, guilds, New Game Plus or live-ops platform before the slice proves the core loop.

## 7. Multiplayer contract

- Every essential objective has a solo solution.
- Co-op interactions are optional enhancements or alternate solutions, not hard party gates.
- Shared puzzle/boss state is server-authoritative.
- Personal inventory, permanent rewards and records cannot be stolen or overwritten by another player.
- Late joiners receive correct shared state and a fair catch-up path.
- Disconnects, party splits, death and rejoin do not permanently block progression.
- No forced PvP, griefable permanent switches or spawn camping.
- Co-op difficulty should add decisions and behaviors, not only inflated enemy health.

## 8. Replayability contract

At least one replayable layer must be present in the first vertical slice, but it must not replace the main handcrafted adventure.

Acceptable early examples:
- optional combat/traversal challenge with a repeatable result;
- boss rematch with a clear rule or difficulty variation;
- optional secret/collection route;
- a co-op challenge with a solo-compatible alternative.

Later layers may include challenge dungeon variants, enemy remixes, equipment builds, curated rotating activities, mastery goals, region completion and new story chapters.

Do not use daily chores, artificial waiting, punitive streaks, endless farming or randomization for its own sake.

## 9. Technical and security contract

- Server owns consequential combat, damage, drops, item grants, puzzle completion, boss state and progression.
- Client sends intent and stable identifiers, never claimed outcomes or reward amounts.
- Validate life/character state, distance, line of sight where relevant, cooldowns, ownership, party membership and rate limits.
- Keep pure gameplay rules separate from Roblox services where practical.
- Use explicit state machines for combatants, bosses, dungeon state and party activities when complexity justifies them.
- Ensure cleanup on PlayerRemoving, CharacterRemoving, death, disconnect and activity completion.
- Use stable identifiers and idempotent completion/reward handling.
- Do not add DataStore persistence until the progression schema, migration, retries, failure UX and recovery are designed.

## 10. Acceptance gates

The vertical slice is not accepted until:
- first-time players understand where to go and what they can do;
- traversal and combat feel responsive and readable;
- puzzles communicate rules and produce clear feedback;
- the dungeon has coherent escalation and a satisfying payoff;
- solo completion is verified;
- two or more players can cooperate without state conflicts;
- late join, disconnect, death and rejoin are tested;
- mobile, keyboard/mouse and gamepad are tested;
- performance remains acceptable on representative Roblox devices;
- external players want to replay, continue or invite a friend.

Green CI and offline validators are necessary where applicable, but are not proof of Studio behavior or fun.

## 11. Explicit non-goals for the first slice

- Copying Zelda IP, exact puzzle layouts, characters, names, maps, music or recognizable item/creature designs.
- A giant empty open world.
- Every mechanic from the matrix implemented at once.
- Procedural generation of all story content.
- Mandatory party size or role/class selection.
- Forced PvP, guilds, trading economy or MMO-scale systems.
- Paid power, paid revives or mandatory monetization.
- A full live-ops pipeline before a repeatable core activity exists.
