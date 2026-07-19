using System;

namespace ruby.domain.Entities
{
    public class CoinPackage
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = null!;
        public int Coins { get; set; }
        public int BonusCoins { get; set; }
        public decimal Price { get; set; }
        public string? Currency { get; set; }
        public bool IsActive { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
        public Guid? UpdatedBy { get; set; }

        // Navigation
        public ICollection<Payment> Payments { get; set; } = new List<Payment>();
    }
}
