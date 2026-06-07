local Upgrades = {}

local function apply_cost_multiplier(cost, key)
    if key == "SellValue" then
        return cost * 2
    elseif key == "FasterRoll" then
        return cost * 3
    else
        return math.floor((cost * 3) / 2)
    end
end

function Upgrades.create_defaults()
    return {
        Luck = { key = "Luck", name = "Luck", level = 0, max_level = 200, base_cost = 10 },
        FasterRoll = { key = "FasterRoll", name = "Faster Roll", level = 0, max_level = 24, base_cost = 20 },
        SellValue = { key = "SellValue", name = "Sell Value Boost", level = 0, max_level = 10, base_cost = 250 },
        AutoRoll = { key = "AutoRoll", name = "Auto Roll", level = 0, max_level = 59, base_cost = 5000 },
    }
end

function Upgrades.get_current_cost(upgrade)
    if upgrade.level >= upgrade.max_level then
        return -1
    end

    local cost = upgrade.base_cost
    for _ = 1, upgrade.level do
        cost = apply_cost_multiplier(cost, upgrade.key)
    end
    return cost
end

function Upgrades.get_roll_time_ms(faster_roll_level)
    local roll_time = 5000 - (faster_roll_level * 200)
    return math.max(roll_time, 100)
end

function Upgrades.get_auto_roll_speed(auto_roll_level)
    if auto_roll_level <= 0 then
        return 0
    end
    return 30.0 - (auto_roll_level * 0.5)
end

return Upgrades
