# Tiny Titans — Product Vision v2.0
## Hybrid Creature Exploration RPG

**Owner approval:** 2026-11-15  
**Status:** Approved product direction; long-term features remain gated by roadmap phases and evidence.  
**Platform:** Roblox  
**Ambition:** Build a high-quality, replayable Roblox experience with a credible path toward Top 1000. This is an ambition, not a guarantee.

## 1. Executive vision

Tiny Titans is a **Hybrid Creature Exploration RPG**: a co-op-friendly PvE adventure in a miniature living ecosystem, where the player is the creature.

The player is a small creature in a world that feels enormous. Explore oversized natural spaces, discover routes and species, grow during a life, evolve into a form with a distinct way of interacting with the world, and carry meaningful knowledge into future lives. Over time, the player builds a personal creature identity, collection and—if the core game earns it—a modest Habitat and bonds with other creatures.

The game combines:
- traversal-led exploration adventure;
- creature growth and evolution;
- light, non-grindy RPG progression;
- Bestiary, discoveries and collections;
- repeatable solo-friendly PvE activities;
- optional cooperative play;
- later, personal Habitat and creature companions.

This is **not** a conventional MMORPG. We want the satisfying long-term goals of an RPG without MMO-scale world production, guild infrastructure, mandatory parties, endless stat inflation or grind before the first fun moment.

**Product promise:** Explore a world that feels enormous, become a creature with a distinct way of moving and interacting, discover life worth remembering, and gradually build a personal place and identity in that ecosystem.

## 2. What makes Tiny Titans distinct

The strongest differentiator is the combination of **tiny-creature scale + expressive evolution + traversal-driven world design + a living ecosystem**.

A leaf becomes a bridge, a root becomes a climbing route, a puddle becomes a hazard, a crack becomes a secret passage, and an ordinary garden creature can become a meaningful encounter. The player is not a human collecting pets; the player inhabits the creature.

### Product pillars (priority order)

1. **Exploration and traversal:** curiosity, route choices, landmarks, secrets and environmental puzzles.
2. **Creature identity and evolution:** form choices change how the world is experienced.
3. **Life-to-life progression:** temporary growth and goals in a life; persistent knowledge and identity across lives.
4. **Living ecosystem and collection:** species, food, resources and events make places distinct.
5. **Social cooperation:** friends create memorable moments, but solo play remains complete.
6. **Personal Habitat and bonds:** later systems provide a home and relationships with other creatures.

The first three pillars must be proven before later pillars expand.

## 3. Core gameplay loops

**Moment-to-moment:** Move → Notice opportunity/threat → Choose route/action → Execute → Receive readable feedback → Choose what next.

**One life / expedition:** Begin in the Nest as Baby Bug → explore and interact → gain Biomass and grow → choose a route or challenge → evolve when eligible → use a form's distinct verb → discover/complete an activity → life ends → recap → begin another life with knowledge retained.

**Long-term:** Explore new content → improve skill → expand Bestiary and discoveries → earn Naturalist progression → express identity → optionally bond with creatures and develop a Habitat → return for new challenges and ecosystem changes.

The loop must not become running between identical pickups. Frequent small decisions, satisfying movement and discoveries matter more than raw session length.

## 4. First Habitat and MVP

The first release is one compact, dense **First Habitat**, not a giant open world. The current greybox contains the Nest, Meadow, Rock Garden, Giant Roots and a Secret route. It is geometry and navigation groundwork, not proof of a finished game.

The MVP must prove:
- a readable safe Nest and onboarding;
- interesting ground, narrow and elevated routes with alternatives;
- a small discovery/landmark loop;
- a satisfying repeatable activity;
- Baby Bug as a viable baseline;
- distinct, useful Tank and Glider roles, if validated;
- fair, understandable life reset and recap;
- solo-completable content and positive optional multiplayer;
- reliable touch, keyboard/mouse and gamepad controls;
- performance and exploit resistance appropriate for Roblox.

Do not add a feature simply because it is easy to code. Each feature must improve a player decision, fantasy or activity and have a measurable test.

## 5. Creature identity and forms

| Form | Intended identity | Signature verb | Target use |
|---|---|---|---|
| Baby Bug | Agile baseline | Squeeze / scurry / explore | Narrow spaces, onboarding, basic traversal and access |
| Tank | Resilience / space control | Brace / withstand / push | Hazard crossing, protecting an interaction, designated heavy obstacles |
| Glider | Aerial traversal | Launch / steer / dive / glide | Meaningful gaps, elevated routes, scouting and optional aerial rewards |

