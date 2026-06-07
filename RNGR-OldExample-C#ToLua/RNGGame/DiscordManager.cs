using System;
using DiscordRPC; // Используем новую библиотеку

namespace RNGGame
{
    public class DiscordManager : IDisposable
    {
        private DiscordRpcClient _client;
        private long _clientId = 1404732012824236083; // <<< ВСТАВЬ СЮДА СВОЙ CLIENT ID

        public void Initialize()
        {
            try
            {
                _client = new DiscordRpcClient(_clientId.ToString());

                _client.Initialize();

                // Устанавливаем базовую активность
                UpdatePresence("Just starting...", "Getting ready to roll!");
            }
            catch (Exception ex)
            {
                Console.WriteLine("Discord Rich Presence failed to initialize: " + ex.Message);
                _client = null;
            }
        }

        public void UpdatePresence(string details, string state)
        {
            if (_client == null || !_client.IsInitialized) return;

            _client.SetPresence(new RichPresence()
            {
                Details = details,
                State = state,
                Assets = new Assets()
                {
                    LargeImageKey = "logo", // Имя картинки
                    LargeImageText = "RNG Royale" // Текст при наведении
                },
                Timestamps = Timestamps.Now // Автоматически ставит время запуска
            });
        }

        // Этот метод больше не нужен, библиотека делает все сама
        // public void RunCallbacks() { }

        public void Dispose()
        {
            _client?.Dispose();
        }
    }
}