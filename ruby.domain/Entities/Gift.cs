using System;
using System.Collections.Generic;

namespace ruby.domain.Entities
{
    public class Gift
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = null!;
        public decimal Price { get; set; }
        public string? ImageUrl { get; set; }
        public string? AnimationUrl { get; set; }
        public bool IsActive { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
        public Guid? UpdatedBy { get; set; }

        // Navigation
        public ICollection<GiftTransaction> GiftTransactions { get; set; } = new List<GiftTransaction>();
    }
}
