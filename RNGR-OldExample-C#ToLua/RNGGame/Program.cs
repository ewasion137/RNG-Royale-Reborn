using System;
using System.Windows.Forms;

namespace RNGGame
{
    static class Program
    {
        [STAThread]
        static void Main()
        {
            // Вызываем наш метод проверки и установки
            bool restartNeeded = FontManager.CheckAndInstallFont();

            // Если метод вернул true, значит это был первый запуск и шрифт только что установился
            if (restartNeeded)
            {
                // Сообщаем пользователю, что сейчас произойдет
                MessageBox.Show("Font installed. Restart the game.", "Installing the font for the game");

                // Перезапускаем приложение
                Application.Restart();

                // И немедленно завершаем текущий экземпляр
                return;
            }

            // Если перезапуск не был нужен, просто запускаем игру как обычно
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new Form1());
        }
    }
}