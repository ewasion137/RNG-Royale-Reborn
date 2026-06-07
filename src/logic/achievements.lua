local Achievements = {}

Achievements.list = {
    {
        id = "first_roll",
        title = "First Steps",
        description = "Make your first roll",
        reward_money = 50,
        check = function(p) return p.total_rolls >= 1 end,
    },
    {
        id = "rolls_100",
        title = "Century Roller",
        description = "Roll 100 times",
        reward_money = 5000,
        check = function(p) return p.stats.total_rolls_all_time >= 100 end,
    },
    {
        id = "rolls_1000",
        title = "Roll Addict",
        description = "Roll 1,000 times",
        reward_money = 50000,
        check = function(p) return p.stats.total_rolls_all_time >= 1000 end,
    },
    {
        id = "rolls_10000",
        title = "RNG Machine",
        description = "Roll 10,000 times",
        reward_money = 500000,
        check = function(p) return p.stats.total_rolls_all_time >= 10000 end,
    },
    {
        id = "money_1m",
        title = "Millionaire",
        description = "Earn 1,000,000$ total",
        reward_money = 10000,
        check = function(p) return p.stats.total_money_earned >= 1000000 end,
    },
    {
        id = "money_1b",
        title = "Billionaire",
        description = "Earn 1,000,000,000$ total",
        reward_money = 1000000,
        check = function(p) return p.stats.total_money_earned >= 1000000000 end,
    },
    {
        id = "level_10",
        title = "Rising Star",
        description = "Reach level 10",
        reward_money = 25000,
        check = function(p) return p.level >= 10 end,
    },
    {
        id = "level_25",
        title = "Veteran",
        description = "Reach level 25",
        reward_money = 100000,
        check = function(p) return p.level >= 25 end,
    },
    {
        id = "prestige_1",
        title = "Reborn",
        description = "Prestige for the first time",
        reward_money = 500000,
        check = function(p) return p.prestige_level >= 1 end,
    },
    {
        id = "prestige_5",
        title = "Ascended",
        description = "Reach prestige level 5",
        reward_money = 5000000,
        check = function(p) return p.prestige_level >= 5 end,
    },
    {
        id = "mutation_first",
        title = "Mutated",
        description = "Get any mutation",
        check = function(p)
            for name, count in pairs(p.stats.mutations_gotten) do
                if count > 0 then return true end
            end
            return false
        end,
        reward_money = 10000,
    },
    {
        id = "mutation_prismatic",
        title = "Rainbow Luck",
        description = "Get a Prismatic mutation",
        reward_money = 1000000,
        check = function(p) return (p.stats.mutations_gotten["Prismatic"] or 0) > 0 end,
    },
    {
        id = "discover_all_common",
        title = "Common Collector",
        description = "Discover all common materials",
        reward_money = 5000,
        check = function(p)
            local needed = { "Coal", "Copper", "Iron", "Pyrite" }
            for _, name in ipairs(needed) do
                local found = false
                for _, d in ipairs(p.discovered_materials) do
                    if d == name then found = true break end
                end
                if not found then return false end
            end
            return true
        end,
    },
    {
        id = "discover_unbelievable",
        title = "Cosmic Find",
        description = "Discover an unbelievable material",
        reward_money = 10000000,
        check = function(p)
            local unbelievable = { "Meteorite Iron", "Starlight", "Cosmic Dust" }
            for _, name in ipairs(unbelievable) do
                for _, d in ipairs(p.discovered_materials) do
                    if d == name then return true end
                end
            end
            return false
        end,
    },
    {
        id = "luck_50",
        title = "Lucky Charm",
        description = "Reach luck level 50",
        reward_money = 250000,
        check = function(p) return p.upgrades.Luck.level >= 50 end,
    },
    {
        id = "auto_roll_max",
        title = "Full Automation",
        description = "Max out Auto Roll",
        reward_money = 10000000,
        check = function(p) return p.upgrades.AutoRoll.level >= p.upgrades.AutoRoll.max_level end,
    },
    {
        id = "inventory_100",
        title = "Hoarder",
        description = "Hold 100+ items in inventory",
        reward_money = 50000,
        check = function(p)
            local total = 0
            for _, count in pairs(p.inventory) do
                total = total + count
            end
            return total >= 100
        end,
    },
    {
        id = "potion_user",
        title = "Alchemist",
        description = "Use 10 potions",
        reward_money = 100000,
        check = function(p)
            local total = 0
            for _, count in pairs(p.stats.potions_used) do
                total = total + count
            end
            return total >= 10
        end,
    },
}

function Achievements.is_unlocked(player, id)
    return player.achievements[id] == true
end

function Achievements.check_all(player)
    local newly_unlocked = {}
    for _, achievement in ipairs(Achievements.list) do
        if not Achievements.is_unlocked(player, achievement.id) then
            if achievement.check(player) then
                player.achievements[achievement.id] = true
                if achievement.reward_money and achievement.reward_money > 0 then
                    player.money = player.money + achievement.reward_money
                    player.stats.total_money_earned = player.stats.total_money_earned + achievement.reward_money
                end
                table.insert(newly_unlocked, achievement)
            end
        end
    end
    return newly_unlocked
end

function Achievements.count_unlocked(player)
    local count = 0
    for _, achievement in ipairs(Achievements.list) do
        if Achievements.is_unlocked(player, achievement.id) then
            count = count + 1
        end
    end
    return count
end

function Achievements.rarity_label(rarity)
    return rarity:upper()
end

Achievements.RARITY_COLORS = {
    common = {0.7, 0.7, 0.7},
    uncommon = {0.3, 0.9, 0.3},
    rare = {0.3, 0.5, 1},
    epic = {0.7, 0.3, 1},
    legendary = {1, 0.6, 0},
    mythic = {1, 0.2, 0.4},
    unbelievable = {1, 0, 1},
}

return Achievements
