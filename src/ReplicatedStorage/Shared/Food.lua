--!strict
-- Pure food-collection rules. No Roblox services, so they are unit-testable outside Studio.
-- The server runs these in a single thread without yielding between the choice of a
-- winner and the consumption, which is what makes collection atomic.

local Food = {}

export type Item = { active: boolean }

-- Index of the closest distance within range (ties go to the lowest index), or nil.
-- NaN distances are ignored.
function Food.PickClosest(distances: { number }, range: number): number?
    local best: number? = nil
    local bestDistance = range
    for index, distance in distances do
        if distance == distance and distance <= range and (best == nil or distance < bestDistance) then
            best = index
            bestDistance = distance
        end
    end
    return best
end

-- Consumes an active item. Returns true only for the call that actually consumed it.
function Food.TryConsume(item: Item): boolean
    if not item.active then
        return false
    end
    item.active = false
    return true
end

-- Makes a consumed item available again. Returns true only if it was inactive.
function Food.Respawn(item: Item): boolean
    if item.active then
        return false
    end
    item.active = true
    return true
end

return table.freeze(Food)
