-- src/ui/game_screen.lua
local UI = require("src.ui.components")
local Visuals = require("src.utils.visuals")
local Format = require("src.utils.format")
local Upgrades = require("src.logic.upgrades")
local Constants = require("src.logic.constants")
local Potions = require("src.logic.potions")
local Mechanics = require("src.logic.mechanics")
local Sound = require("src.utils.sound")
local CraftStore = require("src.ui.overlays.craft_store")
local SettingsOverlay = require("src.ui.overlays.settings")
local Statistics = require("src.ui.overlays.statistics")
local Credits = require("src.ui.overlays.credits")
local Codex = require("src.ui.overlays.codex")
local AchievementsOverlay = require("src.ui.overlays.achievements_overlay")
local Achievements = require("src.logic.achievements")
local Settings = require("src.utils.settings")

local GameScreen = {}

local function play_nav_sound(game)
    if game.overlay or game.dialog then return end
    if UI.hovered_button and UI.clicked_button == UI.hovered_button then
        Sound.play_sfx("navigating.wav")
    end
end

local function draw_upgrade_buttons(game)
    local p = game.player
    local rolling = game.is_rolling

    -- LUCK
    local luck = p.upgrades.Luck
    local luck_cost = Upgrades.get_current_cost(luck)
    local luck_text = luck.level < luck.max_level 
        and ("+LUCK\nLVL " .. luck.level .. "\n" .. Format.money(luck_cost)) 
        or "MAX LEVEL"
    if UI.breathing_button("luck", luck_text, 22, 32, 165, 80,
        {64 / 255, 64 / 255, 0}, {1, 1, 0}, game.can_afford_upgrade("Luck"), not rolling and luck.level < luck.max_level, game.breathing_angle) then
        game.buy_upgrade("Luck")
    end

    -- FASTER ROLL
    local faster = p.upgrades.FasterRoll
    local faster_cost = Upgrades.get_current_cost(faster)
    local roll_ms = Upgrades.get_roll_time_ms(faster.level)
    local faster_text = faster.level < faster.max_level 
        and ("FAST ROLL\n" .. roll_ms .. " MS\n" .. Format.money(faster_cost)) 
        or "MAX LEVEL"
    if UI.breathing_button("faster_roll", faster_text, 202, 32, 165, 80,
        {0, 64 / 255, 64 / 255}, {0, 1, 1}, game.can_afford_upgrade("FasterRoll"), not rolling and faster.level < faster.max_level, game.breathing_angle) then
        game.buy_upgrade("FasterRoll")
    end

    -- SELL BOOST
    local sell = p.upgrades.SellValue
    local sell_cost = Upgrades.get_current_cost(sell)
    local mult_val = 1 + sell.level * 0.1
    local sell_text = sell.level < sell.max_level 
        and ("SELL BOOST\nx" .. string.format("%.1f", mult_val) .. "\n" .. Format.money(sell_cost)) 
        or "MAX LEVEL"
    if UI.breathing_button("sell_value", sell_text, 22, 122, 165, 80,
        {0, 64 / 255, 0}, {0, 1, 0}, game.can_afford_upgrade("SellValue"), not rolling and sell.level < sell.max_level, game.breathing_angle) then
        game.buy_upgrade("SellValue")
    end

    -- AUTO ROLL
    local auto = p.upgrades.AutoRoll
    local auto_cost = Upgrades.get_current_cost(auto)
    local auto_text = auto.level < auto.max_level 
        and ("AUTO ROLL\nLVL " .. auto.level .. "\n" .. Format.money(auto_cost)) 
        or "MAX LEVEL"
    if UI.breathing_button("auto_roll", auto_text, 202, 122, 165, 80,
        {0, 0, 64 / 255}, {0, 0, 1}, game.can_afford_upgrade("AutoRoll"), auto.level < auto.max_level, game.breathing_angle) then
        game.buy_upgrade("AutoRoll")
    end

    -- Переключатели авторолла смещены ниже и не накладываются на текст
    if p.upgrades.AutoRoll.level > 0 then
        if UI.toggle_button("auto_collect", "AUTO COLLECT", 22, 212, 165, 38, p.auto_collect and not p.auto_sell) then
            game.toggle_auto_collect()
        end
        if UI.toggle_button("auto_sell", "AUTO SELL", 202, 212, 165, 38, p.auto_sell) then
            game.toggle_auto_sell()
        end
    end

    -- Новое стильное и крупное табло денег на своем месте в самом низу панели улучшений
    UI.draw_panel(22, 260, 345, 48, {0.14, 0.12, 0.08, 1})
    love.graphics.setColor(1, 0.84, 0, 0.5)
    love.graphics.rectangle("line", 22, 260, 345, 48)
    UI.draw_label("MONEY: " .. Format.money(game.displayed_money), 34, 274, UI.fonts.money, {1, 0.84, 0, 1})
