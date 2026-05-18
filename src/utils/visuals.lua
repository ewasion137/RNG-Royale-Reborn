local Visuals = {}

Visuals.colors = {
    glowing = {1, 1, 1, 0.7},           -- Белый
    scorching = {1, 0.2, 0, 0.6},       -- Оранжево-красный
    iridescent = {1, 1, 0, 0.6},        -- Желтый
    radioactive = {0.4, 1, 0.4, 0.7},   -- Зеленый
    prismatic = {1, 0, 1, 0.7}          -- Пурпурный (будем менять динамически)
}

-- Система тряски
local shake_time = 0
local shake_intensity = 0

function Visuals.shake(duration, intensity)
    shake_time = duration
    shake_intensity = intensity
end

function Visuals.update(dt)
    if shake_time > 0 then
        shake_time = shake_time - dt
    else
        shake_intensity = 0
    end
end

function Visuals.apply_shake()
    if shake_time > 0 then
        local dx = math.random(-shake_intensity, shake_intensity)
        local dy = math.random(-shake_intensity, shake_intensity)
        love.graphics.translate(dx, dy)
    end
end

return Visuals