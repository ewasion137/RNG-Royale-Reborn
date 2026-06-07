using Newtonsoft.Json;
using System.Collections.Generic;
using System.Numerics;

namespace RNGGame
{
    public class PlayerData
    {
        public BigInteger Money { get; set; }
        public Dictionary<string, Upgrade> Upgrades { get; set; }
        public Dictionary<string, int> Inventory { get; set; }
        public HashSet<string> DiscoveredMaterials { get; set; }
        public HashSet<string> DiscoveredMutations { get; set; }
        public BigInteger TotalRolls { get; set; }
        public List<ActiveEffect> ActiveEffects { get; set; }
        public Dictionary<string, int> PotionInventory { get; set; }

        // <<< НОВЫЕ ПОЛЯ ДЛЯ ПРЕСТИЖА И УРОВНЕЙ >>>
        public int PrestigeLevel { get; set; }
        public int Level { get; set; }
        public BigInteger CurrentXP { get; set; }
        public BigInteger RequiredXP { get; set; }

        public PlayerStats Stats { get; set; }
        // Конструктор для создания "чистого" сохранения
        public PlayerData()
        {
            Money = 0;
            TotalRolls = 0;
            Upgrades = new Dictionary<string, Upgrade>
            {
                { "Luck", new Upgrade { Name = "Luck", Level = 0, MaxLevel = 200, BaseCost = 10, CostMultiplier = 1.5 } },
                { "FasterRoll", new Upgrade { Name = "Faster Roll", Level = 0, MaxLevel = 24, BaseCost = 20, CostMultiplier = 3 } },
                { "SellValue", new Upgrade { Name = "Sell Value Boost", Level = 0, MaxLevel = 10, BaseCost = 250, CostMultiplier = 2 } },
                { "AutoRoll", new Upgrade { Name = "Auto Roll", Level = 0, MaxLevel = 59, BaseCost = 5000, CostMultiplier = 1.5 } }
            };
            Inventory = new Dictionary<string, int>();
            DiscoveredMaterials = new HashSet<string>();
            DiscoveredMutations = new HashSet<string>();
            PotionInventory = new Dictionary<string, int>();
            ActiveEffects = new List<ActiveEffect>();

            // <<< ИНИЦИАЛИЗАЦИЯ НОВЫХ ПОЛЕЙ >>>
            PrestigeLevel = 0;
            Level = 1;
            CurrentXP = 0;
            RequiredXP = 100; // Начинаем со 100 XP для 2-го уровня
            Stats = new PlayerStats();
        }
    }
}