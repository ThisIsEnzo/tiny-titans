# Tiny Titans — Roblox Avatar & Player Identity Architecture

**Version:** 2.0 | **Date:** 2026-11-19  
**Status:** Approved product boundary; migration design, not a claim of completed runtime work.  
**Product authority:** Product Vision v3.0, GDD and Gameplay Blueprint. **Execution:** Master Roadmap.

## 1. Purpose

Defines the player-character boundary for Tiny Titans. The canonical playable character is the player's **standard Roblox avatar**. The current custom Baby Bug visual is retired as a player-character implementation because its proportions and animation quality are not acceptable.

This document establishes the desired behavior and migration constraints. It does not claim that runtime code has already been changed or Studio-validated.

## 2. Core invariants

1. The player's normal Roblox avatar remains visible and recognizable.
2. Standard Roblox character animations remain functional: idle, walk, run, jump, fall, swim and supported emotes.
3. Preserve avatar clothing, body packages and accessories wherever Roblox character systems support them.
4. Do not hide the avatar and substitute the current Baby Bug visual.
5. Do not replace the character with a custom rig or scale the avatar down until movement, camera, collision, animation, accessories and mobile readability pass Studio validation.
6. Gameplay state (life, Biomass, discoveries, regional progress) is separate from avatar presentation.
7. Cosmetics do not grant hidden gameplay power.
8. Essential routes and progression remain solo-accessible.
9. Server-authoritative gameplay state is separate from client presentation.
10. Current Baby Bug/Tank/Glider code is historical prototype implementation until migrated; documentation alone does not change runtime behavior.

## 3. Character presentation

### Canonical first implementation

Use the normal Roblox character appearance and animation stack. The standard Roblox avatar is the player character, not a temporary fallback.

- Keep CharacterAutoLoads, Humanoid, Animate and the existing lifecycle/respawn ownership intact unless a separately reviewed task proves a necessary change.
- Do not set avatar body parts, decals or accessories invisible.
- Do not attach BabyBugVisual to HumanoidRootPart.
- Do not allow CreatureAppearanceService to hide the avatar for BABY_BUG.
- Avoid custom animation controllers replacing Roblox's standard animation behavior.
- Do not introduce a custom rig, body scale, collision proxy or camera override in the initial restoration task.

### Selling the miniature fantasy

The world communicates scale through oversized grass, roots, rocks, flowers, water, food, insects and architecture. Camera framing and environment dimensions may be tuned, but must preserve comfortable Roblox avatar control and readable movement. Do not make the player tiny by arbitrary scale changes as a shortcut.

## 4. Current prototype migration boundary

The repository currently contains a historical prototype:
- BABY_BUG, TANK and GLIDER form/evolution concepts and related UI/rules;
- a custom Baby Bug visual model attached to an R15 Humanoid;
- a procedural Baby Bug pose/animation controller;
- Tank Defensive Shell (visual prototype);
- Glider Air Glide (bounded physics prototype).

The owner has retired Baby Bug as the playable character and selected the normal Roblox avatar. The migration should be incremental:

1. Restore the normal Roblox avatar as the visible character for every player.
2. Stop hiding the default avatar and stop attaching the Baby Bug visual.
3. Preserve lifecycle, respawn, Biomass, discoveries, recap and other independent systems.
4. Remove or disable form-selection/evolution presentation only after tracing dependencies and defining a safe compatibility boundary.
5. Decide separately whether any useful Tank/Glider verbs survive as future optional world interactions. Do not preserve them merely because code exists.
6. Delete obsolete modules/assets only after reference search, tests and Studio verification; avoid broad cleanup in the restoration task.

Do not break food pickup distance checks, growth/lifecycle rules or per-player state while restoring the avatar.

## 5. Avatar, movement and world-scale constraints

- Roblox avatar dimensions and collision are the initial baseline.
- Habitat traversal must be validated with common Roblox avatar body packages and accessories.
- Do not make essential routes depend on a custom tiny collision shape.
- Camera must keep the avatar and nearby clues readable without forcing an uncomfortable zoom.
- Touch, keyboard/mouse and gamepad controls must remain usable.
- Any future scale/camera experiment requires a dedicated Studio test matrix and a clear rollback path.

## 6. Future customization

Future customization should prefer Roblox-compatible avatar appearance and authored cosmetic options. Potential rewards include themed accessories, trails, emotes, titles and visual effects, subject to Roblox avatar and platform constraints.

Do not build a full custom character creator before the adventure loop is validated. Cosmetics must not grant power or mandatory access.

## 7. Server authority and persistence

Server owns life state, progression, discovery claims, world interactions and consequential rewards. Client owns input and local presentation. Remotes carry intent and stable identifiers, never arbitrary reward values or claimed outcomes. Validate life state, proximity, cooldowns, ownership and rate limits.

Persistence requires a versioned schema, migrations, retry/backoff, idempotent writes, failure UX and recovery tests. No DataStore implementation is approved by this document.

## 8. Implementation order

1. Restore standard Roblox avatar visibility and standard animation behavior.
2. Validate spawn, respawn, movement, camera, collision, accessories and multiplayer in Studio.
3. Validate First Habitat routes with representative Roblox avatar packages and devices.
4. Continue the first adventure vertical slice without custom creature-form dependencies.
5. Reconsider optional abilities only when a specific puzzle or route has at least two meaningful use cases and solo-compatible alternatives.
6. Add cosmetic persistence only with a designed Legacy schema and recovery behavior.

The Master Roadmap controls execution. This document defines the intended player-character boundary, not proof of implementation.