These are design targets, not claims of accepted runtime behavior. Baby Bug's visual implementation exists but needs Studio validation. Tank's current Shell is visual-only. Glider's bounded Air Glide is a physics prototype, not yet a satisfying traversal role.

No mandatory form-gates: every essential route and progression path must have a solo-accessible alternative. No new forms until the current roles have proven value.

## 6. Progression architecture — one job per layer

| Layer | Lifetime | Purpose |
|---|---|---|
| Biomass / Growth | Current Life; resets on life end | Physical growth and current-life evolution requirement |
| Evolution | Selected form is per life | Choose the role for this expedition |
| Naturalist XP → Rank | Persistent | One general learning/exploration progression track; Rank is derived from XP |
| Creature Mastery | Persistent per form | Record meaningful skill and unlock horizontal expression/challenges |
| Legacy | Persistent | Bestiary, discoveries, achievements, collections, life history, cosmetics and progression records |
| Habitat & Bonds | Future persistent systems | Home, relationships, optional utility and self-expression |

### 6.1 Biomass, Growth and Evolution

Biomass remains the existing Current Life resource. Growth stage is derived from Biomass. Evolution is a deliberate form choice with its own requirement and gameplay identity—not simply a stat level-up.

Do not change current Biomass values, thresholds, cap or reward pacing as part of this vision. Any future decoupling of growth ceiling and evolution requirement requires a separately scoped design and playtest. Biomass is not player XP, crafting material or premium currency.

### 6.2 Naturalist XP and Rank

Naturalist XP is the **only proposed persistent general-purpose XP value**. Naturalist Rank is a display/threshold derived from XP; it is not another currency and is not spendable.

Potential XP sources: first-time discoveries/Bestiary entries, distinct authored challenges, meaningful traversal mastery and meaningful cooperative contribution. Claims must be server-validated, stable-ID based and idempotent. Repeating trivial actions or farming one easy trigger must not produce unlimited full XP.

Rank rewards should be knowledge, titles, cosmetics, optional challenge variants and non-power access. Never permanent damage, health, speed, Biomass multipliers or exclusive mandatory traversal power.

XP amounts, rank curve and pacing remain open playtest decisions. Do not invent numbers before observing a baseline.

### 6.3 Creature Mastery

Track mastery per validated form, based on successful use of its unique verb in authored situations and optional challenges—not time equipped, idling or button spam.

Rewards may include titles, visual variants, emotes, mastery trials or horizontal options with trade-offs. Baseline abilities must work fully without mastery grind. Mastery is deferred until form roles are proven.

### 6.4 Legacy

Legacy is the persistent record of the player's journey:
- Bestiary and species knowledge;
- landmark, secret and other discovery records;
- achievements and collection completion;
- Naturalist XP/Rank;
- per-form mastery;
- bounded life history and notable records;
- cosmetics and identity choices;
- future Habitat and bond records.

Legacy provides knowledge, identity and optional access—not permanent raw power.

## 7. Death: what resets and what persists

**Resets at life end:** Biomass, derived growth, selected form, temporary ability effects/cooldowns under the lifecycle contract, Life Goals, temporary upgrades and per-life statistics after recap capture.

**Must persist once implemented:** Naturalist XP/Rank, Bestiary, permanent discoveries, achievements, collections, mastery records, cosmetics, bounded life history, Habitat and creature bonds.

**Unresolved:** whether natural materials are carried between lives, dropped, stored or lost; voluntary extraction; companion safety on owner death/disconnect; any partial-loss mechanic. Do not implement punitive loss or paid protection without explicit approval and playtests.

Important: the current prototype does not implement persistent Legacy, Naturalist XP, Mastery or DataStore. The current code behavior is described by README/source; this section is a future product contract.

## 8. Quest and activity model

Avoid a sprawling MMO quest log. Use three clear categories:

- **Discoveries:** one-time permanent knowledge claims (landmarks, secrets, species, clues). Record in Legacy; usually grant first-time Naturalist XP.
- **Life Goals:** short goals scoped to one life (visit areas, gather varied resources, reach a landmark, complete a route). Reset on death; reward Biomass or a temporary life reward. XP only for distinct learning milestones.
- **World Challenges:** authored repeatable activities (traversal trials, hazard encounters, cooperative objectives, timed route variants). Reward completion and contribution with anti-farm rules and a solo path.

