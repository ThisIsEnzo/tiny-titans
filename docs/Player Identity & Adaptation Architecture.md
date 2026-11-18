# Tiny Titans — Roblox Avatar & Player Identity Architecture v3.0

**Date:** 2026-11-19  
**Status:** Approved player-character boundary; runtime state must be verified separately.  
**Product authority:** Product Vision v4.0 and GDD v4.0. **Execution:** Master Roadmap.

## 1. Purpose

The canonical playable character is the player's **standard Roblox avatar**. Tiny Titans is an original Zelda-style action-adventure; the player is an adventurer, not a Baby Bug creature or a selectable creature class.

This document defines the player-character boundary. It does not claim that runtime code has been restored or Studio-validated.

## 2. Core invariants

1. Keep the player's normal Roblox avatar visible and recognizable.
2. Preserve supported Roblox avatar appearance, clothing, body packages and accessories.
3. Preserve standard Humanoid movement and Roblox animation behavior wherever supported.
4. Baby Bug, Tank and Glider are historical prototypes, not playable forms or classes.
5. Do not attach BabyBugVisual or hide the standard avatar in the active player path.
6. Do not introduce arbitrary body scaling, custom rigs, collision proxies or camera overrides without a separate design and Studio test gate.
7. Player identity and cosmetics are separate from gameplay power.
8. Tools, weapons, equipment and abilities are acquired gameplay systems, not character classes.
9. Essential traversal, combat and progression must have solo-compatible solutions.
10. Server owns consequential gameplay state; client owns input and local presentation.

## 3. Avatar presentation

Use the normal Roblox character appearance and animation stack. The standard Roblox avatar is the canonical player character, not a temporary fallback.

- Keep CharacterAutoLoads, Humanoid, Animate and existing lifecycle/respawn ownership unless a separately reviewed task proves a necessary change.
- Do not hide avatar body parts, decals or accessories.
- Do not attach BabyBugVisual to HumanoidRootPart.
- Do not let CreatureAppearanceService replace the avatar in the active player path.
- Do not let legacy EvolutionService or form-selection UI determine the player's character identity.
- Preserve familiar Roblox movement and supported emotes.
- Camera and world framing should keep the avatar, nearby threats and puzzle clues readable.

Any scale or custom presentation experiment requires explicit owner approval, a rollback plan and Studio tests for movement, camera, collision, animation, accessories, network replication and mobile readability.

## 4. Tools, equipment and abilities

Future player capabilities should be designed as adventure tools and equipment:
- weapons and defensive equipment;
- puzzle and traversal tools;
- ranged/utility items;
- consumables and temporary effects;
- learned movement or interaction verbs.

Do not implement a capability merely to preserve old Tank/Glider code. Every tool needs a clear gameplay purpose, at least two meaningful authored uses where practical, readable limits, cross-platform controls, server validation and a solo-compatible route through required content.

Avoid permanent role/class selection. Players may prepare different equipment/loadouts if the inventory design later supports it, but no required class gate is allowed.

## 5. World and character scale

The world is an original fantasy adventure setting. It is not required to be miniature, insect-themed or built around a tiny avatar. The title Tiny Titans does not constrain world scale.

World scale, architecture, creatures, camera and effects should create a coherent fantasy. Do not shrink the player as a shortcut to visual identity.

## 6. Security and lifecycle

Server owns equipment ownership, item grants, combat outcomes, ability cooldowns, puzzle completion, progression and rewards. Client sends intent and stable identifiers, never claimed outcomes or reward amounts.

Validate character/life state, distance, line of sight where relevant, cooldowns, party/activity membership, ownership and rate limits. Clean up player and character connections on death, respawn, disconnect and activity completion.

The avatar presentation must not break food/interaction distance checks, lifecycle, respawn, camera or multiplayer visibility.

## 7. Migration order

1. Verify PR #41/current master state before assuming the avatar restoration is merged.
2. Restore standard avatar visibility and standard animation behavior if still pending.
3. Studio-test spawn/respawn, movement, camera, collision, accessories and two-player visibility.
4. Review and retire obsolete form/evolution UI and dependencies safely.
5. Validate the existing First Habitat with standard avatar dimensions, then decide whether it remains useful under the new world direction.
6. Build the adventure vertical slice using tools/equipment rather than creature forms.
