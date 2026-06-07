local UI = require("src.ui.components")
local Format = require("src.utils.format")

local Statistics = {}

local function sorted_pairs(tbl)
    local keys = {}
    for key in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys, function(a, b)
        return (tbl[a] or 0) > (tbl[b] or 0)
    end)
    return keys
end

function Statistics.draw(game)
    local clicked_close = false

    UI.draw_overlay_frame("Statistics", 720, 420, function(x, y, w, h)
        local text_y = y + 52
        local function line(label, value)
            UI.draw_label(label .. ": ", x + 20, text_y, UI.fonts.main, {0.75, 0.75, 0.75, 1})
            local lw = UI.fonts.main:getWidth(label .. ": ")
            UI.draw_label(value, x + 20 + lw, text_y, UI.fonts.main)
            text_y = text_y + 22
        end

        line("Total Rolls (Lifetime)", Format.number(game.player.stats.total_rolls_all_time))
        line("Total Money Earned", Format.money(game.player.stats.total_money_earned))
        line("Total XP Earned", Format.number(game.player.stats.total_xp_earned) .. " XP")
        line("Prestige Level", tostring(game.player.prestige_level))
        text_y = text_y + 8

        UI.draw_label("--- MATERIALS FOUND ---", x + 20, text_y, UI.fonts.main)
        text_y = text_y + 24
        local materials = sorted_pairs(game.player.stats.materials_found)
        if #materials == 0 then
            UI.draw_label("None yet", x + 20, text_y, UI.fonts.main, {0.5, 0.5, 0.5, 1})
            text_y = text_y + 22
        else
            for _, name in ipairs(materials) do
                line(name, Format.number(game.player.stats.materials_found[name]))
            end
        end

        text_y = text_y + 8
        UI.draw_label("--- MUTATIONS GOTTEN ---", x + 20, text_y, UI.fonts.main)
        text_y = text_y + 24
        local mutations = sorted_pairs(game.player.stats.mutations_gotten)
        if #mutations == 0 then
            UI.draw_label("None yet", x + 20, text_y, UI.fonts.main, {0.5, 0.5, 0.5, 1})
        else
            for _, name in ipairs(mutations) do
                line(name, Format.number(game.player.stats.mutations_gotten[name]))
            end
        end

        if UI.button("stats_close", "CLOSE", x + w - 120, y + h - 52, 90, 36,
            {0.25, 0.25, 0.25}, {1, 1, 1}) then
            clicked_close = true
        end
    end)

    return clicked_close
end

return Statistics
