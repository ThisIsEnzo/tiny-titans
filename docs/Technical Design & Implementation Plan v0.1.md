# TINY TITANS — Technical Design & Implementation Plan v0.1

**Status:** Prototype specification  
**Branch:** `prototype/technical-spec-v0.1`  
**Baseline:** GDD v0.1 on `master`  
**Target:** One compact arena, one starting form, two evolution branches  
**Budget:** $0  
**Implementation constraint:** No persistence, monetization, pets, trading, or large content pipeline.

> **Direction update (after v0.1):** this document is the original prototype specification and still describes the prototype scope and today's behavior. The product direction has since moved to an Evolution Adventure Sandbox built on three layers: Current Life, Evolution and Legacy, where death resets the current life and Legacy (planned persistence) survives it. The non-goals below (for example no persistence) apply to the prototype and are revisited in [Evolution Sandbox Architecture v0.1](Evolution%20Sandbox%20Architecture%20v0.1.md) and the [Implementation Migration Plan](TT-P0-02R%20Implementation%20Migration%20Plan.md).

## 1. Technical goals

1. The server owns food availability, consumption, evolution energy, evolution choice, and ability cooldowns.
2. The two evolutions must change playstyle, not merely appearance.
3. Character scaling must not destabilize physics, camera, or collision.
4. A player can complete the full loop in a short Studio session.
5. The prototype must support multiple clients in one server.

## 2. Proposed Rojo project layout

```text
tiny-titans/
├── default.project.json
├── README.md
├── src/
│   ├── ReplicatedStorage/
│   │   └── Shared/
│   │       ├── Config.lua
│   │       ├── CreatureDefinitions.lua
│   │       └── Types.lua
│   ├── ServerScriptService/
│   │   ├── Bootstrap.server.lua
│   │   └── Services/
│   │       ├── PlayerDataService.lua
│   │       ├── FoodService.lua
│   │       ├── EvolutionService.lua
│   │       └── AbilityService.lua
│   ├── StarterPlayer/
│   │   └── StarterPlayerScripts/
│   │       ├── ClientBootstrap.client.lua
│   │       └── Controllers/
│   │           ├── FoodController.lua
│   │           ├── EvolutionUIController.lua
│   │           └── AbilityController.lua
│   └── Workspace/
│       └── Arena/              # greybox arena authored in Studio initially
└── docs/
    ├── Game Design Document v0.1.md
    └── Technical Design & Implementation Plan v0.1.md
```

The exact Rojo mapping must be checked against the installed Rojo version before the first sync. Do not create empty placeholder modules merely to match this diagram.

## 3. Runtime ownership

### Server-owned
- Food spawn/availability and consumption.
- Per-player energy and evolution status.
- Evolution branch selection.
- Ability activation eligibility and cooldown.
- Any future competitive interactions.

### Client-owned
- Input capture.
- UI display and local animation/camera feedback.
- Cosmetic effects that do not grant gameplay advantages.

The client must not tell the server how much energy to award or whether an ability succeeded.

## 4. Shared definitions

Keep creature and tuning data in one shared module. Initial conceptual definitions:

| Form | Role | Gameplay difference |
|---|---|---|
| BABY BUG | Starting form | Basic movement and food consumption |
| TANK | Defensive | Brief defensive shell; reduced incoming knockback/damage if combat is included |
| GLIDER | Mobility | Controlled short glide/air boost to reach elevated surfaces |

Use configuration values for:
- evolution energy threshold;
- food energy values;
- food respawn delay;
- ability duration and cooldown;
- defensive reduction;
- glide force/air-control limits;
- interaction distances.

Do not scatter tuning constants across services and controllers.

## 5. Food and arena contract

Author one compact arena with:
- clearly visible ground-level food points;
- a small number of elevated platforms that make GLIDER useful;
- safe, readable routes;
- obstacles that do not trap the character;
- a bounded play area.

Use CollectionService tags or a registry:
- `FoodSpawn`
- `GliderPlatform`
- `ArenaBoundary`

Food is spawned/managed by the server. A client touch or prompt is only a request; the server verifies the food is active, the player is eligible, and the player is close enough before awarding energy. A food item can be consumed once per spawn cycle.

## 6. Character and evolution model

### Starting form: BABY BUG
- Use one stable character controller for the prototype.
- Avoid changing Humanoid scale dynamically if it causes collision/camera instability.
- Prefer visual scale changes on a creature model while keeping a stable collision root, or omit scale changes entirely in v0.1.
- Ensure all players see the selected form.

### Evolution selection
- When server-owned energy reaches the threshold, mark evolution as available.
- Client displays two choices.
- Server validates the selected branch and records it once.
- Evolution cannot be changed during the same run in v0.1.

