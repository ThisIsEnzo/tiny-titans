# Tiny Titans — Game Design Document v2.2
## The Living World Adventure

**Date:** 2026-11-15  
**Status:** Detailed design proposal based on the owner's approved hybrid direction. One personal Tiny Titan and the hybrid product direction are approved; the specific world mystery and first-region story are proposals pending review.  
**Genre:** Co-op-friendly Creature Exploration RPG  
**Platform:** Roblox

## 1. High concept

Tiny Titans is an exploration-first adventure RPG in which each player inhabits one personal, expressive Tiny Titan and explores an oversized living ecosystem.

The player is not grinding to become the strongest creature. They learn how the world works, discover species and hidden places, help local ecosystems recover, and build a lasting identity and history in that world.

**Player fantasy:** “I am a small creature in a huge world. I notice things others miss. My discoveries matter, the world responds to what I do, and over time I become someone who truly belongs here.”

**Unified long-term goal:** Explore, understand and gradually reconnect the world's ecosystems while creating a personal legacy within them.

This is one connected game, not five unrelated modes:
- Exploration is the primary activity.
- Discovery and visible ecological change provide purpose and payoff.
- The personal Tiny Titan is the emotional anchor.
- Bestiary, Discoveries and Legacy preserve what the player learns.
- Nest/Habitat is the place that makes the world feel personal.
- Co-op lets players share discoveries without making solo play incomplete.

## 2. Product pillars and priority

1. **Explore:** traverse dense, readable environments; choose routes; notice landmarks, clues, unusual behavior and environmental opportunities.
2. **Discover and reconnect:** observe, form a hypothesis, test it in the world, learn something and sometimes cause a visible local change.
3. **Personal Tiny Titan:** one stable creature identity across lives and sessions. Appearance and expression are separate from gameplay capability.
4. **Knowledge and Legacy:** Bestiary, Discoveries, achievements and bounded adventure history preserve meaningful learning once persistence exists.
5. **Nest and social play:** Nest is the safe starting point in the first slice. Customizable Habitat, creature bonds and visitors are later features. Co-op supports helping and shared observation; no mandatory party gates.

Exploration is what players do; discoveries explain why it matters; the creature gives emotional ownership; Legacy remembers it; Habitat and co-op deepen attachment later.

## 3. World fiction and narrative frame

### Recommended premise — not yet locked canon
The world once functioned as a network of connected habitats. Plants, small creatures, water, shelter and natural routes formed relationships that allowed each region to thrive. Something has disrupted parts of that balance. The effects are local and understandable: a route is blocked, a species has stopped visiting, a plant no longer blooms, or a natural resource no longer reaches the place that depends on it.

The player gradually discovers that these events are connected. There need not be an obvious villain or a world-ending catastrophe. The mystery emerges through environmental storytelling, species behavior, natural landmarks and short encounters.

### Narrative rules
- Curiosity leads the story; exposition does not.
- Each region has its own local ecological mystery and identity.
- The player helps by understanding and interacting with the environment, not by defeating a boss.
- Do not make the player a prophesied savior. Small actions matter because the world is interconnected.
- Avoid long mandatory dialogue, lore dumps and quest-marker dependency.
- The exact cause of the imbalance, any ancient civilization and any antagonist remain undecided until justified.

## 4. Player goals at three scales

**Immediate — the next interesting thing.** Notice a nearby point of interest, choose whether to approach, inspect, follow, interact, avoid or take another route. The game should not require staring at a quest list.

**Regional — understand and reconnect a habitat.** Each region contains a safe arrival point, recognizable landmarks and routes, species/phenomena, one main ecological story, optional secrets, a repeatable activity and a visible regional outcome. A region is meaningfully explored when the player understands its defining relationships and completes its main discovery/restoration arc — not merely when a checklist reaches 100%.

**World — uncover the network.** Across regions, discoveries reveal how ecosystems depend on one another. Regional outcomes reveal new routes, species relationships and chapters. Expand one dense region at a time.

Do not lock access behind raw XP levels or paid items. Use meaningful discovery milestones and authored progression, with solo alternatives.

## 5. Core gameplay loops

### Moment-to-moment (seconds)
**Move → Notice → Interpret → Choose → Act → Read feedback.**

Examples: notice an unusual sound or movement; see a trail or a plant behaving differently; choose a direct route, safer detour or elevated path; observe a creature; interact with a small environmental object; receive clear animation, sound, visual or journal feedback.

Movement, camera and environmental readability are core gameplay, not just transportation between quest markers.

### Signature discovery loop
**Clue → Observation → Hypothesis → Test/Interaction → World Response → Record.**

A discovery should answer at least one question: What lives here? How does it behave? What does it depend on? Why has something changed? What can I do that makes this place healthier or more accessible?

Not every discovery needs a puzzle. Some are observation-only; others require a short route or interaction challenge.

