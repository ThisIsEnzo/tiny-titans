# Tiny Titans — Master Roadmap (Prototype → MVP → Public Launch → Live Development)

**Status:** Proposed master plan  
**Version:** 0.1  
**Date:** November 2026  
**Purpose:** One execution-oriented view of product phases, engineering work, MVP gates, launch readiness and post-launch development.

> This is a planning baseline, not a promise of dates, player counts or commercial outcomes. Percentages are coarse owner-facing estimates based on repository evidence and explicit gates—not automated measurements, hours spent or proof that a feature is fun.

## 1. Product north star

Tiny Titans is a multiplayer creature-evolution adventure sandbox: start as a tiny creature in a large-feeling living world, explore, forage, survive, grow, make meaningful evolution choices, discover places/species, and create memorable multiplayer moments.

**Core promise:** You do not merely become bigger. You become different, and your choices change how you experience the world.

Non-negotiable principles:
- Fun and player evidence before feature count.
- Evolution changes gameplay verbs, routes, survival or interaction—not only numbers/skins.
- Current Life is temporary; Evolution is the build/identity within a life; Legacy preserves discoveries and identity.
- Death is a fair transition, never a monetized punishment.
- Legacy should expand choices, knowledge, identity and access opportunities—not permanent raw competitive power.
- Server authority for progression, interactions, combat and rewards.
- Mobile, keyboard/mouse and gamepad support for core actions.
- A compact, dense, replayable habitat beats a huge empty map.
- Implemented ≠ validated; passing unit tests ≠ Roblox runtime validation; runtime validation ≠ fun.

## 2. How to read progress

Three distinct progress measures are used:

1. **Prototype / engineering completion:** implementation of currently scoped foundations and systems.
2. **MVP readiness:** evidence that a new player can enter, understand, enjoy, progress, die/restart and have a reason to return in a small but coherent experience.
3. **Public launch readiness:** production quality, cross-platform testing, onboarding, content, performance, analytics, moderation, release assets and operational readiness.

A feature is only counted as complete when its stated acceptance gate is met. For runtime-dependent features, Studio validation is required. For player-experience claims, playtests are required.

### Baseline estimate (November 2026)

| Measure | Estimated completion | Why |
|---|---:|---|
| Existing prototype mechanics | 25–35% of a *small MVP's* mechanic scope | Food/biomass, three growth stages, Tank/Glider choice and prototype abilities exist; world/activity/feedback are thin |
| Engineering foundation / P1 | 35–45% | Biomass rename and life tracking implemented; death reset and full life transition remain unfinished/unvalidated |
| MVP overall | **10%** | Playable greybox exists, but compelling evolution, habitat, survival loop, Legacy, onboarding and playtest evidence are largely missing |
| Public launch overall | **5%** | MVP itself is not ready; production, cross-platform, release and operations gates remain |
| Post-launch | 0% | No live MVP cohort or validated post-launch cadence yet |

These are intentionally conservative, rounded estimates. They should be revised at each milestone review; they are not additive across rows.

## 3. Release definitions

### Prototype (current)
A developer can enter the greybox, collect food, grow, choose Tank/Glider and test their prototype abilities. It is a mechanics sandbox, not yet a complete game loop.

### MVP / Private Alpha candidate
A coherent, small experience that:
- explains the creature fantasy and first objective without developer coaching;
- has responsive movement, camera and interaction feedback;
- contains one polished first habitat/vertical slice;
- has a longer, decision-rich growth/evolution loop (not the current three-pickup/60-Biomass test thresholds);
- makes the first evolution choice meaningful and demonstrates at least two genuinely different playstyles;
- includes a readable survival/threat encounter and fair death/new-life flow;
- rewards exploration/discovery and preserves selected Legacy records;
- supports a small multiplayer playtest without state leaks or serious exploits;
- has measurable playtest questions and a known issue list.

MVP may deliberately have a limited roster, one habitat and one PvE encounter. It does **not** require a giant world, four fully polished classes, competitive ranked PvP, seasons or monetization.

### Public MVP launch
MVP gates passed, plus:
- mobile/keyboard/gamepad input and UI checks;
- performance and stability checks on target device tiers;
- exploit/security review of progression, combat and rewards;
- onboarding, safe spawn, clear death and recovery;
- moderation/reporting and Roblox policy review;
- analytics/events and crash/error monitoring appropriate to the experience;
- release icon, thumbnails, description, update notes and community/support plan;
- staged release / rollback or disable strategy for risky systems;
- a real playtest cohort with actionable feedback and no launch-blocking issues.

