local Format = require("src.utils.format")

local UI = {
    fonts = {},
    hovered_button = nil,
    clicked_button = nil,
    mouse_was_down = false,
}

function UI.load()
    UI.fonts = {
        main = love.graphics.newFont("assets/fonts/vstr.ttf", 14),
        small = love.graphics.newFont("assets/fonts/vstr.ttf", 12),
        button = love.graphics.newFont("assets/fonts/vstr.ttf", 20),
        title = love.graphics.newFont("assets/fonts/vstr.ttf", 36),
        huge = love.graphics.newFont("assets/fonts/vstr.ttf", 72),
        money = love.graphics.newFont("assets/fonts/vstr.ttf", 18),
    }
end

function UI.begin_frame()
    UI.hovered_button = nil
    UI.clicked_button = nil
end

function UI.end_frame()
    UI.mouse_was_down = love.mouse.isDown(1)
end

function UI.draw_group_box(text, x, y, w, h)
    love.graphics.setFont(UI.fonts.main)
    love.graphics.setColor(1, 1, 1, 0.35)
    love.graphics.rectangle("line", x, y, w, h)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(text, x + 10, y - 10)
end

function UI.draw_label(text, x, y, font, color)
    love.graphics.setFont(font or UI.fonts.main)
    love.graphics.setColor(color or {1, 1, 1, 1})
    love.graphics.print(text, x, y)
end

function UI.draw_panel(x, y, w, h, color)
    love.graphics.setColor(color or {0.1, 0.1, 0.1, 1})
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(1, 1, 1, 0.25)
    love.graphics.rectangle("line", x, y, w, h)
end

function UI.button(id, text, x, y, w, h, bg_color, border_color, enabled)
    enabled = enabled ~= false
    local mx, my = love.mouse.getPosition()
    local is_over = enabled and mx >= x and mx <= x + w and my >= y and my <= y + h

    if is_over then
        UI.hovered_button = id
    end

    love.graphics.setColor(bg_color)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(border_color)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h)

    love.graphics.setFont(UI.fonts.button)
    love.graphics.setColor(1, 1, 1, enabled and (is_over and 1 or 0.85) or 0.45)
    love.graphics.printf(text, x, y + (h / 2 - 12), w, "center")

    local clicked = false
    if is_over and love.mouse.isDown(1) and not UI.mouse_was_down then
        UI.clicked_button = id
        clicked = true
    end

    return clicked
end

function UI.breathing_button(id, text, x, y, w, h, bg_color, border_color, can_afford, enabled, breathing_angle)
    enabled = enabled ~= false
    local scale = 1
    if enabled and can_afford and breathing_angle then
        scale = 1 + math.abs(math.sin(breathing_angle)) * 0.05
    end

    local nw = w * scale
    local nh = h * scale
    local nx = x - (nw - w) / 2
    local ny = y - (nh - h) / 2
    return UI.button(id, text, nx, ny, nw, nh, bg_color, border_color, enabled and can_afford)
end

function UI.draw_progress_bar(x, y, w, h, progress)
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.rectangle("fill", x, y, w * progress, h)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", x, y, w, h)
end

function UI.draw_modal(title, message, buttons)
    local sw, sh = love.graphics.getDimensions()
    love.graphics.setColor(0, 0, 0, 0.65)
    love.graphics.rectangle("fill", 0, 0, sw, sh)

    local w, h = 520, 220
    local x, y = (sw - w) / 2, (sh - h) / 2
    UI.draw_panel(x, y, w, h, {0.12, 0.12, 0.12, 1})

    UI.draw_label(title, x + 20, y + 16, UI.fonts.button)
    love.graphics.setFont(UI.fonts.main)
    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    love.graphics.printf(message, x + 20, y + 56, w - 40, "left")

    local result = nil
    local bw = 120
    local gap = 20
    local total = #buttons * bw + (#buttons - 1) * gap
    local bx = x + (w - total) / 2
    local by = y + h - 56

    for i, btn in ipairs(buttons) do
        if UI.button("dialog_" .. btn.id, btn.text, bx + (i - 1) * (bw + gap), by, bw, 36,
            {0.25, 0.25, 0.25}, {1, 1, 1}) then
            result = btn.id
        end
    end

    return result
end

function UI.draw_overlay_frame(title, w, h, draw_content)
    local sw, sh = love.graphics.getDimensions()
    love.graphics.setColor(0, 0, 0, 0.65)
    love.graphics.rectangle("fill", 0, 0, sw, sh)

    local x, y = (sw - w) / 2, (sh - h) / 2
    UI.draw_panel(x, y, w, h, {0.1, 0.1, 0.1, 1})
    UI.draw_label(title, x + 16, y + 12, UI.fonts.button)

    draw_content(x, y, w, h)
    return x, y, w, h
end

function UI.format_money(value)
    return Format.money(value)
end

return UI
