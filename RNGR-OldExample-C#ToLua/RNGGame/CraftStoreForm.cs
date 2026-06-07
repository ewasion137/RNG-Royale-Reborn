using System;
using System.Collections.Generic;
using System.Linq; // Понадобится для Linq
using System.Numerics;
using System.Windows.Forms;

namespace RNGGame
{
    public partial class CraftStoreForm : Form
    {
        private PlayerData player;
        private Form1 mainForm; // <<< Ссылка на главную форму для фикса бага
        private SoundManager soundManager = new SoundManager();
        private List<Potion> availablePotions = new List<Potion>();
        public event Action OnPurchaseMade;

        // <<< Конструктор теперь принимает и главную форму >>>
        public CraftStoreForm(PlayerData currentPlayerData, Form1 form)
        {
            InitializeComponent();
            this.player = currentPlayerData;
            this.mainForm = form; // Сохраняем ссылку
        }

        private void CraftStoreForm_Load(object sender, EventArgs e)
        {
            InitializePotions();
            UpdateUI();
        }

        private void InitializePotions()
        {
            availablePotions.Clear(); // Очищаем на всякий случай

            availablePotions.Add(new Potion { Name = "Luck Potion", Description = "GIVES YOU X2 LUCK ON 30 MINS", Cost = 350000 });
            availablePotions.Add(new Potion { Name = "Money Potion", Description = "GIVES YOU X2 MONEY ON 30 MINS", Cost = 200000 });
            availablePotions.Add(new Potion { Name = "Mutation Potion", Description = "GUARANTEED ANY MUTATION WITHIN 5 MINUTES", Cost = 250000000 });
            availablePotions.Add(new Potion { Name = "Duplication Potion", Description = "HAVE 20% CHANCE TO DUPLICATE OBJECT", Cost = 100000000 });

            // <<< ВОТ ОНО, НАШЕ НОВОЕ ЗЕЛЬЕ >>>
            availablePotions.Add(new Potion { Name = "Potion of Wisdom", Description = "INCREASES XP GAIN BY 1.5X FOR 10 MINS", Cost = 500000 });
        }

        private void UpdateUI()
        {
            // Теперь UI обновляется автоматически для всех зелий
            btnBuyLuckPotion.Enabled = player.Money >= availablePotions.First(p => p.Name == "Luck Potion").Cost;
            btnBuyMoneyPotion.Enabled = player.Money >= availablePotions.First(p => p.Name == "Money Potion").Cost;
            btnBuyMutationPotion.Enabled = player.Money >= availablePotions.First(p => p.Name == "Mutation Potion").Cost;
            btnBuyDuplicationPotion.Enabled = player.Money >= availablePotions.First(p => p.Name == "Duplication Potion").Cost;
            btnBuyWisdomPotion.Enabled = player.Money >= availablePotions.First(p => p.Name == "Potion of Wisdom").Cost;
        }

        // --- Обработчики кнопок теперь просто вызывают один метод ---
        private void btnBuyLuckPotion_Click(object sender, EventArgs e) => HandlePotionBuy("Luck Potion");
        private void btnBuyMoneyPotion_Click(object sender, EventArgs e) => HandlePotionBuy("Money Potion");
        private void btnBuyMutationPotion_Click(object sender, EventArgs e) => HandlePotionBuy("Mutation Potion");
        private void btnBuyDuplicationPotion_Click(object sender, EventArgs e) => HandlePotionBuy("Duplication Potion");
        private void btnBuyWisdomPotion_Click(object sender, EventArgs e) => HandlePotionBuy("Potion of Wisdom");


        // <<< УНИВЕРСАЛЬНЫЙ МЕТОД ПОКУПКИ С ФИКСОМ БАГА >>>
        private void HandlePotionBuy(string potionName)
        {
            Potion potionToBuy = availablePotions.FirstOrDefault(p => p.Name == potionName);
            if (potionToBuy == null) return;

            if (player.Money >= potionToBuy.Cost)
            {
                // <<< ФИКС БАГА АНИМАЦИИ ДЕНЕГ >>>
                mainForm.StopMoneyAnimationAndSync();
                player.Money -= potionToBuy.Cost;
                mainForm.StopMoneyAnimationAndSync();

                if (player.PotionInventory.ContainsKey(potionToBuy.Name))
                    player.PotionInventory[potionToBuy.Name]++;
                else
                    player.PotionInventory.Add(potionToBuy.Name, 1);

                soundManager.PlaySfx("upgrade_buy.wav", SettingsManager.CurrentSettings.SfxVolume);
                OnPurchaseMade?.Invoke();
                UpdateUI();
            }
            else
            {
                soundManager.PlaySfx("cant_buy.wav", SettingsManager.CurrentSettings.SfxVolume);
            }
        }

        private void btnBuyWisdomPotion_MouseEnter(object sender, EventArgs e)
        {
            soundManager.PlaySfx("navigating.wav", SettingsManager.CurrentSettings.SfxVolume);
        }
    }
}