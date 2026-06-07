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

    local luck = p.upgrades.Luck
    local luck_cost = Upgrades.get_current_cost(luck)
    local luck_text = luck.level < luck.max_level and ("+LUCK\n" .. Format.money(luck_cost)) or "MAX LEVEL"
    if UI.breathing_button("luck", luck_text, 21, 32, 166, 90,
        {64 / 255, 64 / 255, 0}, {1, 1, 0}, game.can_afford_upgrade("Luck"), not rolling and luck.level < luck.max_level, game.breathing_angle) then
        game.buy_upgrade("Luck")
    end

    local faster = p.upgrades.FasterRoll
    local faster_cost = Upgrades.get_current_cost(faster)
    local faster_text = faster.level < faster.max_level and ("FASTER ROLL\n" .. Format.money(faster_cost)) or "MAX LEVEL"
    if UI.breathing_button("faster_roll", faster_text, 207, 32, 171, 90,
        {0, 64 / 255, 64 / 255}, {0, 1, 1}, game.can_afford_upgrade("FasterRoll"), not rolling and faster.level < faster.max_level, game.breathing_angle) then
        game.buy_upgrade("FasterRoll")
    end

    local sell = p.upgrades.SellValue
    local sell_cost = Upgrades.get_current_cost(sell)
    local sell_text = sell.level < sell.max_level and ("SELL VALUE BOOST\n" .. Format.money(sell_cost)) or "MAX LEVEL"
    if UI.breathing_button("sell_value", sell_text, 21, 138, 166, 90,
        {0, 64 / 255, 0}, {0, 1, 0}, game.can_afford_upgrade("SellValue"), not rolling and sell.level < sell.max_level, game.breathing_angle) then
        game.buy_upgrade("SellValue")
    end

    local auto = p.upgrades.AutoRoll
    local auto_cost = Upgrades.get_current_cost(auto)
    local auto_text = auto.level < auto.max_level and ("AUTO ROLL\n" .. Format.money(auto_cost)) or "MAX LEVEL"
    if UI.breathing_button("auto_roll", auto_text, 207, 138, 171, 90,
        {0, 0, 64 / 255}, {0, 0, 1}, game.can_afford_upgrade("AutoRoll"), auto.level < auto.max_level, game.breathing_angle) then
        game.buy_upgrade("AutoRoll")
    end

    if p.upgrades.AutoRoll.level > 0 then
        if UI.toggle_button("auto_collect", "AUTO\nCOLLECT", 21, 240, 166, 58, p.auto_collect and not p.auto_sell) then
            game.toggle_auto_collect()
        end
        if UI.toggle_button("auto_sell", "AUTO\nSELL", 207, 240, 171, 58, p.auto_sell) then
            game.toggle_auto_sell()
        end
    end
end