### Expedition loop (one session)
1. Start at Nest or rejoin the current habitat.
2. Choose a self-directed goal from visible clues, a journal hint or a known regional objective.
3. Explore one or more micro-areas and choose routes.
4. Make discoveries, complete an ecological interaction or attempt a repeatable challenge.
5. See immediate local feedback and receive a concise record/reward.
6. Continue exploring, join another player or return to Nest when desired.
7. Review progress and choose a new goal.

Returning to Nest is useful but never forced after every small activity. No artificial energy, hunger or timer should force the player home.

### Long-term loop
**Explore regions → make discoveries → reconnect local ecosystems → earn knowledge/records → reveal new regional opportunities → build a personal legacy.**

Naturalist XP/Rank and persistent Legacy belong to a later implementation phase, after the first exploration loop proves enjoyable. Rank is derived, not a currency or power level.

### Co-op loop
**Notice together → split or coordinate observations → help with a shared environmental task → confirm the result together → record personal contribution.**

Co-op can make tasks faster or more expressive, but every essential objective must have a solo-completable route. Avoid fixed classes and forced waiting.

## 6. What ecosystem restoration means

Restoration must be concrete and observable, not only a progress bar.

Every main ecological chain needs:
- **Before:** a readable problem (absence, blockage, unusual behavior, unhealthy plant, inaccessible route).
- **Investigation:** clues that help the player understand what is happening.
- **Action:** a small, legible interaction or environmental solution.
- **After:** visible or audible response (species returns, plant blooms, water flows, route opens, behavior changes).
- **Knowledge:** a Bestiary/Discovery record explains what was learned.
- **Continuation:** the change reveals a new clue, route or optional activity.

Use three persistence scopes:
1. Immediate feedback visible to everyone in the current server session.
2. Player discovery record stored for that player once Legacy/persistence exists.
3. Shared permanent world state only if a later live-world architecture explicitly supports it.

For the first slice, prefer simple server-authoritative session state and obvious feedback. Do not imply permanent cross-server ecosystem simulation already exists.

## 7. First Habitat — proposed MVP vertical slice

The existing greybox has Nest, Meadow, Rock Garden, Giant Roots and Secret/Dewdrop Glade. It is a layout, not yet the complete gameplay loop. Physical movement, camera, collision and mobile readability still require Roblox Studio validation.

### Proposed ecological story: “The Quiet Glade” (proposal, not locked lore)
A small pollinating species no longer visits a flowering plant near the Meadow/Secret route. The player notices the missing activity, follows subtle signs toward the roots and discovers that a small natural water channel is blocked by fallen plant matter.

1. **Notice:** a distinctive flower is closed/dry and the expected pollinator is absent.
2. **Observe:** tracks, droplets or sound lead toward the root corridor.
3. **Understand:** the player discovers a simple blockage in a shallow channel.
4. **Act:** one clear server-validated interaction clears or shifts the obstruction; no physics-heavy puzzle.
5. **Response:** water reaches the glade, the flower opens and the pollinator returns with readable VFX/audio.
6. **Record:** the player receives a species observation and a discovery explaining the relationship.
7. **Next hook:** a new behavior or clue becomes observable nearby.

Keep the chain to a few minutes and two or three interaction states, not a generic quest framework.

### MVP minimum content
- One connected habitat using all five existing greybox areas intentionally.
- Three memorable points of interest discoverable from different routes.
- At least two discovery types: landmark/place and species/behavior observation.
- One complete ecological story chain with visible before/after state.
- One optional secret rewarding observation rather than a class ability.
- One compact repeatable route/observation challenge with a small number of authored variants.
- A small readable cast: one featured pollinator plus one or two supporting ambient species/behaviors.
- First-session onboarding that teaches movement, observation and interaction without a long tutorial.
- Immediate discovery feedback; lightweight journal/recap may be session-only in the first prototype.
- Solo completion for every essential interaction; co-op can support shared contribution.
- Existing Biomass pickups may remain incidental, but cannot dominate the route or become the main reason to explore.

### What the MVP proves
A player can understand the fantasy quickly, enjoy moving through the habitat, notice and investigate something without a waypoint, complete a meaningful ecological interaction, see the world respond, want another discovery/replay, and feel their creature belongs in the world.

## 8. Replayability without chores

Replayability comes from authored variation and player knowledge, not mandatory daily tasks.

**MVP variation:** multiple route choices; a repeatable route challenge with a few controlled variants; ambient species behavior with limited authored states; optional secrets rewarding landmark knowledge; co-op moments that differ naturally by group behavior.

**Later variation:** time/weather conditions, non-punitive seasonal events, more species relationships and regional story chains, new regions with distinct verbs and traversal.

Do not begin with procedural generation. First author a small number of high-quality situations and measure whether players want to repeat them.

## 9. Progression and rewards

