# Tiny Titans — Product Vision v2.1
## Personalized Creature Exploration RPG

**Owner approval:** 2026-11-15  
**Status:** Approved direction; implementation remains gated by the Master Roadmap.  
**Platform:** Roblox. **Ambition:** a high-quality, replayable experience with a credible path toward Top 1000, not a guarantee.

## 1. Executive vision

Tiny Titans is a **co-op-friendly Creature Exploration RPG** set in a miniature living ecosystem. Each player inhabits and personalizes one small creature — their own Tiny Titan — and explores a world that feels enormous.

Players discover routes, landmarks and species; gather and learn; develop their creature's identity; complete authored challenges; and gradually build a collection and a personal place in the ecosystem. The world can contain danger and tension, but combat is not a required foundation. Threats should be interesting through observation, avoidance, hiding, distraction, escape and environmental problem-solving.

**Product promise:** Explore a world that feels enormous, make a creature that feels like yours, discover life worth remembering, and build a growing connection to the ecosystem.

This is not a conventional MMORPG, combat arena, generic simulator or class-selection lobby. We want satisfying long-term RPG goals without mandatory parties, endless stat inflation, forced PvP or grind before the first fun moment.

## 2. Product pillars

1. **Exploration and traversal:** curiosity, route choices, landmarks, secrets and environmental puzzles.
2. **Personal creature identity:** one recognizable Tiny Titan per player, with visual customization and optional biological adaptations.
3. **Discovery and collection:** Bestiary, species knowledge, landmarks, secrets, achievements and themed collections.
4. **Life-to-life progression:** temporary growth and goals in a life; persistent knowledge, identity and records across lives.
5. **Living ecosystem:** species, resource opportunities, environmental changes and readable creature behavior.
6. **Social cooperation:** shared discoveries, helping, visiting and cooperative challenges; solo remains complete.
7. **Personal Habitat and bonds:** later systems that create a home, relationships and reasons to return.

The first four pillars must be proven before later pillars expand.

## 3. One player, one personal Tiny Titan

The player does **not** choose Baby Bug, Tank or Glider as separate playable forms/classes. The player owns one persistent character identity: a small, expressive, customizable creature.

This does not mean simply scaling down a standard Roblox R15 avatar and treating it as the final art direction. The target is a purpose-built Tiny Titan visual identity. Exact rig, avatar-compatibility and appearance pipeline are technical decisions to validate separately.

Customization may eventually include body silhouette, palettes, markings, eyes, facial expression, shells, wings, antennae, accessories, trails, emotes, animations and effects. Do not promise unrestricted mix-and-match before compatibility, clipping, readability and mobile performance are proven.

### Adaptations replace form selection

Baby Bug / Tank / Glider are retained only as inspirations for possible adaptations, not separate characters or mandatory classes:
- **Agility / Squeeze:** nimble movement or access to tight routes.
- **Brace / Shell:** bounded resistance to environmental forces, holding a position or protecting an interaction.
- **Glide / Wings:** controlled aerial movement and optional elevated routes.

These are examples, not an approved roster. Each adaptation needs a real world problem, at least two authored use cases, meaningful limits/trade-offs, readable counterplay and cross-platform controls. Do not implement one merely to preserve an old form. Number of slots, unlocks and swap timing remain open. Do not assume all adaptations can be equipped together.

**Identity** answers “what does my Tiny Titan look and feel like?” **Adaptations** answer “how can it interact with this environment?” **Mastery**, if later justified, records learning; it must not gate basic functionality.

## 4. Core gameplay loops

**Moment-to-moment:** Move → Notice an opportunity, clue or risk → Choose a route/action → Execute → Receive feedback → Decide what to explore next.

**One expedition / life:**
1. Begin in a safe Nest with a clear nearby point of interest.
2. Explore a compact habitat, noticing landmarks, resource opportunities and signs of life.
3. Choose routes and interact with the world; growth may develop during the life.
4. Observe or overcome a challenge or creature behavior through movement, hiding, distraction, timing or cooperation.
5. Complete a discovery or authored activity and receive clear feedback.
6. End the life only through fair, understandable failure or a separately validated voluntary return.
7. Review a concise recap; temporary state resets while eligible knowledge and identity persist once Legacy exists.
8. Return with a new goal, collection milestone, route or social activity.

The first meaningful interaction should happen quickly. Session length and reward pacing are playtest questions.

## 5. World and activities

The first release is one compact, dense **First Habitat**, not a giant open world. It needs a safe Nest, distinct micro-areas, memorable landmarks, connected primary/alternative routes, narrow/elevated/ground paths, meaningful discoveries and one repeatable route or exploration challenge. Every essential route must be completable solo without a specific adaptation.

MVP does not require combat, a health/damage framework, boss or enemy roster. Environmental danger and creature encounters are optional future tools, not mandatory checkboxes. If introduced, they should offer readable non-combat responses. Do not add danger solely to justify combat.

