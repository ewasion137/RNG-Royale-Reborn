local UI = require("src.ui.components")
local Achievements = require("src.logic.achievements")
local Format = require("src.utils.format")

local AchievementsOverlay = {}

function AchievementsOverlay.draw(game)
    local clicked_close = false
    local scroll = game.achievements_scroll or 0

    UI.draw_overlay_frame("Achievements", 640, 480, function(x, y, w, h)
        local unlocked = Achievements.count_unlocked(game.player)
        UI.draw_label(
            unlocked .. " / " .. #Achievements.list .. " unlocked",
            x + 20, y + 44, UI.fonts.small, {0.7, 0.9, 0.7, 1}
        )

        local row_h = 56
        local content_h = #Achievements.list * row_h
        local view_h = h - 100
        local max_scroll = math.max(0, content_h - view_h)
        scroll = math.min(scroll, max_scroll)
        game.achievements_scroll = scroll

        love.graphics.setScissor(x + 12, y + 68, w - 24, view_h)

        local row_y = y + 72 - scroll
        for _, achievement in ipairs(Achievements.list) do
            local done = Achievements.is_unlocked(game.player, achievement.id)
            love.graphics.setColor(done and 0.12 or 0.08, done and 0.18 or 0.08, done and 0.12 or 0.08, 1)
            love.graphics.rectangle("fill", x + 16, row_y, w - 32, row_h - 4)
            love.graphics.setColor(done and 0.3 or 0.2, done and 0.8 or 0.2, done and 0.3 or 0.2, done and 0.6 or 0.3)
            love.graphics.rectangle("line", x + 16, row_y, w - 32, row_h - 4)

            local title_color = done and {1, 0.9, 0.4, 1} or {0.6, 0.6, 0.6, 1}
            UI.draw_label((done and "[OK] " or "[  ] ") .. achievement.title, x + 24, row_y + 6, UI.fonts.main, title_color)
            UI.draw_label(achievement.description, x + 24, row_y + 26, UI.fonts.small, {0.65, 0.65, 0.65, 1})

            if achievement.reward_money and achievement.reward_money > 0 then
                local reward_text = "+" .. Format.money(achievement.reward_money)
                UI.draw_label(reward_text, x + w - 24 - UI.fonts.small:getWidth(reward_text), row_y + 18, UI.fonts.small, {1, 0.84, 0, done and 1 or 0.4})
            end

            row_y = row_y + row_h
        end

        love.graphics.setScissor()

        if UI.button("achievements_close", "CLOSE", x + w - 120, y + h - 52, 90, 36,
            {0.25, 0.25, 0.25}, {1, 1, 1}) then
            clicked_close = true
        end
    end)

    return clicked_close
end

function AchievementsOverlay.wheel(game, dx, dy)
    game.achievements_scroll = math.max(0, (game.achievements_scroll or 0) - dy * 30)
end

return AchievementsOverlay
