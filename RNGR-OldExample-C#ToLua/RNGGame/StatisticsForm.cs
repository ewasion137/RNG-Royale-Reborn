using System;
using System.Drawing;
using System.Linq;
using System.Windows.Forms;

namespace RNGGame
{
    public partial class StatisticsForm : Form
    {
        private PlayerData player;

        public StatisticsForm(PlayerData playerData)
        {
            InitializeComponent();
            this.player = playerData;
        }

        private void StatisticsForm_Load(object sender, EventArgs e)
        {
            DisplayStats();
        }

        private void DisplayStats()
        {
            rtbStats.Clear();

            // --- ОБЩАЯ СТАТИСТИКА ---
            AppendHeader("GENERAL STATS");
            AppendStat("Total Rolls (Lifetime)", $"{player.Stats.TotalRollsAllTime:N0}");
            AppendStat("Total Money Earned", $"${player.Stats.TotalMoneyEarned:N0}");
            AppendStat("Total XP Earned", $"{player.Stats.TotalXPEarned:N0} XP");
            AppendStat("Prestige Level", player.PrestigeLevel.ToString());
            rtbStats.AppendText("\n");

            // --- МАТЕРИАЛЫ ---
            AppendHeader("MATERIALS FOUND");
            if (player.Stats.MaterialsFound.Any())
            {
                foreach (var item in player.Stats.MaterialsFound.OrderByDescending(kvp => kvp.Value))
                {
                    AppendStat(item.Key, $"{item.Value:N0}");
                }
            }
            else
            {
                // <<< ИСПРАВЛЕНИЕ ЗДЕСЬ >>>
                AppendText("None yet\n", Color.Gray);
            }
            rtbStats.AppendText("\n");

            // --- МУТАЦИИ ---
            AppendHeader("MUTATIONS GOTTEN");
            if (player.Stats.MutationsGotten.Any())
            {
                foreach (var item in player.Stats.MutationsGotten.OrderByDescending(kvp => kvp.Value))
                {
                    AppendStat(item.Key, $"{item.Value:N0}");
                }
            }
            else
            {
                // <<< И ИСПРАВЛЕНИЕ ЗДЕСЬ >>>
                AppendText("None yet\n", Color.Gray);
            }
            rtbStats.AppendText("\n");
        }

        // Вспомогательные методы для красивого вывода
        private void AppendHeader(string text)
        {
            rtbStats.SelectionFont = new Font("Visitor TT2 BRK", 14, FontStyle.Bold);
            rtbStats.SelectionColor = Color.White;
            rtbStats.AppendText($"--- {text} ---\n");
        }

        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(StatisticsForm));
            rtbStats = new RichTextBox();
            SuspendLayout();
            // 
            // rtbStats
            // 
            rtbStats.BackColor = Color.FromArgb(25, 25, 25);
            rtbStats.BorderStyle = BorderStyle.None;
            rtbStats.ForeColor = Color.White;
            rtbStats.Location = new Point(12, 12);
            rtbStats.Name = "rtbStats";
            rtbStats.ReadOnly = true;
            rtbStats.Size = new Size(703, 334);
            rtbStats.TabIndex = 0;
            rtbStats.Text = "";
            // 
            // StatisticsForm
            // 
            BackColor = Color.FromArgb(25, 25, 25);
            ClientSize = new Size(727, 358);
            Controls.Add(rtbStats);
            Font = new Font("Visitor TT2 BRK", 14.25F, FontStyle.Regular, GraphicsUnit.Point, 0);
            Icon = (Icon)resources.GetObject("$this.Icon");
            MaximizeBox = false;
            Name = "StatisticsForm";
            ShowIcon = false;
            ShowInTaskbar = false;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "Statistics";
            Load += StatisticsForm_Load;
            ResumeLayout(false);

        }
        private void AppendText(string text, Color color)
        {
            rtbStats.SelectionFont = new Font("Visitor TT2 BRK", 14, FontStyle.Bold);
            rtbStats.SelectionColor = color;
            rtbStats.AppendText(text);
        }

        private void AppendStat(string name, string value)
        {
            rtbStats.SelectionFont = new Font("Visitor TT2 BRK", 14, FontStyle.Bold);
            rtbStats.SelectionColor = Color.LightGray;
            rtbStats.AppendText($"{name}: ");

            rtbStats.SelectionColor = Color.White;
            rtbStats.AppendText($"{value}\n");
        }
        private RichTextBox rtbStats;
    }
}