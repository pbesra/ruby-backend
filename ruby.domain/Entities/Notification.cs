using System;

namespace ruby.domain.Entities
{
    public class Notification
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public string? Title { get; set; }
        public string? Body { get; set; }
        public string? Type { get; set; }
        public bool IsRead { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
        public Guid? UpdatedBy { get; set; }
        public Guid? NotificationTypeId { get; set; }

        // Navigation
        public User? User { get; set; }
        public NotificationType? NotificationType { get; set; }
    }
}
