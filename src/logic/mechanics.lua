local Constants = require("src.logic.constants")
local Upgrades = require("src.logic.upgrades")
local Player = require("src.logic.player")
local Potions = require("src.logic.potions")

local Mechanics = {}

local rarity_power = {
    common = 1,
    uncommon = 2,
    rare = 3,
    epic = 4,
    legendary = 5,
    mythic = 6,
    unbelievable = 7,
}

local luck_filter_thresholds = {
    { level = 125, rarity = "mythic" },
    { level = 100, rarity = "legendary" },
    { level = 75, rarity = "epic" },
    { level = 50, rarity = "rare" },
    { level = 25, rarity = "uncommon" },
    { level = 10, rarity = "common" },
}

local function build_inventory_key(material_name, mutation_name)
    if mutation_name == "Ничего" then
        return material_name
    end
    return material_name .. " (" .. mutation_name .. ")"
end

local function parse_inventory_key(key)
    local name, mutation = key:match("^(.+) %((.+)%)$")
    if name then
        return name, mutation
    end
    return key, "Ничего"
end

function Mechanics.parse_inventory_key(key)
    return parse_inventory_key(key)
end

function Mechanics.filter_materials(items_flat, luck_level)
    local excluded = {}
    for _, rule in ipairs(luck_filter_thresholds) do
        if luck_level >= rule.level then
            excluded[rule.rarity] = true
        end
    end

    local filtered = {}
    for _, item in ipairs(items_flat) do
        if not excluded[item.rarity] then
            table.insert(filtered, item)
        end
    end
    return filtered
end

function Mechanics.get_luck_multiplier(player)
    local luck_level = player.upgrades.Luck.level
    local luck_effect = Player.get_effect(player, Potions.EFFECT.LuckBoost)
    local potion_multiplier = luck_effect and luck_effect.multiplier or 1.0
    local prestige_bonus = 1.0 + (player.prestige_level * Constants.PRESTIGE_LUCK_BONUS)
    return (1 + (luck_level * 0.01)) * potion_multiplier * prestige_bonus
end

