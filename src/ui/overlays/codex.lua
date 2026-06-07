local UI = require("src.ui.components")
local Items = require("src.logic.items")
local Achievements = require("src.logic.achievements")
local Format = require("src.utils.format")

local Codex = {}

local rarity_order = { "common", "uncommon", "rare", "epic", "legendary", "mythic", "unbelievable" }

function Codex.draw(game)
    local clicked_close = false
    local scroll = game.codex_scroll or 0

    UI.draw_overlay_frame("Material Codex", 720, 480, function(x, y, w, h)
        local discovered = {}
        for _, name in ipairs(game.player.discovered_materials) do
            discovered[name] = true
        end

        local content_h = 0
        for _, rarity in ipairs(rarity_order) do
            local list = Items.tree[rarity]
            if list then
                content_h = content_h + 28 + math.ceil(#list / 4) * 72
            end
        end

        local view_h = h - 100
        local max_scroll = math.max(0, content_h - view_h)
        scroll = math.min(scroll, max_scroll)
        game.codex_scroll = scroll

        love.graphics.setScissor(x + 12, y + 48, w - 24, view_h)

        local row_y = y + 52 - scroll
        for _, rarity in ipairs(rarity_order) do
            local list = Items.tree[rarity]
            if not list then goto continue end

            local color = Achievements.RARITY_COLORS[rarity] or {1, 1, 1}
            UI.draw_label(rarity:upper(), x + 20, row_y, UI.fonts.button, color)
            row_y = row_y + 28

            local col = 0
            for _, item in ipairs(list) do
                local ix = x + 20 + col * 168
                local is_found = discovered[item.name]
                local image = game.images[item.img]

                love.graphics.setColor(0.15, 0.15, 0.15, 1)
                love.graphics.rectangle("fill", ix, row_y, 156, 64)
                love.graphics.setColor(color[1], color[2], color[3], is_found and 0.8 or 0.25)
                love.graphics.rectangle("line", ix, row_y, 156, 64)

                if is_found and image then
                    love.graphics.setColor(1, 1, 1, 1)
                    love.graphics.draw(image, ix + 4, row_y + 8, 0, 0.35, 0.35)
                    UI.draw_label(item.name, ix + 52, row_y + 8, UI.fonts.small)
                    UI.draw_label(Format.money(item.value), ix + 52, row_y + 28, UI.fonts.small, {1, 0.84, 0, 0.9})
                else
                    UI.draw_label("???", ix + 52, row_y + 20, UI.fonts.main, {0.4, 0.4, 0.4, 1})
                end

                col = col + 1
                if col >= 4 then
                    col = 0
                    row_y = row_y + 72
                end
            end
            if col > 0 then
                row_y = row_y + 72
            end
            row_y = row_y + 8
            ::continue::
        end

        love.graphics.setScissor()

        local found_count = #game.player.discovered_materials
        UI.draw_label(
            "Discovered: " .. found_count .. " / " .. #Items.flat,
            x + 20, y + h - 52, UI.fonts.small, {0.7, 0.7, 0.7, 1}
        )

        if UI.button("codex_close", "CLOSE", x + w - 120, y + h - 52, 90, 36,
            {0.25, 0.25, 0.25}, {1, 1, 1}) then
            clicked_close = true
        end
    end)

    return clicked_close
end

function Codex.wheel(game, dx, dy)
    game.codex_scroll = math.max(0, (game.codex_scroll or 0) - dy * 30)
end

return Codex