local function draw_play_panel(game)
    local px, py = 397, 12
    UI.draw_group_box("Play", px, py, 375, 315)

    local frame_x, frame_y = px + 75, py + 78
    local frame_w, frame_h = 220, 187
    UI.draw_panel(frame_x, frame_y, frame_w, frame_h, {0.08, 0.08, 0.08, 1})

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

    if game.is_rolling then
        UI.draw_label("ROLLING...", px + 120, py + 40, UI.fonts.button)
    elseif game.last_rolled then
        local rolled = game.last_rolled
        UI.draw_label(rolled.material.name:upper(), px + 90, py + 40, UI.fonts.button)
        UI.draw_label(Format.money(rolled.final_value), px + 90, py + 68, UI.fonts.main, {1, 0.84, 0, 1})
        if rolled.mutation.name ~= "Ничего" then
            UI.draw_label(rolled.mutation.name:upper(), px + 90, py + 92, UI.fonts.main, Constants.MUTATION_COLORS[rolled.mutation.name])
        end

        if UI.button("sell_now", "SELL [S]", px + 26, py + 20, 116, 52, {0.25, 0.25, 0.25}, {1, 1, 1}) then
            game.sell_now()
        end
        if UI.button("collect", "KEEP [C]", px + 150, py + 20, 116, 52, {0.25, 0.25, 0.25}, {1, 1, 1}) then
            game.collect_now()
        end
    else
        if UI.button("roll", "ROLL [SPACE]", px + 26, py + 20, 116, 52, {0.25, 0.25, 0.25}, {1, 1, 1}, not game.is_rolling) then
            game.start_roll()
        end
    end

    local potion_slots = {
        { name = "Luck Potion", hotkey = "1", x = px + 240, y = py + 20 },
        { name = "Money Potion", hotkey = "2", x = px + 300, y = py + 20 },
        { name = "Mutation Potion", hotkey = "3", x = px + 240, y = py + 90 },
        { name = "Duplication Potion", hotkey = "4", x = px + 300, y = py + 90 },
        { name = "Potion of Wisdom", hotkey = "5", x = px + 270, y = py + 160 },
    }

    for _, slot in ipairs(potion_slots) do
        local count = game.player.potion_inventory[slot.name] or 0
        if count > 0 then
            local image = game.potion_images[slot.name]
            if image then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.draw(image, slot.x, slot.y, 0, 0.45, 0.45)
            end
            UI.draw_label("x" .. count, slot.x + 28, slot.y + 24, UI.fonts.small)
            UI.draw_label("[" .. slot.hotkey .. "]", slot.x, slot.y - 12, UI.fonts.small, {0.5, 0.5, 0.5, 1})
            if UI.button("use_" .. slot.name, "", slot.x, slot.y, 44, 44, {0, 0, 0, 0}, {0, 0, 0, 0}) then
                game.use_potion(slot.name)
            end
        end
    end
end

local function draw_inventory(game)
    UI.draw_group_box("Inventory", 12, 396, 760, 230)
    local groups = Mechanics.get_inventory_groups(game.player)
    local scroll = game.inventory_scroll or 0
    local x = 24
    local base_y = 420

    love.graphics.setScissor(12, 396, 760, 190)

    if #groups == 0 then
        UI.draw_label("Empty", x, base_y - scroll, UI.fonts.main, {0.5, 0.5, 0.5, 1})
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

                if UI.button("sell_" .. key, text, x, y, 520, 22,
                    {0, 0, 0, 0}, color, true) then
                    game.sell_inventory_key(key)
                end
                y = y + 24
            end
            y = y + 4
        end
    end

    love.graphics.setScissor()

    UI.draw_label("Click item to sell", x, 588, UI.fonts.small, {0.45, 0.45, 0.45, 1})

    local has_items = Mechanics.has_inventory(game.player)
    if UI.button("sell_all", "SELL ALL", 650, 580, 110, 36, {0.25, 0.25, 0.25}, {1, 1, 1}, has_items) then
        game.sell_all()
    end
end

