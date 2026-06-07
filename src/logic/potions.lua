local Potions = {}

Potions.EFFECT = {
    LuckBoost = "LuckBoost",
    MoneyBoost = "MoneyBoost",
    MutationBoost = "MutationBoost",
    DuplicationBoost = "DuplicationBoost",
    WisdomBoost = "WisdomBoost",
}

Potions.catalog = {
    {
        name = "Luck Potion",
        description = "GIVES YOU X2 LUCK ON 30 MINS",
        cost = 350000,
        effect = Potions.EFFECT.LuckBoost,
        multiplier = 2.0,
        duration = 1800,
        image = "potionluck.png",
    },
    {
        name = "Money Potion",
        description = "GIVES YOU X2 MONEY ON 30 MINS",
        cost = 200000,
        effect = Potions.EFFECT.MoneyBoost,
        multiplier = 2.0,
        duration = 1800,
        image = "potionmoney.png",
    },
    {
        name = "Mutation Potion",
        description = "GUARANTEED ANY MUTATION WITHIN 5 MINUTES",
        cost = 250000000,
        effect = Potions.EFFECT.MutationBoost,
        multiplier = 1.0,
        duration = 300,
        image = "potionmutation.png",
    },
    {
        name = "Duplication Potion",
        description = "HAVE 20% CHANCE TO DUPLICATE OBJECT",
        cost = 100000000,
        effect = Potions.EFFECT.DuplicationBoost,
        multiplier = 0.2,
        duration = 60,
        image = "potiondublication.png",
    },
    {
        name = "Potion of Wisdom",
        description = "INCREASES XP GAIN BY 1.5X FOR 10 MINS",
        cost = 500000,
        effect = Potions.EFFECT.WisdomBoost,
        multiplier = 1.5,
        duration = 600,
        image = "potionwisdom.png",
    },
}

function Potions.find_by_name(name)
    for _, potion in ipairs(Potions.catalog) do
        if potion.name == name then
            return potion
        end
    end
end

return Potions