end

local function draw_play_panel(game)
    local px, py = 397, 12
    UI.draw_group_box("Play", px, py, 375, 315)

    -- Рамка для отрисовки предмета
    local frame_x, frame_y = 494, 85
    local frame_w, frame_h = 180, 150
    UI.draw_panel(frame_x, frame_y, frame_w, frame_h, {0.06, 0.06, 0.06, 1})

    love.graphics.setScissor(frame_x, frame_y, frame_w, frame_h)
    if game.is_rolling and game.roll_anim_item then
        local image = game.images[game.roll_anim_item.img]
        if image then
            love.graphics.setColor(1, 1, 1, 0.85)
            Visuals.draw_mutation_aura(image, "Ничего", game.prismatic_color, frame_x, frame_y, frame_w, frame_h)
        end
    elseif game.last_rolled then
        local rolled = game.last_rolled
        local image = game.images[rolled.material.img]
        if image then
            Visuals.draw_mutation_aura(image, rolled.mutation.name, game.prismatic_color, frame_x, frame_y, frame_w, frame_h)
        end
    end
    love.graphics.setScissor()

    -- Отображение названий центрируется строго над рамкой
    local text_y_base = py + 12
    if game.is_rolling then
        UI.draw_label("ROLLING...", px + 130, text_y_base + 24, UI.fonts.button)
    elseif game.last_rolled then
        local rolled = game.last_rolled
        local label_color = Constants.MUTATION_COLORS[rolled.mutation.name] or {1, 1, 1, 1}
        
        local disp_text = rolled.material.name:upper()
        if rolled.mutation.name ~= "Ничего" then
            disp_text = rolled.mutation.name:upper() .. " " .. disp_text
        end
        
        local tw = UI.fonts.button:getWidth(disp_text)
        UI.draw_label(disp_text, px + (375 - tw)/2, text_y_base + 12, UI.fonts.button, label_color)
        
        local val_text = Format.money(rolled.final_value)
        local vw = UI.fonts.small:getWidth(val_text)
        UI.draw_label(val_text, px + (375 - vw)/2, text_y_base + 38, UI.fonts.small, {1, 0.84, 0, 1})
        
        -- Кнопки SELL и KEEP внизу
        if UI.button("sell_now", "SELL [S]", 417, 255, 160, 50, {0.25, 0.25, 0.25}, {1, 1, 1}) then
            local val, lvl_up = game.sell_now()
            Visuals.spawn_particles(584, 160, {1, 0.84, 0, 1}, 20) -- Спарки при ручной продаже
            if lvl_up then Visuals.flash(0.3, {0.2, 0.8, 0.2, 0.8}) end
        end
        if UI.button("collect", "KEEP [C]", 592, 255, 160, 50, {0.25, 0.25, 0.25}, {1, 1, 1}) then
            local amt, lvl_up = game.collect_now()
            Visuals.spawn_particles(584, 160, {0.5, 0.8, 1, 1}, 20)
            if lvl_up then Visuals.flash(0.3, {0.2, 0.8, 0.2, 0.8}) end
        end
    else
        UI.draw_label("FORGE VACANT", px + 115, text_y_base + 24, UI.fonts.button, {0.4, 0.4, 0.4, 1})
        -- Большая кнопка ROLL внизу
        if UI.button("roll", "ROLL [SPACE]", 417, 255, 335, 50, {0.25, 0.25, 0.25}, {1, 1, 1}, not game.is_rolling) then
            game.start_roll()
        end
    end

    -- Слоты зелий по бокам от рамки: кабина пилота
    local potion_slots = {
        { name = "Luck Potion", hotkey = "1", x = 417, y = 85 },
        { name = "Money Potion", hotkey = "2", x = 417, y = 140 },
        { name = "Mutation Potion", hotkey = "3", x = 417, y = 195 },
        { name = "Duplication Potion", hotkey = "4", x = 692, y = 85 },
        { name = "Potion of Wisdom", hotkey = "5", x = 692, y = 140 },
    }

    for _, slot in ipairs(potion_slots) do
        local count = game.player.potion_inventory[slot.name] or 0
        local has_active = count > 0
        
        UI.draw_panel(slot.x, slot.y, 60, 48, {0.1, 0.1, 0.1, 1})
        
        if has_active then
            local image = game.potion_images[slot.name]
            if image then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.draw(image, slot.x + 8, slot.y + 12, 0, 0.4, 0.4)
            end
            UI.draw_label("x" .. count, slot.x + 32, slot.y + 26, UI.fonts.small)
            UI.draw_label("[" .. slot.hotkey .. "]", slot.x + 4, slot.y + 2, UI.fonts.small, {0.5, 0.5, 0.5, 1})
            
            if UI.button("use_" .. slot.name, "", slot.x, slot.y, 60, 48, {0, 0, 0, 0}, {0.3, 0.8, 0.3, 0.2}) then
                game.use_potion(slot.name)
            end
        else
            -- Пустой слот
            UI.draw_label("[" .. slot.hotkey .. "]", slot.x + 22, slot.y + 16, UI.fonts.small, {0.2, 0.2, 0.2, 1})
        end
    end