local function draw_status_labels(game)
    local p = game.player
    UI.draw_label("MONEY: " .. Format.number(game.displayed_money), 15, 292, UI.fonts.money)
    UI.draw_label("TOTAL ROLLS: " .. Format.number(p.total_rolls), 198, 247, UI.fonts.small)
    UI.draw_label("LUCK: " .. game.get_luck_display(), 15, 247, UI.fonts.small)
    UI.draw_label("ROLL SPEED (MS) : " .. Upgrades.get_roll_time_ms(p.upgrades.FasterRoll.level), 198, 259, UI.fonts.small)
    UI.draw_label("SELL MUL. LEVEL : X" .. string.format("%.1f", 1 + p.upgrades.SellValue.level * 0.1), 15, 271, UI.fonts.small)
    UI.draw_label("AUTO ROLL LVL : " .. p.upgrades.AutoRoll.level, 198, 271, UI.fonts.small)
    UI.draw_label("PITY IN: " .. game.get_pity_display() .. " rolls", 15, 259, UI.fonts.small, {0.8, 0.6, 1, 1})

    if (p.luck_streak or 0) >= Constants.LUCK_STREAK_THRESHOLD then
        UI.draw_label("STREAK x" .. p.luck_streak .. "!", 198, 283, UI.fonts.small, {1, 0.8, 0.2, 1})
    else
        UI.draw_label("SPEED: " .. string.format("%.1f", Upgrades.get_auto_roll_speed(p.upgrades.AutoRoll.level)) .. "s", 198, 283, UI.fonts.small)
    end

    UI.draw_label("LVL: " .. p.level .. " (P: " .. p.prestige_level .. ")", 15, 375, UI.fonts.main)
    UI.draw_label(Format.number(p.current_xp) .. " / " .. Format.number(p.required_xp) .. " XP", 180, 375, UI.fonts.main)

    local ach_count = Achievements.count_unlocked(p)
    UI.draw_label("ACH: " .. ach_count .. "/" .. #Achievements.list, 400, 375, UI.fonts.small, {0.8, 0.9, 0.5, 1})

    local timers = {
        game.get_active_timer(Potions.EFFECT.LuckBoost, "x2 LUCK POTION : "),
        game.get_active_timer(Potions.EFFECT.MoneyBoost, "x2 MONEY POTION : "),
        game.get_active_timer(Potions.EFFECT.MutationBoost, "MUTATION POTION : "),
        game.get_active_timer(Potions.EFFECT.DuplicationBoost, "DUPLICATION POTION : "),
        game.get_active_timer(Potions.EFFECT.WisdomBoost, "x1.5 XP POTION : "),
    }
    local timer_y = 12
    for _, timer in ipairs(timers) do
        if timer then
            UI.draw_label(timer, 400, timer_y, UI.fonts.small, {0.8, 1, 0.8, 1})
            timer_y = timer_y + 16
        end
    end

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

    UI.draw_group_box("Upgrades", 12, 12, 375, 315)
    draw_upgrade_buttons(game)
    draw_play_panel(game)
    draw_inventory(game)
    draw_status_labels(game)
    UI.draw_progress_bar(11, 333, 761, 36, game.get_xp_progress())

    if UI.button("store", "Store", 470, 632, 80, 46, {0.25, 0.25, 0.25}, {1, 1, 1}, not game.overlay) then
        game.overlay = "craft"
    end
    if UI.button("codex", "Codex", 290, 632, 80, 46, {0.25, 0.25, 0.25}, {1, 1, 1}, not game.overlay) then
        game.overlay = "codex"
    end
    if UI.button("achievements", "Achieve", 376, 632, 88, 46, {0.25, 0.25, 0.25}, {1, 1, 1}, not game.overlay) then
        game.overlay = "achievements"
    end
    if UI.button("stats", "Stats", 118, 632, 80, 46, {0.25, 0.25, 0.25}, {1, 1, 1}, not game.overlay) then
        game.overlay = "stats"
    end
    if UI.button("credits", "Credits", 204, 632, 80, 46, {0.25, 0.25, 0.25}, {1, 1, 1}, not game.overlay) then
        game.overlay = "credits"
    end
    if UI.button("settings", "Settings", 556, 632, 216, 46, {0.25, 0.25, 0.25}, {1, 1, 1}, not game.overlay) then
        game.overlay = "settings"
    end

    local can_prestige = Mechanics.can_prestige(game.player) and not game.is_rolling and not game.is_prestiging
    if UI.button("prestige", "PRESTIGE", 12, 632, 100, 46, {0.25, 0, 0.25}, {1, 0, 1}, can_prestige) then
        game.request_prestige()
    end

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
        if game.dialog.kind == "prestige" then
            buttons = {
                { id = "yes", text = "YES" },
                { id = "no", text = "NO" },
            }
        elseif game.dialog.kind == "sell_all" or game.dialog.kind == "reset" then
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

    UI.draw_notifications(game.notifications)

    love.graphics.pop()
    play_nav_sound(game)
    UI.end_frame()
end

return GameScreen
