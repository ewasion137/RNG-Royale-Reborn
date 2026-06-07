local Game = require("src.game")
local GameScreen = require("src.ui.game_screen")
local UI = require("src.ui.components")
local Visuals = require("src.utils.visuals")

function love.load()
    love.math.setRandomSeed(os.time())
    UI.load()
    Game.load()
end

function love.update(dt)
    Visuals.update(dt)
    Game.update(dt)
end

function love.draw()
    GameScreen.draw(Game)
end

function love.keypressed(key)
    Game.keypressed(key)
end

function love.wheelmoved(x, y)
    Game.wheelmoved(x, y)
end

function love.quit()
    Game.quit()
end
