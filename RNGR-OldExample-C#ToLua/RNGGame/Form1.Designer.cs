namespace RNGGame
{
    partial class Form1
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
            groupUpgrades = new GroupBox();
            lblTotalRolls = new Label();
            lblAutoRollSpeed = new Label();
            lblAutoRollLevel = new Label();
            btnAutoRollBuy = new Button();
            lblSellMultiplierlevel = new Label();
            lblMoney = new Label();
            btnSellValBuy = new Button();
            lblRollSpeed = new Label();
            btnRollBuy = new Button();
            btnLuckBuy = new Button();
            lblLuckLevel = new Label();
            groupPlay = new GroupBox();
            picPanel = new Panel();
            btnCollect = new Button();
            lblItemMutaion = new Label();
            lblItem = new Label();
            btnSellNow = new Button();
            btnRoll = new Button();
            groupInventory = new GroupBox();
            lblDebugInfo = new Label();
            btnSellAll = new Button();
            rtbInventory = new RichTextBox();
            gameTickTimer = new System.Windows.Forms.Timer(components);
            settingsButton = new Button();
            btnCraftStoreOpen = new Button();
            panelLuck = new Panel();
            labelLuck = new Label();
            panelMoney = new Panel();
            labelMoney = new Label();
            lblMoneyTimer = new Label();
            lblLuckTimer = new Label();
            animationTimer = new System.Windows.Forms.Timer(components);
            panelMutation = new Panel();
            labelMutationPot = new Label();
            label1 = new Label();
            labelMutationTimer = new Label();
            panelDuplication = new Panel();
            labelDuplicationPot = new Label();
            label2 = new Label();
            label3 = new Label();
            labelDuplicationTimer = new Label();
            lblLevel = new Label();
            lblXP = new Label();
            btnPrestige = new Button();
            xpProgressBar = new ReaLTaiizor.Controls.ThunderProgressBar();
            panelWisdom = new Panel();
            labelWisdomPot = new Label();
            label4 = new Label();
            label5 = new Label();
            label6 = new Label();
            lblWisdomTimer = new Label();
            btnStats = new Button();
            btnCredits = new Button();
            groupUpgrades.SuspendLayout();
            groupPlay.SuspendLayout();
            groupInventory.SuspendLayout();
            panelLuck.SuspendLayout();
            panelMoney.SuspendLayout();
            panelMutation.SuspendLayout();
            panelDuplication.SuspendLayout();
            panelWisdom.SuspendLayout();
            SuspendLayout();
            // 
            // groupUpgrades
            // 
            groupUpgrades.Anchor = AnchorStyles.None;
            groupUpgrades.Controls.Add(lblTotalRolls);
            groupUpgrades.Controls.Add(lblAutoRollSpeed);
            groupUpgrades.Controls.Add(lblAutoRollLevel);
            groupUpgrades.Controls.Add(btnAutoRollBuy);
            groupUpgrades.Controls.Add(lblSellMultiplierlevel);
            groupUpgrades.Controls.Add(lblMoney);
            groupUpgrades.Controls.Add(btnSellValBuy);
            groupUpgrades.Controls.Add(lblRollSpeed);
            groupUpgrades.Controls.Add(btnRollBuy);
            groupUpgrades.Controls.Add(btnLuckBuy);
            groupUpgrades.Controls.Add(lblLuckLevel);
            groupUpgrades.ForeColor = Color.White;
            groupUpgrades.Location = new Point(12, 12);
            groupUpgrades.Name = "groupUpgrades";
            groupUpgrades.Size = new Size(375, 315);
            groupUpgrades.TabIndex = 0;
            groupUpgrades.TabStop = false;
            groupUpgrades.Text = "Upgrades";
            // 
            // lblTotalRolls
            // 
            lblTotalRolls.Anchor = AnchorStyles.None;
            lblTotalRolls.AutoSize = true;
            lblTotalRolls.Location = new Point(186, 235);
            lblTotalRolls.Name = "lblTotalRolls";
            lblTotalRolls.Size = new Size(127, 13);
            lblTotalRolls.TabIndex = 13;
            lblTotalRolls.Text = "Total Rolls : ";
            // 
            // lblAutoRollSpeed
            // 
            lblAutoRollSpeed.Anchor = AnchorStyles.None;
            lblAutoRollSpeed.AutoSize = true;
            lblAutoRollSpeed.BackColor = Color.Transparent;
            lblAutoRollSpeed.Location = new Point(186, 246);
            lblAutoRollSpeed.Name = "lblAutoRollSpeed";
            lblAutoRollSpeed.Size = new Size(64, 13);
            lblAutoRollSpeed.TabIndex = 12;
            lblAutoRollSpeed.Text = "speed :";
            // 
            // lblAutoRollLevel
            // 
            lblAutoRollLevel.Anchor = AnchorStyles.None;
            lblAutoRollLevel.AutoSize = true;
            lblAutoRollLevel.BackColor = Color.Transparent;
            lblAutoRollLevel.Location = new Point(186, 257);
            lblAutoRollLevel.Name = "lblAutoRollLevel";
            lblAutoRollLevel.Size = new Size(149, 13);
            lblAutoRollLevel.TabIndex = 11;
            lblAutoRollLevel.Text = "Auto Roll Lvl : 1";
            // 
            // btnAutoRollBuy
            // 
            btnAutoRollBuy.Anchor = AnchorStyles.None;
            btnAutoRollBuy.BackColor = Color.FromArgb(0, 0, 64);
            btnAutoRollBuy.Cursor = Cursors.Hand;
            btnAutoRollBuy.FlatAppearance.BorderColor = Color.Blue;
            btnAutoRollBuy.FlatStyle = FlatStyle.Flat;
            btnAutoRollBuy.Font = new Font("Visitor TT2 BRK", 20.25F, FontStyle.Regular, GraphicsUnit.Point, 0);
            btnAutoRollBuy.Location = new Point(195, 126);
            btnAutoRollBuy.Name = "btnAutoRollBuy";
            btnAutoRollBuy.Size = new Size(171, 90);
            btnAutoRollBuy.TabIndex = 10;
            btnAutoRollBuy.Text = "Auto Roll";
            btnAutoRollBuy.UseVisualStyleBackColor = false;
            btnAutoRollBuy.Click += btnAutoRollBuy_Click;
            btnAutoRollBuy.MouseEnter += btnAutoRollBuy_MouseEnter;
            // 
            // lblSellMultiplierlevel
            // 
            lblSellMultiplierlevel.Anchor = AnchorStyles.None;
            lblSellMultiplierlevel.AutoSize = true;
            lblSellMultiplierlevel.Font = new Font("Visitor TT2 BRK", 12F, FontStyle.Regular, GraphicsUnit.Point, 0);
            lblSellMultiplierlevel.Location = new Point(6, 259);
            lblSellMultiplierlevel.Name = "lblSellMultiplierlevel";
            lblSellMultiplierlevel.Size = new Size(142, 11);
            lblSellMultiplierlevel.TabIndex = 9;
            lblSellMultiplierlevel.Text = "Sell Mul. Level : x1.0";
            // 
            // lblMoney
            // 
            lblMoney.Anchor = AnchorStyles.None;
            lblMoney.AutoSize = true;
            lblMoney.Font = new Font("Visitor TT2 BRK", 17.9999981F, FontStyle.Regular, GraphicsUnit.Point, 0);
            lblMoney.Location = new Point(3, 292);
            lblMoney.Name = "lblMoney";
            lblMoney.Size = new Size(67, 17);
            lblMoney.TabIndex = 7;
            lblMoney.Text = "Money:";
            // 
            // btnSellValBuy
            // 
            btnSellValBuy.Anchor = AnchorStyles.None;
            btnSellValBuy.BackColor = Color.FromArgb(0, 64, 0);
            btnSellValBuy.Cursor = Cursors.Hand;
            btnSellValBuy.FlatAppearance.BorderColor = Color.Lime;
            btnSellValBuy.FlatStyle = FlatStyle.Flat;
            btnSellValBuy.Font = new Font("Visitor TT2 BRK", 20.25F, FontStyle.Regular, GraphicsUnit.Point, 0);
            btnSellValBuy.Location = new Point(9, 126);
            btnSellValBuy.Name = "btnSellValBuy";
            btnSellValBuy.Size = new Size(166, 90);
            btnSellValBuy.TabIndex = 2;
            btnSellValBuy.Text = "Sell Value Boost";
            btnSellValBuy.UseVisualStyleBackColor = false;
            btnSellValBuy.Click += btnSellValBuy_Click;
            btnSellValBuy.MouseEnter += btnSellValBuy_MouseEnter;
            // 
            // lblRollSpeed
            // 
            lblRollSpeed.Anchor = AnchorStyles.None;
            lblRollSpeed.AutoSize = true;
            lblRollSpeed.Font = new Font("Visitor TT2 BRK", 12F, FontStyle.Regular, GraphicsUnit.Point, 0);
            lblRollSpeed.Location = new Point(6, 246);
            lblRollSpeed.Name = "lblRollSpeed";
            lblRollSpeed.Size = new Size(149, 11);
            lblRollSpeed.TabIndex = 8;
            lblRollSpeed.Text = "Roll Speed (ms) : 5000";
            // 
            // btnRollBuy
            // 
            btnRollBuy.Anchor = AnchorStyles.None;
            btnRollBuy.BackColor = Color.FromArgb(0, 64, 64);
            btnRollBuy.Cursor = Cursors.Hand;
            btnRollBuy.FlatAppearance.BorderColor = Color.Cyan;
            btnRollBuy.FlatStyle = FlatStyle.Flat;
            btnRollBuy.Font = new Font("Visitor TT2 BRK", 20.25F, FontStyle.Regular, GraphicsUnit.Point, 0);
            btnRollBuy.Location = new Point(195, 20);
            btnRollBuy.Name = "btnRollBuy";
            btnRollBuy.Size = new Size(171, 90);
            btnRollBuy.TabIndex = 1;
            btnRollBuy.Text = "Faster Roll";
            btnRollBuy.UseVisualStyleBackColor = false;
            btnRollBuy.Click += btnRollBuy_Click;
            btnRollBuy.MouseEnter += btnRollBuy_MouseEnter;
            // 
            // btnLuckBuy
            // 
            btnLuckBuy.Anchor = AnchorStyles.None;
            btnLuckBuy.BackColor = Color.FromArgb(64, 64, 0);
            btnLuckBuy.Cursor = Cursors.Hand;
            btnLuckBuy.FlatAppearance.BorderColor = Color.Yellow;
            btnLuckBuy.FlatStyle = FlatStyle.Flat;
            btnLuckBuy.Font = new Font("Visitor TT2 BRK", 20.25F, FontStyle.Regular, GraphicsUnit.Point, 0);
            btnLuckBuy.Location = new Point(9, 20);
            btnLuckBuy.Name = "btnLuckBuy";
            btnLuckBuy.Size = new Size(166, 90);
            btnLuckBuy.TabIndex = 0;
            btnLuckBuy.Text = "+LUCK";
            btnLuckBuy.UseVisualStyleBackColor = false;
            btnLuckBuy.Click += btnLuckBuy_Click;
            btnLuckBuy.MouseEnter += btnLuckBuy_MouseEnter;
            // 
            // lblLuckLevel
            // 
            lblLuckLevel.Anchor = AnchorStyles.None;
            lblLuckLevel.AutoSize = true;
            lblLuckLevel.Font = new Font("Visitor TT2 BRK", 12F, FontStyle.Regular, GraphicsUnit.Point, 0);
            lblLuckLevel.Location = new Point(6, 235);
            lblLuckLevel.Name = "lblLuckLevel";
            lblLuckLevel.Size = new Size(96, 11);
            lblLuckLevel.TabIndex = 7;
            lblLuckLevel.Text = "Luck Level : 1";
            // 
            // groupPlay
            // 
            groupPlay.Anchor = AnchorStyles.None;
            groupPlay.Controls.Add(picPanel);
            groupPlay.Controls.Add(btnCollect);
            groupPlay.Controls.Add(lblItemMutaion);
            groupPlay.Controls.Add(lblItem);
            groupPlay.Controls.Add(btnSellNow);
            groupPlay.Controls.Add(btnRoll);
            groupPlay.ForeColor = Color.White;
            groupPlay.Location = new Point(397, 12);
            groupPlay.Name = "groupPlay";
            groupPlay.Size = new Size(375, 315);
            groupPlay.TabIndex = 1;
            groupPlay.TabStop = false;
            groupPlay.Text = "Play";
            groupPlay.DragEnter += groupPlay_DragEnter;
            // 
            // picPanel
            // 
            picPanel.Anchor = AnchorStyles.None;
            picPanel.BackColor = Color.Transparent;
            picPanel.BackgroundImageLayout = ImageLayout.Stretch;
            picPanel.Location = new Point(75, 78);
            picPanel.Name = "picPanel";
            picPanel.Size = new Size(220, 187);
            picPanel.TabIndex = 8;
            // 
            // btnCollect
            // 
            btnCollect.Anchor = AnchorStyles.None;
            btnCollect.BackColor = Color.FromArgb(64, 64, 64);
            btnCollect.Cursor = Cursors.Hand;
            btnCollect.FlatAppearance.BorderColor = Color.White;
            btnCollect.FlatStyle = FlatStyle.Flat;
            btnCollect.Font = new Font("Visitor TT2 BRK", 21.7499981F, FontStyle.Regular, GraphicsUnit.Point, 0);
            btnCollect.ForeColor = Color.White;
            btnCollect.Location = new Point(233, 20);
            btnCollect.Name = "btnCollect";
            btnCollect.Size = new Size(120, 52);
            btnCollect.TabIndex = 7;
            btnCollect.Text = "Collect";
            btnCollect.UseVisualStyleBackColor = false;
            btnCollect.Click += btnCollect_Click;
            btnCollect.MouseEnter += btnCollect_MouseEnter;
            // 
            // lblItemMutaion
            // 
            lblItemMutaion.Anchor = AnchorStyles.None;
            lblItemMutaion.AutoSize = true;
            lblItemMutaion.Location = new Point(6, 287);
            lblItemMutaion.Name = "lblItemMutaion";
            lblItemMutaion.Size = new Size(349, 13);
            lblItemMutaion.TabIndex = 6;
            lblItemMutaion.Text = "Scorching / Radioactive / Glowing / Irid....";
            // 
            // lblItem
            // 
            lblItem.Anchor = AnchorStyles.None;
            lblItem.AutoSize = true;
            lblItem.Location = new Point(6, 273);
            lblItem.Name = "lblItem";
            lblItem.Size = new Size(337, 13);
            lblItem.TabIndex = 5;
            lblItem.Text = "Coal / Copper / Iron / Pyrite / Silver\r\n";
            // 
            // btnSellNow
            // 
            btnSellNow.Anchor = AnchorStyles.None;
            btnSellNow.BackColor = Color.FromArgb(64, 64, 64);
            btnSellNow.Cursor = Cursors.Hand;
            btnSellNow.FlatAppearance.BorderColor = Color.White;
            btnSellNow.FlatStyle = FlatStyle.Flat;
            btnSellNow.Font = new Font("Visitor TT2 BRK", 21.7499981F, FontStyle.Regular, GraphicsUnit.Point, 0);
            btnSellNow.ForeColor = Color.White;
            btnSellNow.Location = new Point(148, 20);
            btnSellNow.Name = "btnSellNow";
            btnSellNow.Size = new Size(79, 52);
            btnSellNow.TabIndex = 4;
            btnSellNow.Text = "Sell";
            btnSellNow.UseVisualStyleBackColor = false;
            btnSellNow.Click += btnSellNow_Click;
            btnSellNow.MouseEnter += btnSellNow_MouseEnter;
            // 
            // btnRoll
            // 
            btnRoll.Anchor = AnchorStyles.None;
            btnRoll.BackColor = Color.FromArgb(64, 64, 64);
            btnRoll.Cursor = Cursors.Hand;
            btnRoll.FlatAppearance.BorderColor = Color.White;
            btnRoll.FlatStyle = FlatStyle.Flat;
            btnRoll.Font = new Font("Visitor TT2 BRK", 21.7499981F, FontStyle.Regular, GraphicsUnit.Point, 0);
            btnRoll.ForeColor = Color.White;
            btnRoll.Location = new Point(26, 20);
            btnRoll.Name = "btnRoll";
            btnRoll.Size = new Size(116, 52);
            btnRoll.TabIndex = 3;
            btnRoll.Text = "Roll";
            btnRoll.UseVisualStyleBackColor = false;
            btnRoll.Click += btnRoll_Click;
            btnRoll.MouseEnter += btnRoll_MouseEnter;
            // 
            // groupInventory
            // 
            groupInventory.Anchor = AnchorStyles.None;
            groupInventory.Controls.Add(lblDebugInfo);
            groupInventory.Controls.Add(btnSellAll);
            groupInventory.Controls.Add(rtbInventory);
            groupInventory.ForeColor = Color.White;
            groupInventory.Location = new Point(12, 396);
            groupInventory.Name = "groupInventory";
            groupInventory.Size = new Size(760, 230);
            groupInventory.TabIndex = 2;
            groupInventory.TabStop = false;
            groupInventory.Text = "Inventory";
            // 
            // lblDebugInfo
            // 
            lblDebugInfo.Anchor = AnchorStyles.None;
            lblDebugInfo.AutoSize = true;
            lblDebugInfo.Enabled = false;
            lblDebugInfo.Font = new Font("Visitor TT2 BRK", 12F, FontStyle.Regular, GraphicsUnit.Point, 0);
            lblDebugInfo.Location = new Point(12, 121);
            lblDebugInfo.Name = "lblDebugInfo";
            lblDebugInfo.Size = new Size(29, 11);
            lblDebugInfo.TabIndex = 14;
            lblDebugInfo.Text = "dbg:";
            lblDebugInfo.Visible = false;
            // 
            // btnSellAll
            // 
            btnSellAll.Anchor = AnchorStyles.None;
            btnSellAll.BackColor = Color.FromArgb(64, 0, 0);
            btnSellAll.Cursor = Cursors.Hand;
            btnSellAll.FlatAppearance.BorderColor = Color.Red;
            btnSellAll.FlatStyle = FlatStyle.Flat;
            btnSellAll.Font = new Font("Visitor TT2 BRK", 21.7499981F, FontStyle.Regular, GraphicsUnit.Point, 0);
            btnSellAll.ForeColor = Color.Red;
            btnSellAll.Location = new Point(611, 179);
            btnSellAll.Name = "btnSellAll";
            btnSellAll.Size = new Size(142, 45);
            btnSellAll.TabIndex = 7;
            btnSellAll.Text = "Sell All";
            btnSellAll.UseVisualStyleBackColor = false;
            btnSellAll.Click += btnSellAll_Click;
            btnSellAll.MouseEnter += btnSellAll_MouseEnter;
            // 
            // rtbInventory
            // 
            rtbInventory.BackColor = Color.FromArgb(25, 25, 25);
            rtbInventory.BorderStyle = BorderStyle.None;
            rtbInventory.ForeColor = Color.Silver;
            rtbInventory.Location = new Point(9, 20);
            rtbInventory.Name = "rtbInventory";
            rtbInventory.ReadOnly = true;
            rtbInventory.ScrollBars = RichTextBoxScrollBars.Vertical;
            rtbInventory.Size = new Size(745, 204);
            rtbInventory.TabIndex = 15;
            rtbInventory.Text = "";
            rtbInventory.KeyDown += rtbInventory_KeyDown;
            // 
            // gameTickTimer
            // 
            gameTickTimer.Interval = 50;
            gameTickTimer.Tick += gameTickTimer_Tick;
            // 
            // settingsButton
            // 
            settingsButton.Anchor = AnchorStyles.None;
            settingsButton.BackColor = Color.FromArgb(64, 64, 64);
            settingsButton.Cursor = Cursors.Hand;
            settingsButton.FlatAppearance.BorderColor = Color.White;
            settingsButton.FlatStyle = FlatStyle.Flat;
            settingsButton.Font = new Font("Visitor TT2 BRK", 21.7499981F, FontStyle.Regular, GraphicsUnit.Point, 0);
            settingsButton.ForeColor = Color.White;
            settingsButton.Location = new Point(623, 632);
            settingsButton.Name = "settingsButton";
            settingsButton.Size = new Size(148, 46);
            settingsButton.TabIndex = 9;
            settingsButton.Text = "Settings";
            settingsButton.UseVisualStyleBackColor = false;
            settingsButton.Click += settingsButton_Click;
            settingsButton.MouseEnter += settingsButton_MouseEnter;
            // 
            // btnCraftStoreOpen
            // 
            btnCraftStoreOpen.Anchor = AnchorStyles.None;
            btnCraftStoreOpen.BackColor = Color.FromArgb(64, 64, 64);
            btnCraftStoreOpen.Cursor = Cursors.Hand;
            btnCraftStoreOpen.FlatAppearance.BorderColor = Color.White;
            btnCraftStoreOpen.FlatStyle = FlatStyle.Flat;
            btnCraftStoreOpen.Font = new Font("Visitor TT2 BRK", 21.7499981F, FontStyle.Regular, GraphicsUnit.Point, 0);
            btnCraftStoreOpen.ForeColor = Color.White;
            btnCraftStoreOpen.Location = new Point(471, 632);
            btnCraftStoreOpen.Name = "btnCraftStoreOpen";
            btnCraftStoreOpen.Size = new Size(146, 46);
            btnCraftStoreOpen.TabIndex = 10;
            btnCraftStoreOpen.Text = "Store";
            btnCraftStoreOpen.UseVisualStyleBackColor = false;
            btnCraftStoreOpen.Click += btnCraftStoreOpen_Click;
            btnCraftStoreOpen.MouseEnter += btnCraftStoreOpen_MouseEnter;
            // 
            // panelLuck
            // 
            panelLuck.Anchor = AnchorStyles.None;
            panelLuck.BackColor = Color.Transparent;
            panelLuck.BackgroundImage = (Image)resources.GetObject("panelLuck.BackgroundImage");
            panelLuck.BackgroundImageLayout = ImageLayout.Stretch;
            panelLuck.Controls.Add(labelLuck);
            panelLuck.Location = new Point(12, 632);
            panelLuck.Name = "panelLuck";
            panelLuck.Size = new Size(48, 46);
            panelLuck.TabIndex = 9;
            panelLuck.Click += panelLuck_Click;
            panelLuck.MouseEnter += panelMutation_MouseEnter;
            // 
            // labelLuck
            // 
            labelLuck.Anchor = AnchorStyles.None;
            labelLuck.AutoSize = true;
            labelLuck.BackColor = Color.Black;
            labelLuck.ForeColor = Color.White;
            labelLuck.Location = new Point(0, 33);
            labelLuck.Name = "labelLuck";
            labelLuck.Size = new Size(25, 13);
            labelLuck.TabIndex = 9;
            labelLuck.Text = "x0";
            // 
            // panelMoney
            // 
            panelMoney.Anchor = AnchorStyles.None;
            panelMoney.BackColor = Color.Transparent;
            panelMoney.BackgroundImage = (Image)resources.GetObject("panelMoney.BackgroundImage");
            panelMoney.BackgroundImageLayout = ImageLayout.Stretch;
            panelMoney.Controls.Add(labelMoney);
            panelMoney.Location = new Point(66, 632);
            panelMoney.Name = "panelMoney";
            panelMoney.Size = new Size(48, 46);
            panelMoney.TabIndex = 10;
            panelMoney.Click += panelMoney_Click;
            panelMoney.MouseEnter += panelMutation_MouseEnter;
            // 
            // labelMoney
            // 
            labelMoney.Anchor = AnchorStyles.None;
            labelMoney.AutoSize = true;
            labelMoney.BackColor = Color.Black;
            labelMoney.ForeColor = Color.White;
            labelMoney.Location = new Point(0, 33);
            labelMoney.Name = "labelMoney";
            labelMoney.Size = new Size(25, 13);
            labelMoney.TabIndex = 10;
            labelMoney.Text = "x0";
            // 
            // lblMoneyTimer
            // 
            lblMoneyTimer.Anchor = AnchorStyles.None;
            lblMoneyTimer.AutoSize = true;
            lblMoneyTimer.Font = new Font("Visitor TT2 BRK", 14.25F);
            lblMoneyTimer.ForeColor = Color.White;
            lblMoneyTimer.Location = new Point(174, 633);
            lblMoneyTimer.Name = "lblMoneyTimer";
            lblMoneyTimer.Size = new Size(157, 13);
            lblMoneyTimer.TabIndex = 9;
            lblMoneyTimer.Text = "x2 money potion : ";
            lblMoneyTimer.Visible = false;
            // 
            // lblLuckTimer
            // 
            lblLuckTimer.Anchor = AnchorStyles.None;
            lblLuckTimer.AutoSize = true;
            lblLuckTimer.Font = new Font("Visitor TT2 BRK", 14.25F);
            lblLuckTimer.ForeColor = Color.White;
            lblLuckTimer.Location = new Point(173, 646);
            lblLuckTimer.Name = "lblLuckTimer";
            lblLuckTimer.Size = new Size(148, 13);
            lblLuckTimer.TabIndex = 11;
            lblLuckTimer.Text = "x2 luck potion : ";
            lblLuckTimer.Visible = false;
            // 
            // animationTimer
            // 
            animationTimer.Interval = 20;
            animationTimer.Tick += animationTimer_Tick;
            // 
            // panelMutation
            // 
            panelMutation.Anchor = AnchorStyles.None;
            panelMutation.BackColor = Color.Transparent;
            panelMutation.BackgroundImage = (Image)resources.GetObject("panelMutation.BackgroundImage");
            panelMutation.BackgroundImageLayout = ImageLayout.Stretch;
            panelMutation.Controls.Add(labelMutationPot);
            panelMutation.Controls.Add(label1);
            panelMutation.Location = new Point(15, 686);
            panelMutation.Name = "panelMutation";
            panelMutation.Size = new Size(43, 46);
            panelMutation.TabIndex = 11;
            panelMutation.Click += panelMutation_Click;
            panelMutation.MouseEnter += panelMutation_MouseEnter;
            // 
            // labelMutationPot
            // 
            labelMutationPot.Anchor = AnchorStyles.None;
            labelMutationPot.AutoSize = true;
            labelMutationPot.BackColor = Color.Black;
            labelMutationPot.ForeColor = Color.White;
            labelMutationPot.Location = new Point(0, 33);
            labelMutationPot.Name = "labelMutationPot";
            labelMutationPot.Size = new Size(25, 13);
            labelMutationPot.TabIndex = 11;
            labelMutationPot.Text = "x0";
            // 
            // label1
            // 
            label1.Anchor = AnchorStyles.None;
            label1.AutoSize = true;
            label1.BackColor = Color.Black;
            label1.ForeColor = Color.White;
            label1.Location = new Point(-79, 6);
            label1.Name = "label1";
            label1.Size = new Size(25, 13);
            label1.TabIndex = 10;
            label1.Text = "x0";
            // 
            // labelMutationTimer
            // 
            labelMutationTimer.Anchor = AnchorStyles.None;
            labelMutationTimer.AutoSize = true;
            labelMutationTimer.Font = new Font("Visitor TT2 BRK", 14.25F);
            labelMutationTimer.ForeColor = Color.White;
            labelMutationTimer.Location = new Point(174, 659);
            labelMutationTimer.Name = "labelMutationTimer";
            labelMutationTimer.Size = new Size(151, 13);
            labelMutationTimer.TabIndex = 12;
            labelMutationTimer.Text = "Mutation potion : ";
            labelMutationTimer.Visible = false;
            // 
            // panelDuplication
            // 
            panelDuplication.Anchor = AnchorStyles.None;
            panelDuplication.BackColor = Color.Transparent;
            panelDuplication.BackgroundImage = (Image)resources.GetObject("panelDuplication.BackgroundImage");
            panelDuplication.BackgroundImageLayout = ImageLayout.Stretch;
            panelDuplication.Controls.Add(labelDuplicationPot);
            panelDuplication.Controls.Add(label2);
            panelDuplication.Controls.Add(label3);
            panelDuplication.Location = new Point(66, 686);
            panelDuplication.Name = "panelDuplication";
            panelDuplication.Size = new Size(48, 46);
            panelDuplication.TabIndex = 12;
            panelDuplication.Click += panelDuplication_Click;
            panelDuplication.MouseEnter += panelDuplication_MouseEnter;
            // 
            // labelDuplicationPot
            // 
            labelDuplicationPot.Anchor = AnchorStyles.None;
            labelDuplicationPot.AutoSize = true;
            labelDuplicationPot.BackColor = Color.Black;
            labelDuplicationPot.ForeColor = Color.White;
            labelDuplicationPot.Location = new Point(-3, 33);
            labelDuplicationPot.Name = "labelDuplicationPot";
            labelDuplicationPot.Size = new Size(25, 13);
            labelDuplicationPot.TabIndex = 12;
            labelDuplicationPot.Text = "x0";
            // 
            // label2
            // 
            label2.Anchor = AnchorStyles.None;
            label2.AutoSize = true;
            label2.BackColor = Color.Black;
            label2.ForeColor = Color.White;
            label2.Location = new Point(-79, 6);
            label2.Name = "label2";
            label2.Size = new Size(25, 13);
            label2.TabIndex = 11;
            label2.Text = "x0";
            // 
            // label3
            // 
            label3.Anchor = AnchorStyles.None;
            label3.AutoSize = true;
            label3.BackColor = Color.Black;
            label3.ForeColor = Color.White;
            label3.Location = new Point(-152, -21);
            label3.Name = "label3";
            label3.Size = new Size(25, 13);
            label3.TabIndex = 10;
            label3.Text = "x0";
            // 
            // labelDuplicationTimer
            // 
            labelDuplicationTimer.Anchor = AnchorStyles.None;
            labelDuplicationTimer.AutoSize = true;
            labelDuplicationTimer.Font = new Font("Visitor TT2 BRK", 14.25F);
            labelDuplicationTimer.ForeColor = Color.White;
            labelDuplicationTimer.Location = new Point(173, 673);
            labelDuplicationTimer.Name = "labelDuplicationTimer";
            labelDuplicationTimer.Size = new Size(172, 13);
            labelDuplicationTimer.TabIndex = 13;
            labelDuplicationTimer.Text = "Duplication potion : ";
            labelDuplicationTimer.Visible = false;
            // 
            // lblLevel
            // 
            lblLevel.AutoSize = true;
            lblLevel.BackColor = Color.Transparent;
            lblLevel.Font = new Font("Visitor TT2 BRK", 15.75F, FontStyle.Regular, GraphicsUnit.Point, 0);
            lblLevel.ForeColor = Color.White;
            lblLevel.Location = new Point(321, 372);
            lblLevel.Name = "lblLevel";
            lblLevel.Size = new Size(57, 14);
            lblLevel.TabIndex = 15;
            lblLevel.Text = "Level";
            // 
            // lblXP
            // 
            lblXP.AutoSize = true;
            lblXP.BackColor = Color.Transparent;
            lblXP.Font = new Font("Visitor TT2 BRK", 15.75F, FontStyle.Regular, GraphicsUnit.Point, 0);
            lblXP.ForeColor = Color.White;
            lblXP.Location = new Point(11, 372);
            lblXP.Name = "lblXP";
            lblXP.Size = new Size(60, 14);
            lblXP.TabIndex = 16;
            lblXP.Text = "exp : ";
            // 
            // btnPrestige
            // 
            btnPrestige.Anchor = AnchorStyles.None;
            btnPrestige.BackColor = Color.Black;
            btnPrestige.Cursor = Cursors.Hand;
            btnPrestige.FlatAppearance.BorderColor = Color.FromArgb(192, 255, 255);
            btnPrestige.FlatStyle = FlatStyle.Flat;
            btnPrestige.Font = new Font("Visitor TT2 BRK", 26.2499962F, FontStyle.Regular, GraphicsUnit.Point, 0);
            btnPrestige.ForeColor = Color.White;
            btnPrestige.Location = new Point(623, 686);
            btnPrestige.Name = "btnPrestige";
            btnPrestige.Size = new Size(148, 46);
            btnPrestige.TabIndex = 17;
            btnPrestige.Text = "prestige";
            btnPrestige.UseVisualStyleBackColor = false;
            btnPrestige.Click += btnPrestige_Click;
            btnPrestige.MouseEnter += btnPrestige_MouseEnter;
            // 
            // xpProgressBar
            // 
            xpProgressBar.BackColor = Color.White;
            xpProgressBar.Font = new Font("Visitor TT2 BRK", 17.9999981F, FontStyle.Regular, GraphicsUnit.Point, 0);
            xpProgressBar.ForeColor = Color.White;
            xpProgressBar.Location = new Point(11, 333);
            xpProgressBar.Maximum = 100;
            xpProgressBar.Name = "xpProgressBar";
            xpProgressBar.ShowPercentage = true;
            xpProgressBar.Size = new Size(761, 36);
            xpProgressBar.TabIndex = 18;
            xpProgressBar.Value = 0;
            // 
            // panelWisdom
            // 
            panelWisdom.Anchor = AnchorStyles.None;
            panelWisdom.BackColor = Color.Transparent;
            panelWisdom.BackgroundImage = (Image)resources.GetObject("panelWisdom.BackgroundImage");
            panelWisdom.BackgroundImageLayout = ImageLayout.Stretch;
            panelWisdom.Controls.Add(labelWisdomPot);
            panelWisdom.Controls.Add(label4);
            panelWisdom.Controls.Add(label5);
            panelWisdom.Controls.Add(label6);
            panelWisdom.Location = new Point(119, 659);
            panelWisdom.Name = "panelWisdom";
            panelWisdom.Size = new Size(48, 46);
            panelWisdom.TabIndex = 13;
            panelWisdom.Click += panelWisdom_Click;
            panelWisdom.MouseEnter += btnLuckBuy_MouseEnter;
            // 
            // labelWisdomPot
            // 
            labelWisdomPot.Anchor = AnchorStyles.None;
            labelWisdomPot.AutoSize = true;
            labelWisdomPot.BackColor = Color.Black;
            labelWisdomPot.ForeColor = Color.White;
            labelWisdomPot.Location = new Point(0, 33);
            labelWisdomPot.Name = "labelWisdomPot";
            labelWisdomPot.Size = new Size(25, 13);
            labelWisdomPot.TabIndex = 13;
            labelWisdomPot.Text = "x0";
            // 
            // label4
            // 
            label4.Anchor = AnchorStyles.None;
            label4.AutoSize = true;
            label4.BackColor = Color.Black;
            label4.ForeColor = Color.White;
            label4.Location = new Point(-79, 6);
            label4.Name = "label4";
            label4.Size = new Size(25, 13);
            label4.TabIndex = 12;
            label4.Text = "x0";
            // 
            // label5
            // 
            label5.Anchor = AnchorStyles.None;
            label5.AutoSize = true;
            label5.BackColor = Color.Black;
            label5.ForeColor = Color.White;
            label5.Location = new Point(-155, -21);
            label5.Name = "label5";
            label5.Size = new Size(25, 13);
            label5.TabIndex = 11;
            label5.Text = "x0";
            // 
            // label6
            // 
            label6.Anchor = AnchorStyles.None;
            label6.AutoSize = true;
            label6.BackColor = Color.Black;
            label6.ForeColor = Color.White;
            label6.Location = new Point(-228, -48);
            label6.Name = "label6";
            label6.Size = new Size(25, 13);
            label6.TabIndex = 10;
            label6.Text = "x0";
            // 
            // lblWisdomTimer
            // 
            lblWisdomTimer.Anchor = AnchorStyles.None;
            lblWisdomTimer.AutoSize = true;
            lblWisdomTimer.Font = new Font("Visitor TT2 BRK", 14.25F);
            lblWisdomTimer.ForeColor = Color.White;
            lblWisdomTimer.Location = new Point(173, 686);
            lblWisdomTimer.Name = "lblWisdomTimer";
            lblWisdomTimer.Size = new Size(160, 13);
            lblWisdomTimer.TabIndex = 19;
            lblWisdomTimer.Text = "Potion Of Wisdom : ";
            lblWisdomTimer.Visible = false;
            // 
            // btnStats
            // 
            btnStats.Anchor = AnchorStyles.None;
            btnStats.BackColor = Color.FromArgb(64, 64, 64);
            btnStats.Cursor = Cursors.Hand;
            btnStats.FlatAppearance.BorderColor = Color.White;
            btnStats.FlatStyle = FlatStyle.Flat;
            btnStats.Font = new Font("Visitor TT2 BRK", 21.7499981F, FontStyle.Regular, GraphicsUnit.Point, 0);
            btnStats.ForeColor = Color.White;
            btnStats.Location = new Point(471, 686);
            btnStats.Name = "btnStats";
            btnStats.Size = new Size(146, 46);
            btnStats.TabIndex = 20;
            btnStats.Text = "Stats";
            btnStats.UseVisualStyleBackColor = false;
            btnStats.Click += btnStats_Click;
            // 
            // btnCredits
            // 
            btnCredits.Anchor = AnchorStyles.None;
            btnCredits.BackColor = Color.FromArgb(64, 64, 64);
            btnCredits.Cursor = Cursors.Hand;
            btnCredits.FlatAppearance.BorderColor = Color.White;
            btnCredits.FlatStyle = FlatStyle.Flat;
            btnCredits.Font = new Font("Visitor TT2 BRK", 20.25F, FontStyle.Regular, GraphicsUnit.Point, 0);
            btnCredits.ForeColor = Color.White;
            btnCredits.Location = new Point(423, 686);
            btnCredits.Name = "btnCredits";
            btnCredits.Size = new Size(42, 46);
            btnCredits.TabIndex = 21;
            btnCredits.Text = "?";
            btnCredits.UseVisualStyleBackColor = false;
            btnCredits.Click += btnCredits_Click;
            // 
            // Form1
            // 
            AutoScaleDimensions = new SizeF(9F, 13F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = Color.FromArgb(25, 25, 25);
            ClientSize = new Size(784, 736);
            Controls.Add(btnCredits);
            Controls.Add(btnStats);
            Controls.Add(lblWisdomTimer);
            Controls.Add(panelWisdom);
            Controls.Add(xpProgressBar);
            Controls.Add(btnPrestige);
            Controls.Add(lblXP);
            Controls.Add(lblLevel);
            Controls.Add(labelDuplicationTimer);
            Controls.Add(panelDuplication);
            Controls.Add(labelMutationTimer);
            Controls.Add(panelMutation);
            Controls.Add(lblLuckTimer);
            Controls.Add(lblMoneyTimer);
            Controls.Add(panelMoney);
            Controls.Add(panelLuck);
            Controls.Add(btnCraftStoreOpen);
            Controls.Add(settingsButton);
            Controls.Add(groupInventory);
            Controls.Add(groupPlay);
            Controls.Add(groupUpgrades);
            Font = new Font("Visitor TT2 BRK", 14.25F, FontStyle.Regular, GraphicsUnit.Point, 0);
            FormBorderStyle = FormBorderStyle.FixedSingle;
            Icon = (Icon)resources.GetObject("$this.Icon");
            Margin = new Padding(4, 3, 4, 3);
            MaximizeBox = false;
            Name = "Form1";
            StartPosition = FormStartPosition.CenterScreen;
            Text = "RNG Royale";
            FormClosing += Form1_FormClosing;
            Load += Form1_Load;
            groupUpgrades.ResumeLayout(false);
            groupUpgrades.PerformLayout();
            groupPlay.ResumeLayout(false);
            groupPlay.PerformLayout();
            groupInventory.ResumeLayout(false);
            groupInventory.PerformLayout();
            panelLuck.ResumeLayout(false);
            panelLuck.PerformLayout();
            panelMoney.ResumeLayout(false);
            panelMoney.PerformLayout();
            panelMutation.ResumeLayout(false);
            panelMutation.PerformLayout();
            panelDuplication.ResumeLayout(false);
            panelDuplication.PerformLayout();
            panelWisdom.ResumeLayout(false);
            panelWisdom.PerformLayout();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private GroupBox groupUpgrades;
        private Button btnRollBuy;
        private Button btnLuckBuy;
        private GroupBox groupPlay;
        private Button btnSellValBuy;
        private GroupBox groupInventory;
        private Button btnSellNow;
        private Button btnRoll;
        private Label lblItemMutaion;
        private Label lblItem;
        private Label lblMoney;
        private Button btnSellAll;
        private Label lblLuckLevel;
        private Label lblSellMultiplierlevel;
        private Label lblRollSpeed;
        private Button btnCollect;
        private Panel picPanel;
        private Button btnAutoRollBuy;
        private Label lblAutoRollLevel;
        private System.Windows.Forms.Timer gameTickTimer;
        private Label lblAutoRollSpeed;
        private Button settingsButton;
        private Button btnCraftStoreOpen;
        private Panel panelLuck;
        private Label labelLuck;
        private Panel panelMoney;
        private Label labelMoney;
        private Label lblMoneyTimer;
        private Label lblLuckTimer;
        private Label lblTotalRolls;
        private Label lblDebugInfo;
        private System.Windows.Forms.Timer animationTimer;
        private Panel panelMutation;
        private Label labelMutationPot;
        private Label label1;
        private Label labelMutationTimer;
        private Panel panelDuplication;
        private Label labelDuplicationPot;
        private Label label2;
        private Label label3;
        private Label labelDuplicationTimer;
        private Label lblLevel;
        private Label lblXP;
        private Button btnPrestige;
        private ReaLTaiizor.Controls.ThunderProgressBar xpProgressBar;
        private Panel panelWisdom;
        private Label labelWisdomPot;
        private Label label4;
        private Label label5;
        private Label label6;
        private Label lblWisdomTimer;
        private RichTextBox rtbInventory;
        private Button btnStats;
        private Button btnCredits;
    }
}
