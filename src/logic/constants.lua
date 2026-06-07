return {
    SAVE_SECRET_KEY = "FH98043CUR2MNOAPWJIERFHCGKBDTKYKSPWEOGA111",

    PRESTIGE_BASE_LEVEL_REQ = 25,
    PRESTIGE_SELL_VALUE_BONUS = 0.15,
    PRESTIGE_LUCK_BONUS = 0.10,
    PRESTIGE_XP_BONUS = 0.10,

    XP_LEVEL_MULTIPLIER_NUMERATOR = 15,
    XP_LEVEL_MULTIPLIER_DENOMINATOR = 10,

    AUTOROLL_BASE_COOLDOWN_SEC = 30.0,
    AUTOROLL_REDUCTION_PER_LEVEL_SEC = 0.5,

    MAX_ROLL_TIME_MS = 5000,
    ROLL_TIME_REDUCTION_PER_LEVEL_MS = 200,

    POTION_GLOBAL_TIME_LIMIT_SEC = 86400,

    RARITY_ORDER = {
        common = 0,
        uncommon = 1,
        rare = 2,
        epic = 3,
        legendary = 4,
        mythic = 5,
        unbelievable = 6,
    },

    RARITY_SOUNDS = {
        common = "common_uncommon.wav",
        uncommon = "common_uncommon.wav",
        rare = "rare.wav",
        epic = "epic.wav",
        legendary = "legendary.wav",
        mythic = "mythic.wav",
        unbelievable = "unbelivable.wav",
    },

    MUTATION_SOUNDS = {
        Glowing = "overlapping-mutation-glowing.wav",
        Scorching = "overlapping-mutation-scorching.wav",
        Iridescent = "overlapping-mutation_iridescent.wav",
        Radioactive = "overlapping-mutation_radioactive.wav",
        Prismatic = "overlapping-mutation_prismatic.wav",
    },

    MUTATION_COLORS = {
        ["Ничего"] = {0.6, 0.6, 0.6},
        Glowing = {0.96, 0.96, 0.96},
        Scorching = {1, 0.27, 0},
        Iridescent = {1, 1, 0},
        Radioactive = {0.2, 1, 0.2},
        Prismatic = {0.5, 0, 1},
    },

    MUTATION_ORDER = {
        ["Ничего"] = 0,
        Glowing = 1,
        Scorching = 2,
        Iridescent = 3,
        Radioactive = 4,
        Prismatic = 5,
    },
}
