# TINY TITANS — Product Vision & Top 1000 Strategy

**Status:** Product north star; product strategy reference  
**Version:** 1.0  
**Date:** 2026-11-13  
**Platform:** Roblox  
**Primary ambition:** Build a genuinely compelling, commercially sustainable Roblox experience capable of competing for a Top 1000 experience ranking. This is an ambition, not a guaranteed outcome.

---

## 1. Executive product vision

Tiny Titans must become a game players choose to spend time in because its moment-to-moment play is satisfying, its world rewards curiosity, its creatures express player identity, and its multiplayer creates memorable stories.

We are **not** building a technical demo, a sequence of isolated abilities, or a generic “collect objects until a number fills” simulator.

**Player fantasy:** Start as a tiny creature in a world that feels huge. Explore, discover food and secrets, grow, make meaningful evolution choices, master a distinctive playstyle, meet other creatures, compete and cooperate, and gradually build a creature identity worth showing off.

**Core promise:** *You don't just become bigger. You become something different — and your choices change how you experience the world.*

Every feature must support at least one of these outcomes:
1. The game is fun and understandable immediately.
2. The player has a meaningful short-term goal.
3. The player discovers or masters something new.
4. The player's creature and progress feel personal.
5. Other players make the experience more interesting.
6. The game earns revenue without undermining trust or fair play.

Top 1000 is a product and distribution challenge as well as a development challenge. Good code is necessary, but not sufficient. We must validate the experience with real players and improve it using observed behavior.

**The concrete game and MVP contract now live in [Gameplay Blueprint & MVP Contract](Gameplay%20Blueprint%20%26%20MVP%20Contract.md).** That document is authoritative for the genre, core loop, first habitat, form roles and ability contract. [Tiny Titans Master Roadmap](Tiny%20Titans%20Master%20Roadmap.md) is the only execution roadmap. This document remains the north star and strategy; its strategic stages are not a second task tracker.

## 2. Product principles — non-negotiable

### 2.1 Fun before feature count
A small number of excellent mechanics is better than a large collection of shallow systems. Do not add a feature because it is easy to implement or looks impressive in a PR.

### 2.2 Immediate responsiveness
Movement, camera, input, interactions, ability activation, feedback and UI must feel reliable. A core action that sometimes fails is a P0 issue, not polish.

### 2.3 Meaningful choices
Evolution branches, abilities and upgrades must change decisions and play patterns, not only stats or appearance. Each choice needs strengths, trade-offs and situations where it shines.

### 2.4 Discovery over chores
Reward curiosity, exploration, skill and social play. Avoid padding the experience with long empty travel, repetitive low-value grinding, arbitrary waiting or chores that exist only to inflate session time.

### 2.5 Fair multiplayer
Competition should create exciting stories, not make new or weaker players helpless. Use readable rules, recovery opportunities, safe onboarding and anti-griefing constraints.

### 2.6 Ethical, transparent monetization
Purchases should offer self-expression, optional convenience or additional content — not sell relief from deliberately frustrating design. No pay-to-win advantage in competitive modes, deceptive purchase UI, or pressure tactics aimed at children.

### 2.7 Mobile-first, cross-platform quality
Roblox audiences use touch, keyboard/mouse and gamepad. Every core action must have an accessible input path and clear UI. Never design a mechanic that only works comfortably on a keyboard.

### 2.8 Evidence over assumptions
Design hypotheses must be tested. Do not call a feature successful because it was implemented, because the developer likes it, or because a test passes.

## 3. Target player experience

We should design for overlapping player motivations rather than one narrow player type:

- **Collectors:** want to discover, unlock and complete creature, cosmetic and achievement collections.
- **Mastery players:** want to improve movement, abilities, routes and competitive skill.
- **Explorers:** want secrets, landmarks, unusual resources and environmental surprises.
- **Social players:** want to play with friends, show their creatures, cooperate and compete.
- **Progression players:** want visible goals, meaningful milestones and long-term projects.
- **Creative/identity players:** want a creature that looks and feels like their own.

These are design lenses, not assumptions about every player. First-session testing must reveal which motivations resonate.

## 4. Core gameplay architecture

### 4.1 The moment-to-moment loop

**Move → Notice → Choose → Act → Get satisfying feedback → Make the next choice.**

