using NAudio.Wave;
using NAudio.Wave.SampleProviders;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Windows.Forms;

namespace RNGGame
{
    public class SoundManager : IDisposable
    {
        private WaveOutEvent musicPlayer;
        private LoopStream musicLoopStream;
        private VolumeSampleProvider musicVolumeProvider;

        private List<IDisposable> sfxDisposables = new List<IDisposable>();

        public void StopMusic()
        {
            musicPlayer?.Stop();
            // Мы не делаем Dispose, чтобы можно было потом возобновить, если понадобится.
            // Просто останавливаем воспроизведение.
        }
        public void PlaySfx(string soundName, float volume = 1.0f)
        {
            if (volume <= 0.0f) return;

            try
            {
                var assembly = System.Reflection.Assembly.GetExecutingAssembly();
                string resourcePath = $"RNGGame.Sounds.{soundName}";

                var stream = assembly.GetManifestResourceStream(resourcePath);
                if (stream == null) return;

                // 1. Создаем поток из файла
                var waveStream = new WaveFileReader(stream);

                // 2. Оборачиваем его в регулятор громкости
                var volumeProvider = new VolumeSampleProvider(waveStream.ToSampleProvider())
                {
                    Volume = volume // Устанавливаем громкость здесь
                };

                // 3. Создаем плеер
                var waveOut = new WaveOutEvent();

                // 4. Инициализируем плеер НАШИМ потоком с регулятором громкости
                waveOut.Init(volumeProvider);
                waveOut.Play();

                // 5. Добавляем в список на уничтожение (как и раньше)
                sfxDisposables.Add(waveOut);
                sfxDisposables.Add(waveStream); // И сам поток тоже

                waveOut.PlaybackStopped += (sender, args) => {
                    waveOut.Dispose();
                    waveStream.Dispose();
                    sfxDisposables.Remove(waveOut);
                    sfxDisposables.Remove(waveStream);
                };
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка SFX '{soundName}':\n{ex.Message}");
            }
        }

        // --- МЕТОДЫ ДЛЯ ФОНОВОЙ МУЗЫКИ (остаются без изменений) ---
        public void PlayMusic(string musicName, float volume = 0.5f)
        {
            if (musicPlayer != null) return;

            try
            {
                var assembly = System.Reflection.Assembly.GetExecutingAssembly();
                string resourcePath = $"RNGGame.Sounds.{musicName}";
                var stream = assembly.GetManifestResourceStream(resourcePath);
                if (stream == null) return;

                musicLoopStream = new LoopStream(new WaveFileReader(stream));
                musicVolumeProvider = new VolumeSampleProvider(musicLoopStream.ToSampleProvider());
                musicVolumeProvider.Volume = volume;

                musicPlayer = new WaveOutEvent();
                musicPlayer.Init(musicVolumeProvider);
                musicPlayer.Play();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка музыки:\n{ex.Message}");
            }
        }

        public void SetMusicVolume(float volume)
        {
            if (musicVolumeProvider != null)
            {
                musicVolumeProvider.Volume = volume;
            }
        }
        public async Task FadeOutMusic(int durationMs = 300)
        {
            if (musicVolumeProvider == null) return;

            float startVolume = musicVolumeProvider.Volume;
            for (int i = 0; i < durationMs; i += 20)
            {
                float newVolume = startVolume * (1.0f - (float)i / durationMs);
                musicVolumeProvider.Volume = newVolume;
                await Task.Delay(20);
            }
            musicVolumeProvider.Volume = 0; // Гарантируем, что в конце громкость 0
        }
        public async Task FadeInMusic(float targetVolume, int durationMs = 500)
        {
            if (musicVolumeProvider == null) return;

            for (int i = 0; i < durationMs; i += 20)
            {
                float newVolume = targetVolume * ((float)i / durationMs);
                musicVolumeProvider.Volume = newVolume;
                await Task.Delay(20);
            }
            musicVolumeProvider.Volume = targetVolume; // Гарантируем, что в конце громкость правильная
        }

        public void Dispose()
        {
            musicPlayer?.Stop();
            musicPlayer?.Dispose();
            musicLoopStream?.Dispose();
            musicPlayer = null;

            foreach (var disposable in sfxDisposables.ToList())
            {
                disposable.Dispose();
            }
            sfxDisposables.Clear();
        }
    }
}