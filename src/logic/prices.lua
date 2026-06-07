-- Справочник цен 1:1 с RNGR-OldExample-C#ToLua/RNGGame/GameData.cs
-- sell(sell_lvl, prestige, mutation) = base * floor(mut*100) * floor((1+sell_lvl*0.1)*100) * floor((1+prestige*0.15)*100) / 100^3

local Prices = {}

Prices.materials = {
    { rarity = "Common", name = "Coal", base = 2, chance = 50 },
    { rarity = "Common", name = "Copper", base = 5, chance = 25 },
    { rarity = "Common", name = "Iron", base = 20, chance = 15 },
    { rarity = "Common", name = "Pyrite", base = 150, chance = 8 },
    { rarity = "Uncommon", name = "Silver", base = 650, chance = 2.5 },
    { rarity = "Uncommon", name = "Gold", base = 1200, chance = 1.5 },
    { rarity = "Uncommon", name = "Platinum", base = 500, chance = 0.8 },
    { rarity = "Uncommon", name = "Titanium", base = 9000, chance = 0.4 },
    { rarity = "Rare", name = "Quartz", base = 100000, chance = 0.05 },
    { rarity = "Rare", name = "Pearl", base = 500000, chance = 0.02 },
    { rarity = "Rare", name = "Obsidian", base = 12000000, chance = 0.01 },
    { rarity = "Rare", name = "Topaz", base = 30000000, chance = 0.005 },
    { rarity = "Rare", name = "Lapis Lazuri", base = 75000000, chance = 0.002 },
    { rarity = "Epic", name = "Diamond", base = 250000000, chance = 1e-4 },
    { rarity = "Epic", name = "Emerald", base = 800000000, chance = 5e-5 },
    { rarity = "Epic", name = "Sapphire", base = 2000000000, chance = 2e-5 },
    { rarity = "Epic", name = "Ruby", base = 5000000000, chance = 1e-5 },
    { rarity = "Legendary", name = "Palladium", base = 15000000000, chance = 5e-7 },
    { rarity = "Legendary", name = "Iridium", base = 50000000000, chance = 2e-7 },
    { rarity = "Mythic", name = "Tanzanite", base = 20000000000, chance = 1e-8 },
    { rarity = "Mythic", name = "Amber", base = 1000000000000, chance = 5e-9 },
    { rarity = "Unbelievable", name = "Meteorite Iron", base = 10000000000000, chance = 1e-10 },
    { rarity = "Unbelievable", name = "Starlight", base = 1500000000000000, chance = 1e-11 },
    { rarity = "Unbelievable", name = "Cosmic Dust", base = 18446744073709551615, chance = 1e-12 },
}

Prices.mutations = {
    { name = "Ничего", multiplier = 1.0, chance = 93.495 },
    { name = "Glowing", multiplier = 1.02, chance = 2.0 },
    { name = "Scorching", multiplier = 1.1, chance = 2.0 },
    { name = "Iridescent", multiplier = 1.3, chance = 1.5 },
    { name = "Radioactive", multiplier = 2.0, chance = 1.0 },
    { name = "Prismatic", multiplier = 5.0, chance = 0.05 },
}

Prices.potions = {
    { name = "Luck Potion", cost = 350000 },
    { name = "Money Potion", cost = 200000 },
    { name = "Mutation Potion", cost = 250000000 },
    { name = "Duplication Potion", cost = 100000000 },
    { name = "Potion of Wisdom", cost = 500000 },
}

Prices.upgrades = {
    { key = "Luck", base = 10, max = 200, mult = "x1.5" },
    { key = "FasterRoll", base = 20, max = 24, mult = "x3" },
    { key = "SellValue", base = 250, max = 10, mult = "x2" },
    { key = "AutoRoll", base = 5000, max = 59, mult = "x1.5" },
}

function Prices.sell_value(base, mutation_mult, sell_level, prestige_level)
    local mut = math.floor(mutation_mult * 100)
    local sell = math.floor((1 + sell_level * 0.1) * 100)
    local prestige = math.floor((1 + prestige_level * 0.15) * 100)
    return math.floor(base * mut * sell * prestige / (100 * 100 * 100))
end

return Prices
