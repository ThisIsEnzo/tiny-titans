# Tiny Titans — Master Roadmap

**Status:** Active execution plan  
**Version:** 1.0  
**Date:** 2026-11-13  
**Product authority:** [Product Vision & Top 1000 Strategy](Product%20Vision%20%26%20Top%201000%20Strategy.md)  
**Game definition:** [Gameplay Blueprint & MVP Contract](Gameplay%20Blueprint%20%26%20MVP%20Contract.md)  
**Technical reference:** [Evolution Sandbox Architecture](Evolution%20Sandbox%20Architecture.md)

This is the **single execution roadmap**. Old phase/task documents have been consolidated here. A merged PR is implementation progress, not proof of a fun or validated feature.

---

## 1. Product target

Build a multiplayer, co-op-friendly **creature-evolution PvE exploration/survival adventure** in a miniature living ecosystem.

The first release is not a generic simulator, a PvP arena or a large MMO. It must prove one compact, memorable habitat, a satisfying exploration/growth loop, meaningful evolution roles, one repeatable challenge and reasons to return across lives.

Top 1000 is the ambition, not a forecast. We will optimize for player value, replayability, first-session clarity, fairness, retention and sustainable content—not PR count or raw playtime.

## 2. Current repository status (2026-11-13)

### Implemented in code / merged

