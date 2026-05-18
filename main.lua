-- main.lua
local ItemsData = require("src.logic.items")
local MutationsData = require("src.logic.mutations")
local Mechanics = require("src.logic.mechanics")

local images = {}
local sounds = {}

function love.load()
    -- 1. Загружаем картинки предметов автоматически!
    for _, item in ipairs(ItemsData.flat) do
        local path = "assets/images/items/" .. item.img
        -- Проверяем, существует ли файл, чтобы игра не вылетела
        if love.filesystem.getInfo(path) then
            images[item.id] = love.graphics.newImage(path)
        else
            print("Warning: Image not found for " .. item.id)
        end
    end

    -- 2. Инициализируем игрока
    player = {
        money = 0,
        luck_level = 0,
        inventory = {},
        -- и так далее
    }
    
    print("Game Loaded! Items count: " .. #ItemsData.flat)
end

function love.keypressed(key)
    if key == "space" then
        local item = Mechanics.roll_item(ItemsData.flat, player.luck_level, 1, 1)
        local mut = Mechanics.roll_mutation(MutationsData, false)
        print("You rolled: " .. mut.name .. " " .. item.name .. " Value: " .. (item.value * mut.multiplier))
    end
end

function love.draw()
    love.graphics.print("Press SPACE to ROLL", 10, 10)
    -- Тут будет отрисовка UI
end