### Post-launch live development
A repeatable loop: observe → prioritize → design → prototype → playtest → ship → measure → iterate. Updates should improve depth and reliability, not merely add content volume.

## 4. Product phases (P0–P7)

This numbering follows **Evolution Adventure Sandbox Roadmap v0.1**. Engineering PR identifiers in TT-P0-02R and the Product Vision P0–P8 are separate numbering systems.

---

## P0 — Product foundation & architecture

**Outcome:** A consistent product model, documented boundaries and a credible vertical-slice plan.

### P0.1 — Product model
- [x] Define Current Life / Evolution / Legacy at product level.
- [x] Define death as a transition between lives, not deletion of long-term progress.
- [x] Establish fair monetization and no pay-to-win Legacy principles.
- [x] Establish compact ecosystem + traversal-driven differentiation.
- [x] Establish target roster direction: Baby Bug starter + four evolved roles (Tank/Guardian, Glider/Skirmisher, Striker/Hunter, Support/Controller); latter two remain provisional/unimplemented.
- [x] Define product north star and player motivations.
- [ ] Turn assumptions into a prioritized, testable MVP feature list.

### P0.2 — Architecture and repository audit
- [x] Audit existing prototype and separate implementation facts from target design.
- [x] Architecture document and migration plan.
- [x] Product roadmap and combat/endgame design references.
- [x] Biomass nomenclature decision.
- [ ] Close outstanding documentation alignment / architecture decisions.
- [ ] Establish a single feature acceptance / Studio evidence convention.

**Exit gate:** all MVP-critical state has an owner; no conflicting definitions of life, evolution, reset or Legacy.

**Estimated phase completion: 85–90%.** Remaining work is decisions and validation, not writing more vision documents.

---

## P1 — Core Life Cycle

**Outcome:** A complete Current Life can begin, progress, end and restart without stale state or cross-player effects.

