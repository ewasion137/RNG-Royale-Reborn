using System.Drawing;
using System.IO;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace RNGGame
{
    public static class FontManager
    {
        // Импортируем функцию из Windows API для регистрации шрифта
        [DllImport("gdi32.dll", EntryPoint = "AddFontResourceW", SetLastError = true)]
        public static extern int AddFontResource([In][MarshalAs(UnmanagedType.LPWStr)] string lpFileName);

        // Главный метод, который делает всю работу
        public static bool CheckAndInstallFont()
        {
            string fontName = "vstr.ttf";
            // Путь к файлу шрифта рядом с .exe игры
            string fontPath = Path.Combine(Application.StartupPath, fontName);

            // --- Шаг 1: Проверяем, есть ли уже файл шрифта ---
            if (File.Exists(fontPath))
            {
                // Файл уже на месте. Просто регистрируем его в системе на всякий случай.
                AddFontResource(fontPath);
                return false; // Сообщаем, что перезапуск НЕ нужен.
            }

            // --- Шаг 2: Если файла нет - это первый запуск ---
            try
            {
                // Извлекаем шрифт из ресурсов проекта
                var assembly = System.Reflection.Assembly.GetExecutingAssembly();
                string resourceName = $"RNGGame.Fonts.{fontName}";

                using (var stream = assembly.GetManifestResourceStream(resourceName))
                {
                    if (stream == null) return false; // Не нашли встроенный шрифт

                    byte[] fontData = new byte[stream.Length];
                    stream.Read(fontData, 0, (int)stream.Length);

                    // Сохраняем .ttf файл в папку с игрой
                    File.WriteAllBytes(fontPath, fontData);
                }

                // Регистрируем новый файл шрифта в системе
                AddFontResource(fontPath);

                // Возвращаем true, чтобы главная программа знала, что нужно перезапуститься
                return true;
            }
            catch (System.Exception ex)
            {
                MessageBox.Show($"Не удалось установить шрифт: {ex.Message}");
                return false; // В случае ошибки просто продолжаем
            }
        }
    }
}