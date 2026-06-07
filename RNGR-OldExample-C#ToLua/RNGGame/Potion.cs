public enum PotionEffect
{
    LuckBoost,
    MoneyBoost,
    MutationBoost,
    DuplicationBoost,
    WisdomBoost
}

public class Potion
{
    public string Name { get; set; }
    public string Description { get; set; }
    public long Cost { get; set; }
    public PotionEffect EffectType { get; set; }
    public double Multiplier { get; set; } // Например, 2.0 для x2
    public double DurationSeconds { get; set; } // Например, 1800 для 30 минут
    public string ImageKey { get; set; }
}