Examples:
- Spot a rare food node on a ledge; decide whether to attempt a risky jump or take a safer route.
- See another player approaching the same resource; race, cooperate, or choose another opportunity.
- Discover a hidden route that rewards a Glider's movement skill.
- Use a defensive ability to survive a hazard or protect a teammate, then capitalize on the opening.

The player should be making small, understandable decisions frequently. Avoid long stretches in which the only action is running toward the next identical collectible.

### 4.2 The session loop

1. Spawn into a readable, lively starting area.
2. Receive one clear immediate objective and discover nearby optional opportunities.
3. Explore and collect through varied interactions, not only identical touch pickups.
4. Earn growth/progression and encounter a meaningful milestone.
5. Make or advance a creature/build choice.
6. Participate in an activity: challenge, traversal route, event, cooperative objective or fair competition.
7. Receive clear rewards and understand the next available goal.
8. Have a natural reason to return, without punishing the player for leaving.

### 4.3 Long-term loop

**Explore content → Master mechanics → Evolve/customize → Build collection and reputation → Participate in new challenges/seasons → Return.**

Long-term systems must add new decisions or expression. They must not simply make numbers grow forever.

## 5. Differentiation: what makes Tiny Titans memorable?

The strongest candidate is the combination of **small-creature scale + expressive evolution + traversal-driven world design + readable multiplayer encounters**.

The world should be designed from the creature's perspective. Ordinary objects become landmarks, cover, routes, hazards and opportunities. A leaf, root system, rock formation or fallen branch can create a traversal puzzle.

### 5.1 Signature design direction: a living miniature ecosystem
The arena should feel like a place, not a flat test map:
- distinct micro-biomes with recognizable silhouettes and color palettes;
- vertical routes and multiple ways to reach objectives;
- safe gathering pockets and risk/reward areas;
- environmental movement opportunities;
- resource hotspots that change or rotate;
- secrets visible from a distance and discoverable through play;
- landmarks that help players navigate without staring at a map.

Do not build a huge empty open world. Build a compact, dense, replayable space first.

### 5.2 Evolution must change how the player sees the world
The first two branches remain prototypes, not accepted gameplay identities:
- **Tank:** resilience and space control; should brace against hazards and move/hold designated heavy obstacles.
- **Glider:** aerial traversal; should launch, steer, dive and glide across meaningful gaps and elevated routes.

Baby Bug remains a useful agile baseline. The Glider's current gravity-compensation prototype is not sufficient: it needs agency and world-authored use cases. Do not add more forms until the First Habitat and these roles are validated. See the Gameplay Blueprint for the exact ability contract.

### 5.3 Emergent stories
Design systems that allow short stories to happen naturally: a Glider reaches a high resource first, a Tank holds a narrow passage, two players coordinate to reach a hidden location, or a timed ecosystem event changes the safest route.

## 6. Core pillars and quality bar

### Pillar A — Feel and control
- Responsive movement with predictable acceleration, stopping and jumping.
- Camera that keeps the creature readable and the destination visible.
- Consistent input buffering and clear feedback for accepted/rejected actions.
- Abilities that activate reliably and communicate readiness, activation, duration and cooldown.
- No unexplained input loss, hidden prerequisites or ambiguous controls.
- Touch and gamepad equivalents for every essential action.

**Quality gate:** A new player can move, jump, interact and activate an available ability without coaching. Repeated inputs behave consistently. Any intermittent failure blocks progression.

### Pillar B — Progression and evolution
- Growth milestones are frequent enough to create early momentum but not meaningless.
- Evolution is a memorable decision with clear descriptions and previews.
- Each branch has a distinct gameplay loop, strengths, weaknesses and skill ceiling.
- Progress is visible in the creature, UI, animations, sound and world interactions.
- Future progression includes horizontal choices and mastery, not only linear stat inflation.

### Pillar C — World and discovery
- Dense points of interest and useful landmarks.
- Several viable routes to important resources.
- Discoverable secrets and optional challenges.
- Environmental hazards that are readable, fair and teachable.
- Resource variety with different interaction patterns and risk/reward.
- Content density before map size.

### Pillar D — Social and competitive play
- Friends can find and join one another easily.
- Players can identify creature forms and notable achievements at a glance.
- Cooperative activities provide shared goals and complementary roles.
- Competitive activities are short, readable and fair.
- Avoid spawn camping, unavoidable griefing and permanent loss of valuable progress.
- Solo players still have a satisfying experience.