Goals should teach a gameplay verb or point toward an interesting world opportunity. Prefer contextual clues to NPC errands. Do not pay every reward type for every action: Biomass = current-life growth; Naturalist XP = persistent learning; Legacy = permanent record; cosmetics = identity.

## 9. Resource and economy rules

| Resource | Decision | Role |
|---|---|---|
| Biomass | Existing | Current-life growth/evolution only |
| Naturalist XP | Approved direction; not implemented | Persistent progression; non-spendable |
| Natural Materials | Future hypothesis | Habitat/crafting inputs only if a real source and sink are designed |
| Research Samples | Not approved as a currency | Prefer Bestiary/discovery records unless a real spend is justified |
| Rare Discoveries | Records/collection items, not currency | Knowledge, collection and optional cosmetic unlocks |
| Premium currency | Not approved for current scope | Do not add before economy and player value are proven |

Future food such as berries, mushrooms, nectar, seeds and acorns must have distinct gameplay purpose, biome identity and interaction—not just decorative models replacing identical pickups. No hunger/thirst chores without evidence they improve play.

## 10. Palworld-inspired directions — principles only

These are post-MVP hypotheses, not implementation commitments:

- **Creature bonding/companions:** meet, study, help and build trust. Avoid capture balls and disposable creature inventory as the central loop.
- **Personal Habitat:** a modest personal Nest with curated modular decoration and a few meaningful stations; not unrestricted base construction.
- **Utility creatures:** optional helpers may reveal resources/clues, assist a small garden or interact with environmental objects. They must not automate the core loop or become mandatory.
- **Alpha/territorial creatures:** readable ecosystem encounters with multiple responses—avoid, distract, escape, observe, use the environment; combat only where deliberately designed.
- **World events:** short ecosystem changes or migrations that create shared moments without punishing players who miss them.

Explicitly deferred: factories/production chains, breeding/genetics, player trading/marketplace, creature capture as the core loop, guild infrastructure, large MMO zones, mandatory companion loadouts, base raids and paid power.

## 11. Multiplayer, accessibility and fairness

- Solo is a first-class path, not a fallback. Every core unlock and MVP activity has a solo route.
- Co-op may add role synergy and shared stories, never mandatory waiting.
- No forced PvP, spawn camping, griefable persistent assets or shared-resource theft.
- Shared rewards require server-authoritative proximity/contribution rules.
- Core actions must have clear touch, keyboard/mouse and gamepad paths.
- New players need safe onboarding and recovery; veterans must not farm or block them.

## 12. Monetization

Cosmetic-first and transparent: creature skins/palettes/markings, trails, emotes, animations, Habitat decoration and optional supporter products. Seasonal cosmetics only if content cadence is sustainable.

Never sell permanent power, stronger companions, faster Naturalist XP, protected death, exclusive mandatory routes or relief from intentionally frustrating design. The game must remain enjoyable without spending. Avoid misleading scarcity, unclear odds and manipulative pressure.

## 13. Evidence gates

- **Exploration:** new players find points of interest, understand routes and want a second pass.
- **Forms:** players can explain why they choose each form; each has a satisfying use case and meaningful weakness.
- **RPG:** players understand reset/persistence; Rank creates goals without power creep.
- **Quests:** players enjoy the activity rather than tolerate it for rewards.
- **Companions/Habitat:** attachment and expression deepen return intent without replacing the adventure.
- **Retention:** D1/D7/D30 and qualitative evidence indicate real player value; session time is never optimized in isolation.

No feature is accepted because it is implemented or CI passes. Studio, device and external-player validation are separate gates.

## 14. Authority and relationship to other documents

- This is the product north star and long-term direction.
- Gameplay Blueprint & MVP Contract defines the actual first playable product and MVP gates.
- Tiny Titans Master Roadmap is the sole execution order.
- Evolution Sandbox Architecture records technical boundaries and audited implementation facts; Progression & Legacy Architecture Addendum defines the future progression contract.
- Combat Progression & Endgame Design remains a deferred reference.

Approval of this vision does not approve all long-term systems for implementation. In particular, TT-P3-02 remains a narrow exploration-loop task using existing systems only.