**Status note (after PR #26):** P1.03, P1.04 and P1.05 implementation is present in the repository. Automated test files/coverage were added, but the test suite has not been confirmed as executed in this review. Roblox Studio validation remains outstanding. Do not interpret implementation checkmarks as runtime validation or proof of a fun player experience.

### P1.01 — Biomass naming
- [x] Rename Energy → Biomass and related identifiers.
- [x] Preserve existing values and behavior (cap 100, food reward 10, stages 0/30/60).
- [x] Update HUD terminology.

### P1.02 — Life state and death detection
- [x] Shared life transition rules.
- [x] LifeService, lifeId and idempotent LifeEnded.
- [x] Character/death/removal/replacement handling.
- [x] Unit tests for pure life-state rules (authored; execution not confirmed here).
- [ ] Roblox Studio signal wiring checklist verified.

### P1.03 — Reset Current Life on death
- [x] Biomass resets to 0.
- [x] Form returns to BABY_BUG.
- [x] Growth and current-life ability state/cooldowns/effects reset.
- [x] Duplicate/stale life events cannot reset a newer life.
- [x] Old-life delayed callbacks cannot mutate new-life state.
- [x] Automated tests for reset/lifecycle and multiplayer isolation are present (execution not confirmed).
- [ ] Studio death/respawn, effects during death, rapid-death and two-player isolation checks recorded.

### P1.04 — Respawn / life transition experience
- [x] Controlled, player-requested new-life flow implemented.
- [x] Minimal life recap implemented (duration and highest form).
- [x] Fresh BABY_BUG initialization and server-side request validation implemented.
- [x] Automated transition/request-validity test coverage is present (execution not confirmed).
- [ ] Studio first-join, recap, begin-new-life, mobile button, respawn timing and two-player checks recorded.

### P1.05 — Lifecycle hardening
- [x] Spawn operation sequencing and stale/in-flight callback protection implemented.
- [x] Initial spawn failure handling and retry path implemented.
- [x] Pending recap replay/ready handshake and request throttling implemented.
- [x] Client-side recap validation against stale, malformed and replayed life data implemented.
- [x] Lifecycle regression tests are present (execution not confirmed; Lune test run not evidenced).
- [ ] Studio rapid death/respawn, failed initial spawn/retry, leave/rejoin and simultaneous-event checks recorded.
- [ ] Studio evidence and regression results recorded in the project documentation.

**Exit gate:** implementation is substantially present, but the phase is **not closed** until automated tests are executed and the essential Studio scenarios are recorded. Repeated lives must start cleanly, death must be readable, current-life state must be isolated, and no unintended carry-over may occur.

**Estimated P1 implementation completion: 90–95%.** This is implementation progress only. Automated test execution and Roblox Studio validation are tracked separately and remain unconfirmed/outstanding.
 
## P2 — Evolution & Progression (the first major gameplay redesign)

**Outcome:** Growth becomes a longer, more interesting sequence of decisions; evolution changes the way the player plays.

> **P2-01 alignment.** P2 uses the engineering IDs P2-01 to P2-07, matching the Evolution Adventure Sandbox Roadmap and TT-P0-02R. P2-01 is a documentation-only design gate. Its design remains PROPOSED and awaits owner approval; documenting it does not mean the decisions are approved or implemented.

### P2-01 — Progression & Evolution Design Gate (documentation only)
Design lives in `Combat Progression & Endgame Design v0.1.md`, section 13. It defines, without any code:
- [ ] Current Life / Evolution / Legacy boundaries and what resets on death.
- [ ] The one-life gameplay loop and why it is not "collect, wait, collect, evolve".
- [ ] Biomass versus growth versus evolution, a recommended model, and pacing metrics (hypotheses only; no playtest results).
- [ ] Tank and Glider roles, strengths, weaknesses and interactions; future roles marked FUTURE.
- [ ] Resource/activity categories, anti-grind and fair-progression principles, retention and ethical monetization principles.
- [ ] A playtest and validation plan with ten scenarios.
- [ ] P2-02 to P2-07 task sequence with goal, scope, dependencies, out-of-scope and acceptance criteria.

Moved out of P2-01 (they need playtests or code): target pacing values and session length (P2-07); replacing the current test progression with a configurable multi-step curve (data in P2-02, values and behavior in P2-07).

### P2-02 — Creature Definitions
- [ ] Forms, per-form requirements and growth milestones as data, with today's values unchanged.
- [ ] Server stays authoritative for choices and eligibility.

### P2-03 — Ability Definitions
- [ ] Ability definitions and dispatch with the existing handlers; validation of unknown ids.

### P2-04 — Data-driven Evolution UI
- [ ] UI reads actual definitions and requirements.
- [ ] Clear previews, strengths, limitations and feedback.

### P2-05 — Tank gameplay validation and iteration
- [ ] Validate Tank identity; define a Tank world interaction that needs no combat or record the dependency on P3/P4.
- [ ] Replace the visual-only shell with a meaningful defensive/control role only when damage and threats exist (later combat implementation).
- [ ] Add readable protection, counterplay and movement trade-offs; validate on supported inputs.

### P2-06 — Glider gameplay validation and iteration
- [ ] Validate platform reachability, air movement, landing and momentum in Studio.
- [ ] Use vertical traversal, shortcuts, scouting and precision routes in the habitat.
- [ ] Add risks and counters; avoid universal best mobility.

### P2-07 — Progression UX and balance validation
- [ ] Milestone feedback, evolution preview, readable requirements and next goal.
- [ ] Measure pacing; implement the approved Biomass model only after owner approval.
- [ ] Cross-form balance and meaningful trade-offs.
- [ ] Automated tests, Studio tests and first-player usability test.

### Gated item (not a numbered P2 task): additional initial roles
- [ ] Design Striker / Hunter only after encounter and combat foundations are playtested.
- [ ] Design Support / Controller only after a real cooperative use case exists.
- [ ] Prototype each role's unique verb and test it before full implementation.
- [ ] No automatic expansion beyond the four-role target roster without product evidence.
These roles remain gated by P3.5 and the first validated PvE loop; they are not P2 implementation tasks.

**Exit gate:** players can explain their evolution choice; two initial forms have distinct useful play patterns; progression is more than filling one meter.

**Estimated P2 completion: 5–10%.** Current evolution selection and two ability prototypes are foundations, not the redesigned progression. P2-01 documentation does not change this estimate; credit follows the exit criteria, not the existence of a design.

## P3 — First Habitat & Exploration

**Outcome:** One compact, memorable ecosystem that makes creature scale and evolution matter.

### P3.01 — Habitat design / greybox
- [x] Existing small greybox arena and basic food markers.
- [ ] Design First Habitat routes, safe pockets, landmarks, verticality and risk zones.
- [ ] Replace test arena layout with a deliberate playable slice.
- [ ] Ensure navigation clarity and multiple routes.

### P3.02 — Habitat production
- [ ] Meadow / safe onboarding zone.
- [ ] Rock Garden / cover, crevices and jump routes.
- [ ] Giant Roots / vertical traversal and hidden spaces.
- [ ] Add only a small number of areas required for MVP; Pond, Mushroom Grove and Underground can be later slices.

### P3.03 — Exploration activities
- [ ] Resource nodes with varied interactions and meaningful choices.
- [ ] Discoveries, landmarks, secrets and route rewards.
- [ ] Environmental interactions that reward specific abilities.
- [ ] Respawning/rotation rules that avoid camping and repetitive chores.

### P3.04 — World feedback
- [ ] Navigation landmarks and discoverable goals.
- [ ] Audio/visual feedback, ambience and environmental readability.
- [ ] Playtest route clarity, density and performance.

**Exit gate:** first-time players can explore for several minutes, find multiple opportunities and understand why forms change their routes.

**Estimated P3 completion: 5–10%.** Arena exists; production habitat and discovery loop do not.

---

## P3.5 — Combat & Ecosystem Design Gate (proposed in combat design)

**Outcome:** A tested combat/survival model before scaling into full encounters.

- [ ] Decide whether MVP needs damage/health, combat, hazards, or a narrower survival challenge.
- [ ] Define damage, defense, cooldown, telegraph, hit validation and counterplay.
- [ ] Define NPC/threat behavior and encounter scope.
- [ ] Define rewards and progression economy; prevent farming/exploit loops.
- [ ] Define PvP boundaries, safe zones, opt-in or contextual rules, grief prevention.
- [ ] Prototype one encounter and one defensive/offensive interaction.
- [ ] Playtest readability, fairness and performance.
- [ ] Record design decisions and reject features that do not improve the loop.

**Exit gate:** one encounter is understandable, fair, repeatable and fun enough to justify implementation at scale.

**Estimated completion: 0%.** Design gate not started.

---

## P4 — Adventure, Survival & PvE

**Outcome:** The world presents risks and challenges that make movement, evolution and decisions matter.

### P4.01 — Health / damage / recovery
- [ ] Server-authoritative health and damage.
- [ ] Damage validation, cooldowns and state transitions.
- [ ] Readable hit feedback, recovery and death causes.
- [ ] Exploit/rate-limit validation.

### P4.02 — First threat / NPC encounter
- [ ] One high-quality threat with detection, telegraph, chase and attack states.
- [ ] Fair detection and escape opportunities.
- [ ] Clear behavior under lag, character replacement and player departure.
- [ ] Reward or discovery tied to encounter, not raw farming.

### P4.03 — Survival and risk/reward
- [ ] Hazard or survival challenge with readable warning and counterplay.
- [ ] Safe areas and spawn protection policy (not monetized).
- [ ] Riskier routes offer meaningful discovery/reward.
- [ ] No unavoidable spawn deaths or invisible instant kills.

### P4.04 — Encounter variety (MVP-limited)
- [ ] Add a second encounter/activity only if the first is validated.
- [ ] Tune each form's role in encounter.
- [ ] Playtest solo and multiplayer.

**Exit gate:** one polished PvE loop is fun, readable and repeatable; death feels fair and recovery is understandable.

**Estimated P4 completion: 0–2%.** No damage/combat/PvE currently exists.

---

## P5 — Legacy, Persistence & Long-Term Goals

**Outcome:** A life can end without erasing meaningful long-term discoveries, and persistent progress does not create raw competitive power.

### P5.01 — Legacy product design
- [ ] Define records that survive: bestiary, territories, secrets, achievements, cosmetics, life history.
- [ ] Define what unlocks choices/knowledge/access—not power multipliers.
- [ ] Define death recap and discovery presentation.
- [ ] Define reset, migration, corruption and data-loss handling.

### P5.02 — In-memory Legacy model
- [ ] Implement pure data schema and progression rules.
- [ ] Tests for unlocks, duplicates, versioning and isolation.
- [ ] Keep DataStore out until schema and gameplay are proven.

### P5.03 — DataStore persistence
- [ ] Safe server-only load/save.
- [ ] Retry/backoff and budget-aware behavior.
- [ ] Session locking or equivalent concurrency protection.
- [ ] Schema versioning and migrations.
- [ ] Failure fallback; never overwrite valid data with empty defaults after load failure.
- [ ] Save on lifecycle/leave and periodic safety path.
- [ ] Test Studio/API access and simulated failures.

### P5.04 — Long-term goals
- [ ] Bestiary / discoveries / collections.
- [ ] A small set of achievable milestones.
- [ ] New-life goals surfaced without daily-login pressure.
- [ ] Cosmetic identity or markings if appropriate for MVP.

**Exit gate:** persistence survives rejoin reliably; player can see meaningful Legacy growth; no permanent raw-stat advantage.

**Estimated P5 completion: 0%.** No Legacy or DataStore implementation.

---

## P6 — Multiplayer Experiences & Fairness

**Outcome:** Other players create interesting cooperation/competition without breaking the experience.

### P6.01 — Multiplayer baseline
- [x] Basic server-owned per-player state and prototype remotes.
- [x] Initial pure multiplayer rule tests.
- [ ] Studio Start Server / 2–4 clients verification for core loops.
- [ ] No cross-player reset, reward, ability or lifecycle leaks.

### P6.02 — Cooperative moments
- [ ] Shared objectives or encounter interactions.
- [ ] Complementary roles/abilities with a real use case.
- [ ] Rewards and credit rules that resist exploit/AFK farming.

### P6.03 — Fair competition (scope gated)
- [ ] Decide MVP PvP policy; PvP is not automatically required.
- [ ] Safe onboarding, protected recovery and readable boundaries.
- [ ] Avoid spawn camping and grief loops.
- [ ] Balance new/experienced players and group sizes.
- [ ] Test server authority, latency and abuse.

### P6.04 — Social identity
- [ ] Show forms and selected discoveries clearly.
- [ ] Group/friend play improvements only where valuable.
- [ ] Reporting/moderation and player safety readiness.

**Exit gate:** multiplayer creates positive moments; core systems are isolated and abuse-resistant; PvP (if present) is fair and optional/contextual.

**Estimated P6 completion: 10–15%** for prototype-level foundations only; actual cooperative/competitive gameplay is not implemented.

---

## P7 — Polish, MVP validation & launch

**Outcome:** A small but coherent, reliable and discoverable Roblox experience can be released publicly.

### P7.01 — UX / onboarding
- [ ] First-session tutorial or guided first objective.
- [ ] Clear controls, prompts and ability states.
- [ ] Readable HUD and progression feedback.
- [ ] Death/new-life flow and next objective.
- [ ] Accessibility, text sizing and touch-safe layout.

### P7.02 — Art, animation, audio
- [ ] Creature silhouettes/models and evolution visual changes.
- [ ] Movement/ability/attack/impact/interaction animations.
- [ ] Audio cues for pickups, growth, evolution, threats and death.
- [ ] Habitat visual identity, VFX readability and performance budget.

### P7.03 — Performance / compatibility
- [ ] Mobile-first profiling and memory/CPU/network budgets.
- [ ] Keyboard/mouse, touch and gamepad checks.
- [ ] Low/medium/high device tests.
- [ ] Streaming/content loading strategy if needed.
- [ ] No severe frame drops, input failures or replication overload.

### P7.04 — Quality and security
- [ ] Automated pure-rule tests and build validation.
- [ ] Studio smoke/regression suite.
- [ ] 2–4 player server test.
- [ ] Progression, remote, movement and reward exploit review.
- [ ] Error/warning cleanup and known issue triage.
- [ ] Moderation/reporting and Roblox policy check.

### P7.05 — Closed playtest / Alpha
- [ ] Recruit players beyond the developer.
- [ ] Observe first 5–10 minutes without coaching.
- [ ] Record where players get confused, bored, stuck or overpowered.
- [ ] Measure completion, session quality, evolution choice and return intent.
- [ ] Fix top blockers and rerun test.

### P7.06 — Release operations
- [ ] Analytics/events and privacy-conscious instrumentation.
- [ ] Icon, thumbnails, description, trailer/short clips if useful.
- [ ] Release notes and support/feedback channel.
- [ ] Staged launch, feature flags/kill switches where appropriate.
- [ ] Rollback plan and incident owner.
- [ ] Public MVP release decision based on gates, not calendar pressure.

**Exit gate:** a new player can understand and enjoy the core loop; no launch-blocking bugs/security issues; mobile and multiplayer validated; playtest evidence supports release.

**Estimated P7 completion: 0–5%.** No external playtest or launch operations.

---

## 5. MVP scope: what we ship and what we defer

### Required for MVP
- One safe starting zone + one compact, polished First Habitat.
- Responsive movement/camera and clear interaction feedback.
- Longer, configurable multi-stage growth and meaningful evolution decision.
- Two distinct, validated evolved playstyles (Tank and Glider).
- One fair threat/PvE or survival encounter.
- Complete death → recap/restart → new life cycle.
- A small Legacy record (e.g. discoveries/bestiary) that survives death and rejoin.
- Reliable multiplayer baseline, preferably cooperative moments; fair PvP policy even if PvP is disabled.
- Onboarding, mobile UI, audio/visual feedback and performance.
- External playtest evidence and basic operational readiness.

### Explicitly not required for first MVP
- Huge open world or all candidate biomes.
- All four evolved classes fully complete (Tank/Glider are first; Striker/Support are gated).
- Ranked PvP, competitive ladders, esports or large-scale PvPvE.
- Seasons, daily login streaks, guilds or complex social systems.
- Large bestiary or hundreds of collectibles.
- Monetization at all; if added, cosmetic/identity-first and fair.
- Premium resurrection, death protection, permanent combat stats or pay-to-win.

## 6. Engineering sequence and PR decomposition

Use TT-P0-02R as the detailed engineering plan. Proposed next sequence:

1. **P1-03 — Reset Current Life on Death** (implemented; Studio validation outstanding).
2. **P1-04 — Respawn / minimal life transition UX** (implemented as controlled respawn with a minimal recap; Studio validation outstanding).
3. **P1-05 — Lifecycle hardening and regression** (implemented; pure tests written, Studio validation outstanding).
4. **P2-01 — Progression & Evolution Design Gate** (documentation only; no code).
5. **P2-02 — Creature Definitions** (data-driven forms).
6. **P2-03 — Ability Definitions** (data-driven abilities).
7. **P2-04 — Data-driven Evolution UI**.
8. **P2-05 — Tank gameplay validation and iteration**.
9. **P2-06 — Glider gameplay validation and iteration**.
10. **P2-07 — Progression UX and balance validation**.
11. **P3-01 — First Habitat vertical-slice design + greybox**.
12. **P3-02 — Habitat traversal/resource activities**.
13. **P3.5 — Combat & Ecosystem Design Gate**.
14. **P4-01 — Health/damage foundation**.
15. **P4-02 — First threat/encounter**.
16. **P5-01 — Legacy schema and rules (in-memory)**.
17. **P5-02 — DataStore persistence and recovery**.
18. **P6 — Multiplayer activity and fairness** (some can run in parallel after system contracts).
19. **P7 — UX/art/performance/security/playtests/release**.

Each PR should:
- Have one outcome and narrow scope.
- Include acceptance criteria, tests and Studio checklist.
- Avoid changing unrelated systems.
- Record actual validation status (not just intended checks).
- Be merged only after review and required validation.

## 7. MVP and launch progress tracking

Use a gate-weighted checklist, not PR count. Suggested weights:

| Gate | Weight |
|---|---:|
| Core Life and reset reliable | 10% |
| Evolution/progression fun and meaningful | 20% |
| First Habitat/exploration loop | 15% |
| First PvE/survival loop | 15% |
| Legacy + persistence | 10% |
| Multiplayer/fairness | 10% |
| UX/onboarding/art/audio | 10% |
| Performance/security/testing/playtest | 10% |
| **Total** | **100%** |

A gate earns credit only when its exit criteria are met; partial implementation can receive partial credit after review. Current estimated overall MVP readiness: **~10%**.

Public launch readiness should be tracked separately after MVP:

| Launch gate | Weight |
|---|---:|
| MVP feature gates passed | 40% |
| Cross-platform performance and compatibility | 15% |
| Security, moderation and policy | 15% |
| External playtest and blocker closure | 15% |
| Release assets, analytics and operations | 10% |
| Staged rollout/rollback plan | 5% |
| **Total** | **100%** |

Current public launch readiness: **~5%**. This is not “5% of time”; it is a readiness estimate.

## 8. Post-launch roadmap (P8+)

Post-launch work is evidence-driven; do not promise a fixed cadence before retention and team capacity are known.

### P8 — Stabilization & first retention cycle
- Fix launch issues and confusing first-session flows.
- Improve performance and reliability using telemetry and player reports.
- Rebalance progression and death/recovery based on actual behavior.
- Add small quality-of-life updates; avoid adding content over unresolved core problems.

### P9 — Habitat expansion
- Add one new micro-biome/route at a time.
- Introduce new traversal interactions and secrets.
- Validate performance and navigation before expanding footprint.

### P10 — Evolution depth
- Add one new evolution/ability only when it introduces a proven new gameplay verb.
- Expand specialization, mutation or build choices only if players understand them.
- Rebalance existing forms and maintain fair matchups.

### P11 — Ecosystem and encounter variety
- Additional threats, behaviors, environmental events and challenge variants.
- Cooperative objectives and emergent encounters.
- Avoid repetitive farming and reward inflation.

### P12 — Legacy, identity and collections
- More bestiary/discovery records, cosmetics, markings and life-history features.
- Optional collection goals and mastery milestones.
- Legacy continues to grant identity, knowledge and choices—not raw competitive power.

### P13 — Social and competitive systems (gated)
- Groups, cooperative events, opt-in PvP or PvPvE only after safety and fairness evidence.
- Competitive modes need matchmaking/skill and anti-grief design; do not bolt them onto the sandbox casually.

### P14 — Live operations and seasonal experiments (optional)
- Limited-time habitat events, community challenges and themed content.
- Transparent rewards, no punitive FOMO or manipulative daily pressure.
- Evaluate impact on retention, fairness, workload and player sentiment before making recurring.

## 9. Product metrics and playtest questions

Do not optimize for raw playtime alone. Use a balanced view:

- **First-session clarity:** Can a new player identify the next action and why it matters?
- **Activation:** Does the player complete the first meaningful activity/evolution milestone?
- **Progression quality:** Are choices understood and felt as different?
- **Exploration:** Do players discover optional routes/opportunities without a guide?
- **Fairness:** Are deaths and losses understood, avoidable through skill/decision, and recoverable?
- **Social quality:** Do other players create cooperation, competition or memorable moments rather than grief?
- **Return intent/retention:** Do players voluntarily want another life/session?
- **Stability:** crashes, errors, severe performance problems, exploit incidents.
- **Economy integrity:** reward sources/sinks, farming and power disparity.

Use cohorts and qualitative observation; early sample sizes are small and should not be overinterpreted. A metric is a diagnostic, not a target to manipulate.

## 10. Governance and change control

- This master document connects product and engineering plans; it does not replace them.
- Product phases P0–P7, engineering P1–P7/P3.5 and Product Vision P0–P8 are distinct.
- Revisit estimates after each phase exit and meaningful playtest.
- Any scope expansion must answer: What player problem does it solve? How will we test it? What is deferred?
- Keep a visible list of decisions, risks, blockers and validated evidence.
- Never label a feature “done” solely because its PR merged.
- Do not make launch date or Top 1000 promises without evidence.

## 11. Current status snapshot

As of the November 2026 planning baseline:
- Prototype: greybox arena, food pickup, Biomass, three growth stages, evolution choice (Tank/Glider), prototype Shell and Glide abilities.
- P1.01 Biomass rename: merged.
- P1.02 LifeService: implementation PR exists; runtime Studio verification is still a separate requirement.
- P1.03 death reset, P1.04 controlled respawn with a minimal life recap, and P1.05 lifecycle hardening: implemented in code, with pure unit tests written but not executed in the authoring environment. No Roblox Studio validation of any P1 step has been recorded; see the README checklists.
- No damage, combat, PvE, Legacy, DataStore, production habitat, external playtest or public launch readiness.
- Current progression values (food 10; thresholds 0/30/60; cap 100) are **test tuning**, not final design.

## 12. Definition of success

MVP is successful when external players—not only the developer—can:
1. Understand the creature fantasy and first objective.
2. Enjoy moving, exploring and collecting in the habitat.
3. Make an evolution choice and feel a real difference.
4. Encounter a fair challenge and understand death/recovery.
5. Discover something worth preserving in Legacy.
6. Play with others without serious state leaks, grief or exploit-driven advantage.
7. Express a clear desire (and reason) to play another life.

Public launch is a decision made after these outcomes and release gates are evidenced—not merely after the final planned PR.
