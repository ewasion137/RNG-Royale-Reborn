using System.Collections.Generic;
using System.Numerics;

namespace RNGGame
{
    public class PlayerStats
    {
        public BigInteger TotalRollsAllTime { get; set; } = 0;
        public BigInteger TotalMoneyEarned { get; set; } = 0;
        public BigInteger TotalXPEarned { get; set; } = 0;

        // Статистика предметов
        public Dictionary<string, int> MaterialsFound { get; set; } = new Dictionary<string, int>();
        public Dictionary<string, int> MutationsGotten { get; set; } = new Dictionary<string, int>();

        // Статистика зелий
        public Dictionary<string, int> PotionsUsed { get; set; } = new Dictionary<string, int>();

        // Рекорды
        public BigInteger HighestItemValue { get; set; } = 0;
        public string HighestItemName { get; set; } = "None";
    }
}