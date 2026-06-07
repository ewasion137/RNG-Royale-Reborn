-- src/ui/components.lua
local Format = require("src.utils.format")

local UI = {
    fonts = {},
    hovered_button = nil,
    clicked_button = nil,
    mouse_was_down = false,
}

local function load_font(path, size)
    local font = love.graphics.newFont(path, size)
    font:setFilter("nearest", "nearest")
    return font
end

local function pick_font_path()
    local candidates = {
        "assets/fonts/Pixel Game.otf",
        "assets/fonts/game.ttf",
        "assets/fonts/vstr.ttf",
    }
    for _, path in ipairs(candidates) do
        if love.filesystem.getInfo(path) then
            return path
        end
    end
    error("no font found in assets/fonts/")
end

function UI.load()
    local font_path = pick_font_path()

    UI.fonts = {
        main = load_font(font_path, 16),
        small = load_font(font_path, 14),
        button = load_font(font_path, 19), -- Слегка уменьшен, чтобы текст гарантированно влезал в кнопки
        title = load_font(font_path, 32),
        huge = load_font(font_path, 64),
        money = load_font(font_path, 20),
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
    love.graphics.setColor(1, 1, 1, 0.25)
    -- Брутальная двойная рамка
    love.graphics.rectangle("line", x, y, w, h)
    love.graphics.rectangle("line", x + 1, y + 1, w - 2, h - 2)
    
    -- Вырезаем плашку под текст
    local tw = UI.fonts.main:getWidth(text)
    love.graphics.setColor(25/255, 25/255, 25/255, 1)
    love.graphics.rectangle("fill", x + 10, y - 10, tw + 8, 18)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(text, x + 14, y - 10)
end

function UI.draw_label(text, x, y, font, color)
    love.graphics.setFont(font or UI.fonts.main)
    love.graphics.setColor(color or {1, 1, 1, 1})
    love.graphics.print(text, x, y)
end

function UI.draw_panel(x, y, w, h, color)
    love.graphics.setColor(color or {0.1, 0.1, 0.1, 1})
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(1, 1, 1, 0.2)
    love.graphics.rectangle("line", x, y, w, h)
end

function UI.button(id, text, x, y, w, h, bg_color, border_color, enabled)
    enabled = enabled ~= false
    local mx, my = love.mouse.getPosition()
    local is_over = enabled and mx >= x and mx <= x + w and my >= y and my <= y + h

    if is_over then
        UI.hovered_button = id
    end

    -- Тень под кнопкой
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", x + 3, y + 3, w, h)

    local final_bg = {bg_color[1], bg_color[2], bg_color[3]}
    if is_over then
        final_bg[1] = math.min(1, final_bg[1] + 0.1)
        final_bg[2] = math.min(1, final_bg[2] + 0.1)
        final_bg[3] = math.min(1, final_bg[3] + 0.1)
    end
    
    love.graphics.setColor(final_bg[1], final_bg[2], final_bg[3], enabled and 1 or 0.25)
    love.graphics.rectangle("fill", x, y, w, h)
    
    love.graphics.setColor(border_color[1], border_color[2], border_color[3], enabled and 1 or 0.2)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h)

    love.graphics.setFont(UI.fonts.button)
    love.graphics.setColor(1, 1, 1, enabled and (is_over and 1 or 0.85) or 0.3)
    
    -- Безопасный перенос строк внутри кнопки
    local lines = {}
    for s in string.gmatch(text, "[^\n]+") do
        table.insert(lines, s)
    end
    
    local total_h = #lines * 18
    local start_y = y + (h - total_h) / 2
    for i, line in ipairs(lines) do
        love.graphics.printf(line, x, start_y + (i - 1) * 18, w, "center")
    end

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
        scale = 1 + math.abs(math.sin(breathing_angle)) * 0.04
    end

    local nw = w * scale
    local nh = h * scale
    local nx = x - (nw - w) / 2
    local ny = y - (nh - h) / 2
    return UI.button(id, text, nx, ny, nw, nh, bg_color, border_color, enabled and can_afford)
end

function UI.draw_progress_bar(x, y, w, h, progress)
    love.graphics.setColor(0.08, 0.08, 0.08, 1)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(0.25, 0.45, 0.25, 1) -- Брутальный темно-зеленый
    love.graphics.rectangle("fill", x + 2, y + 2, (w - 4) * progress, h - 4)
    love.graphics.setColor(1, 1, 1, 0.35)
    love.graphics.rectangle("line", x, y, w, h)
end

function UI.draw_modal(title, message, buttons)
    local sw, sh = love.graphics.getDimensions()
    love.graphics.setColor(0, 0, 0, 0.75)
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
            {0.2, 0.2, 0.2}, {1, 1, 1}) then
            result = btn.id
        end
    end

    return result
end

function UI.draw_overlay_frame(title, w, h, draw_content)
    local sw, sh = love.graphics.getDimensions()
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", 0, 0, sw, sh)

    local x, y = (sw - w) / 2, (sh - h) / 2
    UI.draw_panel(x, y, w, h, {0.09, 0.09, 0.09, 1})
    UI.draw_label(title, x + 16, y + 12, UI.fonts.button)

    draw_content(x, y, w, h)
    return x, y, w, h
end

function UI.toggle_button(id, text, x, y, w, h, active)
    local bg = active and {0.08, 0.25, 0.08} or {0.15, 0.15, 0.15}
    local border = active and {0.2, 0.8, 0.2} or {0.4, 0.4, 0.4}
    if UI.button(id, text, x, y, w, h, bg, border) then
        return true
    end
    return false
end

function UI.draw_notifications(notifications)
    local sw = love.graphics.getDimensions()
    local y = 80
    for i = #notifications, 1, -1 do
        local note = notifications[i]
        local alpha = math.min(1, note.life / (note.max_life * 0.3))
        local text_w = UI.fonts.main:getWidth(note.text) + 24
        local nx = sw - text_w - 16
        love.graphics.setColor(0.08, 0.12, 0.08, 0.9 * alpha)
        love.graphics.rectangle("fill", nx, y, text_w, 28, 4, 4)
        love.graphics.setColor(0.3, 0.9, 0.3, 0.7 * alpha)
        love.graphics.rectangle("line", nx, y, text_w, 28, 4, 4)
        UI.draw_label(note.text, nx + 12, y + 6, UI.fonts.main, {0.9, 1, 0.9, alpha})
        y = y + 34
    end
end

function UI.format_money(value)
    return Format.money(value)
end

return UI