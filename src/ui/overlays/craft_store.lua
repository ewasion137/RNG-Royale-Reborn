local UI = require("src.ui.components")
local Potions = require("src.logic.potions")
local Format = require("src.utils.format")

local CraftStore = {}

function CraftStore.draw(game)
    local clicked_close = false
    local clicked_buy = nil

    UI.draw_overlay_frame("Craft Store", 640, 420, function(x, y, w, h)
        local row_y = y + 56
        for i, potion in ipairs(Potions.catalog) do
            local row_x = x + 20
            local image = game.potion_images[potion.name]
            if image then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.draw(image, row_x, row_y, 0, 0.5, 0.5)
            end

            UI.draw_label(potion.name, row_x + 48, row_y + 2, UI.fonts.main)
            UI.draw_label(potion.description, row_x + 48, row_y + 22, UI.fonts.small, {0.75, 0.75, 0.75, 1})
            UI.draw_label(Format.money(potion.cost), row_x + 48, row_y + 40, UI.fonts.small, {1, 1, 0.4, 1})

            if UI.button("buy_" .. potion.name, "BUY", x + w - 120, row_y + 10, 90, 36,
                {0, 0.25, 0}, {0, 1, 0}, game.player.money >= potion.cost) then
                clicked_buy = potion.name
            end

            row_y = row_y + 68
        end

        if UI.button("craft_close", "CLOSE", x + w - 120, y + h - 52, 90, 36,
            {0.25, 0.25, 0.25}, {1, 1, 1}) then
            clicked_close = true
        end
    end)

    return clicked_close, clicked_buy
end

return CraftStore
