local ItemsData = require("src.logic.items")
local MutationsData = require("src.logic.mutations")
local Mechanics = require("src.logic.mechanics")
local Visuals = require("src.utils.visuals")
local Player = require("src.logic.player")

local last_roll = nil
local images = {}

function love.load()
    -- Загрузка картинок (уже есть)
    for _, item in ipairs(ItemsData.flat) do
        images[item.id] = love.graphics.newImage("assets/images/items/" .. item.img)
    end
    -- Создадим белый круг для ауры (или загрузи свой png ауры)
    -- images.aura = love.graphics.newImage("assets/images/aura.png")
end

function love.update(dt)
    Visuals.update(dt)
end

function love.draw()
    Visuals.apply_shake() -- Применяем тряску ко всему экрану
    
    love.graphics.print("Money: " .. Player.money .. " | Level: " .. Player.level, 20, 20)
    love.graphics.print("Press SPACE to ROLL", 20, 40)

    if last_roll then
        local item = last_roll.item
        local mut = last_roll.mut
        
        -- 1. Рисуем ауру (если мутация не "none")
        if mut.id ~= "none" then
            local color = Visuals.colors[mut.id] or {1,1,1,1}
            love.graphics.setColor(color)
            -- Рисуем светящийся круг за предметом
            love.graphics.circle("fill", 400, 300, 70 + math.sin(love.timer.getTime()*5)*10)
        end
        
        -- 2. Рисуем сам предмет
        love.graphics.setColor(1, 1, 1, 1)
        if images[item.id] then
            love.graphics.draw(images[item.id], 400, 300, 0, 2, 2, 16, 16)
        end
        
        -- 3. Текст
        love.graphics.printf(mut.name .. " " .. item.name, 0, 400, 800, "center")
        love.graphics.printf("Value: " .. math.floor(item.value * mut.multiplier), 0, 430, 800, "center")
    end
end

function love.keypressed(key)
    if key == "space" then
        local item = Mechanics.roll_item(ItemsData.flat, Player.luck_upgrades, 1, 1)
        local mut = Mechanics.roll_mutation(MutationsData, false)
        
        last_roll = {item = item, mut = mut}
        Player.award_xp(item, mut)

        -- Если выпало что-то крутое (Epic и выше) — трясем экран!
        if item.rarity == "epic" or item.rarity == "legendary" or item.rarity == "mythic" or item.rarity == "unbelievable" then
            Visuals.shake(0.5, 10)
        end
    end
end