Later activity categories:
- **Discoveries:** one-time permanent knowledge claims.
- **Life Goals:** short goals scoped to one life.
- **World Challenges:** authored repeatable activities with solo completion and anti-farm rules.

Do not build a generic MMO quest framework before actual activities prove the need.

## 6. Progression

| Layer | Lifetime | Purpose |
|---|---|---|
| Biomass / Growth | Current Life | Temporary growth; not player XP or crafting currency |
| Naturalist XP → Rank | Persistent, future | One general learning/exploration progression track; Rank derived from XP |
| Legacy | Persistent, future | Bestiary, discoveries, achievements, collections, cosmetics, bounded life history |
| Adaptations | Future, if justified | Optional world-interaction capabilities; no mandatory power gates |
| Mastery | Deferred hypothesis | Meaningful skill only after activities/adaptations prove useful |
| Habitat & Bonds | Post-MVP hypothesis | Home, relationships, optional utility and self-expression |

Biomass remains a Current Life resource. Growth stage is derived from it. Do not turn Biomass into player XP, crafting material or premium currency. Temporary size changes must not make cosmetics, camera or collision unreadable.

Naturalist XP is the only proposed persistent general XP value. Rank is derived, not another currency. Sources may include first-time discoveries, Bestiary study, authored challenges and meaningful co-op contribution. Repeated trivial actions must not generate unlimited XP. Rewards favor knowledge, titles, cosmetics, optional challenge variants and non-power access — never permanent damage, health, speed or resource multipliers.

Legacy records the player's Bestiary, discoveries, achievements, collections, Naturalist XP/Rank, cosmetic identity and bounded life history. It provides knowledge, identity and optional access, not permanent raw power.

## 7. Death, danger and fairness

Danger does not imply combat. Tension may come from territorial creatures, patrols, environmental forces, weather, unstable routes and time-limited opportunities. Responses include observation, avoidance, hiding, distraction, escape or environmental problem-solving.

Death is a possible consequence, not the core activity or a monetization lever. No paid revives, paid death protection or punitive loss. The boundary between death, failed expedition and voluntary return remains an explicit design decision.

At life end, temporary Current Life state resets according to the lifecycle contract; future Legacy persists. Inventory/material carry-over, drops and partial-loss mechanics remain unresolved. Persistent Legacy, Naturalist XP, Mastery and DataStore are not implemented; README/source remain implementation truth.

## 8. Retention and player value

Build return intent across horizons:
- **Minutes:** visible nearby discoveries, satisfying movement and a clear next action.
- **One session:** a route, challenge, landmark or collection progress.
- **Several sessions:** Bestiary, Naturalist Rank milestones, cosmetic expression and optional adaptations.
- **Long term:** distinctive personal Tiny Titan, rare records, Habitat, bonds, social visits and new ecosystem chapters.

Do not optimize session time in isolation. Measure voluntary return, goal comprehension, activity enjoyment and respect for player time. Avoid daily chores, punitive streaks, artificial waiting and repetitive farming.

## 9. Monetization

**Cosmetic-first, transparent and non-coercive.** Long-term opportunities: creature palettes/markings/shells/wings/eyes/accessories; animations, emotes, trails and visual effects; Habitat decoration; optional supporter products; sustainable seasonal cosmetic collections; later companion appearance/presentation, never stronger companion power.

The character must be worth personalizing before a large cosmetic catalogue is built. Monetization follows demonstrated player value; it must not create the value gap.

Never sell permanent power, stronger adaptations, faster Naturalist XP, exclusive mandatory routes, protected death or relief from intentionally frustrating design. The game must remain enjoyable without spending. Avoid misleading scarcity, unclear odds and manipulative pressure.

## 10. Multiplayer and fairness

Solo is first-class; co-op adds stories and optional synergy, never mandatory waiting. No forced PvP, spawn camping, griefable persistent assets or shared-resource theft. Shared rewards need server-authoritative proximity/contribution rules. Core actions need touch, keyboard/mouse and gamepad support.

## 11. Evidence gates

- **Exploration:** players find points of interest and want a second pass.
- **Identity:** players recognize, care about and want to personalize their Tiny Titan.
- **Adaptations:** each tested adaptation solves a real problem without mandatory gates or power creep.
- **RPG/Collection:** players understand reset/persistence and enjoy discoveries without checklist fatigue.
- **Habitat/Bonds:** attachment deepens return intent without replacing the adventure.
- **Retention:** D1/D7/D30 and qualitative evidence indicate real player value; session time is never optimized alone.

Implementation or green CI is not proof of fun. Studio, device and external-player validation are separate gates.

## 12. Authority

This is the product north star. Gameplay Blueprint defines the first playable product; Master Roadmap is the sole execution order; Player Identity & Adaptation Architecture defines future technical boundaries. The former Evolution Sandbox Architecture and Combat Progression & Endgame design are superseded. Current prototype facts remain in README/source and Git history.

TT-P3-02 remains a narrow exploration-loop task using existing systems only.