- First Habitat greybox (TT-P3-01: Nest, Meadow, Rock Garden, Giant Roots and a secret route; checked by an offline validator, Studio validation pending), spawn and food pickup loop.
- Biomass and three growth stages (current values are prototype tuning).
- Current Life lifecycle, death reset, controlled respawn and Life Recap.
- Data-driven creature definitions, ability definitions and evolution UI.
- Procedural Baby Bug visual character.
- Tank Defensive Shell visual prototype.
- Glider Air Glide physics prototype (PR #34 merged).
- CI, Rojo build and pure-rule test workflow.

### Not yet validated as a complete player experience

- Roblox Studio runtime checks for lifecycle, Baby Bug visuals, Tank and Glider.
- Real movement/camera feel and collision quality across devices.
- Glider aerial steering, useful range, landing reliability and world use cases.
- Tank's actual defensive/obstacle utility (currently visual only).
- Whether the first-session loop is fun and whether players want another life.

### Not implemented

- Production First Habitat (final art, audio, varied resource interactions); the current environment is the First Habitat greybox.
- Varied resource interactions, discovery/bestiary, secrets and repeatable activities.
- Health/damage, a PvE encounter or a designed environmental threat.
- Legacy model and DataStore persistence.
- Validated cooperative gameplay, external playtests, product analytics and launch operations.
- Monetization.

**Do not interpret merged code or passing CI as Studio validation or evidence of fun.**

## 3. Priority zero — stop feature expansion and validate the foundation

**Outcome:** establish what actually works in Roblox Studio and remove uncertainty before adding systems.

1. Run the existing manual Studio checklist for lifecycle, death/recap, Baby Bug appearance and multiplayer isolation.
2. Validate the merged Glider prototype: activation, air steering (currently limited/absent), lift/descent, landing, cooldown, mobile/gamepad input and replication.
3. Validate Tank's current shell behavior and record honestly that it is visual-only if it has no mechanical effect.
4. Observe at least one first-time player in the current prototype without coaching. Record confusion, dead time, fun moments and whether they want to continue.
5. Capture a short gameplay recording and a prioritized issue list.

**Exit gate:** no critical lifecycle/input defects; known limitations recorded; owner accepts the first-habitat gameplay brief before more ability work.

## 4. Product phases

### Phase 1 — First Habitat vertical slice

**Outcome:** a small world that is interesting to explore before we add content breadth.

- Design a safe Nest and three distinct micro-areas.
- Build readable landmarks, ground routes, elevated routes, narrow passages and meaningful gaps.
- Add a small set of varied resource interactions.
- Add one discovery/secret loop and a simple activity objective.
- Ensure there are multiple routes and no mandatory class gate.
- Tune camera, movement, scale, collision and mobile readability.

Status (TT-P3-01): the greybox covers the Nest, three micro-areas, landmarks, ground and elevated routes, narrow passages, a hidden route with a reward location and a leaf-platform gap, with no ability gate. Still open: varied resource interactions, a simple activity objective, and tuning of camera, movement, scale, collision and mobile readability in Studio.

**Exit gate:** a new player can explore for several minutes, find multiple opportunities and explain what makes the miniature world interesting. A second pass offers at least one different route or goal.

### Phase 2 — Meaningful evolution and abilities

**Outcome:** Baby Bug, Tank and Glider provide understandable, useful, balanced playstyles.

- Keep Baby Bug as the agile baseline with narrow-space access.
- Prototype Tank brace/impact protection and a meaningful heavy-object interaction.
- Redesign Glider as controlled aerial traversal: launch, steer, dive, glide and land.
- Build routes and optional rewards that demonstrate each role.
- Define explicit trade-offs, counterplay, cooldown/resource rules and feedback.
- Test each form solo and in multiplayer; ensure no form is mandatory for progression.

**Exit gate:** testers can describe when and why they would choose each form; each form has at least one satisfying use case and a meaningful weakness; no form dominates all routes. Numeric balance is based on playtest evidence.

### Phase 3 — Repeatable exploration and survival activity

**Outcome:** the player has a reason to explore, take risks and replay a life.

- Add one readable hazard or simple PvE creature encounter.
- Add a small objective/challenge structure with clear completion and rewards.
- Make risk/reward and failure understandable.
- Ensure the activity is enjoyable without PvP or a second player.
- Tune Biomass and evolution pacing around the activity rather than arbitrary thresholds.

**Exit gate:** players can complete and replay the activity, understand the threat/counterplay and voluntarily start another life.

### Phase 4 — Life, Legacy and long-term goals

**Outcome:** death ends a life without making the session feel wasted.

- Define the Legacy schema: discoveries, bestiary, achievements, collections, cosmetics and life history.
- Keep Legacy free of permanent raw combat/movement power.
- Implement an in-memory model and recap integration first.
- Add DataStore only after schema versioning, migration, retry, failure and recovery paths are tested.
- Add a few long-term goals that unlock knowledge, identity or options.

**Exit gate:** discoveries survive death and rejoin reliably; data failure cannot erase valid progress; players can name a meaningful next goal.

### Phase 5 — Multiplayer and social value

**Outcome:** other players make the habitat more interesting without breaking solo play.

- Add one co-op objective or encounter with complementary but non-mandatory roles.
- Add clear contribution/reward rules and anti-AFK/farming protection.
- Add friend/session improvements only when useful.
- Consider friendly competitions after core PvE is stable.
- Keep PvP optional and out of core progression.

**Exit gate:** multiplayer produces positive interactions, solo play remains complete, and 2–4+ client tests show no state leaks or reward exploits.

### Phase 6 — First public-quality MVP

**Outcome:** a coherent, polished and testable release candidate.

- First-session onboarding and readable UI.
- Final-enough creature models, animation, sound and VFX for the MVP forms.
- Mobile-first performance and keyboard/mouse/gamepad parity.
- Server-authority, exploit and data-safety review.
- Moderation/reporting and Roblox policy review.
- External playtests, funnel instrumentation and issue closure.
- Store page, icon, thumbnails, release/rollback plan.

**Exit gate:** external players understand the game, enjoy the core loop, complete meaningful activities and express a reason to return; no launch-blocking technical, security, policy or performance issue remains.

### Phase 7 — Live development and scale toward Top 1000

Only after launch evidence:
- expand the habitat one dense area at a time;
- add forms only when they introduce a proven new gameplay verb;
- add rotating challenges/events and collection chapters;
- add cosmetic-first monetization and optional supporter products;
- invest in creator/community outreach, localization and sustainable update cadence;
- use cohort retention and player feedback to choose the next work.

No paid resurrection, death protection, pay-to-win stats or monetized frustration.

## 5. Work policy: what is paused

Until Phase 1 and the product/runtime validation gate pass, pause:
- additional classes and abilities;
- full combat systems, PvP, ranked modes and deep combat progression;
- large-scale persistence and DataStore;
- pets, breeding, trading, crafting, guilds and multiple biomes;
- shop, premium currency and monetization.

This is not abandoning those ideas. It prevents expensive systems from being built before the core game is worth playing.

## 6. Ability task acceptance template

Every ability PR must include:

- player fantasy and exact purpose;
- two or more concrete world use cases;
- unique gameplay verb;
- strength, weakness, trade-off and counterplay;
- activation, rejection, duration, cancel and cooldown rules;
- server authority and exploit boundaries;
- visual/audio/UI feedback;
- keyboard, touch and gamepad behavior;
- automated tests for deterministic rules;
- manual Studio checklist and observed results;
- playtest question and evidence required to accept the ability.

If the ability has no meaningful habitat use case, do not implement it.

## 7. Release readiness tracking

Track gates, not a misleading percentage based on merged PRs:

| Gate | Status |
|---|---|
| Core lifecycle and reset implementation | Implemented; Studio validation pending |
| Baby Bug visual | Implemented; Studio validation pending |
| Tank role and ability | Not validated; current shell is visual-only |
| Glider role and ability | Physics prototype merged; gameplay validation pending |
| First Habitat | Greybox implemented (TT-P3-01); Studio validation pending |
| Repeatable exploration/survival activity | Not implemented |
| Legacy and persistence | Not implemented |
| Multiplayer activity and fairness | Not implemented |
| External playtests and retention evidence | Not started |
| Public launch operations | Not started |

Do not report an overall MVP percentage until these gates have measurable exit evidence.

## 8. PR and branch workflow

- Default branch: `master`.
- One independent task = one feature branch = one PR.
- Claude Code must not work directly on `master` and must not merge PRs.
- Each PR has one outcome, narrow scope, tests, acceptance criteria and a Studio checklist where Roblox runtime behavior is involved.
- Record what was actually run. Never claim Studio validation without evidence.
- Product design approval precedes ability/feature implementation.
- Prefer direct documentation/code changes by the project owner or assistant when they can be safely completed without local Studio work.

## 9. Decision log

- **2026-11-13:** Product direction consolidated as a co-op-friendly PvE creature-evolution exploration/survival adventure in a miniature living ecosystem.
- **2026-11-13:** First release is one dense habitat and a small activity set; forced PvP, large roster, MMO systems and monetization are deferred.
- **2026-11-13:** Glider is not accepted as a finished ability. Target direction is controlled aerial traversal with steering, momentum, diving and world-authored routes.
- **2026-11-13:** Tank is not accepted as a finished ability. Target direction is meaningful bracing/protection and a physical world interaction.
