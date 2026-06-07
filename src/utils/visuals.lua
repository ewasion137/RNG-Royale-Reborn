-- src/utils/visuals.lua
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
local flash_time = 0
local flash_color = {1, 1, 1, 1}

Visuals.particles = {}

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

function Visuals.flash(duration, color)
    flash_time = duration
    flash_color = color or {1, 1, 1, 1}
end

function Visuals.spawn_particles(x, y, color, count)
    count = count or 15
    color = color or {1, 1, 1, 1}
    for i = 1, count do
        local angle = math.random() * math.pi * 2
        local speed = math.random(80, 240)
        table.insert(Visuals.particles, {
            x = x,
            y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed - math.random(40, 100),
            color = {color[1], color[2], color[3], color[4] or 1},
            size = math.random(4, 8),
            life = math.random(0.4, 1.2),
            max_life = 1.2,
            gravity = math.random(200, 350)
        })
    end
end

function Visuals.update(dt)
    if shake_time > 0 then
        shake_time = shake_time - dt
    else
        shake_intensity = 0
    end

    if flash_time > 0 then
        flash_time = flash_time - dt
    end

    -- Обновление частиц
    for i = #Visuals.particles, 1, -1 do
        local p = Visuals.particles[i]
        p.life = p.life - dt
        if p.life <= 0 then
            table.remove(Visuals.particles, i)
        else
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
            p.vy = p.vy + p.gravity * dt
        end
    end
end

function Visuals.apply_shake()
    if shake_time > 0 then
        local dx = math.random(-shake_intensity, shake_intensity)
        local dy = math.random(-shake_intensity, shake_intensity)
        love.graphics.translate(dx, dy)
    end
end

function Visuals.draw_flash()
    if flash_time > 0 then
        love.graphics.setColor(flash_color[1], flash_color[2], flash_color[3], flash_time * 0.75)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function Visuals.draw_particles()
    for _, p in ipairs(Visuals.particles) do
        local alpha = p.life / p.max_life
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], (p.color[4] or 1) * alpha)
        love.graphics.rectangle("fill", p.x, p.y, p.size, p.size)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function Visuals.draw_mutation_aura(image, mutation_name, dynamic_color, x, y, w, h)
    local img_w, img_h = image:getWidth(), image:getHeight()
    local scale = math.min(w / img_w, h / img_h) * 0.85
    local draw_w = img_w * scale
    local draw_h = img_h * scale
    local draw_x = x + (w - draw_w) / 2
    local draw_y = y + (h - draw_h) / 2

    if mutation_name == "Ничего" then
        love.graphics.draw(image, draw_x, draw_y, 0, scale, scale)
        return
    end

    local aura_color
    if mutation_name == "Prismatic" and dynamic_color then
        aura_color = {dynamic_color[1], dynamic_color[2], dynamic_color[3], 0.7}
    else
        aura_color = Visuals.colors[mutation_name]
    end

    if not aura_color then
        love.graphics.draw(image, draw_x, draw_y, 0, scale, scale)
        return
    end

    local cx = draw_x + draw_w / 2
    local cy = draw_y + draw_h / 2
    
    -- Брутальная анимированная аура
    local pulse = 1 + math.sin(love.timer.getTime() * 12) * 0.15
    love.graphics.setColor(aura_color[1], aura_color[2], aura_color[3], aura_color[4] * 0.4)
    love.graphics.ellipse("fill", cx, cy, draw_w * 0.85 * pulse, draw_h * 0.85 * pulse)
    
    love.graphics.setColor(aura_color[1], aura_color[2], aura_color[3], aura_color[4])
    love.graphics.ellipse("fill", cx, cy, draw_w * 0.62, draw_h * 0.62)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(image, draw_x, draw_y, 0, scale, scale)
end

return Visuals