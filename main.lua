local UI = require("src.ui.components")

function love.draw()
    -- Устанавливаем фон (25, 25, 25)
    love.graphics.clear(25/255, 25/255, 25/255)

    -- 1. Групбокс Upgrades (12, 12, 375, 315)
    UI.drawGroupBox("Upgrades", 12, 12, 375, 315)
    
    -- Кнопка LUCK (9, 20) внутри группы -> (12+9, 12+20)
    if UI.button("+LUCK", 21, 32, 166, 90, {64/255, 64/255, 0}, {1, 1, 0}) then
        -- Логика покупки
    end
    
    -- Кнопка Faster Roll (195, 20) -> (12+195, 12+20)
    UI.button("Faster Roll", 207, 32, 171, 90, {0, 64/255, 64/255}, {0, 1, 1})

    -- 2. Групбокс Play (397, 12, 375, 315)
    UI.drawGroupBox("Play", 397, 12, 375, 315)
    
    -- Кнопка Roll (26, 20)
    if UI.button("Roll", 397+26, 12+20, 116, 52, {64/255, 64/255, 64/255}, {1, 1, 1}) then
        -- Логика ролла
    end

    -- 3. XP Progress Bar (11, 333, 761, 36)
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 11, 333, 761, 36) -- Фон бара
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 11, 333, 761, 36) -- Рамка бара
    -- Отрисовка заполнения (пример 50%)
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.rectangle("fill", 11, 333, 761 * 0.5, 36)

    -- 4. Групбокс Inventory (12, 396, 760, 230)
    UI.drawGroupBox("Inventory", 12, 396, 760, 230)

    -- 5. Нижние кнопки (Store, Settings и т.д.)
    UI.button("Store", 471, 632, 146, 46, {64/255, 64/255, 64/255}, {1, 1, 1})
    UI.button("Settings", 623, 632, 148, 46, {64/255, 64/255, 64/255}, {1, 1, 1})
end