function Mechanics.roll_material(items_flat, player)
    local luck_level = player.upgrades.Luck.level
    local available = Mechanics.filter_materials(items_flat, luck_level)
    if #available == 0 then
        available = items_flat
    end

    local total_luck = Mechanics.get_luck_multiplier(player)
    local weighted = {}
    local total_weight = 0

    for _, item in ipairs(available) do
        local power = rarity_power[item.rarity] or 1
        local weight = item.chance * math.pow(total_luck, power)
        table.insert(weighted, { item = item, weight = weight })
        total_weight = total_weight + weight
    end

    if total_weight <= 0 then
        return available[1]
    end

    local rnd = math.random() * total_weight
    for _, node in ipairs(weighted) do
        rnd = rnd - node.weight
        if rnd <= 0 then
            return node.item
        end
    end
    return weighted[#weighted].item
end

function Mechanics.roll_mutation(mutations, player)
    local mutation_boost = Player.get_effect(player, Potions.EFFECT.MutationBoost)
    local pool = {}

    for _, mutation in ipairs(mutations) do
        if not (mutation_boost and mutation.name == "Ничего") then
            table.insert(pool, mutation)
        end
    end

    local total_weight = 0
    for _, mutation in ipairs(pool) do
        total_weight = total_weight + mutation.chance
    end

    if total_weight <= 0 then
        for _, mutation in ipairs(mutations) do
            if mutation.name == "Ничего" then
                return mutation
            end
        end
        return mutations[1]
    end

    local rnd = math.random() * total_weight
    for _, mutation in ipairs(pool) do
        rnd = rnd - mutation.chance
        if rnd <= 0 then
            return mutation
        end
    end
    return pool[#pool]
end

function Mechanics.calculate_item_value(material, mutation, player, include_money_potion)
    local sell_boost = 1.0 + (player.upgrades.SellValue.level * 0.1)
    local prestige_sell = 1.0 + (player.prestige_level * Constants.PRESTIGE_SELL_VALUE_BONUS)
    local money_multiplier = 1.0

    if include_money_potion then
        local money_effect = Player.get_effect(player, Potions.EFFECT.MoneyBoost)
        if money_effect then
            money_multiplier = money_effect.multiplier
        end
    end

    local numerator = material.value
        * math.floor(mutation.multiplier * 100)
        * math.floor(sell_boost * 100)
        * math.floor(prestige_sell * 100)
        * math.floor(money_multiplier * 100)

    local denominator = 100 * 100 * 100
    if include_money_potion then
        denominator = denominator * 100
    end

    return math.floor(numerator / denominator)
end

function Mechanics.roll_item(items_flat, mutations, player)
    local material = Mechanics.roll_material(items_flat, player)
    local mutation = Mechanics.roll_mutation(mutations, player)
    local final_value = Mechanics.calculate_item_value(material, mutation, player, false)

    return {
        material = material,
        mutation = mutation,
        final_value = final_value,
    }
end

function Mechanics.record_roll_stats(player, rolled)
    Player.increment_stat_count(player.stats.materials_found, rolled.material.name)

    if rolled.mutation.name ~= "Ничего" then
        Player.increment_stat_count(player.stats.mutations_gotten, rolled.mutation.name)
    end

    Player.add_discovered_material(player, rolled.material.name)

    if rolled.final_value > player.stats.highest_item_value then
        player.stats.highest_item_value = rolled.final_value
        player.stats.highest_item_name = rolled.material.name
    end
end

function Mechanics.award_xp(player, rolled)
    if not rolled then return false end

    local xp_gained = math.floor(rolled.final_value * 25 / 10 - 2)
    local rarity_index = Constants.RARITY_ORDER[rolled.material.rarity] or 0
    xp_gained = xp_gained + rarity_index * 10

    if rolled.mutation.name ~= "Ничего" then
        xp_gained = xp_gained + 50
    end

    local prestige_multiplier = 1.0 + (player.prestige_level * Constants.PRESTIGE_XP_BONUS)
    local wisdom_effect = Player.get_effect(player, Potions.EFFECT.WisdomBoost)
    local wisdom_multiplier = wisdom_effect and wisdom_effect.multiplier or 1.0
    local total_bonus = prestige_multiplier * wisdom_multiplier

    xp_gained = math.floor(xp_gained * math.floor(total_bonus * 100) / 100)
    if xp_gained < 1 then
        xp_gained = 1
    end

    player.stats.total_xp_earned = player.stats.total_xp_earned + xp_gained
    player.current_xp = player.current_xp + xp_gained

    local leveled_up = false
    while player.current_xp >= player.required_xp do
        leveled_up = true
        player.current_xp = player.current_xp - player.required_xp
        player.level = player.level + 1
        player.required_xp = math.floor(
            player.required_xp * Constants.XP_LEVEL_MULTIPLIER_NUMERATOR / Constants.XP_LEVEL_MULTIPLIER_DENOMINATOR
        )
    end

    return leveled_up
end

function Mechanics.sell_rolled_item(player, rolled)
    local value = rolled.final_value
    player.stats.total_money_earned = player.stats.total_money_earned + value
    player.money = player.money + value
    local leveled_up = Mechanics.award_xp(player, rolled)
    return value, leveled_up
end

function Mechanics.collect_rolled_item(player, rolled)
    local leveled_up = Mechanics.award_xp(player, rolled)
    local key = build_inventory_key(rolled.material.name, rolled.mutation.name)
    local amount = 1

    local duplication = Player.get_effect(player, Potions.EFFECT.DuplicationBoost)
    if duplication and math.random() < duplication.multiplier then
        amount = 2
    end

    player.inventory[key] = (player.inventory[key] or 0) + amount
    return amount, leveled_up
end

function Mechanics.sell_all_inventory(player, items_by_name, mutations_by_name)
    if not next(player.inventory) then
        return 0, false
    end

    local total_value = 0
    local any_level_up = false

    for key, quantity in pairs(player.inventory) do
        local name, mutation_name = parse_inventory_key(key)
        local material = items_by_name[name]
        local mutation = mutations_by_name[mutation_name]
        if material and mutation then
            local single_value = Mechanics.calculate_item_value(material, mutation, player, true)
            total_value = total_value + single_value * quantity

            local xp_item = {
                material = material,
                mutation = mutation,
                final_value = Mechanics.calculate_item_value(material, mutation, player, false),
            }
            for _ = 1, quantity do
                if Mechanics.award_xp(player, xp_item) then
                    any_level_up = true
                end
            end
        end
    end

    player.stats.total_money_earned = player.stats.total_money_earned + total_value
    player.money = player.money + total_value
    player.inventory = {}
    return total_value, any_level_up
end

function Mechanics.buy_upgrade(player, upgrade_key)
    local upgrade = player.upgrades[upgrade_key]
    if not upgrade then return false, "unknown" end

    local cost = Upgrades.get_current_cost(upgrade)
    if cost < 0 then return false, "max" end
    if player.money < cost then return false, "money" end

    player.money = player.money - cost
    upgrade.level = upgrade.level + 1
    return true
end

function Mechanics.can_prestige(player)
    local required = Constants.PRESTIGE_BASE_LEVEL_REQ + player.prestige_level
    return player.level >= required
end

function Mechanics.prestige_reset(player)
    local old_prestige = player.prestige_level
    local discovered_materials = player.discovered_materials
    local discovered_mutations = player.discovered_mutations
    local potion_inventory = player.potion_inventory
    local stats = player.stats

    local fresh = Player.new()
    fresh.prestige_level = old_prestige + 1
    fresh.discovered_materials = discovered_materials
    fresh.discovered_mutations = discovered_mutations
    fresh.potion_inventory = potion_inventory
    fresh.stats = stats

    return fresh
end

function Mechanics.use_potion(player, potion_name)
    local potion = Potions.find_by_name(potion_name)
    if not potion then return false, "unknown" end
    if (player.potion_inventory[potion_name] or 0) <= 0 then
        return false, "empty"
    end

    local existing = Player.get_effect(player, potion.effect)
    if existing and existing.time_remaining + potion.duration > Constants.POTION_GLOBAL_TIME_LIMIT_SEC then
        return false, "limit"
    end

    player.potion_inventory[potion_name] = player.potion_inventory[potion_name] - 1
    Player.increment_stat_count(player.stats.potions_used, potion_name)

    if existing then
        existing.time_remaining = existing.time_remaining + potion.duration
    else
        table.insert(player.active_effects, {
            effect_type = potion.effect,
            multiplier = potion.multiplier,
            time_remaining = potion.duration,
        })
    end

    return true
end

function Mechanics.buy_potion(player, potion_name)
    local potion = Potions.find_by_name(potion_name)
    if not potion then return false, "unknown" end
    if player.money < potion.cost then return false, "money" end

    player.money = player.money - potion.cost
    player.potion_inventory[potion_name] = (player.potion_inventory[potion_name] or 0) + 1
    return true
end

function Mechanics.tick_effects(player, dt)
    local changed = false
    for i = #player.active_effects, 1, -1 do
        local effect = player.active_effects[i]
        effect.time_remaining = effect.time_remaining - dt
        if effect.time_remaining <= 0 then
            table.remove(player.active_effects, i)
            changed = true
        end
    end
    return changed
end

function Mechanics.perform_silent_roll(player, items_flat, mutations)
    local rolled = Mechanics.roll_item(items_flat, mutations, player)
    Mechanics.record_roll_stats(player, rolled)

    local key = build_inventory_key(rolled.material.name, rolled.mutation.name)
    player.inventory[key] = (player.inventory[key] or 0) + 1
    return rolled
end

function Mechanics.get_inventory_groups(player)
    local groups = {}

    for key, count in pairs(player.inventory) do
        local name, mutation = parse_inventory_key(key)
        groups[mutation] = groups[mutation] or {}
        table.insert(groups[mutation], { name = name, count = count })
    end

    local ordered = {}
    for mutation, entries in pairs(groups) do
        table.insert(ordered, {
            mutation = mutation,
            entries = entries,
            order = Constants.MUTATION_ORDER[mutation] or 99,
        })
    end

    table.sort(ordered, function(a, b)
        return a.order < b.order
    end)

    return ordered
end

function Mechanics.has_inventory(player)
    return next(player.inventory) ~= nil
end

return Mechanics
