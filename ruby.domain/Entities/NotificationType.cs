using System;

namespace ruby.domain.Entities
{
    public class NotificationType
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = null!;
        public string? Description { get; set; }
        public bool RequiresPushNotification { get; set; }
        public bool IsActive { get; set; }
        public short SortOrder { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
        public Guid? UpdatedBy { get; set; }
    }
}
