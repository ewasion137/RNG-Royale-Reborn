local UI = require("src.ui.components")

local Credits = {}

function Credits.draw()
    local clicked_close = false

    UI.draw_overlay_frame("Credits", 720, 380, function(x, y, w, h)
        love.graphics.setFont(UI.fonts.title)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("RNG ROYALE", x, y + 48, w, "center")

        love.graphics.setFont(UI.fonts.main)
        love.graphics.printf(
            "Game by ewasion\n\nA luck-based incremental RNG game.\nRoll materials, collect mutations,\nupgrade your luck and prestige for permanent bonuses.",
            x + 40, y + 110, w - 80, "center"
        )

        if UI.button("credits_close", "CLOSE", x + w - 120, y + h - 52, 90, 36,
            {0.25, 0.25, 0.25}, {1, 1, 1}) then
            clicked_close = true
        end
    end)

    return clicked_close
end

return Credits
