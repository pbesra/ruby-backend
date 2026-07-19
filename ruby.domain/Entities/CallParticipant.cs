using System;

namespace ruby.domain.Entities
{
    public class CallParticipant
    {
        public Guid CallId { get; set; }
        public Guid UserId { get; set; }
        public string? Role { get; set; }
        public DateTimeOffset? JoinedAt { get; set; }
        public DateTimeOffset? LeftAt { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
        public Guid? UpdatedBy { get; set; }

        // Navigation
        public Call? Call { get; set; }
        public User? User { get; set; }
    }
}
