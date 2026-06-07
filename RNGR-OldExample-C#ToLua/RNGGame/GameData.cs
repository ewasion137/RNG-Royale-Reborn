using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Numerics;
using System.Windows.Forms;

namespace RNGGame
{
    // Статический класс - "справочник", который не нужно создавать.
    // Он просто существует и хранит данные.
    public static class GameData
    {
        public static List<Material> allMaterials { get; private set; } = new List<Material>();
        public static List<Mutation> allMutations { get; private set; } = new List<Mutation>();

        // Этот метод будет вызываться один раз при запуске игры
        public static void Initialize()
        {
            // ЗАПОЛНЯЕМ МУТАЦИИ
            allMutations.Add(new Mutation { Name = "Ничего", Multiplier = 1.0, Chance = 93.495 });
            allMutations.Add(new Mutation { Name = "Glowing", Multiplier = 1.02, Chance = 2.0 });
            allMutations.Add(new Mutation { Name = "Scorching", Multiplier = 1.1, Chance = 2.0 });
            allMutations.Add(new Mutation { Name = "Iridescent", Multiplier = 1.3, Chance = 1.5 });
            allMutations.Add(new Mutation { Name = "Radioactive", Multiplier = 2.0, Chance = 1.0 });
            allMutations.Add(new Mutation { Name = "Prismatic", Multiplier = 5.0, Chance = 0.05 });

            // ЗАПОЛНЯЕМ МАТЕРИАЛЫ (я сократил для примера, ты вставишь все)
            allMaterials.Add(new Material { Name = "Coal", Value = new BigInteger(2), BaseChance = 50, RarityGroup = Rarity.Common, ImageKey = "coal.png" });
            allMaterials.Add(new Material { Name = "Copper", Value = new BigInteger(5), BaseChance = 25, RarityGroup = Rarity.Common, ImageKey = "copper.png" });
            allMaterials.Add(new Material { Name = "Iron", Value = new BigInteger(20), BaseChance = 15, RarityGroup = Rarity.Common, ImageKey = "iron.png" });
            allMaterials.Add(new Material { Name = "Pyrite", Value = new BigInteger(150), BaseChance = 8, RarityGroup = Rarity.Common, ImageKey = "pyrite.png" });

            // --- Uncommon (Суммарный шанс ~5%) ---
            // Уже сложнее. Чтобы их фармить, нужна небольшая прокачка удачи.
            allMaterials.Add(new Material { Name = "Silver", Value = new BigInteger(650), BaseChance = 2.5, RarityGroup = Rarity.Uncommon, ImageKey = "silver.png" });
            allMaterials.Add(new Material { Name = "Gold", Value = new BigInteger(1200), BaseChance = 1.5, RarityGroup = Rarity.Uncommon, ImageKey = "gold.png" });
            allMaterials.Add(new Material { Name = "Platinum", Value = new BigInteger(500), BaseChance = 0.8, RarityGroup = Rarity.Uncommon, ImageKey = "platinum.png" });
            allMaterials.Add(new Material { Name = "Titanium", Value = new BigInteger(9000), BaseChance = 0.4, RarityGroup = Rarity.Uncommon, ImageKey = "titanium.png" });

            // --- Rare (Суммарный шанс ~0.1%) ---
            // Здесь начинается "мид-гейм". Без хорошей удачи и зелий их почти не увидеть.
            allMaterials.Add(new Material { Name = "Quartz", Value = new BigInteger(100000), BaseChance = 0.05, RarityGroup = Rarity.Rare, ImageKey = "quartz.png" }); // 1 к 2000
            allMaterials.Add(new Material { Name = "Pearl", Value = new BigInteger(500000), BaseChance = 0.02, RarityGroup = Rarity.Rare, ImageKey = "pearl.png" }); // 1 к 5000
            allMaterials.Add(new Material { Name = "Obsidian", Value = new BigInteger(12000000), BaseChance = 0.01, RarityGroup = Rarity.Rare, ImageKey = "obsidian.png" }); // 1 к 10000
            allMaterials.Add(new Material { Name = "Topaz", Value = new BigInteger(30000000), BaseChance = 0.005, RarityGroup = Rarity.Rare, ImageKey = "topaz.png" }); // 1 к 20000
            allMaterials.Add(new Material { Name = "Lapis Lazuri", Value = new BigInteger(75000000), BaseChance = 0.002, RarityGroup = Rarity.Rare, ImageKey = "lapislazuri.png" }); // 1 к 50000

            // --- Epic (Здесь начинается "энд-гейм") ---
            // Шансы становятся астрономическими. Это цель на долгие часы/дни игры.
            allMaterials.Add(new Material { Name = "Diamond", Value = new BigInteger(250000000), BaseChance = 1e-4, RarityGroup = Rarity.Epic, ImageKey = "diamond.png" }); // 1e-4 = 0.0001, или 1 к 1,000,000
            allMaterials.Add(new Material { Name = "Emerald", Value = new BigInteger(800000000), BaseChance = 5e-5, RarityGroup = Rarity.Epic, ImageKey = "emerald.png" }); // 5e-5 = 0.00005, или 1 к 2,000,000
            allMaterials.Add(new Material { Name = "Sapphire", Value = new BigInteger(2000000000), BaseChance = 2e-5, RarityGroup = Rarity.Epic, ImageKey = "saphire.png" }); // 1 к 5,000,000
            allMaterials.Add(new Material { Name = "Ruby", Value = new BigInteger(5000000000), BaseChance = 1e-5, RarityGroup = Rarity.Epic, ImageKey = "ruby.png" });     // 1 к 10,000,000

            // --- Legendary (Практически недостижимые без максимальной прокачки) ---
            allMaterials.Add(new Material { Name = "Palladium", Value = new BigInteger(15000000000), BaseChance = 5e-7, RarityGroup = Rarity.Legendary, ImageKey = "palladium.png" }); // 5e-7 = 0.0000005, или 1 к 200,000,000
            allMaterials.Add(new Material { Name = "Iridium", Value = new BigInteger(50000000000), BaseChance = 2e-7, RarityGroup = Rarity.Legendary, ImageKey = "iridium.png" });   // 1 к 500,000,000

            // --- Mythic (Пост-эндгейм, гринд ради гринда) ---
            allMaterials.Add(new Material { Name = "Tanzanite", Value = new BigInteger(20000000000), BaseChance = 1e-8, RarityGroup = Rarity.Mythic, ImageKey = "tanzanite.png" });      // 1 к 1,000,000,000
            allMaterials.Add(new Material { Name = "Amber", Value = new BigInteger(1000000000000), BaseChance = 5e-9, RarityGroup = Rarity.Mythic, ImageKey = "amber.png" });        // 1 к 2,000,000,000

            // --- UNBELIEVABLE! (Лото) ---
            allMaterials.Add(new Material { Name = "Meteorite Iron", Value = new BigInteger(10000000000000), BaseChance = 1e-10, RarityGroup = Rarity.Unbelievable, ImageKey = "meteoriteiron.png" });
            allMaterials.Add(new Material { Name = "Starlight", Value = new BigInteger(1500000000000000), BaseChance = 1e-11, RarityGroup = Rarity.Unbelievable, ImageKey = "starlight.png" });
            allMaterials.Add(new Material { Name = "Cosmic Dust", Value = new BigInteger(18446744073709551615), BaseChance = 1e-12, RarityGroup = Rarity.Unbelievable, ImageKey = "cosmicdust.png" });

            // Загружаем картинки для материалов
            LoadMaterialImages();
        }

        private static void LoadMaterialImages()
        {
            foreach (var material in allMaterials)
            {
                try
                {
                    material.Image = LoadImageFromEmbeddedResource(material.ImageKey);
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Ошибка загрузки картинки: {material.ImageKey}\n{ex.Message}");
                }
            }
        }

        private static Image LoadImageFromEmbeddedResource(string imageKey)
        {
            var assembly = System.Reflection.Assembly.GetExecutingAssembly();
            // Убедись, что пространство имен тут правильное, если твои картинки лежат в другой папке
            string resourceName = $"RNGGame.pic.{imageKey}";
            using (var stream = assembly.GetManifestResourceStream(resourceName))
            {
                if (stream == null) throw new FileNotFoundException($"Ресурс не найден: {resourceName}");
                return Image.FromStream(stream);
            }
        }
    }
}