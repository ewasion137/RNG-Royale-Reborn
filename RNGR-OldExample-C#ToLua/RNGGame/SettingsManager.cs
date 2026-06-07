using Newtonsoft.Json;
using System;
using System.IO;

namespace RNGGame
{
    public static class SettingsManager
    {
        public static readonly string AppDataPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "RNG Royale");
        public static readonly string SettingsFilePath = Path.Combine(AppDataPath, "settings.json");
        public static readonly string SaveFilePath = Path.Combine(AppDataPath, "save.json");
        public static GameSettings CurrentSettings { get; private set; }

        // Статический конструктор - вызывается один раз при первом обращении к классу
        static SettingsManager()
        {
            LoadSettings();
        }

        public static void LoadSettings()
        {
            if (File.Exists(SettingsFilePath))
            {
                string json = File.ReadAllText(SettingsFilePath);
                CurrentSettings = JsonConvert.DeserializeObject<GameSettings>(json);
            }
            else
            {
                // Если файла нет, создаем настройки по умолчанию
                CurrentSettings = new GameSettings();
            }
        }

        public static void SaveSettings()
        {
            Directory.CreateDirectory(AppDataPath);
            string json = JsonConvert.SerializeObject(CurrentSettings, Formatting.Indented);
            File.WriteAllText(SettingsFilePath, json);
        }
    }
}