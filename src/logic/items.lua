local items = {
    -- --- Common ---
    common = {
        { id = "coal", name = "Coal", value = 2, chance = 50, img = "coal.png" },
        { id = "copper", name = "Copper", value = 5, chance = 25, img = "copper.png" },
        { id = "iron", name = "Iron", value = 20, chance = 15, img = "iron.png" },
        { id = "pyrite", name = "Pyrite", value = 150, chance = 8, img = "pyrite.png" },
    },
    
    -- --- Uncommon ---
    uncommon = {
        { id = "silver", name = "Silver", value = 650, chance = 2.5, img = "silver.png" },
        { id = "gold", name = "Gold", value = 1200, chance = 1.5, img = "gold.png" },
        { id = "platinum", name = "Platinum", value = 500, chance = 0.8, img = "platinum.png" },
        { id = "titanium", name = "Titanium", value = 9000, chance = 0.4, img = "titanium.png" },
    },
    
    -- --- Rare ---
    rare = {
        { id = "quartz", name = "Quartz", value = 100000, chance = 0.05, img = "quartz.png" },
        { id = "pearl", name = "Pearl", value = 500000, chance = 0.02, img = "pearl.png" },
        { id = "obsidian", name = "Obsidian", value = 12000000, chance = 0.01, img = "obsidian.png" },
        { id = "topaz", name = "Topaz", value = 30000000, chance = 0.005, img = "topaz.png" },
        { id = "lapislazuri", name = "Lapis Lazuri", value = 75000000, chance = 0.002, img = "lapislazuri.png" },
    },
    
    -- --- Epic ---
    epic = {
        { id = "diamond", name = "Diamond", value = 250000000, chance = 1e-4, img = "diamond.png" },
        { id = "emerald", name = "Emerald", value = 800000000, chance = 5e-5, img = "emerald.png" },
        { id = "sapphire", name = "Sapphire", value = 2000000000, chance = 2e-5, img = "saphire.png" },
        { id = "ruby", name = "Ruby", value = 5000000000, chance = 1e-5, img = "ruby.png" },
    },
    
    -- --- Legendary ---
    legendary = {
        { id = "palladium", name = "Palladium", value = 15000000000, chance = 5e-7, img = "palladium.png" },
        { id = "iridium", name = "Iridium", value = 50000000000, chance = 2e-7, img = "iridium.png" },
    },
    
    -- --- Mythic ---
    mythic = {
        { id = "tanzanite", name = "Tanzanite", value = 20000000000, chance = 1e-8, img = "tanzanite.png" },
        { id = "amber", name = "Amber", value = 1000000000000, chance = 5e-9, img = "amber.png" },
    },
    
    -- --- UNBELIEVABLE! ---
    unbelievable = {
        { id = "meteoriteiron", name = "Meteorite Iron", value = 10000000000000, chance = 1e-10, img = "meteoriteiron.png" },
        { id = "starlight", name = "Starlight", value = 1500000000000000, chance = 1e-11, img = "starlight.png" },
        { id = "cosmicdust", name = "Cosmic Dust", value = 18446744073709551615, chance = 1e-12, img = "cosmicdust.png" },
    }
}

-- Плоский список для быстрого перебора
local flat_list = {}
for rarity, list in pairs(items) do
    for _, item in ipairs(list) do
        item.rarity = rarity
        table.insert(flat_list, item)
    end
end

return { tree = items, flat = flat_list }