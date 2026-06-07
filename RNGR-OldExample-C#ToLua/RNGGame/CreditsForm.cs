using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RNGGame
{
    internal class CreditsForm : Form
    {
        public CreditsForm()
        {
            if (this.DesignMode) return;
            InitializeComponent();
        }

        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(CreditsForm));
            label1 = new Label();
            label2 = new Label();
            linkLabel1 = new LinkLabel();
            SuspendLayout();
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Visitor TT2 BRK", 71.99999F, FontStyle.Regular, GraphicsUnit.Point, 0);
            label1.Location = new Point(138, 9);
            label1.Name = "label1";
            label1.Size = new Size(479, 67);
            label1.TabIndex = 0;
            label1.Text = "RNG ROYALE";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Arial", 11.25F, FontStyle.Regular, GraphicsUnit.Point, 204);
            label2.Location = new Point(96, 82);
            label2.Name = "label2";
            label2.Size = new Size(521, 289);
            label2.TabIndex = 1;
            label2.Text = resources.GetString("label2.Text");
            label2.TextAlign = ContentAlignment.TopCenter;
            // 
            // linkLabel1
            // 
            linkLabel1.AutoSize = true;
            linkLabel1.Font = new Font("Arial", 14.25F, FontStyle.Regular, GraphicsUnit.Point, 0);
            linkLabel1.LinkColor = Color.White;
            linkLabel1.Location = new Point(12, 348);
            linkLabel1.Name = "linkLabel1";
            linkLabel1.Size = new Size(172, 22);
            linkLabel1.TabIndex = 2;
            linkLabel1.TabStop = true;
            linkLabel1.Text = "See the agreement";
            linkLabel1.Click += linkLabel1_Click;
            // 
            // CreditsForm
            // 
            BackColor = Color.FromArgb(25, 25, 25);
            ClientSize = new Size(719, 379);
            Controls.Add(linkLabel1);
            Controls.Add(label2);
            Controls.Add(label1);
            Font = new Font("Visitor TT2 BRK", 14.25F, FontStyle.Regular, GraphicsUnit.Point, 0);
            ForeColor = Color.White;
            Icon = (Icon)resources.GetObject("$this.Icon");
            MaximizeBox = false;
            Name = "CreditsForm";
            StartPosition = FormStartPosition.CenterScreen;
            Text = "Credits";
            ResumeLayout(false);
            PerformLayout();

        }
        private Label label1;
        private LinkLabel linkLabel1;
        private Label label2;

        private void linkLabel1_Click(object sender, EventArgs e)
        {
            string url = "https://ewasion.itch.io/rng-royale";
            System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo(url) { UseShellExecute = true });
        }
    }
}
