namespace RNGGame
{
    partial class SettingsForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
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
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(SettingsForm));
            musicVolumeTrackBar = new TrackBar();
            label1 = new Label();
            label2 = new Label();
            label3 = new Label();
            sfxVolumeTrackBar = new TrackBar();
            resetProgressButton = new Button();
            closeButton = new Button();
            ((System.ComponentModel.ISupportInitialize)musicVolumeTrackBar).BeginInit();
            ((System.ComponentModel.ISupportInitialize)sfxVolumeTrackBar).BeginInit();
            SuspendLayout();
            // 
            // musicVolumeTrackBar
            // 
            musicVolumeTrackBar.Cursor = Cursors.SizeWE;
            musicVolumeTrackBar.Location = new Point(12, 12);
            musicVolumeTrackBar.Maximum = 100;
            musicVolumeTrackBar.Name = "musicVolumeTrackBar";
            musicVolumeTrackBar.Size = new Size(589, 45);
            musicVolumeTrackBar.TabIndex = 0;
            musicVolumeTrackBar.Value = 50;
            musicVolumeTrackBar.Scroll += musicVolumeTrackBar_Scroll;
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Visitor TT2 BRK", 71.99999F, FontStyle.Bold | FontStyle.Italic, GraphicsUnit.Point, 0);
            label1.ForeColor = Color.White;
            label1.Location = new Point(12, 285);
            label1.Name = "label1";
            label1.Size = new Size(397, 67);
            label1.TabIndex = 1;
            label1.Text = "SETTINGS";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Visitor TT2 BRK", 20.25F, FontStyle.Regular, GraphicsUnit.Point, 0);
            label2.ForeColor = Color.White;
            label2.Location = new Point(601, 16);
            label2.Name = "label2";
            label2.Size = new Size(165, 19);
            label2.TabIndex = 2;
            label2.Text = "MUSIC VOLUME";
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Font = new Font("Visitor TT2 BRK", 20.25F, FontStyle.Regular, GraphicsUnit.Point, 0);
            label3.ForeColor = Color.White;
            label3.Location = new Point(601, 67);
            label3.Name = "label3";
            label3.Size = new Size(139, 19);
            label3.TabIndex = 4;
            label3.Text = "SFX VOLUME";
            // 
            // sfxVolumeTrackBar
            // 
            sfxVolumeTrackBar.Cursor = Cursors.SizeWE;
            sfxVolumeTrackBar.Location = new Point(12, 63);
            sfxVolumeTrackBar.Maximum = 100;
            sfxVolumeTrackBar.Name = "sfxVolumeTrackBar";
            sfxVolumeTrackBar.Size = new Size(589, 45);
            sfxVolumeTrackBar.TabIndex = 3;
            sfxVolumeTrackBar.Value = 50;
            sfxVolumeTrackBar.Scroll += sfxVolumeTrackBar_Scroll;
            // 
            // resetProgressButton
            // 
            resetProgressButton.Anchor = AnchorStyles.None;
            resetProgressButton.AutoSize = true;
            resetProgressButton.BackColor = Color.FromArgb(64, 0, 0);
            resetProgressButton.Cursor = Cursors.Hand;
            resetProgressButton.FlatAppearance.BorderColor = Color.Red;
            resetProgressButton.FlatStyle = FlatStyle.Flat;
            resetProgressButton.Font = new Font("Visitor TT2 BRK", 35.9999962F, FontStyle.Bold | FontStyle.Italic, GraphicsUnit.Point, 0);
            resetProgressButton.ForeColor = Color.Red;
            resetProgressButton.Location = new Point(12, 162);
            resetProgressButton.Name = "resetProgressButton";
            resetProgressButton.Size = new Size(754, 62);
            resetProgressButton.TabIndex = 17;
            resetProgressButton.Text = "RESET PROGRESS";
            resetProgressButton.UseVisualStyleBackColor = false;
            resetProgressButton.Click += resetProgressButton_Click;
            resetProgressButton.MouseEnter += resetProgressButton_MouseEnter;
            // 
            // closeButton
            // 
            closeButton.Anchor = AnchorStyles.None;
            closeButton.BackColor = Color.FromArgb(64, 64, 64);
            closeButton.Cursor = Cursors.Hand;
            closeButton.FlatAppearance.BorderColor = Color.White;
            closeButton.FlatStyle = FlatStyle.Flat;
            closeButton.Font = new Font("Visitor TT2 BRK", 20.25F, FontStyle.Regular, GraphicsUnit.Point, 0);
            closeButton.ForeColor = Color.White;
            closeButton.Location = new Point(619, 285);
            closeButton.Name = "closeButton";
            closeButton.Size = new Size(147, 62);
            closeButton.TabIndex = 18;
            closeButton.Text = "Close";
            closeButton.UseVisualStyleBackColor = false;
            closeButton.Click += closeButton_Click;
            closeButton.MouseEnter += closeButton_MouseEnter;
            // 
            // SettingsForm
            // 
            AutoScaleDimensions = new SizeF(9F, 13F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = Color.FromArgb(25, 25, 25);
            ClientSize = new Size(778, 361);
            Controls.Add(closeButton);
            Controls.Add(resetProgressButton);
            Controls.Add(label3);
            Controls.Add(sfxVolumeTrackBar);
            Controls.Add(label2);
            Controls.Add(label1);
            Controls.Add(musicVolumeTrackBar);
            Font = new Font("Visitor TT2 BRK", 14.25F, FontStyle.Regular, GraphicsUnit.Point, 0);
            FormBorderStyle = FormBorderStyle.FixedSingle;
            Icon = (Icon)resources.GetObject("$this.Icon");
            Margin = new Padding(4, 2, 4, 2);
            MaximizeBox = false;
            Name = "SettingsForm";
            ShowIcon = false;
            ShowInTaskbar = false;
            StartPosition = FormStartPosition.CenterScreen;
            Text = "Settings";
            FormClosing += SettingsForm_FormClosing;
            Load += SettingsForm_Load;
            ((System.ComponentModel.ISupportInitialize)musicVolumeTrackBar).EndInit();
            ((System.ComponentModel.ISupportInitialize)sfxVolumeTrackBar).EndInit();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private TrackBar musicVolumeTrackBar;
        private Label label1;
        private Label label2;
        private Label label3;
        private TrackBar sfxVolumeTrackBar;
        private Button resetProgressButton;
        private Button closeButton;
    }
}