### Pillar E — Identity and collection
- Creature silhouettes, animations and sound make forms recognizable.
- Cosmetic customization gives players meaningful expression.
- Collections and achievements celebrate different playstyles.
- Rare items should be exciting but not required for competitive viability.
- Players can show off identity in the world and in their profile.

## 7. Glider and ability design: immediate product priority

The current Glider experience has been reported as unreliable (Q sometimes does not activate on the first press) and mechanically limited. This is a player-facing core-quality issue.

**Do not proceed to add more abilities until this is investigated and corrected.**

### 7.1 Diagnose before redesign
Inspect the full client-input → remote request → server validation → physics/state → client feedback path. Determine whether the issue is caused by:
- input capture/focus or duplicate input connections;
- character/form/grounded-state prerequisites;
- cooldown/state replication timing;
- remote throttling or request rejection;
- character/root availability during spawn;
- server/client physics ownership or force lifecycle;
- activation feedback not matching actual server state.

Instrument or log rejection reasons during development. Do not silently swallow failed activation. Distinguish “input received”, “request sent”, “server accepted/rejected”, and “effect started”.

### 7.2 Product direction to prototype
The chosen direction is an aerial traversal specialist: launch from height, steer, trade altitude for speed/distance, and use limited updrafts. It must not hover indefinitely or provide unrestricted flight. The habitat must contain meaningful aerial routes and rewards. Prototype and compare:
- reliable one-press activation;
- meaningful air steering;
- momentum and direction control;
- predictable start/end conditions;
- clear landing and cooldown feedback;
- routes, shortcuts and optional rewards designed around gliding;
- mobile/gamepad activation and directional control.

A simple initial control scheme is acceptable if it feels excellent. Do not add complex flight simulation for its own sake. Keep physics bounded and server-validated.

### 7.3 Ability design contract
Every ability must define:
- fantasy and player-facing purpose;
- activation input and platform equivalents;
- valid states and explicit rejection feedback;
- duration, cooldown and cancel conditions;
- movement/physics behavior and bounds;
- counterplay and trade-offs;
- world interactions it enables;
- visual/audio/UI feedback;
- accessibility and network behavior;
- measurable playtest questions.

Tank Shell must similarly become a meaningful gameplay action, not a visual-only button. It needs a clear use case in a tested interaction before we expand it.

## 8. First-session experience and onboarding

The first 30 seconds should communicate: “I am a tiny creature in a world worth exploring, and I can do something fun right now.”

### First-session sequence (design target, validate with tests)
1. Spawn in a safe, visually readable location with camera and movement already working.
2. A concise contextual prompt demonstrates movement and the nearest interesting interaction.
3. The player gets a satisfying first collection/action quickly.
4. Show progress and explain what it unlocks in plain language.
5. Demonstrate a small discovery or traversal opportunity.
6. Introduce evolution as a choice with clear role previews and a safe explanation.
7. Give the player a short post-evolution activity that proves the choice matters.
8. Surface the next goal and a social invitation without blocking play.

Avoid long text tutorials, forced multi-screen dialogs and unexplained UI. Teach by doing; let players revisit help.

## 9. Content and activity strategy

Do not rely on one activity. Build a small set of reusable activity patterns:

- **Forage routes:** resource clusters with route choices and changing availability.
- **Traversal challenges:** timed but forgiving movement courses; Glider routes are one example.
- **Discovery hunts:** clues, hidden objects and landmarks.
- **Ecosystem events:** temporary world changes or resource appearances that create shared moments.
- **Co-op objectives:** complementary roles and shared rewards.
- **Friendly competitions:** short races, collection contests or skill trials.
- **Mastery challenges:** optional goals that teach advanced ability use.

For the first MVP, choose only 2–3 activities that reinforce the core identity. Make them replayable through route variation, player interaction and rotating modifiers rather than huge amounts of one-off content.

## 10. Retention strategy — reasons to return

Retention should come from a combination of mastery, unfinished meaningful goals, social bonds, discovery and fresh content.

### D1: reason to return tomorrow
- A clear next evolution/mastery objective.
- A discovered lead or challenge the player has not completed.
- A social reason: friend, group challenge or shared event.
- A small, transparent return reward may support the loop, but must not be the only reason to return.

