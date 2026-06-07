local Constants = require("src.logic.constants")
local Items = require("src.logic.items")
local Mutations = require("src.logic.mutations")
local Mechanics = require("src.logic.mechanics")
local Upgrades = require("src.logic.upgrades")
local Potions = require("src.logic.potions")
local Player = require("src.logic.player")
local Save = require("src.logic.save")
local Settings = require("src.utils.settings")
local Sound = require("src.utils.sound")

local Game = {
    player = nil,
    items = Items,
    mutations = Mutations.list,
    images = {},
    potion_images = {},

    last_rolled = nil,
    is_rolling = false,
    roll_timer = 0,
    is_prestiging = false,

    auto_roll_cooldown = 0,
    displayed_money = 0,
    target_money = 0,

    overlay = nil,
    dialog = nil,

    floating_money = {},
    breathing_angle = 0,
    prismatic_hue = 0,
    prismatic_color = {1, 0, 0},

    save_corrupted = false,
    mouse_was_down = false,
}

local RARE_SHAKE_RARITIES = {
    legendary = true,
    mythic = true,
    unbelievable = true,
}

function Game.load()
    Settings.load()
    Sound.load()
    Sound.play_music("musa.wav")

    for _, item in ipairs(Items.flat) do
        Game.images[item.img] = love.graphics.newImage("assets/pic/" .. item.img)
    end

    for _, potion in ipairs(Potions.catalog) do
        Game.potion_images[potion.name] = love.graphics.newImage("assets/pic/" .. potion.image)
    end

    local player, ok = Save.load()
    Game.player = player
    Game.save_corrupted = not ok
    Game.displayed_money = player.money
    Game.target_money = player.money

    local auto_level = player.upgrades.AutoRoll.level
    if auto_level > 0 then
        Game.auto_roll_cooldown = Upgrades.get_auto_roll_speed(auto_level)
    end
end

function Game.quit()
    Save.save(Game.player)
    Sound.stop_music()
end

function Game.sync_money()
    Game.displayed_money = Game.player.money
    Game.target_money = Game.player.money
end

function Game.spawn_floating_money(amount)
    table.insert(Game.floating_money, {
        amount = amount,
        x = 20,
        y = 285,
        life = 1.5,
        max_life = 1.5,
    })
end

function Game.update_money_animation(dt)
    if Game.displayed_money < Game.target_money then
        local difference = Game.target_money - Game.displayed_money
        local step = math.max(1, math.floor(difference / 20))
        local min_step = math.max(1, math.floor(Game.target_money / 5000))
        step = math.max(step, min_step)
        Game.displayed_money = math.min(Game.target_money, Game.displayed_money + step)
    else
        Game.displayed_money = Game.player.money
        Game.target_money = Game.player.money
    end

    for i = #Game.floating_money, 1, -1 do
        local floater = Game.floating_money[i]
        floater.life = floater.life - dt
        floater.y = floater.y - 20 * dt
        if floater.life <= 0 then
            table.remove(Game.floating_money, i)
        end
    end
end

function Game.start_roll()
    if Game.is_rolling or Game.last_rolled or Game.overlay or Game.dialog then
        return
    end

    Game.is_rolling = true
    Game.player.total_rolls = Game.player.total_rolls + 1
    Game.player.stats.total_rolls_all_time = Game.player.stats.total_rolls_all_time + 1
    Game.roll_timer = Upgrades.get_roll_time_ms(Game.player.upgrades.FasterRoll.level) / 1000
    Sound.play_sfx("roll.wav")
end

function Game.finish_roll()
    local rolled = Mechanics.roll_item(Items.flat, Mutations.list, Game.player)
    Mechanics.record_roll_stats(Game.player, rolled)
    Game.last_rolled = rolled

    if rolled.material.rarity == "unbelievable" and rolled.mutation.name ~= "Ничего" then
        Sound.play_sfx("unbelivable_mutation.wav")
    else
        Sound.play_sfx(Constants.RARITY_SOUNDS[rolled.material.rarity])
        if rolled.mutation.name ~= "Ничего" then
            Sound.play_sfx(Constants.MUTATION_SOUNDS[rolled.mutation.name])
        end
    end

    if RARE_SHAKE_RARITIES[rolled.material.rarity] then
        require("src.utils.visuals").shake(0.3, 5)
    end

    Game.is_rolling = false
end

function Game.sell_now()
    if not Game.last_rolled then return end
    local value, leveled_up = Mechanics.sell_rolled_item(Game.player, Game.last_rolled)
    Game.target_money = Game.player.money
    Game.spawn_floating_money(value)
    Game.last_rolled = nil
    Sound.play_sfx("selling.wav")
    if leveled_up then
        Sound.play_sfx("level_up.wav")
    end
end

function Game.collect_now()
    if not Game.last_rolled then return end
    local amount, leveled_up = Mechanics.collect_rolled_item(Game.player, Game.last_rolled)
    if amount > 1 then
        Sound.play_sfx("duplication_success.wav")
    end
    Sound.play_sfx("inventory.wav")
    Game.last_rolled = nil
    if leveled_up then
        Sound.play_sfx("level_up.wav")
    end
