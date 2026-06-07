namespace RNGGame
{
    public class GameSettings
    {
        // Громкость от 0.0f до 1.0f
        public float MusicVolume { get; set; }
        public float SfxVolume { get; set; }

        // Конструктор с настройками по умолчанию
        public GameSettings()
        {
            MusicVolume = 0.5f; // 30%
            SfxVolume = 0.3f;   // 50%
        }
    }
}