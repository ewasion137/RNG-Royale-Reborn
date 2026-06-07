using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D; // Для InterpolationMode
using System.Globalization;
using System.IO;
using System.Linq;
using System.Numerics;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace RNGGame
{
    public partial class Form1 : Form
    {
        private DiscordManager _discordManager = new DiscordManager();
        private float uiUpdateCooldown = 1.0f;
        private bool isRolling = false;
        private PlayerData player;
        private bool isPrestiging = false;
        private Dictionary<Button, Rectangle> originalButtonBounds = new Dictionary<Button, Rectangle>();
        private RolledItem lastRolledItem;
        private Random rng = new Random();
        private static readonly string AppDataPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "RNG Royale");
        private readonly string _saveFilePath = Path.Combine(AppDataPath, "save.json");
        private SoundManager soundManager = new SoundManager();
        private float autoRollCooldown = 0f;
        private Color prismaticColor = Color.Red;
        private int colorAngle = 0;
        private double breathingAngle = 0;
        private BigInteger displayedMoney = 0;
        private BigInteger targetMoney = 0;
        private Point originalFormLocation;
        private int screenShakeDuration = 0;
        private readonly Dictionary<Rarity, string> _raritySounds = new Dictionary<Rarity, string>

{
    { Rarity.Common, "common_uncommon.wav" },
    { Rarity.Uncommon, "common_uncommon.wav" },
    { Rarity.Rare, "rare.wav" },
    { Rarity.Epic, "epic.wav" },
    { Rarity.Legendary, "legendary.wav" },
    { Rarity.Mythic, "mythic.wav" },
    { Rarity.Unbelievable, "unbelivable.wav" }
};
        private readonly Dictionary<string, string> _mutationSounds = new Dictionary<string, string>
    {
        { "Glowing", "overlapping-mutation-glowing.wav" },
        { "Scorching", "overlapping-mutation-scorching.wav" },
        { "Iridescent", "overlapping-mutation_iridescent.wav" },
        { "Radioactive", "overlapping-mutation_radioactive.wav" }, // У тебя тут опечатка в имени файла, кстати
        { "Prismatic", "overlapping-mutation_prismatic.wav" }
    };
        // === КОНСТРУКТОР ФОРМЫ ===
        public Form1()
        {
            InitializeComponent();
            soundManager.PlayMusic("musa.wav", SettingsManager.CurrentSettings.MusicVolume);
        }
        private void Form1_Shown(object sender, EventArgs e)
        {
            // --- ШАГ 1: Загружаем статические данные ---
            GameData.Initialize();

            // --- ШАГ 2: Пытаемся загрузить игру ---
            if (!LoadGameAndHandleErrors())
            {
                // Если загрузка провалилась...
                string saveFilePath = SettingsManager.SaveFilePath;
                MessageBox.Show("Save file is corrupted or was tampered with. Starting a new game.", "Save File Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);

                if (File.Exists(saveFilePath))
                {
                    try { File.Delete(saveFilePath); } catch { /* Игнорируем ошибку удаления здесь */ }
                }

                // Создаем нового чистого игрока
                player = new PlayerData();
            }

            // --- ШАГ 3: Инициализируем переменные и UI ---
            // Этот код переезжает сюда из Form1_Load
            displayedMoney = player.Money;
            targetMoney = player.Money;

            foreach (var button in new[] { btnLuckBuy, btnRollBuy, btnSellValBuy, btnAutoRollBuy })
            {
                originalButtonBounds[button] = button.Bounds;
            }

            int autoRollLevel = player.Upgrades["AutoRoll"].Level;
            if (autoRollLevel > 0)
            {
                autoRollCooldown = 30.0f - (autoRollLevel * 0.5f);
            }

            _discordManager.Initialize();
            UpdateUI();
            gameTickTimer.Start();
        }
        private void Form1_Load(object sender, EventArgs e)
        {
            Form1_Shown(sender, e);
        }
        private void ApplyCustomFontToControls(Control parentControl, FontFamily customFontFamily)
        {
            if (customFontFamily == null) return; // Защита от ошибок

            foreach (Control control in parentControl.Controls)
            {
                control.Font = new Font(customFontFamily, control.Font.Size, control.Font.Style);

                if (control.HasChildren)
                {
                    ApplyCustomFontToControls(control, customFontFamily);
                }
            }
        }
        // private void Form1_KeyDown(object sender, KeyEventArgs e)
        //{
        //    // Проверяем, что нажата именно клавиша 'D'
        //    if (e.KeyCode == Keys.D)
        //    {
        //        player.Money += BigInteger.Parse("1000000000000000");
        //        StopMoneyAnimationAndSync();
        //    }
        //
        //    // Нажата 'L' - даем 10 уровней
        //    if (e.KeyCode == Keys.L)
        //    {
        //        player.Level += 10;
        //        UpdatePrestigeUI();
        //    }
        //}

        #region Логика игры (RNG)
        private Material GetRandomMaterial()
        {
            var availableMaterials = new List<Material>(GameData.allMaterials);
            int luckLevel = player.Upgrades["Luck"].Level;

            // --- Убираем низкоуровневые материалы в зависимости от уровня удачи ---
            if (luckLevel >= 125) availableMaterials.RemoveAll(m => m.RarityGroup == Rarity.Mythic);
            if (luckLevel >= 100) availableMaterials.RemoveAll(m => m.RarityGroup == Rarity.Legendary);
            if (luckLevel >= 75) availableMaterials.RemoveAll(m => m.RarityGroup == Rarity.Epic);
            if (luckLevel >= 50) availableMaterials.RemoveAll(m => m.RarityGroup == Rarity.Rare);
            if (luckLevel >= 25) availableMaterials.RemoveAll(m => m.RarityGroup == Rarity.Uncommon);
            if (luckLevel >= 10) availableMaterials.RemoveAll(m => m.RarityGroup == Rarity.Common);

            // --- Проверяем, активно ли зелье удачи ---
            double potionLuckMultiplier = 1.0; // По умолчанию множитель равен 1 (нет эффекта)
            var luckBoostEffect = player.ActiveEffects.FirstOrDefault(e => e.EffectType == PotionEffect.LuckBoost);

            if (luckBoostEffect != null)
            {
                // Если эффект найден, используем его множитель
                potionLuckMultiplier = luckBoostEffect.Multiplier;
            }

            // --- Рассчитываем итоговый фактор удачи ---
            // Складываем постоянный бонус от улучшения и временный от зелья
            double prestigeLuckBonus = 1.0 + (player.PrestigeLevel * 0.10); // +10% за уровень престижа

            // Умножаем все бонусы друг на друга
            double totalLuckFactor = (1 + (luckLevel * 0.01)) * potionLuckMultiplier * prestigeLuckBonus;

            // --- Применяем удачу к шансам ---
            // Создаем новый список материалов с измененными "весами" (шансами)
            var weightedMaterials = availableMaterials.Select(m => new
            {
                Material = m,
                // Чем выше редкость, тем сильнее на нее влияет удача
                Weight = m.BaseChance * Math.Pow(totalLuckFactor, (int)m.RarityGroup + 1)
            }).ToList();

            // --- Выбираем случайный материал по весу ---
            double totalWeight = weightedMaterials.Sum(x => x.Weight);
            if (totalWeight <= 0) // На случай, если все шансы стали нулевыми
            {
                return availableMaterials.FirstOrDefault() ?? GameData.allMaterials.First();
            }

            double randomValue = rng.NextDouble() * totalWeight;

            foreach (var item in weightedMaterials)
            {
                randomValue -= item.Weight;
                if (randomValue <= 0)
                {
                    return item.Material;
                }
            }

            // Резервный вариант на случай ошибок округления
            return weightedMaterials.Last().Material;
        }

        private Mutation GetRandomMutation()
        {
            // --- Шаг 1: Определяем, какой список мутаций использовать ---

            // Проверяем, активно ли зелье
            var mutationBoost = player.ActiveEffects.FirstOrDefault(e => e.EffectType == PotionEffect.MutationBoost);

            // Создаем переменную, в которой будет лежать наш рабочий список мутаций
            List<Mutation> availableMutations;

            if (mutationBoost != null)
            {
                // Если зелье активно, берем все мутации, КРОМЕ "Ничего"
                availableMutations = GameData.allMutations.Where(m => m.Name != "Ничего").ToList();
            }
            else
            {
                // Если зелье неактивно, берем ПОЛНЫЙ список мутаций
                availableMutations = GameData.allMutations;
            }

            // --- Шаг 2: Проводим розыгрыш по выбранному списку ---

            // Считаем суммарный "вес" (шанс) только для доступных мутаций
            double totalWeight = availableMutations.Sum(m => m.Chance);
            if (totalWeight <= 0) // На случай, если список пуст
            {
                // Возвращаем самую простую мутацию, чтобы игра не упала
                return GameData.allMutations.First(m => m.Name == "Ничего");
            }

            double randomValue = rng.NextDouble() * totalWeight;

            // Проходимся по доступным мутациям
            foreach (var mutation in availableMutations)
            {
                randomValue -= mutation.Chance;
                if (randomValue <= 0)
                {
                    // Как только нашли победителя - возвращаем его
                    return mutation;
                }
            }

            // Резервный вариант на случай ошибок округления
            return availableMutations.Last();
        }
        #endregion

        #region Обновление интерфейса (UI)

        // В Form1.cs
        private void HandleBreathingButton(Button button, Upgrade upgrade)
        {
            // --- Устанавливаем текст и базовое состояние ---
            BigInteger cost = upgrade.GetCurrentCost();
            button.Text = upgrade.Level < upgrade.MaxLevel ? $"{upgrade.Name.ToUpper()}\n{cost.ToString("N0")}$" : "MAX LEVEL";
            button.Enabled = upgrade.Level < upgrade.MaxLevel;

            // --- Логика цвета (исправленная) ---
            bool canAfford = player.Money >= cost;

            // Если кнопка включена, решаем, какого она цвета

            // --- УБИРАЕМ АНИМАЦИЮ ОТСЮДА ---
            // Возвращаем кнопке ее оригинальный размер на случай, если что-то пошло не так
            if (originalButtonBounds.ContainsKey(button))
                button.Bounds = originalButtonBounds[button];
        }
        private void UpdateUI()
        {
            // --- ДЕНЬГИ И УЛУЧШЕНИЯ ---
            lblMoney.Text = $"MONEY: {player.Money:N0}";
            lblTotalRolls.Text = $"TOTAL ROLLS: {player.TotalRolls.ToString("N0")}";

            var luck = player.Upgrades["Luck"];
            HandleBreathingButton(btnLuckBuy, luck);
            lblLuckLevel.Text = $"LUCK LEVEL : {luck.Level}";
            btnLuckBuy.Text = luck.Level < luck.MaxLevel ? $"+LUCK\n{luck.GetCurrentCost():N0}$" : "MAX LEVEL";
            // Кнопка активна, ТОЛЬКО ЕСЛИ не идет ролл И выполнены остальные условия
            btnLuckBuy.Enabled = !isRolling && luck.Level < luck.MaxLevel;

            var fasterRoll = player.Upgrades["FasterRoll"];
            HandleBreathingButton(btnRollBuy, fasterRoll);
            int rollSpeed = 5000 - (fasterRoll.Level * 200);

            if (rollSpeed < 100) rollSpeed = 100;

            lblRollSpeed.Text = $"ROLL SPEED (MS) : {rollSpeed}";

            // Дальше твой код кнопки...
            btnRollBuy.Text = fasterRoll.Level < fasterRoll.MaxLevel ? $"FASTER ROLL\n{fasterRoll.GetCurrentCost():N0}$" : "MAX LEVEL";
            btnRollBuy.Enabled = !isRolling && fasterRoll.Level < fasterRoll.MaxLevel;

            var sellValue = player.Upgrades["SellValue"];
            HandleBreathingButton(btnSellValBuy, sellValue);
            lblSellMultiplierlevel.Text = $"SELL MUL. LEVEL : X{1.0 + (sellValue.Level * 0.1):F1}";
            btnSellValBuy.Text = sellValue.Level < sellValue.MaxLevel ? $"SELL VALUE BOOST\n{sellValue.GetCurrentCost():N0}$" : "MAX LEVEL";
            btnSellValBuy.Enabled = !isRolling && sellValue.Level < sellValue.MaxLevel;

            var autoRoll = player.Upgrades["AutoRoll"];
            HandleBreathingButton(btnAutoRollBuy, autoRoll);
            lblAutoRollLevel.Text = $"AUTO ROLL LVL : {autoRoll.Level}"; // Добавь соответствующий Label
            lblAutoRollSpeed.Text = $"SPEED: {(30.0f - (player.Upgrades["AutoRoll"].Level * 0.5f)).ToString("F1", CultureInfo.InvariantCulture)}s";
            btnAutoRollBuy.Text = autoRoll.Level < autoRoll.MaxLevel ? $"AUTO ROLL\n{autoRoll.GetCurrentCost():N0}$" : "MAX LEVEL";
            btnAutoRollBuy.Enabled = autoRoll.Level < autoRoll.MaxLevel;

            int luckLevel = player.Upgrades["Luck"].Level;
            var luckBoost = player.ActiveEffects.FirstOrDefault(e => e.EffectType == PotionEffect.LuckBoost);
            double potionMultiplier = luckBoost?.Multiplier ?? 1.0;

            // <<< ДОБАВЛЯЕМ БОНУС ПРЕСТИЖА СЮДА >>>
            // double prestigeLuckBonus = 1.0 + (player.PrestigeLevel * 0.10);
            //  double totalLuckFactor = (1 + (luckLevel * 0.01)) * potionMultiplier * prestigeLuckBonus;

            // Вычисляем примерный шанс на метеорит для наглядности
            // double meteoriteBaseChance = 1e-10;
            // int meteoriteRarityLevel = (int)Rarity.Unbelievable + 1;
            // double finalMeteoriteChance = meteoriteBaseChance * Math.Pow(totalLuckFactor, meteoriteRarityLevel);

            // lblDebugInfo.Text = $"Luck Lvl: {luckLevel} | Potion: x{potionMultiplier:F1} | Prestige: x{prestigeLuckBonus:F2} | Total: {totalLuckFactor:F2} | Meteorite Chance: ~1 in {(1 / finalMeteoriteChance):E2}";

            // --- ПАНЕЛЬ ИГРЫ (РОЛЛ) ---
            if (lastRolledItem != null)
            {
                // Показываем результат ролла
                Image baseImg = lastRolledItem.BaseMaterial.Image;
                Image finalImg = Visuals.ApplyMutationAura(baseImg, lastRolledItem.Mutation.Name, prismaticColor);
                picPanel.BackgroundImage = finalImg;
                lblItem.Text = $"{lastRolledItem.BaseMaterial.Name.ToUpper()}";
                lblItemMutaion.Text = lastRolledItem.Mutation.Name == "Ничего" ? "" : lastRolledItem.Mutation.Name.ToUpper();

                btnRoll.Visible = false;
                btnSellNow.Visible = true;
                btnCollect.Visible = true;
            }
            else
            {
                picPanel.BackgroundImage = null;
                lblItem.Text = "";
                lblItemMutaion.Text = "";


                btnRoll.Visible = !isRolling;
                btnSellNow.Visible = false;
                btnCollect.Visible = false;
            }
            if (player.PotionInventory.ContainsKey("Luck Potion") && player.PotionInventory["Luck Potion"] > 0)
            {
                panelLuck.Visible = true;
                labelLuck.Text = $"x{player.PotionInventory["Luck Potion"]}";
            }
            else
            {
                panelLuck.Visible = false;
            }

            // Зелье денег
            if (player.PotionInventory.ContainsKey("Money Potion") && player.PotionInventory["Money Potion"] > 0)
            {
                panelMoney.Visible = true;
                labelMoney.Text = $"x{player.PotionInventory["Money Potion"]}";
            }
            else
            {
                panelMoney.Visible = false;
            }
            if (player.PotionInventory.ContainsKey("Mutation Potion") && player.PotionInventory["Mutation Potion"] > 0)
            {
                panelMutation.Visible = true;
                labelMutationPot.Text = $"x{player.PotionInventory["Mutation Potion"]}";
            }
            else
            {
                panelMutation.Visible = false;
            }
            if (player.PotionInventory.ContainsKey("Duplication Potion") && player.PotionInventory["Duplication Potion"] > 0)
            {
                panelDuplication.Visible = true; // Убедись, что панель называется panelDuplication
                labelDuplicationPot.Text = $"x{player.PotionInventory["Duplication Potion"]}";
            }
            else
            {
                panelDuplication.Visible = false;
            }
            if (player.PotionInventory.ContainsKey("Potion of Wisdom") && player.PotionInventory["Potion of Wisdom"] > 0)
            {
                panelWisdom.Visible = true;
                // Убедись, что у тебя есть labelWisdomPot на панели
                labelWisdomPot.Text = $"x{player.PotionInventory["Potion of Wisdom"]}";
            }
            else
            {
                panelWisdom.Visible = false;
            }

            int requiredLevel = GameConstants.PRESTIGE_BASE_LEVEL_REQ + player.PrestigeLevel;
            // Кнопка активна, только если все условия выполнены
            btnPrestige.Enabled = (player.Level >= requiredLevel && !isRolling && !isPrestiging);

            string details = $"Level: {player.Level} (P: {player.PrestigeLevel})";
            string state = $"Money: ${player.Money:N0}";
            _discordManager.UpdatePresence(details, state);
            UpdateTimersUI();
            UpdateInventoryDisplay();
            UpdatePrestigeUI();
        }

        #endregion

        #region Обработчики событий кнопок
        private void PlayRaritySound(Rarity rarity)
        {
            if (_raritySounds.TryGetValue(rarity, out string soundName))
            {
                soundManager.PlaySfx(soundName, SettingsManager.CurrentSettings.SfxVolume);
            }
        }

        private void PlayMutationSound(string mutationName)
        {
            if (_mutationSounds.TryGetValue(mutationName, out string soundName))
            {
                soundManager.PlaySfx(soundName, SettingsManager.CurrentSettings.SfxVolume);
            }
        }

        private async void btnRoll_Click(object sender, EventArgs e)
        {
            // --- НАЧАЛО ЗАЩИЩЕННОЙ СЕКЦИИ ---
            isRolling = true;
            UpdateUI(); // Блокируем кнопки
            player.TotalRolls++;
            player.Stats.TotalRollsAllTime++;

            lblItem.Text = "ROLLING...";
            soundManager.PlaySfx("roll.wav", SettingsManager.CurrentSettings.SfxVolume);

            // Улучшения для этого ролла берутся на момент нажатия кнопки
            int rollTime = 5000 - (player.Upgrades["FasterRoll"].Level * 200);
            await Task.Delay(rollTime);

            // --- ПОЛУЧЕНИЕ РЕЗУЛЬТАТА ---
            var rolledMaterial = GetRandomMaterial();
            var mutation = GetRandomMutation();
            if (player.Stats.MaterialsFound.ContainsKey(rolledMaterial.Name))
                player.Stats.MaterialsFound[rolledMaterial.Name]++;
            else
                player.Stats.MaterialsFound.Add(rolledMaterial.Name, 1);

            if (mutation.Name != "Ничего")
            {
                if (player.Stats.MutationsGotten.ContainsKey(mutation.Name))
                    player.Stats.MutationsGotten[mutation.Name]++;
                else
                    player.Stats.MutationsGotten.Add(mutation.Name, 1);
            }

            // --- РАСЧЕТ СТОИМОСТИ ---
            double sellBoost = 1.0 + (player.Upgrades["SellValue"].Level * 0.1);
            double prestigeSellMultiplier = 1.0 + (player.PrestigeLevel * 0.15); // +15% за уровень престижа

            BigInteger finalValue = rolledMaterial.Value
                                    * new BigInteger(mutation.Multiplier * 100)
                                    * new BigInteger(sellBoost * 100)
                                    * new BigInteger(prestigeSellMultiplier * 100)
                                    / (100 * 100 * 100);

            // --- СОХРАНЕНИЕ РЕЗУЛЬТАТА ДЛЯ ОТОБРАЖЕНИЯ ---
            lastRolledItem = new RolledItem
            {
                BaseMaterial = rolledMaterial,
                Mutation = mutation,
                FinalValue = finalValue
            };

            // --- ЛОГИКА ЗВУКОВ ---
            player.DiscoveredMaterials.Add(rolledMaterial.Name);
            if (rolledMaterial.RarityGroup == Rarity.Unbelievable && mutation.Name != "Ничего")
            {
                soundManager.PlaySfx("unbelivable_mutation.wav", SettingsManager.CurrentSettings.SfxVolume);
            }
            else
            {
                PlayRaritySound(rolledMaterial.RarityGroup);
                if (mutation.Name != "Ничего")
                {
                    await Task.Delay(150);
                    PlayMutationSound(mutation.Name);
                }
            }

            if (rolledMaterial.RarityGroup >= Rarity.Legendary)
            {
                originalFormLocation = this.Location;
                screenShakeDuration = 15; // Трясти 15 тиков (15 * 20мс = 300мс)
                animationTimer.Start();
            }
            isRolling = false;
            UpdateUI(); // Обновляем UI с результатом и разблокируем кнопки
        }

        // Кнопка "ПРОДАТЬ СЕЙЧАС"
        private void btnSellNow_Click(object sender, EventArgs e)
        {
            if (lastRolledItem == null) return;
            AwardXP(lastRolledItem);
            // 1. Получаем сумму
            BigInteger value = lastRolledItem.FinalValue;
            player.Stats.TotalMoneyEarned += value;

            // 2. Устанавливаем ЦЕЛЬ для анимации
            targetMoney = player.Money + value;

            // 3. Запускаем всплывающую цифру
            SpawnFloatingMoney(value);

            // 4. РЕАЛЬНО добавляем деньги
            player.Money += value;

            // 5. Очищаем слот ролла
            lastRolledItem = null;

            // 6. Запускаем таймер анимаций
            animationTimer.Start();

            // 7. Проигрываем звук
            soundManager.PlaySfx("selling.wav", SettingsManager.CurrentSettings.SfxVolume);

            // 8. Вручную обновляем ТОЛЬКО то, что не связано с деньгами
            // (например, прячем кнопки SELL/COLLECT и показываем ROLL)
            btnRoll.Visible = true;
            btnSellNow.Visible = false;
            btnCollect.Visible = false;
            picPanel.BackgroundImage = null;
            lblItem.Text = "";
            lblItemMutaion.Text = "";

            // НЕ вызываем полный UpdateUI() здесь!
        }

        // Кнопка "ЗАБРАТЬ В ИНВЕНТАРЬ"
        private void btnCollect_Click(object sender, EventArgs e)
        {
            if (lastRolledItem == null) return;

            // Сначала начисляем XP за ОДИН полученный предмет.
            AwardXP(lastRolledItem);

            // --- ШАГ 1: Формируем правильный ключ для инвентаря ---
            string inventoryKey = lastRolledItem.BaseMaterial.Name;
            if (lastRolledItem.Mutation.Name != "Ничего")
            {
                inventoryKey = $"{lastRolledItem.BaseMaterial.Name} ({lastRolledItem.Mutation.Name})";
            }

            // --- ШАГ 2: Определяем, сколько предметов добавить ---
            int amountToAdd = 1; // По умолчанию всегда добавляем один предмет.

            // Проверяем зелье дубликации
            var duplicationEffect = player.ActiveEffects.FirstOrDefault(e => e.EffectType == PotionEffect.DuplicationBoost);
            if (duplicationEffect != null)
            {
                double chance = duplicationEffect.Multiplier; // У тебя это 0.2 для 20%
                if (rng.NextDouble() < chance)
                {
                    // УСПЕХ! Дублируем предмет.
                    amountToAdd = 2;
                    soundManager.PlaySfx("duplication_success.wav", SettingsManager.CurrentSettings.SfxVolume);
                }
            }

            // --- ШАГ 3: Добавляем нужное количество предметов в инвентарь ---
            if (player.Inventory.ContainsKey(inventoryKey))
            {
                player.Inventory[inventoryKey] += amountToAdd;
            }
            else
            {
                player.Inventory.Add(inventoryKey, amountToAdd);
            }

            // --- ШАГ 4: Очистка и обновление UI ---
            soundManager.PlaySfx("inventory.wav", SettingsManager.CurrentSettings.SfxVolume);
            lastRolledItem = null;
            UpdateUI(); // UpdateUI вызовет UpdateInventoryDisplay, так что все обновится.
        }
        public async Task PerformPrestigeReset()
        {
            if (isPrestiging) return;
            isPrestiging = true;

            // <<< ОБЪЯВЛЯЕМ ПЕРЕМЕННЫЕ ОДИН РАЗ В САМОМ НАЧАЛЕ >>>
            float originalMusicVolume = SettingsManager.CurrentSettings.MusicVolume;
            bool sfxEnabled = SettingsManager.CurrentSettings.SfxVolume > 0;
            string prestigeSound;
            int requiredLevel = GameConstants.PRESTIGE_BASE_LEVEL_REQ + player.PrestigeLevel;
            try
            {

                // 1. Проверяем условие по новой формуле
                if (player.Level < requiredLevel)
                {
                    // Показываем в сообщении актуальное требование
                    MessageBox.Show($"You need to be at least level {requiredLevel} to prestige.", "Requirement not met", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                // --- Рассчитываем НОВЫЕ бонусы, которые игрок получит ---
                int newPrestigeLevel = player.PrestigeLevel + 1;
                double newXpBonusPercent = newPrestigeLevel * GameConstants.PRESTIGE_XP_BONUS * 100;
                double newSellBonusPercent = newPrestigeLevel * GameConstants.PRESTIGE_SELL_VALUE_BONUS * 100;
                double newLuckBonusPercent = newPrestigeLevel * GameConstants.PRESTIGE_LUCK_BONUS * 100;

                string confirmationMessage = $@"Are you sure you want to prestige?

This will reset:
- Money, Upgrades, Inventory
- Active Potions, Level and XP

You will reach Prestige Level {newPrestigeLevel}, which grants you permanent bonuses:
- XP Gain: +{newXpBonusPercent:F0}% (Total)
- Sell Value: +{newSellBonusPercent:F0}% (Total)
- Luck: +{newLuckBonusPercent:F0}% (Total)";

                var result = MessageBox.Show(confirmationMessage, "Confirm Prestige", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
                if (result != DialogResult.Yes) return;

                prestigeSound = (player.PrestigeLevel < 5) ? "prestige_success_early.wav" : "prestige_success_epic.wav";

                if (sfxEnabled)
                {
                    await soundManager.FadeOutMusic();
                    soundManager.PlaySfx(prestigeSound, SettingsManager.CurrentSettings.SfxVolume);
                    await Task.Delay(1500); // Подождем 1.5 секунды
                    await soundManager.FadeInMusic(originalMusicVolume);
                }

                lastRolledItem = null;
                int oldPrestigeLevel = player.PrestigeLevel;
                var discoveredItems = player.DiscoveredMaterials;
                var discoveredMutations = player.DiscoveredMutations;
                var potionInventory = player.PotionInventory;
                var oldStats = player.Stats;

                player = new PlayerData();

                player.PrestigeLevel = oldPrestigeLevel + 1;
                player.DiscoveredMaterials = discoveredItems;
                player.DiscoveredMutations = discoveredMutations;
                player.PotionInventory = potionInventory;
                player.Stats = oldStats;

                SaveGame();
                UpdateUI(); // ВАЖНО: полный вызов UI после сброса
            }
            finally
            {
                isPrestiging = false; // В любом случае снимаем замок
            }
        }

        private void btnSellAll_Click(object sender, EventArgs e)
        {
            if (!player.Inventory.Any()) return;

            var dialogResult = MessageBox.Show("Are you sure?", "Confirming selling", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
            if (dialogResult != DialogResult.Yes) return;

            BigInteger totalSellValue = 0;
            double baseSellBoost = 1.0 + (player.Upgrades["SellValue"].Level * 0.1);
            double prestigeSellMultiplier = 1.0 + (player.PrestigeLevel * 0.15);

            double moneyMultiplier = 1.0;
            var moneyBoost = player.ActiveEffects.FirstOrDefault(e => e.EffectType == PotionEffect.MoneyBoost);
            if (moneyBoost != null) moneyMultiplier = moneyBoost.Multiplier;

            foreach (var inventoryItem in player.Inventory)
            {
                // Разбираем ключ на части: "Имя" и "Мутация"
                var parts = inventoryItem.Key.Split(new[] { " (" }, StringSplitOptions.None);
                string name = parts[0];
                string mutationName = parts.Length > 1 ? parts[1].TrimEnd(')') : "Ничего";

                var material = GameData.allMaterials.First(m => m.Name == name);
                var mutation = GameData.allMutations.First(m => m.Name == mutationName);
                int quantity = inventoryItem.Value;

                // Рассчитываем стоимость ОДНОГО такого предмета
                BigInteger singleItemValue = material.Value * new BigInteger(mutation.Multiplier * 100)
                                           * new BigInteger(baseSellBoost * 100)
                                           * new BigInteger(prestigeSellMultiplier * 100)
                                           * new BigInteger(moneyMultiplier * 100)
                                           / (100 * 100 * 100 * 100);

                totalSellValue += singleItemValue * quantity;

                // Для XP нам не нужен бонус от зелья денег.
                BigInteger valueForXp = material.Value * new BigInteger(mutation.Multiplier * 100)
                                       * new BigInteger(baseSellBoost * 100)
                                       * new BigInteger(prestigeSellMultiplier * 100)
                                       / (100 * 100 * 100);

                var xpItem = new RolledItem { BaseMaterial = material, Mutation = mutation, FinalValue = valueForXp };

                for (int i = 0; i < quantity; i++)
                {
                    AwardXP(xpItem);
                }
            }
            player.Stats.TotalMoneyEarned += totalSellValue;
            UpdatePrestigeUI();
            targetMoney = player.Money + totalSellValue;

            // 2. Запускаем всплывающую цифру
            SpawnFloatingMoney(totalSellValue);

            // 3. РЕАЛЬНО добавляем деньги
            player.Money += totalSellValue;
            player.Inventory.Clear();

            // 4. Запускаем таймер анимаций
            animationTimer.Start();

            // 5. Проигрываем звук
            soundManager.PlaySfx("selling.wav", SettingsManager.CurrentSettings.SfxVolume);

            // 6. Вручную обновляем инвентарь
            rtbInventory.Text = "";
            btnSellAll.Enabled = false;

            // НЕ вызываем полный UpdateUI() здесь!
        }


        // Асинхронный метод для анимации полета
        private async void SpawnFloatingMoney(BigInteger amount)
        {
            // --- 1. Создание и настройка лейбла ---
            Label floatingLabel = new Label
            {
                Text = $"+{amount.ToString("N0")}$",
                AutoSize = true,
                Font = new Font("Visitor TT2 BRK", 14, FontStyle.Bold),
                ForeColor = Color.Gold,
                BackColor = Color.Transparent,
            };

            // --- 2. Вычисление стартовой позиции ---
            // Стартуем прямо под основным счетчиком денег, по центру
            int startX = lblMoney.Left + (lblMoney.Width / 2) - (floatingLabel.PreferredWidth / 2);
            int startY = lblMoney.Bottom + 5; // На 5 пикселей ниже
            floatingLabel.Location = new Point(startX, startY);

            this.Controls.Add(floatingLabel);
            floatingLabel.BringToFront();

            // --- 3. Анимация ---
            int animationDuration = 1500; // Длительность в миллисекундах (1.5 секунды)
            int steps = 60; // Количество шагов
            int delay = animationDuration / steps;

            for (int i = 0; i <= steps; i++)
            {
                // Вычисляем прогресс анимации от 0.0 до 1.0
                float progress = (float)i / steps;

                // --- Анимация движения вверх ---
                // Лейбл проедет вверх 30 пикселей за все время
                int currentY = startY - (int)(progress * 30);
                floatingLabel.Location = new Point(startX, currentY);

                // --- Анимация плавного пропадания ---
                // Начинаем делать прозрачным после 30% времени
                if (progress > 0.3f)
                {
                    // Плавно уменьшаем альфа-канал от 255 до 0
                    float fadeProgress = (progress - 0.3f) / 0.7f; // Прогресс от 0 до 1 только для фазы затухания
                    int newAlpha = 255 - (int)(fadeProgress * 255);
                    if (newAlpha < 0) newAlpha = 0;
                    floatingLabel.ForeColor = Color.FromArgb(newAlpha, Color.Gold);
                }

                await Task.Delay(delay);
            }

            // --- 4. Очистка ---
            this.Controls.Remove(floatingLabel);
            floatingLabel.Dispose();
        }

        // Главный обработчик тика для всех анимаций
        private void animationTimer_Tick(object sender, EventArgs e)
        {
            bool isMoneyAnimating = false;
            bool isShaking = false;

            // --- Анимация плавного счетчика денег ---
            if (displayedMoney < targetMoney)
            {
                isMoneyAnimating = true;
                BigInteger difference = targetMoney - displayedMoney;
                BigInteger step = difference / 20;
                if (step < 1) step = 1;

                // --- УМЕНЬШАЕМ МИНИМАЛЬНЫЙ ШАГ ---
                // Чтобы на маленьких суммах он не пролетал моментально
                BigInteger minStep = targetMoney / 5000;
                if (minStep < 1) minStep = 1;
                if (step < minStep) step = minStep;

                displayedMoney += step;
                if (displayedMoney > targetMoney) displayedMoney = targetMoney;

                lblMoney.Text = $"MONEY: {displayedMoney.ToString("N0")}";
            }
            else
            {
                displayedMoney = player.Money;
                targetMoney = player.Money;
            }

            // --- Анимация тряски экрана ---
            if (screenShakeDuration > 0)
            {
                isShaking = true;
                screenShakeDuration--;

                var rnd = new Random();
                this.Location = new Point(originalFormLocation.X + rnd.Next(-5, 6), originalFormLocation.Y + rnd.Next(-5, 6));

                if (screenShakeDuration == 0)
                {
                    // Возвращаем форму на место в самом конце
                    this.Location = originalFormLocation;
                }
            }

            // --- Условие остановки таймера ---
            // Если и деньги досчитались, и тряска закончилась, выключаем таймер
            if (!isMoneyAnimating && !isShaking)
            {
                animationTimer.Stop();
                UpdateUI(); // Финальное обновление
            }
        }
        public void StopMoneyAnimationAndSync()
        {
            animationTimer.Stop();
            displayedMoney = player.Money;
            targetMoney = player.Money;
            lblMoney.Text = $"MONEY: {player.Money.ToString("N0")}";
        }
        private void HandleUpgradeClick(string upgradeName)
        {
            var upgrade = player.Upgrades[upgradeName];

            // Переменная cost теперь тоже BigInteger
            BigInteger cost = upgrade.GetCurrentCost();

            // -1 - это наша метка "максимальный уровень", проверяем ее
            if (cost == -1) return;

            // Сравнение BigInteger и BigInteger - все в порядке
            if (player.Money >= cost)
            {
                StopMoneyAnimationAndSync(); // <--- Вызываем наш новый метод
                player.Money -= cost;
                StopMoneyAnimationAndSync();
                if (upgradeName == "AutoRoll" && upgrade.Level == 0)
                {
                    autoRollCooldown = GameConstants.AUTOROLL_BASE_COOLDOWN_SEC - GameConstants.AUTOROLL_REDUCTION_PER_LEVEL_SEC;
                }
                upgrade.Level++;
                soundManager.PlaySfx("upgrade_buy.wav", SettingsManager.CurrentSettings.SfxVolume);
                UpdateUI();
            }
            else
            {
                soundManager.PlaySfx("cant_buy.wav", SettingsManager.CurrentSettings.SfxVolume);
            }
        }

        private void btnLuckBuy_Click(object sender, EventArgs e)
        {
            HandleUpgradeClick("Luck");
        }
        private void btnRollBuy_Click(object sender, EventArgs e)
        {
            HandleUpgradeClick("FasterRoll");
        }
        private void btnSellValBuy_Click(object sender, EventArgs e)
        {
            HandleUpgradeClick("SellValue");
        }
        #endregion

        #region Сохранение и загрузка
        // ... (Код SaveGame и LoadGame остается без изменений)
        private const string SECRET_KEY = "FH98043CUR2MNOAPWJIERFHCGKBDTKYKSPWEOGA111"; // Секретный ключ

        private void SaveGame()
        {
            Directory.CreateDirectory(SettingsManager.AppDataPath);
            string gameDataJson = JsonConvert.SerializeObject(player);

            // Создаем хэш из данных и секретного ключа
            string hash;
            using (var sha256 = System.Security.Cryptography.SHA256.Create())
            {
                byte[] bytes = System.Text.Encoding.UTF8.GetBytes(gameDataJson + SECRET_KEY);
                byte[] hashBytes = sha256.ComputeHash(bytes);
                hash = BitConverter.ToString(hashBytes).Replace("-", "").ToLowerInvariant();
            }

            // Создаем объект для сохранения
            var saveFile = new SaveFile { GameDataJson = gameDataJson, Hash = hash };
            string finalJson = JsonConvert.SerializeObject(saveFile);

            // Кодируем в Base64 для дополнительной защиты
            File.WriteAllText(SettingsManager.SaveFilePath, Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(finalJson)));
        }
        private bool LoadGameAndHandleErrors()
        {
            try
            {
                if (File.Exists(SettingsManager.SaveFilePath))
                {
                    string base64String = File.ReadAllText(SettingsManager.SaveFilePath);
                    string finalJson = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(base64String));

                    var saveFile = JsonConvert.DeserializeObject<SaveFile>(finalJson);

                    // Проверяем хэш
                    string expectedHash;
                    using (var sha256 = System.Security.Cryptography.SHA256.Create())
                    {
                        byte[] bytes = System.Text.Encoding.UTF8.GetBytes(saveFile.GameDataJson + SECRET_KEY);
                        byte[] hashBytes = sha256.ComputeHash(bytes);
                        expectedHash = BitConverter.ToString(hashBytes).Replace("-", "").ToLowerInvariant();
                    }

                    if (saveFile.Hash == expectedHash)
                    {
                        player = JsonConvert.DeserializeObject<PlayerData>(saveFile.GameDataJson);
                        return true; // Успех!
                    }
                    else
                    {
                        throw new Exception("Hash mismatch!");
                    }
                }
                else
                {
                    player = new PlayerData();
                    return true; // Успех! (Новая игра)
                }
            }
            catch (Exception)
            {
                // Если что-то пошло не так, просто сообщаем об этом
                return false; // Провал!
            }
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            SaveGame();
            _discordManager.Dispose();
            soundManager.Dispose();
        }

        private void btnLuckBuy_MouseEnter(object sender, EventArgs e)
        {
            soundManager.PlaySfx("navigating.wav", SettingsManager.CurrentSettings.SfxVolume);
        }


        #endregion

        private void btnRollBuy_MouseEnter(object sender, EventArgs e)
        {
            soundManager.PlaySfx("navigating.wav", SettingsManager.CurrentSettings.SfxVolume);
        }

        private void btnSellValBuy_MouseEnter(object sender, EventArgs e)
        {
            soundManager.PlaySfx("navigating.wav", SettingsManager.CurrentSettings.SfxVolume);
        }

        private void groupPlay_DragEnter(object sender, DragEventArgs e)
        {
            soundManager.PlaySfx("navigating.wav", SettingsManager.CurrentSettings.SfxVolume);
        }

        private void btnSellNow_MouseEnter(object sender, EventArgs e)
        {
            soundManager.PlaySfx("navigating.wav", SettingsManager.CurrentSettings.SfxVolume);
        }

        private void btnCollect_MouseEnter(object sender, EventArgs e)
        {
            soundManager.PlaySfx("navigating.wav", SettingsManager.CurrentSettings.SfxVolume);
        }

        private void btnSellAll_MouseEnter(object sender, EventArgs e)
        {
            soundManager.PlaySfx("navigating.wav", SettingsManager.CurrentSettings.SfxVolume);
        }

        private void btnRoll_MouseEnter(object sender, EventArgs e)
        {
            soundManager.PlaySfx("navigating.wav", SettingsManager.CurrentSettings.SfxVolume);
        }

        private void gameTickTimer_Tick(object sender, EventArgs e)
        {

            float deltaTime = gameTickTimer.Interval / 1000.0f;
            int autoRollLevel = player.Upgrades["AutoRoll"].Level;
            if (autoRollLevel > 0)
            {
                autoRollCooldown -= deltaTime;
                if (autoRollCooldown <= 0)
                {
                    PerformSilentRoll();
                    float currentRollSpeed = 30.0f - (autoRollLevel * 0.5f);
                    autoRollCooldown = currentRollSpeed;
                }
            }

            // --- Логика активных эффектов зелий ---
            bool needsUiUpdate = false;
            for (int i = player.ActiveEffects.Count - 1; i >= 0; i--)
            {
                var effect = player.ActiveEffects[i];
                effect.TimeRemainingSeconds -= deltaTime;
                if (effect.TimeRemainingSeconds <= 0)
                {
                    player.ActiveEffects.RemoveAt(i);
                    needsUiUpdate = true;
                }
            }
            breathingAngle += 0.1;
            if (breathingAngle > Math.PI * 2) breathingAngle = 0;
            AnimateSingleButton(btnLuckBuy, player.Upgrades["Luck"]);
            AnimateSingleButton(btnRollBuy, player.Upgrades["FasterRoll"]);
            AnimateSingleButton(btnSellValBuy, player.Upgrades["SellValue"]);
            AnimateSingleButton(btnAutoRollBuy, player.Upgrades["AutoRoll"]);

            // --- АНИМАЦИЯ ПРИЗМАТИЧЕСКОГО ЦВЕТА ---
            colorAngle += 2;
            if (colorAngle >= 360) colorAngle = 0;
            prismaticColor = ColorFromHSV(colorAngle, 1.0, 1.0);
            if (lastRolledItem != null && lastRolledItem.Mutation.Name == "Prismatic")
            {
                UpdatePlayPanel();
            }

            // --- Обновление UI каждую секунду ---
            uiUpdateCooldown -= deltaTime;
            if (uiUpdateCooldown <= 0)
            {
                UpdateTimersUI();
                // Обновляем деньги и кнопку (это важно, чтобы отображалось то, что накапало от зелий/других эффектов)
                lblMoney.Text = $"MONEY: {player.Money.ToString("N0")}";
                btnSellAll.Enabled = player.Inventory.Any();
                uiUpdateCooldown = 1.0f;
            }

            if (needsUiUpdate) UpdateUI();
        }
        private void UpdateInventoryDisplay()
        {
            rtbInventory.Clear();
            if (!player.Inventory.Any())
            {
                btnSellAll.Enabled = false;
                return;
            }

            btnSellAll.Enabled = true;

            var groupedInventory = player.Inventory
                .Select(kvp =>
                {
                    var parts = kvp.Key.Split(new[] { " (" }, StringSplitOptions.None);
                    string name = parts[0];
                    string mutation = parts.Length > 1 ? parts[1].TrimEnd(')') : "Ничего";
                    return new { Name = name, Mutation = mutation, Count = kvp.Value };
                })
                .GroupBy(item => item.Mutation)
                .OrderBy(g => GetMutationOrder(g.Key));

            bool firstGroup = true;
            foreach (var group in groupedInventory)
            {
                if (!firstGroup)
                {
                    rtbInventory.SelectionColor = Color.DimGray;
                    rtbInventory.AppendText(" | ");
                }

                // <<< ВОТ ЗДЕСЬ ДОБАВЛЯЕМ ЦВЕТА ДЛЯ ВСЕХ МУТАЦИЙ >>>
                Color groupColor = Color.Gray;
                switch (group.Key)
                {
                    case "Glowing":
                        groupColor = Color.WhiteSmoke; // Чуть приглушенный белый
                        break;
                    case "Scorching":
                        groupColor = Color.OrangeRed;
                        break;
                    case "Iridescent":
                        groupColor = Color.Yellow;
                        break;
                    case "Radioactive":
                        groupColor = Color.LimeGreen;
                        break;
                    case "Prismatic":
                        groupColor = Color.Violet; // Или LightPink, как тебе больше нравится
                        break;
                }

                // --- Формируем текст для группы (без лишних скобок) ---
                string groupText = $"{group.Key.ToUpper()}: ";
                groupText += string.Join(", ", group.Select(item => $"{item.Name.ToUpper()} X{item.Count}"));

                // Если мутации нет ("Ничего"), показываем только предметы без заголовка
                if (group.Key == "Ничего")
                {
                    groupText = string.Join(", ", group.Select(item => $"{item.Name.ToUpper()} X{item.Count}"));
                }

                rtbInventory.SelectionColor = groupColor;
                rtbInventory.AppendText(groupText);

                firstGroup = false;
            }
        }

        // <<< А ЗДЕСЬ ДОБАВЛЯЕМ ПОРЯДОК ДЛЯ ВСЕХ МУТАЦИЙ >>>
        private int GetMutationOrder(string mutationName)
        {
            switch (mutationName)
            {
                case "Ничего": return 0; // Обычные всегда первые
                case "Glowing": return 1;
                case "Scorching": return 2;
                case "Iridescent": return 3;
                case "Radioactive": return 4;
                case "Prismatic": return 5; // Самые редкие всегда последние
                default: return 99; // На случай непредвиденных мутаций
            }
        }
        private void AnimateSingleButton(Button button, Upgrade upgrade)
        {
            if (!originalButtonBounds.ContainsKey(button)) return;
            Rectangle original = originalButtonBounds[button];

            // --- ПРОВЕРЯЕМ УСЛОВИЯ КАЖДЫЙ ТИК ---
            BigInteger cost = upgrade.GetCurrentCost();
            // Проверяем по РЕАЛЬНЫМ деньгам, а не по анимированным
            bool canAfford = player.Money >= cost;
            bool isBuyable = button.Enabled && canAfford && !isRolling;

            // --- ОБНОВЛЯЕМ ЦВЕТ КАЖДЫЙ ТИК ---
            button.ForeColor = isBuyable ? Color.White : Color.Gray;

            // --- АНИМИРУЕМ РАЗМЕР, ТОЛЬКО ЕСЛИ КНОПКА "ЖИВАЯ" ---
            if (isBuyable)
            {
                // Если кнопка должна "дышать"
                float scale = 1.0f + ((float)Math.Abs(Math.Sin(breathingAngle)) * 0.05f);

                int newWidth = (int)(original.Width * scale);
                int newHeight = (int)(original.Height * scale);
                int newX = original.Left - (newWidth - original.Width) / 2;
                int newY = original.Top - (newHeight - original.Height) / 2;

                button.Bounds = new Rectangle(newX, newY, newWidth, newHeight);
            }
            else
            {
                // Если кнопка "дышать" не должна, возвращаем ее в исходное состояние
                button.Bounds = original;
            }
        }
        private void UpdateTimersUI()
        {
            // --- Таймер Удачи ---
            var luckEffect = player.ActiveEffects.FirstOrDefault(e => e.EffectType == PotionEffect.LuckBoost);
            if (luckEffect != null && luckEffect.TimeRemainingSeconds > 0)
            {
                lblLuckTimer.Visible = true;
                var time = TimeSpan.FromSeconds(luckEffect.TimeRemainingSeconds);
                lblLuckTimer.Text = $"x2 LUCK POTION : {(time.TotalHours >= 1 ? time.ToString(@"hh\:mm\:ss") : time.ToString(@"mm\:ss"))}";
            }
            else
            {
                lblLuckTimer.Visible = false;
            }

            // --- Таймер Денег ---
            var moneyEffect = player.ActiveEffects.FirstOrDefault(e => e.EffectType == PotionEffect.MoneyBoost);
            if (moneyEffect != null && moneyEffect.TimeRemainingSeconds > 0)
            {
                lblMoneyTimer.Visible = true;
                var time = TimeSpan.FromSeconds(moneyEffect.TimeRemainingSeconds);
                lblMoneyTimer.Text = $"x2 MONEY POTION : {(time.TotalHours >= 1 ? time.ToString(@"hh\:mm\:ss") : time.ToString(@"mm\:ss"))}";
            }
            else
            {
                lblMoneyTimer.Visible = false;
            }

            // --- Таймер Мутаций ---
            var mutationEffect = player.ActiveEffects.FirstOrDefault(e => e.EffectType == PotionEffect.MutationBoost);
            if (mutationEffect != null && mutationEffect.TimeRemainingSeconds > 0)
            {
                labelMutationTimer.Visible = true;
                var time = TimeSpan.FromSeconds(mutationEffect.TimeRemainingSeconds);
                labelMutationTimer.Text = $"MUTATION POTION : {(time.TotalHours >= 1 ? time.ToString(@"hh\:mm\:ss") : time.ToString(@"mm\:ss"))}";
            }
            else
            {
                labelMutationTimer.Visible = false;
            }

            // --- Таймер Дубликации (НОВЫЙ БЛОК) ---
            var duplicationEffect = player.ActiveEffects.FirstOrDefault(e => e.EffectType == PotionEffect.DuplicationBoost);
            if (duplicationEffect != null && duplicationEffect.TimeRemainingSeconds > 0)
            {
                labelDuplicationTimer.Visible = true;
                var time = TimeSpan.FromSeconds(duplicationEffect.TimeRemainingSeconds);
                // Эффект короткий, поэтому формат mm:ss
                labelDuplicationTimer.Text = $"DUPLICATION POTION : {(time.TotalHours >= 1 ? time.ToString(@"hh\:mm\:ss") : time.ToString(@"mm\:ss"))}";
            }
            else
            {
                labelDuplicationTimer.Visible = false;
            }
            var wisdomEffect = player.ActiveEffects.FirstOrDefault(e => e.EffectType == PotionEffect.WisdomBoost);
            if (wisdomEffect != null && wisdomEffect.TimeRemainingSeconds > 0)
            {
                lblWisdomTimer.Visible = true;
                var time = TimeSpan.FromSeconds(wisdomEffect.TimeRemainingSeconds);
                lblWisdomTimer.Text = $"x1.5 XP POTION : {(time.TotalHours >= 1 ? time.ToString(@"hh\:mm\:ss") : time.ToString(@"mm\:ss"))}";
            }
            else
            {
                lblWisdomTimer.Visible = false;
            }
        }
        private void PerformSilentRoll()
        {
            // Эта функция не имеет await, звуков и не трогает UI, кроме инвентаря.
            var rolledMaterial = GetRandomMaterial();
            var mutation = GetRandomMutation(); // Мутации тоже учитываются!

            if (player.Stats.MaterialsFound.ContainsKey(rolledMaterial.Name))
                player.Stats.MaterialsFound[rolledMaterial.Name]++;
            else
                player.Stats.MaterialsFound.Add(rolledMaterial.Name, 1);
            if (mutation.Name != "Ничего")
            {
                if (player.Stats.MutationsGotten.ContainsKey(mutation.Name))
                    player.Stats.MutationsGotten[mutation.Name]++;
                else
                    player.Stats.MutationsGotten.Add(mutation.Name, 1);
            }
            string materialName = rolledMaterial.Name;
            string inventoryKey = rolledMaterial.Name;
            if (mutation.Name != "Ничего")
            {
                inventoryKey = $"{rolledMaterial.Name} ({mutation.Name})";
            }

            // Добавляем предмет в инвентарь
            if (player.Inventory.ContainsKey(inventoryKey))
            {
                player.Inventory[inventoryKey]++;
            }
            else
            {
                player.Inventory.Add(inventoryKey, 1);
            }

            // ВАЖНО: нужно обновить лейбл инвентаря, но не всю форму
            UpdateInventoryDisplay();
        }
        private void UpdatePlayPanel()
        {
            if (lastRolledItem != null)
            {
                Image baseImg = lastRolledItem.BaseMaterial.Image;
                // Передаем в Visuals наш анимированный цвет
                Image finalImg = Visuals.ApplyMutationAura(baseImg, lastRolledItem.Mutation.Name, prismaticColor);
                picPanel.BackgroundImage = finalImg;
            }
        }

        // И этот конвертер цвета тоже должен быть в Form1.cs
        public static Color ColorFromHSV(double hue, double saturation, double value)
        {
            int hi = Convert.ToInt32(Math.Floor(hue / 60)) % 6;
            double f = hue / 60 - Math.Floor(hue / 60);
            value = value * 255;
            int v = Convert.ToInt32(value);
            int p = Convert.ToInt32(value * (1 - saturation));
            int q = Convert.ToInt32(value * (1 - f * saturation));
            int t = Convert.ToInt32(value * (1 - (1 - f) * saturation));

            if (hi == 0) return Color.FromArgb(255, v, t, p);
            if (hi == 1) return Color.FromArgb(255, q, v, p);
            if (hi == 2) return Color.FromArgb(255, p, v, t);
            if (hi == 3) return Color.FromArgb(255, p, q, v);
            if (hi == 4) return Color.FromArgb(255, t, p, v);
            return Color.FromArgb(255, v, p, q);
        }
        private void btnAutoRollBuy_Click(object sender, EventArgs e)
        {

            HandleUpgradeClick("AutoRoll");
        }

        private void btnAutoRollBuy_MouseDown(object sender, MouseEventArgs e)
        {
            soundManager.PlaySfx("navigating.wav", SettingsManager.CurrentSettings.SfxVolume);
        }

        private void btnAutoRollBuy_MouseEnter(object sender, EventArgs e)
        {
            soundManager.PlaySfx("navigating.wav", SettingsManager.CurrentSettings.SfxVolume);
        }

        private void settingsButton_Click(object sender, EventArgs e)
        {
            SettingsForm settingsForm = new SettingsForm(soundManager);
            settingsForm.ShowDialog();
        }

        private void btnCraftStoreOpen_Click(object sender, EventArgs e)
        {
            CraftStoreForm craftForm = new CraftStoreForm(this.player, this);
            craftForm.OnPurchaseMade += UpdateUI;
            craftForm.ShowDialog();
            UpdateUI();
        }

        private void panelMoney_Click(object sender, EventArgs e)
        {
            UsePotion("Money Potion");
        }

        private void panelLuck_Click(object sender, EventArgs e)
        {
            UsePotion("Luck Potion");
        }
        private void UsePotion(string potionName)
        {
            // Проверяем, есть ли такое зелье и больше ли его нуля
            if (player.PotionInventory.ContainsKey(potionName) && player.PotionInventory[potionName] > 0)
            {
                if (player.Stats.PotionsUsed.ContainsKey(potionName))
                    player.Stats.PotionsUsed[potionName]++;
                else
                    player.Stats.PotionsUsed.Add(potionName, 1);
                PotionEffect effectType;
                double durationToAdd;

                switch (potionName)
                {
                    case "Luck Potion":
                        effectType = PotionEffect.LuckBoost;
                        durationToAdd = 1800; // 30 минут
                        break;
                    case "Money Potion":
                        effectType = PotionEffect.MoneyBoost;
                        durationToAdd = 1800; // 30 минут
                        break;
                    case "Mutation Potion":
                        effectType = PotionEffect.MutationBoost;
                        durationToAdd = 600; // 10 минут
                        break;
                    // --- ВОТ ОН, НЕДОСТАЮЩИЙ КУСОК ---
                    case "Duplication Potion":
                        effectType = PotionEffect.DuplicationBoost;
                        durationToAdd = 60; // 1 минута
                        break;
                    case "Potion of Wisdom":
                        effectType = PotionEffect.WisdomBoost;
                        durationToAdd = 600; // 10 минут
                        break;
                    // --- КОНЕЦ ---
                    default:
                        return; // Неизвестное зелье
                }

                // --- Проверка на лимит времени в 24 часа ---
                ActiveEffect existingEffect = player.ActiveEffects.FirstOrDefault(e => e.EffectType == effectType);
                if (existingEffect != null)
                {
                    double timeLimitSeconds = 86400; // 24 часа
                    if (existingEffect.TimeRemainingSeconds + durationToAdd > timeLimitSeconds)
                    {
                        soundManager.PlaySfx("cant_buy.wav", SettingsManager.CurrentSettings.SfxVolume);
                        MessageBox.Show("You can't exceed the potion time, more than 24 hours.", "LIMIT");
                        return; // Выходим из метода
                    }
                }

                // --- Если все проверки пройдены ---
                player.PotionInventory[potionName]--; // Уменьшаем количество
                ActivatePotionEffect(potionName);     // Активируем эффект
                soundManager.PlaySfx("drink_potion.wav", SettingsManager.CurrentSettings.SfxVolume);
                UpdateUI(); // Обновляем интерфейс
            }
        }


        // Замени свой старый метод ActivatePotionEffect на этот
        private void ActivatePotionEffect(string potionName)
        {
            PotionEffect effectType;
            double multiplier;
            double duration;

            // Определяем параметры в зависимости от имени зелья
            switch (potionName)
            {
                case "Luck Potion":
                    effectType = PotionEffect.LuckBoost;
                    multiplier = 2.0;
                    duration = 1800; // 30 минут
                    break;
                case "Money Potion":
                    effectType = PotionEffect.MoneyBoost;
                    multiplier = 2.0;
                    duration = 1800; // 30 минут
                    break;
                case "Mutation Potion":
                    effectType = PotionEffect.MutationBoost;
                    multiplier = 1.0; // Множитель тут не важен, но пусть будет
                    duration = 300; // 10 минут
                    break;
                case "Duplication Potion":
                    effectType = PotionEffect.DuplicationBoost;
                    multiplier = 0.2; // Мы будем использовать множитель для хранения шанса (10% = 0.1)
                    duration = 60;
                    break;
                case "Potion of Wisdom":
                    effectType = PotionEffect.WisdomBoost;
                    multiplier = 1.5; // Наш множитель x1.5
                    duration = 600; // 10 минут
                    break;
                default:
                    return;
            }

            // Проверяем, есть ли уже такой активный эффект
            ActiveEffect existingEffect = player.ActiveEffects.FirstOrDefault(e => e.EffectType == effectType);

            if (existingEffect != null)
            {
                // Если есть - просто продлеваем его действие
                existingEffect.TimeRemainingSeconds += duration;
            }
            else
            {
                // Если нет - создаем новый
                player.ActiveEffects.Add(new ActiveEffect
                {
                    EffectType = effectType,
                    Multiplier = multiplier,
                    TimeRemainingSeconds = duration
                });
            }
        }
        private void UpdatePrestigeUI()
        {
            // Обновляем текст уровня
            // Предполагается, что у тебя есть лейбл с именем lblLevel
            lblLevel.Text = $"LVL: {player.Level} (P: {player.PrestigeLevel})";

            // Обновляем текст с опытом
            // Предполагается, что у тебя есть лейбл с именем lblXP
            lblXP.Text = $"{player.CurrentXP.ToString("N0")} / {player.RequiredXP.ToString("N0")} XP";

            // Обновляем ProgressBar
            // Предполагается, что у тебя есть ProgressBar с именем xpProgressBar
            if (player.RequiredXP > 0)
            {
                // BigInteger не лезет в int/double, поэтому нужна безопасная конвертация
                double progressPercentage = 0;
                if (player.CurrentXP < player.RequiredXP)
                {
                    progressPercentage = (double)player.CurrentXP / (double)player.RequiredXP;
                }
                else
                {
                    progressPercentage = 1.0;
                }

                xpProgressBar.Value = (int)(progressPercentage * xpProgressBar.Maximum);
            }
        }
        private void AwardXP(RolledItem item)
        {
            if (item == null) return;

            BigInteger cost = item.FinalValue;
            BigInteger xpGained = cost * 25 / 10 - 2;
            xpGained += (int)item.BaseMaterial.RarityGroup * 10;
            if (item.Mutation.Name != "Ничего")
            {
                xpGained += 50;
            }

            double prestigeMultiplier = 1.0 + (player.PrestigeLevel * GameConstants.PRESTIGE_XP_BONUS);
            var wisdomEffect = player.ActiveEffects.FirstOrDefault(e => e.EffectType == PotionEffect.WisdomBoost);
            double wisdomMultiplier = wisdomEffect?.Multiplier ?? 1.0;
            double totalBonusMultiplier = prestigeMultiplier * wisdomMultiplier;
            xpGained = xpGained * new BigInteger(totalBonusMultiplier * 100) / 100;
            if (xpGained < 1) xpGained = 1;

            player.Stats.TotalXPEarned += xpGained;
            player.CurrentXP += xpGained;

            bool leveledUp = false;
            while (player.CurrentXP >= player.RequiredXP)
            {
                leveledUp = true;
                player.CurrentXP -= player.RequiredXP;
                player.Level++;
                player.RequiredXP = player.RequiredXP * GameConstants.XP_LEVEL_MULTIPLIER_NUMERATOR / GameConstants.XP_LEVEL_MULTIPLIER_DENOMINATOR;
            }

            // <<< ГЛАВНЫЙ ФИКС ЗДЕСЬ >>>
            if (leveledUp)
            {
                soundManager.PlaySfx("level_up.wav", SettingsManager.CurrentSettings.SfxVolume);
                UpdateUI();
            }

            // После начисления XP нужно обновить UI, чтобы игрок видел прогресс
            UpdatePrestigeUI(); // Мы создадим этот метод в шаге 4
        }
        private void panelMutation_Click(object sender, EventArgs e)
        {
            UsePotion("Mutation Potion");
        }

        private void panelDuplication_Click(object sender, EventArgs e)
        {
            UsePotion("Duplication Potion");
        }

        private async void btnPrestige_Click(object sender, EventArgs e)
        {
            // Проверяем, не заняты ли мы чем-то важным
            if (isPrestiging || isRolling) return;

            // Просто выключаем кнопку и запускаем процесс.
            // UpdateUI() после сброса оставит ее выключенной, что правильно.
            btnPrestige.Enabled = false;
            await PerformPrestigeReset();
        }

        private void btnCraftStoreOpen_MouseEnter(object sender, EventArgs e)
        {
            soundManager.PlaySfx("navigating.wav", SettingsManager.CurrentSettings.SfxVolume);
        }

        private void settingsButton_MouseEnter(object sender, EventArgs e)
        {
            soundManager.PlaySfx("navigating.wav", SettingsManager.CurrentSettings.SfxVolume);
        }

        private void btnPrestige_MouseEnter(object sender, EventArgs e)
        {
            soundManager.PlaySfx("navigating.wav", SettingsManager.CurrentSettings.SfxVolume);
        }

        private void panelDuplication_MouseEnter(object sender, EventArgs e)
        {
            soundManager.PlaySfx("navigating.wav", SettingsManager.CurrentSettings.SfxVolume);
        }

        private void panelMutation_MouseEnter(object sender, EventArgs e)
        {
            soundManager.PlaySfx("navigating.wav", SettingsManager.CurrentSettings.SfxVolume);
        }

        private void panelWisdom_Click(object sender, EventArgs e)
        {
            UsePotion("Potion of Wisdom");
        }

        private void btnStats_Click(object sender, EventArgs e)
        {
            StatisticsForm statsForm = new StatisticsForm(player); // Передаем все данные игрока
            statsForm.ShowDialog();
        }

        private void btnCredits_Click(object sender, EventArgs e)
        {
            CreditsForm creditsForm = new CreditsForm();
            creditsForm.Show();
        }

        private void rtbInventory_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.L)
            {
                // Добавляем 1 квадриллион (15 нулей)
                player.Money += System.Numerics.BigInteger.Parse("10000000000000000000000000000");

                // Останавливаем анимацию денег и сразу обновляем текст, чтобы видеть результат
                StopMoneyAnimationAndSync();

                // (Опционально) Обновляем кнопки, чтобы они загорелись, если стало доступно улучшение
                UpdateUI();

                // Проигрываем звук (опционально, используем звук покупки)
                soundManager.PlaySfx("upgrade_buy.wav", SettingsManager.CurrentSettings.SfxVolume);

                // Эта строка запрещает печатать букву "L" или "l" внутри самого инвентаря
                e.SuppressKeyPress = true;
                e.Handled = true;
            }
        }
    }
}