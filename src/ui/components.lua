local UI = {}

-- Загружаем шрифты (размеры из твоего дизайнера)
UI.fonts = {
    main = love.graphics.newFont("assets/fonts/vstr.ttf", 14),
    button = love.graphics.newFont("assets/fonts/vstr.ttf", 20),
    title = love.graphics.newFont("assets/fonts/vstr.ttf", 36),
    huge = love.graphics.newFont("assets/fonts/vstr.ttf", 72)
}

function UI.drawGroupBox(text, x, y, w, h)
    love.graphics.setFont(UI.fonts.main)
    love.graphics.setColor(1, 1, 1, 0.3) -- Полупрозрачная рамка
    love.graphics.rectangle("line", x, y, w, h)
    
    -- Рисуем текст сверху рамки (как в WinForms)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(text, x + 10, y - 10)
end

function UI.button(text, x, y, w, h, bgColor, borderColor)
    local mx, my = love.mouse.getPosition()
    local isOver = mx >= x and mx <= x + w and my >= y and my <= y + h
    
    -- Фон
    love.graphics.setColor(bgColor)
    love.graphics.rectangle("fill", x, y, w, h)
    
    -- Граница
    love.graphics.setColor(borderColor)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h)
    
    -- Текст по центру
    love.graphics.setFont(UI.fonts.button)
    love.graphics.setColor(1, 1, 1, isOver and 1 or 0.8)
    love.graphics.printf(text, x, y + (h/2 - 10), w, "center")
    
    return isOver and love.mouse.isDown(1)
end

return UI