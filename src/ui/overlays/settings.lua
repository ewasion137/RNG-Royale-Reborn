local UI = require("src.ui.components")
local Settings = require("src.utils.settings")
local Save = require("src.logic.save")
local Sound = require("src.utils.sound")

local SettingsOverlay = {}

local function draw_slider(x, y, w, value)
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", x, y, w, 16)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", x, y, w, 16)

    local knob_x = x + value * w
    love.graphics.rectangle("fill", knob_x - 6, y - 2, 12, 20)

    local mx, my = love.mouse.getPosition()
    if love.mouse.isDown(1) and mx >= x and mx <= x + w and my >= y - 4 and my <= y + 20 then
        value = math.max(0, math.min(1, (mx - x) / w))
    end
    return value
end

function SettingsOverlay.draw(game)
    local clicked_close = false
    local clicked_reset = false

    UI.draw_overlay_frame("Settings", 520, 280, function(x, y, w, h)
        UI.draw_label("Music Volume", x + 24, y + 64, UI.fonts.main)
        Settings.music_volume = draw_slider(x + 24, y + 92, w - 48, Settings.music_volume)
        Sound.set_music_volume(Settings.music_volume)

        UI.draw_label("SFX Volume", x + 24, y + 132, UI.fonts.main)
        Settings.sfx_volume = draw_slider(x + 24, y + 160, w - 48, Settings.sfx_volume)

        if UI.button("settings_reset", "RESET PROGRESS", x + 24, y + h - 56, 180, 36,
            {0.35, 0.1, 0.1}, {1, 0.3, 0.3}) then
            clicked_reset = true
        end

        if UI.button("settings_close", "CLOSE", x + w - 120, y + h - 56, 90, 36,
            {0.25, 0.25, 0.25}, {1, 1, 1}) then
            clicked_close = true
        end
    end)

    return clicked_close, clicked_reset
end

function SettingsOverlay.confirm_reset()
    return {
        kind = "reset",
        title = "RESET",
        message = "ARE YOU SURE?\n\nTHIS ACTION IS UNDONEABLE.\nTHIS WILL RESET ALL YOUR MONEY, UPGRADES AND INVENTORY!",
    }
end

function SettingsOverlay.apply_reset()
    Save.delete()
    love.event.quit()
end

return SettingsOverlay
