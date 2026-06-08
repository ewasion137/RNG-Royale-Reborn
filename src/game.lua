-- src/game.lua
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
local Format = require("src.utils.format")
local Visuals = require("src.utils.visuals")

local Game = {
    player = nil,
    items = Items,
    mutations = Mutations.list,
    images = {},
    potion_images = {},

    last_rolled = nil,
    is_rolling = false,
    roll_timer = 0,
    roll_anim_item = nil,
    roll_anim_timer = 0,
    is_prestiging = false,

    auto_roll_cooldown = 0,
    displayed_money = 0,
    target_money = 0,

    overlay = nil,
    dialog = nil,

    floating_money = {},
    notifications = {},
    breathing_angle = 0,
    prismatic_hue = 0,
    prismatic_color = {1, 0, 0},

    save_corrupted = false,
    mouse_was_down = false,
    pending_action = nil,
    autosave_timer = 30,

    codex_scroll = 0,
    achievements_scroll = 0,
    inventory_scroll = 0,
}

local RARE_SHAKE_RARITIES = {
    legendary = true,
    mythic = true,
    unbelievable = true,
}

local RARE_NOTIFY_RARITIES = {
    epic = true,
    legendary = true,
    mythic = true,
    unbelievable = true,
}

local POTION_HOTKEYS = {
    ["1"] = "Luck Potion",
    ["2"] = "Money Potion",
    ["3"] = "Mutation Potion",
    ["4"] = "Duplication Potion",
    ["5"] = "Potion of Wisdom",
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

    local offline = Mechanics.process_offline_progress(player, Items.flat, Mutations.list)
    if offline and offline.rolls > 0 then
        Game.sync_money()
        Game.show_notification(string.format(
            "Offline: %d rolls in %s! +%s",
            offline.rolls,
            Format.time(offline.seconds),
            Format.money(offline.money)
        ), 6)
        if offline.items > 0 then
            Game.show_notification("Collected " .. offline.items .. " items while away", 4)
        end
    end

    Mechanics.check_achievements(player)
end

function Game.save()
    local ok, err = pcall(Save.save, Game.player)
    if not ok then
        print("Save failed: " .. tostring(err))
    end
    return ok
end

function Game.quit()
    Game.save()
    Sound.stop_music()
end

function Game.sync_money()
    Game.displayed_money = Game.player.money
    Game.target_money = Game.player.money
end

function Game.show_notification(text, duration)
    table.insert(Game.notifications, {
        text = text,
        life = duration or 4,
        max_life = duration or 4,
    })
end

function Game.spawn_floating_money(amount)
    table.insert(Game.floating_money, {
        amount = amount,
        x = 50,
        y = 285,
        life = 1.5,
        max_life = 1.5,
    })
end

function Game.unlock_achievements(achievements)
    for _, achievement in ipairs(achievements) do
        local reward_text = achievement.reward_money and (" (+" .. Format.money(achievement.reward_money) .. ")") or ""
        Game.show_notification("Achievement: " .. achievement.title .. reward_text, 5)
        Sound.play_sfx("level_up.wav")
    end
    if #achievements > 0 then
        Game.target_money = Game.player.money
    end
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

function Game.update_notifications(dt)
    for i = #Game.notifications, 1, -1 do
        local note = Game.notifications[i]
        note.life = note.life - dt
        if note.life <= 0 then
            table.remove(Game.notifications, i)
        end
    end
end

function Game.pick_roll_anim_item()
    return Items.flat[math.random(#Items.flat)]
end

function Game.start_roll()
    if Game.is_rolling or Game.last_rolled or Game.overlay or Game.dialog then
        return
    end

    Game.is_rolling = true
    Game.player.total_rolls = Game.player.total_rolls + 1
    Game.player.stats.total_rolls_all_time = Game.player.stats.total_rolls_all_time + 1
    Game.roll_timer = Upgrades.get_roll_time_ms(Game.player.upgrades.FasterRoll.level) / 1000
    Game.roll_anim_item = Game.pick_roll_anim_item()
    Game.roll_anim_timer = 0
    Sound.play_sfx("roll.wav")
end

function Game.finish_roll()
    Sound.stop_sfx("roll.wav") -- МГНОВЕННАЯ ОБРЕЗКА ЗВУКА КРУТИЛКИ!

    local rolled = Mechanics.roll_item(Items.flat, Mutations.list, Game.player)
    Mechanics.record_roll_stats(Game.player, rolled)
    Game.last_rolled = rolled

    -- Определение цвета эффектов
    local rarity = rolled.material.rarity
    local mut_name = rolled.mutation.name
    local effect_color = {1, 1, 1, 1}

    if Constants.MUTATION_COLORS[mut_name] then
        effect_color = Constants.MUTATION_COLORS[mut_name]
    elseif rarity == "rare" then
        effect_color = {0.3, 0.6, 1, 1}
    elseif rarity == "epic" then
        effect_color = {0.7, 0.2, 1, 1}
    elseif rarity == "legendary" then
        effect_color = {1, 0.8, 0, 1}
    elseif rarity == "mythic" then
        effect_color = {1, 0.1, 0.1, 1}
    elseif rarity == "unbelievable" then
        effect_color = {0, 1, 1, 1}
    end

    -- Взрыв брутальных частиц прямо по центру рамки Play (x=584, y=160)
    Visuals.spawn_particles(584, 160, effect_color, 25)

    if rolled.material.rarity == "unbelievable" and rolled.mutation.name ~= "Ничего" then
        Sound.play_sfx("unbelivable_mutation.wav")
        Visuals.flash(0.5, {0, 1, 1, 0.8}) -- Яркая бирюзовая вспышка
        Visuals.shake(0.8, 15)             -- Мощнейшее землетрясение экрана
    else
        Sound.play_sfx(Constants.RARITY_SOUNDS[rolled.material.rarity])
        if rolled.mutation.name ~= "Ничего" then
            Sound.play_sfx(Constants.MUTATION_SOUNDS[rolled.mutation.name])
        end

        -- Вспышки и встряски для редких предметов
        if rarity == "epic" then
            Visuals.flash(0.2, {0.7, 0.2, 1, 0.4})
            Visuals.shake(0.3, 4)
        elseif rarity == "legendary" then
            Visuals.flash(0.3, {1, 0.8, 0, 0.5})
            Visuals.shake(0.5, 8)
        elseif rarity == "mythic" then
            Visuals.flash(0.4, {1, 0.1, 0.1, 0.6})
            Visuals.shake(0.7, 12)
        elseif rarity == "unbelievable" then
            Visuals.flash(0.5, {0, 1, 1, 0.7})
            Visuals.shake(0.8, 15)
        end
    end

    Game.unlock_achievements(Mechanics.check_achievements(Game.player))
    Game.is_rolling = false
    Game.roll_anim_item = nil
end

function Game.sell_now()
    if not Game.last_rolled then return end
    local value, leveled_up = Mechanics.sell_rolled_item(Game.player, Game.last_rolled)
    Game.target_money = Game.player.money
    Game.spawn_floating_money(value)
    
    -- Золотые искры при продаже
    Visuals.spawn_particles(584, 160, {1, 0.84, 0, 1}, 15)

    Game.last_rolled = nil
    Sound.play_sfx("selling.wav")
    if leveled_up then
        Sound.play_sfx("level_up.wav")
        Visuals.flash(0.3, {0.2, 0.8, 0.2, 0.4})
    end
    Game.unlock_achievements(Mechanics.check_achievements(Game.player))
end

function Game.collect_now()
    if not Game.last_rolled then return end
    local amount, leveled_up = Mechanics.collect_rolled_item(Game.player, Game.last_rolled)
    
    -- Синие искры при сохранении предмета
    Visuals.spawn_particles(584, 160, {0.3, 0.6, 1, 1}, 12)

    if amount > 1 then
        Sound.play_sfx("duplication_success.wav")
        Visuals.flash(0.2, {0.3, 1, 0.3, 0.3})
    end
    Sound.play_sfx("inventory.wav")
    Game.last_rolled = nil
    if leveled_up then
        Sound.play_sfx("level_up.wav")
        Visuals.flash(0.3, {0.2, 0.8, 0.2, 0.4})
    end
    Game.unlock_achievements(Mechanics.check_achievements(Game.player))
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
        
        -- Массивный золотой фонтан из инвентаря
        Visuals.spawn_particles(240, 500, {1, 0.84, 0, 1}, 30)

        Sound.play_sfx("selling.wav")
        if leveled_up then
            Sound.play_sfx("level_up.wav")
            Visuals.flash(0.3, {0.2, 0.8, 0.2, 0.4})
        end
    end
    Game.dialog = nil
    Game.unlock_achievements(Mechanics.check_achievements(Game.player))
end

function Game.buy_upgrade(key)
    local ok, reason = Mechanics.buy_upgrade(Game.player, key)
    if ok then
        if key == "AutoRoll" and Game.player.upgrades.AutoRoll.level == 1 then
            Game.auto_roll_cooldown = Constants.AUTOROLL_BASE_COOLDOWN_SEC - Constants.AUTOROLL_REDUCTION_PER_LEVEL_SEC
        end
        Game.sync_money()
        Sound.play_sfx("upgrade_buy.wav")
        
        -- Зеленое свечение покупки
        Visuals.flash(0.15, {0.2, 0.8, 0.2, 0.2})
        Game.unlock_achievements(Mechanics.check_achievements(Game.player))
    else
        Sound.play_sfx("cant_buy.wav")
    end
    return ok, reason
end

function Game.use_potion(name)
    local ok, reason = Mechanics.use_potion(Game.player, name)
    if ok then
        Sound.play_sfx("drink_potion.wav")
        Visuals.flash(0.2, {0.3, 0.9, 0.3, 0.3})
        Game.unlock_achievements(Mechanics.check_achievements(Game.player))
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

function Game.toggle_auto_sell()
    Mechanics.toggle_auto_sell(Game.player)
    Game.show_notification(Game.player.auto_sell and "Auto Sell: ON" or "Auto Sell: OFF", 2)
end

function Game.toggle_auto_collect()
    Mechanics.toggle_auto_collect(Game.player)
    Game.show_notification(Game.player.auto_collect and "Auto Collect: ON" or "Auto Collect: OFF", 2)
end

function Game.sell_inventory_key(key)
    local total, leveled_up = Mechanics.sell_inventory_item(Game.player, key, Items.by_name, Mutations.by_name)
    if total > 0 then
        Game.target_money = Game.player.money
        Game.spawn_floating_money(total)
        Sound.play_sfx("selling.wav")
        if leveled_up then
            Sound.play_sfx("level_up.wav")
            Visuals.flash(0.3, {0.2, 0.8, 0.2, 0.4})
        end
    end
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
            "Are you sure you want to prestige?\n\nThis will reset:\n- Money, Upgrades, Inventory\n- Active Potions, Level and XP\n\nYou will reach Prestige Level %d.\n\nBonuses: +%.0f%% sell, +%.0f%% luck, +%.0f%% XP per prestige.",
            new_level,
            Constants.PRESTIGE_SELL_VALUE_BONUS * 100,
            Constants.PRESTIGE_LUCK_BONUS * 100,
            Constants.PRESTIGE_XP_BONUS * 100
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

    -- Масштабный взрыв фиолетовых осколков на престиж
    Visuals.spawn_particles(392, 368, {0.8, 0.1, 1, 1}, 50)
    Visuals.flash(0.6, {0.8, 0.1, 1, 0.7})

    Game.last_rolled = nil
    Game.player = Mechanics.prestige_reset(Game.player)
    Game.sync_money()
    Game.auto_roll_cooldown = 0
    Game.save()
    Game.is_prestiging = false
    Game.dialog = nil
    Game.unlock_achievements(Mechanics.check_achievements(Game.player))
end

-- НАДЕЖНЫЙ СБРОС ИГРЫ (Очищает оперативную память и перезаписывает сейв чистым игроком)
function Game.reset_progress()
    -- 1. Сбрасываем игрока в RAM на дефолтного персонажа
    Game.player = Player.new()
    
    -- 2. Синхронизируем все переменные, чтобы UI мгновенно отрисовал нули
    Game.sync_money()
    Game.last_rolled = nil
    Game.is_rolling = false
    Game.auto_roll_cooldown = 0
    Game.floating_money = {}
    Game.notifications = {}
    
    -- 3. Принудительно перезаписываем сейв на диске чистыми данными
    -- Теперь даже при выходе из игры или автосейве запишется чистый сейв
    Game.save()
    
    -- 4. Закрываем настройки и диалоги
    Game.overlay = nil
    Game.dialog = nil
    
    Game.show_notification("GAME RESET COMPLETED!", 5)
    Sound.play_sfx("level_up.wav")
end

function Game.process_pending_action()
    local action = Game.pending_action
    if not action then return end
    Game.pending_action = nil

    if action == "prestige" then
        Game.confirm_prestige()
    elseif action == "sell_all" then
        Game.confirm_sell_all()
    elseif action == "reset" then
        -- Вызываем наш надежный сброс вместо внешнего метода
        Game.reset_progress()
    end
end

function Game.handle_auto_roll()
    local rolled, mode, amount = Mechanics.perform_silent_roll(Game.player, Items.flat, Mutations.list)
    Game.player.total_rolls = Game.player.total_rolls + 1
    Game.player.stats.total_rolls_all_time = Game.player.stats.total_rolls_all_time + 1

    if mode == "sell" then
        Game.target_money = Game.player.money
        -- Пассивные мелкие искры в табло денег
        Visuals.spawn_particles(180, 280, {1, 0.84, 0, 0.5}, 2)
    else
        -- Пассивные синие искры в инвентаре
        Visuals.spawn_particles(200, 500, {0.3, 0.6, 1, 0.5}, 2)
    end

    if RARE_NOTIFY_RARITIES[rolled.material.rarity] then
        local mut_text = rolled.mutation.name ~= "Ничего" and (" " .. rolled.mutation.name) or ""
        Game.show_notification("Auto: " .. rolled.material.name .. mut_text .. "!", 3)
        
        -- Авторолл редких предметов также трясет экран и дает легкую вспышку!
        if RARE_SHAKE_RARITIES[rolled.material.rarity] then
            Visuals.shake(0.15, 3)
            Visuals.flash(0.15, {1, 0.5, 0, 0.3})
        end
    end

    local achievements = Mechanics.check_achievements(Game.player)
    if #achievements > 0 then
        Game.unlock_achievements(achievements)
    end
end

function Game.update(dt)
    Game.process_pending_action()

    Game.breathing_angle = Game.breathing_angle + dt * 6
    Game.prismatic_hue = (Game.prismatic_hue + dt * 120) % 360
    Game.prismatic_color = {Visuals.color_from_hsv(Game.prismatic_hue, 1, 1)}

    if Game.is_rolling then
        Game.roll_timer = Game.roll_timer - dt
        Game.roll_anim_timer = Game.roll_anim_timer + dt
        if Game.roll_anim_timer >= 0.08 then
            Game.roll_anim_timer = 0
            Game.roll_anim_item = Game.pick_roll_anim_item()
        end
        if Game.roll_timer <= 0 then
            Game.finish_roll()
        end
    end

    -- СТАРАЯ ЛОГИКА АВТОРОЛЛА: авторолл работает полностью в фоне (не блокируется ручным роллом)
    local auto_level = Game.player.upgrades.AutoRoll.level
    if auto_level > 0 then
        Game.auto_roll_cooldown = Game.auto_roll_cooldown - dt
        if Game.auto_roll_cooldown <= 0 then
            Game.handle_auto_roll()
            Game.auto_roll_cooldown = Upgrades.get_auto_roll_speed(auto_level)
        end
    end

    Mechanics.tick_effects(Game.player, dt)
    Game.update_money_animation(dt)
    Game.update_notifications(dt)

    Game.autosave_timer = Game.autosave_timer - dt
    if Game.autosave_timer <= 0 then
        Game.save()
        Game.autosave_timer = 30
    end
end

function Game.get_active_timer(effect_type, label)
    local effect = Player.get_effect(Game.player, effect_type)
    if effect and effect.time_remaining > 0 then
        return label .. Format.time(effect.time_remaining)
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

function Game.get_luck_display()
    return string.format("x%.2f", Mechanics.get_luck_multiplier(Game.player))
end

function Game.get_pity_display()
    local remaining = Constants.PITY_THRESHOLD - (Game.player.pity_counter or 0)
    return math.max(0, remaining)
end

function Game.wheelmoved(x, y)
    if Game.overlay == "codex" then
        require("src.ui.overlays.codex").wheel(Game, x, y)
    elseif Game.overlay == "achievements" then
        require("src.ui.overlays.achievements_overlay").wheel(Game, x, y)
    elseif not Game.overlay then
        Game.inventory_scroll = math.max(0, (Game.inventory_scroll or 0) - y * 24)
    end
end

function Game.keypressed(key)
    if key == "escape" then
        if Game.dialog then
            Game.dialog = nil
        elseif Game.overlay then
            Game.overlay = nil
        end
        return
    end

    if Game.overlay or Game.dialog then return end

    if key == "space" or key == "return" then
        if Game.last_rolled then
            Game.collect_now()
        else
            Game.start_roll()
        end
    elseif key == "s" then
        if Game.last_rolled then
            Game.sell_now()
        end
    elseif key == "c" then
        if Game.last_rolled then
            Game.collect_now()
        end
    elseif key == "a" then
        Game.toggle_auto_sell()
    elseif key == "v" then
        Game.toggle_auto_collect()
    elseif POTION_HOTKEYS[key] then
        Game.use_potion(POTION_HOTKEYS[key])
    elseif key == "l" and not Game.overlay then
        Game.player.money = Game.player.money + 1e28
        Game.sync_money()
        Sound.play_sfx("upgrade_buy.wav")
    end
end

return Game