end

local function draw_inventory(game)
    -- Левая половина - инвентарь
    UI.draw_group_box("Inventory", 12, 396, 760, 230)
    local groups = Mechanics.get_inventory_groups(game.player)
    local scroll = game.inventory_scroll or 0
    local x = 24
    local base_y = 422

    love.graphics.setScissor(12, 396, 520, 180)

    if #groups == 0 then
        UI.draw_label("Empty", x, base_y - scroll, UI.fonts.main, {0.4, 0.4, 0.4, 1})
    else
        local y = base_y - scroll
        for _, group in ipairs(groups) do
            local color = Constants.MUTATION_COLORS[group.mutation] or {0.8, 0.8, 0.8}
            for _, entry in ipairs(group.entries) do
                local key = entry.name
                if group.mutation ~= "Ничего" then
                    key = entry.name .. " (" .. group.mutation .. ")"
                end
                local text = entry.name:upper() .. " x" .. entry.count
                if group.mutation ~= "Ничего" then
                    text = group.mutation:upper() .. " " .. text
                end

                if UI.button("sell_" .. key, text, x, y, 480, 22,
                    {0.07, 0.07, 0.07, 1}, color, true) then
                    local money_added, lvl_up = game.sell_inventory_key(key)
                    Visuals.spawn_particles(love.mouse.getX(), love.mouse.getY(), {1, 0.84, 0, 1}, 10)
                    if lvl_up then Visuals.flash(0.3, {0.2, 0.8, 0.2, 0.8}) end
                end
                y = y + 24
            end
            y = y + 4
        end
    end

    love.graphics.setScissor()

    UI.draw_label("Click item to sell", x, 588, UI.fonts.small, {0.4, 0.4, 0.4, 1})

    local has_items = Mechanics.has_inventory(game.player)
    if UI.button("sell_all", "SELL ALL", 394, 580, 110, 36, {0.25, 0.1, 0.1}, {1, 0.2, 0.2}, has_items) then
        game.sell_all()
    end
end

