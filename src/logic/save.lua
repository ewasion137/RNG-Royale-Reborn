local Constants = require("src.logic.constants")
local Player = require("src.logic.player")
local json = require("src.utils.json")

local Save = {}

local SAVE_FILE = "save.json"

local function to_save_data(player)
    return {
        Money = player.money,
        Upgrades = {
            Luck = {
                Name = player.upgrades.Luck.name,
                Level = player.upgrades.Luck.level,
                MaxLevel = player.upgrades.Luck.max_level,
                BaseCost = player.upgrades.Luck.base_cost,
            },
            FasterRoll = {
                Name = player.upgrades.FasterRoll.name,
                Level = player.upgrades.FasterRoll.level,
                MaxLevel = player.upgrades.FasterRoll.max_level,
                BaseCost = player.upgrades.FasterRoll.base_cost,
            },
            SellValue = {
                Name = player.upgrades.SellValue.name,
                Level = player.upgrades.SellValue.level,
                MaxLevel = player.upgrades.SellValue.max_level,
                BaseCost = player.upgrades.SellValue.base_cost,
            },
            AutoRoll = {
                Name = player.upgrades.AutoRoll.name,
                Level = player.upgrades.AutoRoll.level,
                MaxLevel = player.upgrades.AutoRoll.max_level,
                BaseCost = player.upgrades.AutoRoll.base_cost,
            },
        },
        Inventory = player.inventory,
        DiscoveredMaterials = player.discovered_materials,
        DiscoveredMutations = player.discovered_mutations,
        TotalRolls = player.total_rolls,
        ActiveEffects = (function()
            local list = {}
            for _, effect in ipairs(player.active_effects) do
                table.insert(list, {
                    EffectType = effect.effect_type,
                    Multiplier = effect.multiplier,
                    TimeRemainingSeconds = effect.time_remaining,
                })
            end
            return list
        end)(),
        PotionInventory = player.potion_inventory,
        PrestigeLevel = player.prestige_level,
        Level = player.level,
        CurrentXP = player.current_xp,
        RequiredXP = player.required_xp,
        Stats = {
            TotalRollsAllTime = player.stats.total_rolls_all_time,
            TotalMoneyEarned = player.stats.total_money_earned,
            TotalXPEarned = player.stats.total_xp_earned,
            MaterialsFound = player.stats.materials_found,
            MutationsGotten = player.stats.mutations_gotten,
            PotionsUsed = player.stats.potions_used,
            HighestItemValue = player.stats.highest_item_value,
            HighestItemName = player.stats.highest_item_name,
        },
    }
end

local function from_save_data(data)
    local player = Player.new()

    player.money = data.Money or 0
    player.inventory = data.Inventory or {}
    player.discovered_materials = data.DiscoveredMaterials or {}
    player.discovered_mutations = data.DiscoveredMutations or {}
    player.total_rolls = data.TotalRolls or 0
    player.potion_inventory = data.PotionInventory or {}
    player.prestige_level = data.PrestigeLevel or 0
    player.level = data.Level or 1
    player.current_xp = data.CurrentXP or 0
    player.required_xp = data.RequiredXP or 100

    if data.Upgrades then
        for key, upgrade in pairs(data.Upgrades) do
            if player.upgrades[key] then
                player.upgrades[key].level = upgrade.Level or 0
            end
        end
    end

    if data.ActiveEffects then
        player.active_effects = {}
        for _, effect in ipairs(data.ActiveEffects) do
            table.insert(player.active_effects, {
                effect_type = effect.EffectType,
                multiplier = effect.Multiplier,
                time_remaining = effect.TimeRemainingSeconds,
            })
        end
    end

    if data.Stats then
        player.stats.total_rolls_all_time = data.Stats.TotalRollsAllTime or 0
        player.stats.total_money_earned = data.Stats.TotalMoneyEarned or 0
        player.stats.total_xp_earned = data.Stats.TotalXPEarned or 0
        player.stats.materials_found = data.Stats.MaterialsFound or {}
        player.stats.mutations_gotten = data.Stats.MutationsGotten or {}
        player.stats.potions_used = data.Stats.PotionsUsed or {}
        player.stats.highest_item_value = data.Stats.HighestItemValue or 0
        player.stats.highest_item_name = data.Stats.HighestItemName or "None"
    end

    return player
end

function Save.load()
    if not love.filesystem.getInfo(SAVE_FILE) then
        return Player.new(), true
    end

    local ok, result = pcall(function()
        local encoded = love.filesystem.read(SAVE_FILE)
        local decoded = love.data.decode("string", "base64", encoded)
        local save_file = json.decode(decoded)

        local expected_hash = love.data.hash("sha256", save_file.GameDataJson .. Constants.SAVE_SECRET_KEY)
        if save_file.Hash ~= expected_hash then
            error("hash mismatch")
        end

        local data = json.decode(save_file.GameDataJson)
        return from_save_data(data)
    end)

    if ok then
        return result, true
    end
    return Player.new(), false
end

function Save.save(player)
    local game_data_json = json.encode(to_save_data(player))
    local hash = love.data.hash("sha256", game_data_json .. Constants.SAVE_SECRET_KEY)
    local save_file = json.encode({
        GameDataJson = game_data_json,
        Hash = hash,
    })
    local encoded = love.data.encode("string", "base64", save_file)
    local written = love.filesystem.write(SAVE_FILE, encoded)
    if not written then
        error("failed to write save file")
    end
end

function Save.delete()
    if love.filesystem.getInfo(SAVE_FILE) then
        love.filesystem.remove(SAVE_FILE)
    end
end

return Save
