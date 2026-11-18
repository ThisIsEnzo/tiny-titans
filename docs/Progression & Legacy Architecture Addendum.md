# Tiny Titans — Progression, Inventory & Adventure Records Addendum v3.0

**Date:** 2026-11-19  
**Status:** Design boundaries only; no new persistence or inventory behavior is implied.  
**Product authority:** Product Vision v4.0, GDD v4.0 and Zelda Mechanics Adaptation Matrix.  
**Execution:** Master Roadmap.

## 1. Purpose and authority

This addendum replaces the former creature/Naturalist progression framing with boundaries for an adventure RPG. README/source describe implementation. Product Vision defines the product north star; GDD defines the experience; Gameplay Blueprint defines the first vertical slice; Master Roadmap controls execution.

The current Biomass, GrowthService, life reset, discovery and evolution systems are historical prototype implementation. They must be audited against this model before reuse. Do not assume they are the final progression system.

## 2. State domains

| Domain | Lifetime | Design intent |
|---|---|---|
| Character identity | Account | Standard Roblox avatar and cosmetic presentation |
| Adventure progression | Account or campaign, decision pending | Story flags, region access, dungeon completion |
| Inventory/equipment | Account or campaign, decision pending | Owned tools, weapons, armor, consumables and loadouts |
| Session/party state | Party/session | Shared puzzle, dungeon, boss and activity state |
| Personal records | Account | Discoveries, achievements, collections, optional completion |
| Temporary activity state | Activity/life | Current encounter, temporary buffs, checkpoint and challenge state |
| Economy | Deferred | Only introduce currencies with a proven source/sink and clear purpose |

Introduce services only when an approved vertical-slice feature requires them.

## 3. Invariants

1. Standard Roblox avatar identity is not a class or progression choice.
2. Baby Bug, Tank and Glider forms are retired prototypes.
3. Tools and equipment expand options; they must not become mandatory paid power.
4. Every essential progression step has a solo-compatible path.
5. Co-op rewards and shared progress are server-authoritative and idempotent.
6. Personal inventory/records cannot be stolen or overwritten by another player.
7. Shared party state and personal account state are explicitly separated.
8. No currency without a clear source, sink, cap/inflation plan and reason it cannot be represented as a record.
9. No permanent raw-stat inflation that trivializes content or destabilizes co-op.
10. No DataStore implementation before schema, migration, retry, failure UX and recovery are designed.

## 4. Progression layers

Potential layers, subject to playtest:
- **Adventure progression:** story chapters, region access, dungeon completion and world-state changes.
- **Capability progression:** tools, weapons, traversal verbs and equipment options.
- **Equipment progression:** meaningful upgrades and trade-offs, not endless stat inflation.
- **Knowledge/records:** discoveries, Bestiary or world journal, achievements and collections.
- **Mastery:** optional skill challenges and records for combat, traversal or dungeons.
- **Cosmetic identity:** avatar-compatible appearance, effects, emotes and titles.

Do not implement every layer at once. The first vertical slice should prove a small, coherent progression path.

## 5. Shared versus personal ownership

The following decisions must be made before persistent multiplayer progression:
- Which story flags belong to the party, the session or each player?
- Does a guest receive personal credit for a shared dungeon/boss completion?
- What happens if a player leaves during a dungeon or boss?
- Can a late joiner enter an active dungeon, and from which checkpoint?
- Are tools/items personal, shared, loaned or session-scoped?
- Can players trade? Trading is deferred and not assumed.
- What happens to progress when a party dissolves?
- How are solo saves and co-op campaign saves reconciled?

Default safety principle: no player should lose permanent progress because another player disconnects, griefs or leaves.

## 6. Death and recovery

Before implementation, define:
- respawn location and timing;
- encounter/dungeon checkpoint behavior;
- whether consumables are consumed on use, death or activity completion;
- whether equipment can ever be lost (default: no punitive permanent loss);
- rescue/revive behavior in co-op and solo fallback;
- party behavior when a member dies or disconnects;
- rejoin and recovery behavior.

No paid revives, paid death protection or loss designed to sell relief. The old per-life Biomass reset model is not automatically carried forward.

## 7. Reward pipeline

Future server flow: validate an event and eligibility → derive stable reward identity → check idempotency → grant the configured item/record/progression → update shared and personal state according to explicit ownership → send presentation feedback.

Client never supplies reward amount, item ownership, boss outcome, dungeon completion or progression flags.

## 8. Replayability records

Records may support:
- optional region completion;
- hidden secrets and collectibles;
- boss rematches and challenge modifiers;
- dungeon challenge results;
- combat/traversal mastery;
- co-op activity participation;
- achievement and cosmetic unlocks.

Records should encourage exploration and mastery, not turn the game into an exhaustive checklist. No daily chores or punitive streaks.

## 9. Deferred decisions

Not approved yet: exact currency/economy, weapon durability, crafting, item trading, inventory capacity, consumable loss, New Game Plus, account-versus-party campaign saves, permanent stats, DataStore schema, guilds and live-ops reward schedules. Each needs a concrete use case and an explicit design decision before implementation.