### D7: reason to return over a week
- Multiple playstyles worth mastering.
- Collection milestones and cosmetic goals.
- Rotating challenges and a small event cadence.
- Cooperative/competitive activities with fresh combinations.
- Visible progress that respects time already invested.

### D30+: durable reasons to stay
- Skill mastery and meaningful build variety.
- New areas, creatures or activity variations.
- Seasonal themes and collection chapters.
- Community challenges and social identity.
- A roadmap informed by player feedback and usage data.

**Avoid:** punitive streak loss, energy systems that block play, excessive time gates, deliberately slow progression, daily chores with no gameplay value, and FOMO that pressures children to spend.

## 11. Monetization and economy

Monetization must be designed alongside the product, but only activated after the game is enjoyable and its economy is understood.

### 11.1 Suitable product categories
- **Cosmetics:** skins, palettes, markings, trails, emotes, victory/idle animations, ability visual effects.
- **Customization:** additional cosmetic presets, profile presentation, non-power creature expression.
- **Optional convenience:** carefully evaluated quality-of-life features that do not create competitive advantage.
- **Seasonal content:** transparent pass with clearly listed rewards and free progression path.
- **Supporter products:** optional ways to support development with cosmetic recognition.
- **Private servers / social options:** only if they provide real player value.

### 11.2 Monetization guardrails
- No pay-to-win combat, movement or resource advantage in competitive play.
- No selling a fix for frustration intentionally introduced into the free experience.
- No misleading scarcity, fake discounts or unclear odds.
- If randomized paid rewards are ever considered, review Roblox policy, age-related requirements and disclosure obligations first; the preferred initial approach is direct-purchase cosmetics.
- Make prices and contents clear before purchase.
- The game must remain enjoyable without spending.
- Test economy inflation and reward pacing before adding paid currency.

### 11.3 Economy foundations
Before implementing a shop, define:
- earnable currencies and their sources/sinks;
- reward pacing and expected session earnings;
- cosmetic price tiers;
- duplicate handling if collections exist;
- inflation controls;
- server-authoritative transactions and persistence;
- purchase failure/refund-safe behavior;
- analytics for purchase funnel and player sentiment.

Do not add premium currency simply because other games have it.

## 12. MVP scope — prove the experience, not the content volume

The first public-quality MVP should be small but complete.

### Required
- Polished movement, camera and reliable inputs on keyboard, touch and gamepad.
- One compact, dense, visually coherent ecosystem zone.
- A satisfying collection/growth loop with more than one interaction pattern.
- Two genuinely distinct, useful evolution branches (Tank and Glider).
- At least one meaningful activity for each branch.
- A short onboarding flow and clear UI/feedback.
- Multiplayer interactions that create interesting moments without griefing.
- Basic persistent player progress, after data schema and failure handling are designed.
- A small set of cosmetics/identity options.
- Analytics events needed to evaluate the first-session funnel and retention.
- Performance and exploit/security checks.
- A repeatable playtest process.

### Not required for MVP
- Dozens of creatures or biomes.
- Huge open world.
- Breeding, trading, player marketplace or complex crafting.
- Large-scale guild systems.
- Complex PvP progression or ranked esports.
- Aggressive live operations.
- Large paid item catalogue.

Add these only when evidence shows the core game supports them.

## 13. Product roadmap and gates

Roadmap is outcome-driven. Milestones are not permission to skip testing.

### P0 — Product and technical audit
**Outcome:** Know what exists, what works, and what is not fun.
- Audit current repository, systems and Studio place.
- Run a real multiplayer Studio session.
- Reproduce and diagnose Glider's inconsistent Q activation.
- Observe a new player attempting the current loop.
- Record friction, confusion, dead time and fun moments.
- Map current implementation against this strategy.

**Exit gate:** Prioritized issue list with evidence; no assumed runtime success.

### P1 — Core feel
**Outcome:** Movement and actions feel reliable and satisfying.
- Fix input reliability and state feedback.
- Tune movement, jump, camera, character scale and collision.
- Make Glider a controllable traversal ability.
- Give Tank a real, testable defensive use case.
- Add sound, animation, VFX and UI feedback where they improve clarity.
- Verify touch/gamepad paths.

**Exit gate:** Repeated use is consistent across platforms and multiplayer Studio tests; testers can explain what happened after each ability attempt.