local function draw_status_labels(game)
    local p = game.player

    -- Правая изолированная колонка инвентаря для статов и таймеров зелий
    local stat_x = 544
    local stat_y = 412
    
    UI.draw_label("STATS & TIMERS", stat_x, stat_y, UI.fonts.button, {1, 0.84, 0, 1})
    
    UI.draw_label("TOTAL ROLLS: " .. Format.number(p.total_rolls), stat_x, stat_y + 24, UI.fonts.small, {0.8, 0.8, 0.8, 1})
    UI.draw_label("LUCK: " .. game.get_luck_display(), stat_x, stat_y + 40, UI.fonts.small, {0.8, 0.8, 0.8, 1})
    UI.draw_label("ROLL SPEED: " .. Upgrades.get_roll_time_ms(p.upgrades.FasterRoll.level) .. " MS", stat_x, stat_y + 56, UI.fonts.small, {0.8, 0.8, 0.8, 1})
    
    -- Динамический цвет счетчика гаранта (жарче по мере приближения)
    local pity_count = game.get_pity_display()
    local pity_pct = (p.pity_counter or 0) / Constants.PITY_THRESHOLD
    local pity_color = {0.8 * pity_pct + 0.2, 0.6 * (1 - pity_pct), 0.8, 1}
    UI.draw_label("PITY IN: " .. pity_count .. " ROLLS", stat_x, stat_y + 72, UI.fonts.small, pity_color)

    -- Серии удач / Скорость
    if (p.luck_streak or 0) >= Constants.LUCK_STREAK_THRESHOLD then
        UI.draw_label("STREAK x" .. p.luck_streak .. "!", stat_x, stat_y + 88, UI.fonts.small, {1, 0.5, 0, 1})
    else
        UI.draw_label("SPEED: " .. string.format("%.1f", Upgrades.get_auto_roll_speed(p.upgrades.AutoRoll.level)) .. "s", stat_x, stat_y + 88, UI.fonts.small, {0.6, 0.6, 0.6, 1})
    end

    -- Активные таймеры зелий внизу колонки
    local timers = {
        game.get_active_timer(Potions.EFFECT.LuckBoost, "x2 LUCK : "),
        game.get_active_timer(Potions.EFFECT.MoneyBoost, "x2 MONEY : "),
        game.get_active_timer(Potions.EFFECT.MutationBoost, "MUTATION : "),
        game.get_active_timer(Potions.EFFECT.DuplicationBoost, "DUPLICATE : "),
        game.get_active_timer(Potions.EFFECT.WisdomBoost, "x1.5 XP : "),
    }
    
    local timer_y_pos = stat_y + 110
    for _, timer in ipairs(timers) do
        if timer then
            UI.draw_label(timer, stat_x, timer_y_pos, UI.fonts.small, {0.3, 0.9, 0.3, 1})
            timer_y_pos = timer_y_pos + 15
        end
    end

    -- Летящие золотые цифры
    for _, floater in ipairs(game.floating_money) do
        local alpha = math.max(0, floater.life / floater.max_life)
        if floater.life / floater.max_life < 0.7 then
            alpha = alpha * 0.6
        end
        UI.draw_label("+" .. Format.money(floater.amount), floater.x, floater.y, UI.fonts.main, {1, 0.84, 0, alpha})
    end
end