| System | Role | MVP status |
|---|---|---|
| Biomass / Growth | Temporary current-life growth | Existing prototype; incidental, not core goal |
| Naturalist XP / Rank | Persistent general learning progression | Phase 2 |
| Bestiary | Knowledge about species and behavior | Lightweight/session record first; persistence later |
| Discoveries | Records of places, events and ecological facts | Session feedback first; persistent claims in Phase 2 |
| Legacy | Persistent history, achievements and collections | Phase 2 |
| Cosmetics | Personal expression of one Tiny Titan | Small visual proof desirable; full creator later |
| Nest/Habitat | Safe start and later personal home | Safe Nest in MVP; customizable Habitat post-MVP |
| Adaptations | Optional world verbs | Not MVP; only after proven use cases |
| Bonds/companions | Optional relationships | Post-MVP |

Reward information, visible change, new optional opportunities, recognition and self-expression. Do not pay XP for trivial spam. No permanent raw power, mandatory grind, paid power or paid death protection.

## 10. MVP scope

### Must-have for the first playable vertical slice
- First Habitat route validated in Studio.
- Clear onboarding and a discoverable first point of interest.
- Basic inspect/observe interaction with server validation where state/rewards matter.
- Two discovery categories.
- One ecological chain with visible response.
- Clear feedback/journal.
- One repeatable activity with controlled variation and solo completion.
- Responsive feedback: animation, sound, VFX or environment state.
- Basic multiplayer safety and server-authoritative discovery claims.
- Input plan for touch, keyboard/mouse and gamepad; actual device validation before release.

### Should-have if inexpensive and validated
- A few appearance presets/palette choices.
- Ambient creature behaviors observable without a prompt.
- Optional co-op contribution feedback.
- A second short side discovery.
- Nest presentation improvement.

### Explicitly out of scope
- Separate Baby Bug/Tank/Glider forms or class selection.
- Agility/Brace/Glide adaptations or a generic loadout system.
- Combat, health/damage, bosses, PvP or enemy progression.
- Full Naturalist XP/Rank and DataStore before the discovery loop is proven.
- Generic quest framework, long quest chains or large dialogue systems.
- Full character creator, breeding/genetics or companion collection.
- Customizable player-owned Habitat, crafting trees, trading/marketplace or multiple large biomes.
- Hunger/thirst chores, energy timers, daily streaks, forced waiting or punitive loss.
- Premium currency, paid revives, paid power or exclusive mandatory routes.

## 11. UX principles
- World-first guidance: landmarks and clues before quest markers.
- Contextual interaction prompts only when relevant.
- Compact discovery notification and lightweight journal with known/unknown entries.
- Clear Nest/return affordance without forcing return.
- No minimap requirement if landmarks are readable.
- Avoid large quest HUDs, multiple currencies, persistent popups and reward spam.

The player should always understand: Where am I? What interesting thing can I investigate next? What changed because of what I did?

## 12. Playtest success criteria

The following are initial hypotheses, not guarantees. Establish a baseline and adjust:
- Most first-time players identify a nearby point of interest within roughly 60–90 seconds.
- First meaningful discovery occurs within roughly three minutes.
- Players can explain the ecological problem, their action and the result without a long tutorial.
- Players notice the visible environmental response.
- A meaningful share voluntarily chooses a second discovery or repeatable activity.
- Some players try another route/variant for its own interest.
- Co-op creates positive help/shared discovery without blocking solo players.
- Players can describe what makes their Tiny Titan feel like theirs.

Track first-session funnel, time to first discovery, chain completion, voluntary second activity, route selection, repeat attempts, interaction failures, device performance and qualitative enjoyment. Later track D1/D7/D30. Do not optimize session duration alone.

Test first-time and returning players, solo and mixed co-op groups. Observe behavior; do not rely only on surveys. Studio physics/camera/device validation is separate from offline validators and automated tests.

## 13. Future region contract

Every new region must add a distinct ecological identity and visual silhouette, at least one new player decision/verb, new species behavior or environmental relationship, a main local mystery/restoration chain, optional discoveries, a repeatable activity, a visible outcome, and a solo-completable core route. A region that only adds acreage, collectibles or stat requirements does not qualify.

## 14. Monetization
Cosmetic-first and only after players value their creature. Candidate products: palettes, markings, shells, eyes, accessories, animations, emotes, trails, visual effects and later Habitat decoration. Optional supporter products are acceptable if transparent.

Never sell power, mandatory route access, faster Naturalist XP, stronger adaptations, paid revives, death protection or relief from intentionally frustrating design. The core adventure must be complete and enjoyable without spending.

## 15. Open decisions
- Final lore and cause of ecological disruption.
- Exact first ecological story and species art direction.
- Final Tiny Titan rig, collision and relationship to Roblox avatar appearance.
- Whether MVP discovery records remain session-only or need minimal persistence before public testing.
- Death/failed expedition/voluntary return contract.
- Whether the first slice needs a full ambient creature system or can begin with authored observation states.
- Numeric playtest targets after baseline evidence.

## 16. Authority
Product Vision defines the north star. This GDD defines the detailed experience contract. Gameplay Blueprint defines the first playable slice and acceptance boundary. Master Roadmap defines execution order. Identity/Progression docs define future technical boundaries.

No runtime implementation is implied. Every implementation task needs a narrow branch/PR, server-authority rules, acceptance criteria and Studio checklist where runtime behavior is involved.
