namespace RNGGame
{
    public static class GameConstants
    {
        // Секретный ключ для сохранения
        public const string SAVE_SECRET_KEY = "FH98043CUR2MNOAPWJIERFHCGKBDTKYKSPWEOGA111";

        // Престиж
        public const int PRESTIGE_BASE_LEVEL_REQ = 25;
        public const double PRESTIGE_SELL_VALUE_BONUS = 0.15; // +15%
        public const double PRESTIGE_LUCK_BONUS = 0.10;       // +10%
        public const double PRESTIGE_XP_BONUS = 0.10;         // +10%

        // Прокачка XP
        public const int XP_LEVEL_MULTIPLIER_NUMERATOR = 15;   // Числитель для x1.5
        public const int XP_LEVEL_MULTIPLIER_DENOMINATOR = 10; // Знаменатель для x1.5

        // Авто-ролл
        public const float AUTOROLL_BASE_COOLDOWN_SEC = 30.0f;
        public const float AUTOROLL_REDUCTION_PER_LEVEL_SEC = 0.5f;

        // Ролл
        public const int MAX_ROLL_TIME_MS = 5000;
        public const int ROLL_TIME_REDUCTION_PER_LEVEL_MS = 200;

        // Зелья
        public const int POTION_GLOBAL_TIME_LIMIT_SEC = 86400; // 24 часа
    }
}