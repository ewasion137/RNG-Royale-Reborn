local Player = {
    money = 0,
    level = 1,
    xp = 0,
    req_xp = 100,
    prestige = 0,
    luck_upgrades = 0,
    -- Инвентарь: ключ = "item_id:mutation_id", значение = количество
    inventory = {} 
}

function Player.award_xp(item, mutation)
    local base_xp = (item.value * 2.5 - 2) + (mutation.multiplier * 50)
    
    -- Бонусы престижа (как в твоем GameConstants.cs)
    local prestige_bonus = 1 + (Player.prestige * 0.10)
    local total_xp = math.floor(base_xp * prestige_bonus)
    
    Player.xp = Player.xp + total_xp
    
    -- Level up logic
    while Player.xp >= Player.req_xp do
        Player.xp = Player.xp - Player.req_xp
        Player.level = Player.level + 1
        Player.req_xp = math.floor(Player.req_xp * 1.5)
        print("LEVEL UP! Current level: " .. Player.level)
    end
end

return Player