### P2 — Core loop and first session
**Outcome:** A new player understands and enjoys the first session.
- Improve arena readability and environmental density.
- Add resource/interaction variety.
- Tune growth and evolution pacing.
- Add contextual onboarding.
- Make evolution a meaningful decision with immediate proof of difference.

**Exit gate:** Observed players can independently complete the first-session journey and describe why they want to continue.

### P3 — Signature experience
**Outcome:** Tiny Titans has a memorable reason to exist.
- Prototype miniature-ecosystem traversal and discovery.
- Add a small set of branch-specific challenges.
- Test emergent player interactions.
- Compare alternative concepts with playtests; retain the strongest.

**Exit gate:** Testers can describe what is distinctive about Tiny Titans without being prompted.

### P4 — Social gameplay
**Outcome:** Playing with others adds value.
- Friends/session joining improvements.
- Cooperative activity and friendly competition.
- Anti-griefing, safe zones and fair reward rules.
- Clear player identity and readable forms.

**Exit gate:** Multiplayer sessions produce positive interactions and remain enjoyable for solo players.

### P5 — Retention foundation
**Outcome:** Players have meaningful goals beyond the first session.
- Persistent progression with robust server-side data handling.
- Collections, mastery and achievements.
- Rotating challenges/events with sustainable content cost.
- Return goals that do not punish absence.

**Exit gate:** Early cohort data shows players return for gameplay goals, not only login rewards.

### P6 — Monetization
**Outcome:** Players can support and personalize without breaking fairness.
- Cosmetic-first shop.
- Transparent products and purchase flow.
- Optional season structure only if content cadence is sustainable.
- Economy telemetry and safeguards.

**Exit gate:** Purchases are optional, understandable, non-pay-to-win and do not materially damage player experience.

### P7 — Public beta and iteration
**Outcome:** Validate audience fit and improve with evidence.
- Instrument funnel and performance.
- Run moderated and unmoderated playtests.
- Test thumbnails, icon and store description responsibly.
- Fix the largest retention/friction problems before adding breadth.
- Establish a realistic update cadence.

**Exit gate:** Product health is stable enough to scale acquisition and content updates.

### P8 — Scale toward Top 1000
**Outcome:** Grow a durable audience.
- Expand content based on proven player motivations.
- Creator/community outreach and shareable in-game moments.
- Seasonal updates with clear value.
- Localization and accessibility based on audience data.
- Performance, moderation and support readiness.

**Exit gate:** Growth is accompanied by healthy retention, satisfaction, stability and sustainable operations — not visits alone.

## 14. Metrics and experimentation

Do not invent universal success thresholds before collecting a baseline. Establish targets after comparable genre research and initial cohorts.

### North-star candidate
**Weekly players who complete a meaningful gameplay activity and return in a later session.**

This balances activity completion and return behavior better than raw playtime alone. Validate the definition once analytics are available.

### Funnel
- Experience start → character control.
- Control → first meaningful interaction.
- First interaction → first progression milestone.
- Milestone → evolution decision.
- Evolution → branch-specific activity.
- First session → return session.

### Core metrics
- D1, D7 and D30 retention by acquisition cohort.
- Average and median session length (never optimize this in isolation).
- First meaningful action time.
- First-session activity completion.
- Evolution selection and branch distribution.
- Ability activation success/rejection rates and reasons.
- Challenge completion and replay rates.
- Party/friend participation.
- Crash/error/performance rates.
- Purchase conversion, payer retention and revenue per active user, once monetization is live.
- Qualitative fun, clarity, fairness and intent-to-return feedback.

### Experiment rules
- Change one major variable at a time where practical.
- Compare cohorts, not anecdotes alone.
- Segment by platform, new/returning players and party/solo context.
- Pair quantitative data with direct observation and player feedback.
- Do not optimize playtime by making the game slower or more frustrating.
- Record hypothesis, change, result and decision.

## 15. Playtesting discipline

Every meaningful gameplay milestone must include:
1. Developer test for obvious failures.
2. Multiplayer Studio test with at least 2 clients for networked mechanics.
3. Cross-platform input test where relevant.
4. First-time player observation without verbal coaching.
5. Short post-test questions: What was fun? What was confusing? What did you want to do next? Would you return? Why/why not?
6. Issue log ranked by player impact, frequency and confidence.
7. Follow-up test after fixes.

A successful unit test or Rojo build does not prove that the game is fun or that the Roblox runtime behavior is correct.

## 16. Technical and operational foundations

