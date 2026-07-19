using System;

namespace ruby.domain.Entities
{
    public class Payment
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public Guid CoinPackageId { get; set; }
        public string? Provider { get; set; }
        public string? TransactionId { get; set; }
        public decimal Amount { get; set; }
        public short? Status { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
        public Guid? UpdatedBy { get; set; }
        public Guid? PaymentStatusId { get; set; }

        // Navigation
        public User? User { get; set; }
        public CoinPackage? CoinPackage { get; set; }
    }
}
