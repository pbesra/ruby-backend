using System;

namespace ruby.domain.Entities
{
    public class ConversationMember
    {
        public Guid ConversationId { get; set; }
        public Guid UserId { get; set; }
        public DateTimeOffset JoinedAt { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
        public Guid? UpdatedBy { get; set; }

        // Navigation
        public Conversation? Conversation { get; set; }
        public User? User { get; set; }
    }
}
