local Visuals = {}

Visuals.colors = {
    Glowing = {1, 1, 1, 0.7},
    Scorching = {1, 0.2, 0, 0.6},
    Iridescent = {1, 1, 0, 0.6},
    Radioactive = {0.4, 1, 0.4, 0.7},
    Prismatic = {1, 0, 1, 0.7},
}

local shake_time = 0
local shake_intensity = 0

function Visuals.color_from_hsv(hue, saturation, value)
    local hi = math.floor(hue / 60) % 6
    local f = hue / 60 - math.floor(hue / 60)
    value = value * 255
    local v = math.floor(value)
    local p = math.floor(value * (1 - saturation))
    local q = math.floor(value * (1 - f * saturation))
    local t = math.floor(value * (1 - (1 - f) * saturation))

    if hi == 0 then return v / 255, t / 255, p / 255
    elseif hi == 1 then return q / 255, v / 255, p / 255
    elseif hi == 2 then return p / 255, v / 255, t / 255
    elseif hi == 3 then return p / 255, q / 255, v / 255
    elseif hi == 4 then return t / 255, p / 255, v / 255
    end
    return v / 255, p / 255, q / 255
end

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

function Visuals.draw_mutation_aura(image, mutation_name, dynamic_color, x, y, scale)
    scale = scale or 1
    local w = image:getWidth() * scale
    local h = image:getHeight() * scale
    local padding = 16 * scale

    if mutation_name == "Ничего" then
        love.graphics.draw(image, x, y, 0, scale, scale)
        return
    end

    local aura_color
    if mutation_name == "Prismatic" and dynamic_color then
        aura_color = {dynamic_color[1], dynamic_color[2], dynamic_color[3], 0.7}
    else
        aura_color = Visuals.colors[mutation_name]
    end

    if not aura_color then
        love.graphics.draw(image, x, y, 0, scale, scale)
        return
    end

    love.graphics.setColor(aura_color)
    love.graphics.ellipse("fill", x + w / 2, y + h / 2, (w + padding) / 2, (h + padding) / 2)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(image, x, y, 0, scale, scale)
end

return Visuals
