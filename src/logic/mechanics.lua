-- src/logic/mechanics.lua
local Constants = require("src.logic.constants")
local Upgrades = require("src.logic.upgrades")
local Player = require("src.logic.player")
local Potions = require("src.logic.potions")
local Achievements = require("src.logic.achievements")

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

local pity_min_rarity_index = Constants.RARITY_ORDER[Constants.PITY_MIN_RARITY] or 2

local function is_rarity_at_least(rarity, min_rarity)
    return (Constants.RARITY_ORDER[rarity] or 0) >= (Constants.RARITY_ORDER[min_rarity] or 0)
end

local function pick_pity_material(items_flat, min_rarity_index)
    local pool = {}
    for _, item in ipairs(items_flat) do
        if (Constants.RARITY_ORDER[item.rarity] or 0) >= min_rarity_index then
            table.insert(pool, item)
        end
    end
    if #pool == 0 then
        return items_flat[#items_flat]
    end
    return pool[math.random(#pool)]
end

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

-- БРУТАЛЬНЫЙ РАСЧЕТ УДАЧИ
function Mechanics.get_luck_multiplier(player)
    local luck_level = player.upgrades.Luck.level
    local luck_effect = Player.get_effect(player, Potions.EFFECT.LuckBoost)
    local potion_multiplier = luck_effect and luck_effect.multiplier or 1.0
    local prestige_bonus = 1.0 + (player.prestige_level * Constants.PRESTIGE_LUCK_BONUS)
    
    -- НАЛОГ НА БРУТАЛЬНОСТЬ: удача презирает тебя за мусорные роллы!
    local brutality_tax = 1.0
    local pity = player.pity_counter or 0
    if pity > 300 then
        brutality_tax = 0.65 -- Штраф 35% к удаче!
    elseif pity > 150 then
        brutality_tax = 0.80 -- Штраф 20% к удаче!
    elseif pity > 50 then
        brutality_tax = 0.90 -- Штраф 10% к удаче!
    end

    -- ПОБЛАЖКА ЗА СЕРИЮ (Streak Bonus): Мощнейший буст при череде хороших роллов!
    local streak_bonus = 1.0
    local streak = player.luck_streak or 0
    if streak >= Constants.LUCK_STREAK_THRESHOLD then
        streak_bonus = 1.5 + (streak * 0.05)
    end

    return (1 + (luck_level * 0.01)) * potion_multiplier * prestige_bonus * streak_bonus * brutality_tax
end

function Mechanics.update_luck_streak(player, material)
    if is_rarity_at_least(material.rarity, "uncommon") then
        player.luck_streak = (player.luck_streak or 0) + 1
    else
        player.luck_streak = 0
    end
end

function Mechanics.update_pity(player, material)
    if is_rarity_at_least(material.rarity, Constants.PITY_MIN_RARITY) then
        player.pity_counter = 0
    else
        player.pity_counter = (player.pity_counter or 0) + 1
    end
end

function Mechanics.should_trigger_pity(player)
    return (player.pity_counter or 0) >= Constants.PITY_THRESHOLD
end

function Mechanics.roll_material(items_flat, player)
    if Mechanics.should_trigger_pity(player) then
        return pick_pity_material(items_flat, pity_min_rarity_index)
    end

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

-- ИСПРАВЛЕННЫЙ ИДЕАЛЬНЫЙ РАСЧЕТ СТОИМОСТИ (без деления на 1 000 000 и умножения на 100)
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

    -- Расчет идет напрямую через плавные множители без костылей скейлинга
    local total_multiplier = mutation.multiplier * sell_boost * prestige_sell * money_multiplier
    return math.floor(material.value * total_multiplier)
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
    Player.add_discovered_mutation(player, rolled.mutation.name)
    Mechanics.update_pity(player, rolled.material)
    Mechanics.update_luck_streak(player, rolled.material)

    if rolled.final_value > player.stats.highest_item_value then
        player.stats.highest_item_value = rolled.final_value
        player.stats.highest_item_name = rolled.material.name
    end
end

function Mechanics.check_achievements(player)
    return Achievements.check_all(player)
end

function Mechanics.award_xp(player, rolled)
    if not rolled then return false end

    local xp_gained = math.floor(rolled.final_value * 2.5 - 2)
    local rarity_index = Constants.RARITY_ORDER[rolled.material.rarity] or 0
    xp_gained = xp_gained + rarity_index * 10

    if rolled.mutation.name ~= "Ничего" then
        xp_gained = xp_gained + 50
    end

    local prestige_multiplier = 1.0 + (player.prestige_level * Constants.PRESTIGE_XP_BONUS)
    local wisdom_effect = Player.get_effect(player, Potions.EFFECT.WisdomBoost)
    local wisdom_multiplier = wisdom_effect and wisdom_effect.multiplier or 1.0
    local total_bonus = prestige_multiplier * wisdom_multiplier

    xp_gained = math.floor(xp_gained * total_bonus)
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
    local achievements = player.achievements

    local fresh = Player.new()
    fresh.prestige_level = old_prestige + 1
    fresh.discovered_materials = discovered_materials
    fresh.discovered_mutations = discovered_mutations
    fresh.potion_inventory = potion_inventory
    fresh.stats = stats
    fresh.achievements = achievements

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

    if player.auto_sell then
        local value = rolled.final_value
        player.stats.total_money_earned = player.stats.total_money_earned + value
        player.money = player.money + value
        Mechanics.award_xp(player, rolled)
        return rolled, "sell", value
    end

    local key = build_inventory_key(rolled.material.name, rolled.mutation.name)
    local amount = 1

    local duplication = Player.get_effect(player, Potions.EFFECT.DuplicationBoost)
    if duplication and math.random() < duplication.multiplier then
        amount = 2
    end

    player.inventory[key] = (player.inventory[key] or 0) + amount
    return rolled, "collect", amount
end

function Mechanics.process_offline_progress(player, items_flat, mutations)
    local auto_level = player.upgrades.AutoRoll.level
    if auto_level <= 0 then
        player.last_save_time = os.time()
        return nil
    end

    local elapsed = os.time() - (player.last_save_time or os.time())
    elapsed = math.min(elapsed, Constants.OFFLINE_AUTO_ROLL_MAX_SEC)
    if elapsed <= 0 then
        player.last_save_time = os.time()
        return nil
    end

    local roll_interval = Upgrades.get_auto_roll_speed(auto_level)
    local roll_count = math.floor(elapsed / roll_interval)
    if roll_count <= 0 then
        player.last_save_time = os.time()
        return nil
    end

    local total_money = 0
    local total_items = 0
    local best_rarity = "common"
    local best_index = 0

    for _ = 1, roll_count do
        player.total_rolls = player.total_rolls + 1
        player.stats.total_rolls_all_time = player.stats.total_rolls_all_time + 1
        local rolled, mode, amount = Mechanics.perform_silent_roll(player, items_flat, mutations)
        if mode == "sell" then
            total_money = total_money + amount
        else
            total_items = total_items + amount
        end
        local idx = Constants.RARITY_ORDER[rolled.material.rarity] or 0
        if idx > best_index then
            best_index = idx
            best_rarity = rolled.material.rarity
        end
    end

    Mechanics.check_achievements(player)
    player.last_save_time = os.time()

    return {
        rolls = roll_count,
        money = total_money,
        items = total_items,
        seconds = elapsed,
        best_rarity = best_rarity,
    }
end

function Mechanics.toggle_auto_sell(player)
    player.auto_sell = not player.auto_sell
    if player.auto_sell then
        player.auto_collect = false
    end
    return player.auto_sell
end

function Mechanics.toggle_auto_collect(player)
    player.auto_collect = not player.auto_collect
    if player.auto_collect then
        player.auto_sell = false
    end
    return player.auto_collect
end

function Mechanics.sell_inventory_item(player, key, items_by_name, mutations_by_name)
    local quantity = player.inventory[key]
    if not quantity or quantity <= 0 then
        return 0, false
    end

    local name, mutation_name = parse_inventory_key(key)
    local material = items_by_name[name]
    local mutation = mutations_by_name[mutation_name]
    if not material or not mutation then
        return 0, false
    end

    local single_value = Mechanics.calculate_item_value(material, mutation, player, true)
    local total_value = single_value * quantity

    local xp_item = {
        material = material,
        mutation = mutation,
        final_value = Mechanics.calculate_item_value(material, mutation, player, false),
    }
    local any_level_up = false
    for _ = 1, quantity do
        if Mechanics.award_xp(player, xp_item) then
            any_level_up = true
        end
    end

    player.stats.total_money_earned = player.stats.total_money_earned + total_value
    player.money = player.money + total_value
    player.inventory[key] = nil
    return total_value, any_level_up
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