- Keep rewards, progression, purchases, cooldowns and competitive outcomes server-authoritative.
- Treat client input as a request; validate state, distance, rate and ownership on the server.
- Design persistence with schema versioning, safe retries, failure handling and no data-loss assumptions.
- Instrument key product events without collecting unnecessary personal data.
- Keep performance budgets for low-end mobile devices.
- Use modular systems, but do not over-engineer speculative features.
- Add automated tests for deterministic rules and Studio tests for actual runtime behavior.
- Plan moderation, reporting and safe social defaults before expanding social features.
- Review Roblox platform policies before implementing purchases, trading, randomized rewards or user-generated content.

## 17. Feature proposal scorecard

Before accepting a new feature, answer:

1. Which player motivation does it serve?
2. What is the player-facing fantasy or problem?
3. What new decision or gameplay verb does it add?
4. How does it improve fun, discovery, identity, social play or progression?
5. What is the smallest prototype that can test it?
6. What could make it frustrating, unfair or exploitable?
7. How will we measure whether it works?
8. What existing work should be delayed or removed to make room?

Prioritize using:
- Player impact (high/medium/low)
- Confidence in the hypothesis (high/medium/low)
- Implementation cost (small/medium/large)
- Risk (technical, balance, moderation, economy)

Do not confuse engineering complexity with player value.

## 18. Current state and immediate decisions

The current repository represents an early prototype foundation: a compact greybox arena, food/growth, Energy HUD, Tank/Glider evolution selection, initial Tank Shell and Glider abilities, and multiplayer hardening. This is a foundation, not a retention-ready or monetization-ready product.

The original prototype GDD explicitly excluded persistence, monetization, pets, trading, multiple biomes and long-term progression. This strategy supersedes those exclusions as long-term product direction, but does **not** mean all such systems should be built now. The MVP remains deliberately constrained.

Immediate priorities:
1. Freeze feature expansion briefly and perform a product/runtime audit.
2. Reproduce and fix Glider input reliability.
3. Redesign ability quality around player agency and world use cases.
4. Test whether the current collect-grow-evolve loop is fun for new players.
5. Prototype the miniature-ecosystem signature experience.
6. Only then choose the next implementation milestones based on playtest evidence.

### Explicit decision
**Do not automatically proceed to the next numbered ability milestone (for example, another Tank feature) just because it is next in the technical sequence.** Product priority takes precedence over milestone numbering.

## 19. Definition of a Tiny Titans release candidate

A release candidate is not “all planned features implemented.” It must demonstrate:
- Reliable and enjoyable controls on supported platforms.
- A compelling first session with minimal explanation.
- A repeatable core loop with meaningful choices.
- Distinct evolution playstyles that are useful in real activities.
- A memorable world and at least one recognizable signature experience.
- Social play that is fun and fair.
- Clear progression and reasons to return.
- Optional, transparent monetization that respects fair play.
- Stable persistence, performance, security and moderation basics.
- Playtest and cohort evidence that supports continued investment.

**Our standard:** If players do not want to return when there are no daily rewards and no purchase pressure, the core game is not ready. Fix the game before adding retention wrappers.

---

## Appendix A — Document authority

- [Gameplay Blueprint & MVP Contract](Gameplay%20Blueprint%20%26%20MVP%20Contract.md) defines the actual game, first release scope, form roles and ability quality bar.
- [Tiny Titans Master Roadmap](Tiny%20Titans%20Master%20Roadmap.md) is the only execution roadmap and task sequence.
- [Evolution Sandbox Architecture](Evolution%20Sandbox%20Architecture.md) defines technical boundaries and current implementation facts.
- [Combat Progression & Endgame Design](Combat%20Progression%20%26%20Endgame%20Design.md) is a deferred design reference, not approved implementation scope.
- This document defines the north star and Top 1000 strategy. It does not authorize implementation without a scoped task, acceptance criteria and validation plan.

## Appendix B — Terminology

- **Retention:** the proportion of players from a cohort who return after a defined period.
- **First-session funnel:** the sequence from joining to experiencing the core promise.
- **Core loop:** the repeated set of actions and decisions that make the game enjoyable.
- **North-star metric:** a primary measure that represents recurring player value.
- **Live operations:** ongoing events, updates and content after launch.
- **Pay-to-win:** purchases that provide meaningful competitive power or unfair advantage.