function GameScreen.draw(game)
    UI.begin_frame()

    love.graphics.clear(25 / 255, 25 / 255, 25 / 255)
    love.graphics.push()
    Visuals.apply_shake()

    -- Основные панели
    UI.draw_group_box("Upgrades", 12, 12, 375, 315)
    draw_upgrade_buttons(game)
    draw_play_panel(game)
    draw_inventory(game)
    draw_status_labels(game)
    
    -- Нижняя строка прогресса
    UI.draw_progress_bar(11, 333, 761, 36, game.get_xp_progress())
    UI.draw_label("LVL: " .. game.player.level .. " (P: " .. game.player.prestige_level .. ")", 24, 342, UI.fonts.button, {1, 1, 1, 1})
    UI.draw_label(Format.number(game.player.current_xp) .. " / " .. Format.number(game.player.required_xp) .. " XP", 460, 342, UI.fonts.button, {0.8, 0.8, 0.8, 1})

    local ach_count = Achievements.count_unlocked(game.player)
    UI.draw_label("ACHIEVEMENTS: " .. ach_count .. "/" .. #Achievements.list, 204, 375, UI.fonts.small, {0.8, 0.9, 0.5, 1})

    -- Кнопки действий в самом низу экрана
    if UI.button("store", "Store", 470, 632, 80, 46, {0.2, 0.2, 0.2}, {1, 1, 1}, not game.overlay) then
        game.overlay = "craft"
    end
    if UI.button("codex", "Codex", 290, 632, 80, 46, {0.2, 0.2, 0.2}, {1, 1, 1}, not game.overlay) then
        game.overlay = "codex"
    end
    if UI.button("achievements", "Achieve", 376, 632, 88, 46, {0.2, 0.2, 0.2}, {1, 1, 1}, not game.overlay) then
        game.overlay = "achievements"
    end
    if UI.button("stats", "Stats", 118, 632, 80, 46, {0.2, 0.2, 0.2}, {1, 1, 1}, not game.overlay) then
        game.overlay = "stats"
    end
    if UI.button("credits", "Credits", 204, 632, 80, 46, {0.2, 0.2, 0.2}, {1, 1, 1}, not game.overlay) then
        game.overlay = "credits"
    end
    if UI.button("settings", "Settings", 556, 632, 216, 46, {0.2, 0.2, 0.2}, {1, 1, 1}, not game.overlay) then
        game.overlay = "settings"
    end

    local can_prestige = Mechanics.can_prestige(game.player) and not game.is_rolling and not game.is_prestiging
    if UI.button("prestige", "PRESTIGE", 12, 632, 100, 46, {0.25, 0, 0.25}, {1, 0, 1}, can_prestige) then
        game.request_prestige()
    end

    -- Оверлеи
    if game.overlay == "craft" then
        local close, buy = CraftStore.draw(game)
        if close then game.overlay = nil end
        if buy then game.buy_potion(buy) end
    elseif game.overlay == "settings" then
        local close, reset = SettingsOverlay.draw(game)
        if close then
            Settings.save()
            game.overlay = nil
        end
        if reset then
            game.dialog = SettingsOverlay.confirm_reset()
        end
    elseif game.overlay == "stats" then
        if Statistics.draw(game) then
            game.overlay = nil
        end
    elseif game.overlay == "credits" then
        if Credits.draw() then
            game.overlay = nil
        end
    elseif game.overlay == "codex" then
        if Codex.draw(game) then
            game.overlay = nil
        end
    elseif game.overlay == "achievements" then
        if AchievementsOverlay.draw(game) then
            game.overlay = nil
        end
    end

    if game.dialog then
        local buttons
        if game.dialog.kind == "prestige" or game.dialog.kind == "sell_all" or game.dialog.kind == "reset" then
            buttons = {
                { id = "yes", text = "YES" },
                { id = "no", text = "NO" },
            }
        else
            buttons = {{ id = "ok", text = "OK" }}
        end

        local result = UI.draw_modal(game.dialog.title, game.dialog.message, buttons)
        if result == "yes" then
            game.pending_action = game.dialog.kind
            game.dialog = nil
        elseif result == "no" or result == "ok" then
            game.dialog = nil
        end
    elseif game.save_corrupted then
        local result = UI.draw_modal("Save File Error",
            "Save file is corrupted or was tampered with. Starting a new game.",
            {{ id = "ok", text = "OK" }})
        if result == "ok" then
            game.save_corrupted = false
        end
    end

    Visuals.draw_particles() -- Рисование летящих осколков/пыли
    Visuals.draw_flash()     -- Экранные вспышки при уровнях/легендарках
    UI.draw_notifications(game.notifications)

    love.graphics.pop()
    play_nav_sound(game)
    UI.end_frame()
end

return GameScreen