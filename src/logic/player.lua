local Upgrades = require("src.logic.upgrades")

local Player = {}

function Player.new()
    return {
        money = 0,
        upgrades = Upgrades.create_defaults(),
        inventory = {},
        discovered_materials = {},
        discovered_mutations = {},
        total_rolls = 0,
        active_effects = {},
        potion_inventory = {},
        prestige_level = 0,
        level = 1,
        current_xp = 0,
        required_xp = 100,
        stats = {
            total_rolls_all_time = 0,
            total_money_earned = 0,
            total_xp_earned = 0,
            materials_found = {},
            mutations_gotten = {},
            potions_used = {},
            highest_item_value = 0,
            highest_item_name = "None",
        },
    }
end

function Player.get_effect(player, effect_type)
    for _, effect in ipairs(player.active_effects) do
        if effect.effect_type == effect_type then
            return effect
        end
    end
end

function Player.has_discovered_material(player, name)
    for _, n in ipairs(player.discovered_materials) do
        if n == name then return true end
    end
    return false
end

function Player.add_discovered_material(player, name)
    if not Player.has_discovered_material(player, name) then
        table.insert(player.discovered_materials, name)
    end
end

function Player.increment_stat_count(table_ref, key)
    table_ref[key] = (table_ref[key] or 0) + 1
end

return Player
