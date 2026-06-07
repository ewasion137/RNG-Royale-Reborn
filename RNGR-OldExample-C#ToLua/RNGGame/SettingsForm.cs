using Newtonsoft.Json;
using System;
using System.IO;
using System.Windows.Forms;

namespace RNGGame
{
    public partial class SettingsForm : Form
    {
        private SoundManager soundManager;
        private static readonly string AppDataPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "RNGGame");
        private readonly string _saveFilePath = Path.Combine(AppDataPath, "save.json");

        // Конструктор теперь принимает SoundManager
        public SettingsForm(SoundManager manager)
        {
            InitializeComponent();
            this.soundManager = manager;
        }

        private void SettingsForm_Load(object sender, EventArgs e)
        {
            // Устанавливаем ползунки в значения из настроек
            // TrackBar работает с int, а у нас float. Конвертируем 0.5f -> 50
            musicVolumeTrackBar.Value = (int)(SettingsManager.CurrentSettings.MusicVolume * 100);
            sfxVolumeTrackBar.Value = (int)(SettingsManager.CurrentSettings.SfxVolume * 100);
        }

        // --- Обработчики событий ползунков ---

        private void musicVolumeTrackBar_Scroll(object sender, EventArgs e)
        {
            // Конвертируем значение ползунка (0-100) в громкость (0.0-1.0)
            float newVolume = musicVolumeTrackBar.Value / 100.0f;
            SettingsManager.CurrentSettings.MusicVolume = newVolume;
            soundManager.SetMusicVolume(newVolume); // Меняем громкость в реальном времени
        }

        private void sfxVolumeTrackBar_Scroll(object sender, EventArgs e)
        {
            float newVolume = sfxVolumeTrackBar.Value / 100.0f;
            SettingsManager.CurrentSettings.SfxVolume = newVolume;
        }

        // --- Кнопки ---

        private void resetProgressButton_Click(object sender, EventArgs e)
        {
            DialogResult result = MessageBox.Show(
                "ARE YOU SURE?\n\nTHIS ACTION IS UNDONEABLE.\nTHIS WILL RESER ALL YOUR MONEY, UPGRADES AND INVENTORY!.",
                "RESET",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Warning);

            if (result == DialogResult.Yes)
            {
                // Если игрок уверен, удаляем файл сохранения
                if (File.Exists(SettingsManager.SaveFilePath))
                {
                    try
                    {
                        File.Delete(SettingsManager.SaveFilePath);
                        MessageBox.Show("Progress resetted. Restart the game.", "All done");
                        Environment.Exit(0);
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show($"Can't delete the save file: {ex.Message}");
                    }
                }
                else
                {
                    MessageBox.Show("Nothing to reset", "Info");
                }
            }
        }

        private void closeButton_Click(object sender, EventArgs e)
        {
            this.Close(); // Просто закрываем форму
        }

        // При закрытии формы сохраняем все настройки
        private void SettingsForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            SettingsManager.SaveSettings();
        }

        private void closeButton_MouseEnter(object sender, EventArgs e)
        {
            soundManager.PlaySfx("navigating.wav", SettingsManager.CurrentSettings.SfxVolume);
        }

        private void resetProgressButton_MouseEnter(object sender, EventArgs e)
        {
            soundManager.PlaySfx("navigating.wav", SettingsManager.CurrentSettings.SfxVolume);
        }
    }
}