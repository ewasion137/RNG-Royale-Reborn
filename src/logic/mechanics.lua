local Mechanics = {}

local rarity_power = {
    common = 1, uncommon = 2, rare = 3, epic = 4, 
    legendary = 5, mythic = 6, unbelievable = 7
}

function Mechanics.roll_item(items_flat, luck_level, potion_multiplier, prestige_bonus)
    -- Итоговая удача как в C#
    local total_luck = (1 + (luck_level * 0.01)) * potion_multiplier * prestige_bonus
    
    local weighted_items = {}
    local total_weight = 0

    for _, item in ipairs(items_flat) do
        -- Твоя формула: Chance * Luck ^ (Rarity_Index + 1)
        local power = rarity_power[item.rarity] or 1
        local weight = item.chance * math.pow(total_luck, power)
        
        table.insert(weighted_items, {item = item, weight = weight})
        total_weight = total_weight + weight
    end

    local rnd = math.random() * total_weight
    for _, node in ipairs(weighted_items) do
        rnd = rnd - node.weight
        if rnd <= 0 then return node.item end
    end
    return weighted_items[1].item
end

function Mechanics.roll_mutation(mutations, is_potion_active)
    local pool = {}
    local total_weight = 0
    
    for _, m in ipairs(mutations) do
        -- Если зелье мутации активно, убираем "None"
        if not (is_potion_active and m.id == "none") then
            table.insert(pool, m)
            total_weight = total_weight + m.chance
        end
    end

    local rnd = math.random() * total_weight
    for _, m in ipairs(pool) do
        rnd = rnd - m.chance
        if rnd <= 0 then return m end
    end
    return pool[1]
end

return Mechanics