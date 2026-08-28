using System;
using System.Collections.Generic;

namespace ruby.domain.Entities
{
    public class User
    {
        public Guid Id { get; set; }
        public string UserName { get; set; } = null!;
        public string Email { get; set; } = null!;
        public string? PhoneNumber { get; set; }
        public string PasswordHash { get; set; } = null!;
        public short Status { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
        public Guid? UpdatedBy { get; set; }
        public DateTimeOffset? LastLoginAt { get; set; }

        // Navigation
        public Profile? Profile { get; set; }
        public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();
        // One-to-one Wallet
        public Wallet? Wallet { get; set; }
        public ICollection<GiftTransaction> SentGiftTransactions { get; set; } = new List<GiftTransaction>();
        public ICollection<GiftTransaction> ReceivedGiftTransactions { get; set; } = new List<GiftTransaction>();
        public ICollection<Payment> Payments { get; set; } = new List<Payment>();
        public ICollection<Notification> Notifications { get; set; } = new List<Notification>();

        // Foreign keys / references
        public Guid? UserStatusId { get; set; }
        public UserStatus? UserStatus { get; set; }
        public Guid? AccountStatusId { get; set; }
        public AccountStatus? AccountStatus { get; set; }
        public Guid? UserRoleId { get; set; }
        public UserRole? UserRole { get; set; }
    }
}
