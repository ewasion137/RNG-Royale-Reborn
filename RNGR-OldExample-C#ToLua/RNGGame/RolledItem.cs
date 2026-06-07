using System.Numerics;

namespace RNGGame
{
    public class RolledItem
    {
        public Material BaseMaterial { get; set; }
        public Mutation Mutation { get; set; }
        public BigInteger FinalValue { get; set; }
    }
}