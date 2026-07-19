using System;

namespace ruby.domain.Entities
{
    public class GiftTransaction
    {
        public Guid Id { get; set; }
        public Guid GiftId { get; set; }
        public Guid SenderUserId { get; set; }
        public Guid ReceiverUserId { get; set; }
        public decimal Coins { get; set; }
        public Guid? WalletTransactionId { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
        public Guid? UpdatedBy { get; set; }

        // Navigation
        public Gift? Gift { get; set; }
        public User? Sender { get; set; }
        public User? Receiver { get; set; }
    }
}