end

function Game.sell_all()
    Game.dialog = {
        kind = "sell_all",
        message = "Are you sure?",
        title = "Confirming selling",
    }
end

function Game.confirm_sell_all()
    local total, leveled_up = Mechanics.sell_all_inventory(Game.player, Items.by_name, Mutations.by_name)
    if total > 0 then
        Game.target_money = Game.player.money
        Game.spawn_floating_money(total)
        Sound.play_sfx("selling.wav")
        if leveled_up then
            Sound.play_sfx("level_up.wav")
        end
    end
    Game.dialog = nil
end

function Game.buy_upgrade(key)
    local ok, reason = Mechanics.buy_upgrade(Game.player, key)
    if ok then
        if key == "AutoRoll" and Game.player.upgrades.AutoRoll.level == 1 then
            Game.auto_roll_cooldown = Constants.AUTOROLL_BASE_COOLDOWN_SEC - Constants.AUTOROLL_REDUCTION_PER_LEVEL_SEC
        end
        Game.sync_money()
        Sound.play_sfx("upgrade_buy.wav")
    else
        Sound.play_sfx("cant_buy.wav")
    end
    return ok, reason
end

function Game.use_potion(name)
    local ok, reason = Mechanics.use_potion(Game.player, name)
    if ok then
        Sound.play_sfx("drink_potion.wav")
    elseif reason == "limit" then
        Sound.play_sfx("cant_buy.wav")
        Game.dialog = {
            kind = "message",
            title = "LIMIT",
            message = "You can't exceed the potion time, more than 24 hours.",
        }
    end
    return ok, reason
end

function Game.buy_potion(name)
    local ok = Mechanics.buy_potion(Game.player, name)
    if ok then
        Game.sync_money()
        Sound.play_sfx("upgrade_buy.wav")
    else
        Sound.play_sfx("cant_buy.wav")
    end
    return ok
end

function Game.request_prestige()
    if Game.is_prestiging or Game.is_rolling or not Mechanics.can_prestige(Game.player) then
        return
    end

    local new_level = Game.player.prestige_level + 1
    Game.dialog = {
        kind = "prestige",
        title = "Confirm Prestige",
        message = string.format(
            "Are you sure you want to prestige?\n\nThis will reset:\n- Money, Upgrades, Inventory\n- Active Potions, Level and XP\n\nYou will reach Prestige Level %d.",
            new_level
        ),
    }
end

function Game.confirm_prestige()
    if not Mechanics.can_prestige(Game.player) then
        Game.dialog = nil
        return
    end

    Game.is_prestiging = true
    local prestige_sound = Game.player.prestige_level < 5 and "prestige_success_early.wav" or "prestige_success_epic.wav"

    if Settings.sfx_volume > 0 then
        Sound.play_sfx(prestige_sound)
    end

    Game.last_rolled = nil
    Game.player = Mechanics.prestige_reset(Game.player)
    Game.sync_money()
    Game.auto_roll_cooldown = 0
    Save.save(Game.player)
    Game.is_prestiging = false
    Game.dialog = nil
end

function Game.update(dt)
    Game.breathing_angle = Game.breathing_angle + dt * 6
    Game.prismatic_hue = (Game.prismatic_hue + dt * 120) % 360
    Game.prismatic_color = {require("src.utils.visuals").color_from_hsv(Game.prismatic_hue, 1, 1)}

    if Game.is_rolling then
        Game.roll_timer = Game.roll_timer - dt
        if Game.roll_timer <= 0 then
            Game.finish_roll()
        end
    end

    local auto_level = Game.player.upgrades.AutoRoll.level
    if auto_level > 0 and not Game.is_rolling and not Game.last_rolled then
        Game.auto_roll_cooldown = Game.auto_roll_cooldown - dt
        if Game.auto_roll_cooldown <= 0 then
            Mechanics.perform_silent_roll(Game.player, Items.flat, Mutations.list)
            Game.auto_roll_cooldown = Upgrades.get_auto_roll_speed(auto_level)
        end
    end

    if Mechanics.tick_effects(Game.player, dt) and not Game.overlay then
        -- effects expired
    end

    Game.update_money_animation(dt)
end

function Game.get_active_timer(effect_type, label)
    local effect = Player.get_effect(Game.player, effect_type)
    if effect and effect.time_remaining > 0 then
        return label .. require("src.utils.format").time(effect.time_remaining)
    end
end

function Game.can_afford_upgrade(key)
    local upgrade = Game.player.upgrades[key]
    local cost = Upgrades.get_current_cost(upgrade)
    return cost >= 0 and Game.player.money >= cost
end

function Game.get_xp_progress()
    if Game.player.required_xp <= 0 then
        return 1
    end
    return math.min(1, Game.player.current_xp / Game.player.required_xp)
end

function Game.keypressed(key)
    if key == "l" and not Game.overlay then
        Game.player.money = Game.player.money + 1e28
        Game.sync_money()
        Sound.play_sfx("upgrade_buy.wav")
    end
end

return Game
