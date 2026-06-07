using System;
using System.Numerics;

namespace RNGGame
{
    public class Upgrade
    {
        public string Name { get; set; }
        public int Level { get; set; }
        public int MaxLevel { get; set; }
        public BigInteger BaseCost { get; set; }
        public double CostMultiplier { get; set; } // Для формулы Цена * Множитель^Уровень
        public BigInteger GetCurrentCost()
        {
            if (Level >= MaxLevel) return -1;

            BigInteger currentCost = BaseCost;

            // Используем простые циклы вместо Math.Pow
            for (int i = 0; i < Level; i++)
            {
                if (this.Name == "Sell Value Boost")
                {
                    // Множитель x2
                    currentCost *= 2;
                }
                else if (this.Name == "Faster Roll")
                {
                    // Множитель x3
                    currentCost *= 3;
                }
                else if (this.Name == "Auto Roll")
                {
                    // Множитель x1.5 (умножаем на 3, делим на 2)
                    currentCost = (currentCost * 3) / 2;
                }
                else // Для Luck
                {
                    // Множитель x1.5
                    currentCost = (currentCost * 3) / 2;
                }
            }
            return currentCost;
        }
    }
}