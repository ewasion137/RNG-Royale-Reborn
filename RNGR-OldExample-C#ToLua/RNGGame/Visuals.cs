using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;

namespace RNGGame
{
    public static class Visuals
    {
        // Метод теперь принимает дополнительный параметр - цвет для призматической ауры
        public static Image ApplyMutationAura(Image baseImage, string mutationName, Color dynamicColor)
        {
            if (baseImage == null || mutationName == "Ничего")
            {
                return baseImage;
            }

            int padding = 16;
            Bitmap finalBitmap = new Bitmap(baseImage.Width + padding, baseImage.Height + padding);

            using (Graphics g = Graphics.FromImage(finalBitmap))
            {
                g.SmoothingMode = SmoothingMode.AntiAlias;

                Color auraColor;

                // --- Логика выбора цвета ---
                if (mutationName == "Prismatic")
                {
                    // Для Prismatic используем наш анимированный цвет, переданный извне
                    auraColor = Color.FromArgb(180, dynamicColor);
                }
                else
                {
                    // Для остальных - старая логика
                    switch (mutationName)
                    {
                        case "Glowing":
                            auraColor = Color.FromArgb(180, 255, 255, 255);
                            break;
                        case "Scorching":
                            auraColor = Color.FromArgb(150, 255, 50, 0);
                            break;
                        case "Iridescent":
                            auraColor = Color.FromArgb(150, 255, 255, 0);
                            break;
                        case "Radioactive":
                            auraColor = Color.FromArgb(180, 100, 255, 100);
                            break;
                        default:
                            // Если мутация неизвестна, просто рисуем предмет без ауры
                            g.DrawImage(baseImage, padding / 2, padding / 2, baseImage.Width, baseImage.Height);
                            return finalBitmap;
                    }
                }

                // --- Рисуем ауру выбранным цветом ---
                using (GraphicsPath path = new GraphicsPath())
                {
                    path.AddEllipse(0, 0, finalBitmap.Width, finalBitmap.Height);
                    using (PathGradientBrush brush = new PathGradientBrush(path))
                    {
                        brush.CenterColor = auraColor;
                        brush.SurroundColors = new Color[] { Color.FromArgb(0, auraColor) };
                        g.FillEllipse(brush, 0, 0, finalBitmap.Width, finalBitmap.Height);
                    }
                }

                // Рисуем спрайт поверх ауры
                g.DrawImage(baseImage, padding / 2, padding / 2, baseImage.Width, baseImage.Height);
            }

            return finalBitmap;
        }
    }
}