### TANK ability
- Server checks that player has evolved into TANK.
- Server enforces cooldown and duration.
- Apply defensive effect on server if damage/knockback exists.
- If no combat exists, demonstrate the fantasy with a short, visible shell state and a small environmental pushback test; do not build a full combat system just to justify the ability.

### GLIDER ability
- Server checks form and cooldown.
- Server authorizes a short, bounded glide window.
- Client may provide responsive input, but server clamps duration/force and validates activation.
- Use a simple, controlled air-movement effect; do not build a complex flight controller.

## 7. Networking contract

Create RemoteEvents/RemoteFunctions under ReplicatedStorage only where needed. Suggested events:
- `RequestConsumeFood`
- `RequestEvolution`
- `RequestAbility`
- `PlayerProgressChanged` (server → clients)
- `AbilityStateChanged` (server → clients)

For every client request, server validates:
1. player is alive and in the arena;
2. action is valid for their current form/state;
3. target food exists and is active (for consumption);
4. distance is within configured range;
5. evolution threshold is met and branch has not already been selected;
6. ability cooldown is ready;
7. request rate is within limits.

Never accept client-supplied energy totals, cooldown completion, evolution status, or arbitrary physics values.

## 8. Implementation sequence and acceptance checks

### TT-01 — Project bootstrap
- Add Rojo project mapping and minimal README.
- Confirm Rojo build/sync works with installed toolchain.
- Confirm server and client bootstraps run.

**Accept:** Clean Studio output; repeatable sync.

### TT-02 — Greybox arena and food
- Build compact arena and place food spawn points.
- Implement server-controlled food spawn/respawn and consumption.
- Add basic energy UI.

**Accept:** Food grants energy once; respawn works; simultaneous attempts cannot double-award.

### TT-03 — Evolution threshold and choice
- Add server-owned per-player progression.
- Show choice UI at threshold.
- Implement TANK and GLIDER selection.
- Replicate selected form to all clients.

**Accept:** Both branches can be selected in separate test runs; a client cannot select before threshold or select twice.

### TT-04 — TANK ability
- Add shell visual state and server-side duration/cooldown.
- Add a minimal defensive interaction only if it can be implemented without full combat.

**Accept:** TANK activation is visible to all clients, respects cooldown, and cannot be activated by BABY BUG/GLIDER.

### TT-05 — GLIDER ability
- Add bounded glide/air boost and cooldown.
- Place a test platform reachable only with the ability.

**Accept:** GLIDER can reach the test platform reliably; BABY BUG cannot; no unbounded flight or physics exploit.

### TT-06 — Multiplayer hardening
- Test 2–4 clients.
- Test simultaneous food collection, respawn, player leaving, death/respawn, and ability requests.
- Fix only blockers to the core loop.

**Accept:** All clients see correct forms and food state; progress remains per-player; no duplicate rewards.

## 9. Test matrix

| Scenario | Expected result |
|---|---|
| Player consumes active food | Energy increases once |
| Two players touch same food simultaneously | Only one receives that food's reward |
| Player consumes inactive food | Rejected |
| Player requests evolution below threshold | Rejected |
| Player selects both branches rapidly | First valid choice only |
| Player requests TANK ability as GLIDER | Rejected |
| Ability used during cooldown | Rejected |
| GLIDER activates glide | Bounded glide visible and controllable |
| New player joins | Existing players' forms remain visible |
| Player leaves mid-session | No stuck food/progression state |

## 10. Explicit non-goals

- 30+ creature forms
- Multiple biomes
- Breeding, pets, trading
- Permanent account progression or DataStores
- Complex combat or kill/reward loops
- Monetization, shops, premium currency
- Large social hub
- Advanced creature animation pipeline

## 11. Technical risks and guardrails

- **Food loop feels repetitive:** validate that evolution choice creates a real change before adding content.
- **TANK has no meaningful test:** do not add a full combat system; use a tiny environmental/knockback test or keep ability demonstrative.
- **GLIDER physics exploits:** clamp activation and movement; test server/client behavior.
- **Character scaling breaks movement:** keep collision root stable; scale visuals first.
- **Network trust:** all rewards, progression, and cooldowns are server-authoritative.

## 12. Definition of implementation-ready

Before gameplay code begins:
- [ ] Confirm Rojo and Roblox Studio versions/toolchain.
- [ ] Confirm whether arena geometry is authored in Studio or generated by Rojo.
- [ ] Decide whether the prototype includes any damage/knockback interaction for TANK.
- [ ] Create a test place and verify Rojo mapping.
- [ ] Keep all implementation work on this feature branch until reviewed.
