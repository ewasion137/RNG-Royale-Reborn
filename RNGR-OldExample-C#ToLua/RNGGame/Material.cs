using Newtonsoft.Json;
using System.Drawing;
using System.Numerics;
namespace RNGGame
{
    // Перечисление для удобства работы с редкостью
    public enum Rarity { Common, Uncommon, Rare, Epic, Legendary, Mythic, Unbelievable }

    public class Material
    {
        public string Name { get; set; }
        public BigInteger Value { get; set; }
        public double BaseChance { get; set; }
        public Rarity RarityGroup { get; set; }
        public string ImageKey { get; set; }

        [JsonIgnore]
        public Image Image { get; set; }
    }
}