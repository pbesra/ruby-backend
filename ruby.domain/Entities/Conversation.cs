using System;
using System.Collections.Generic;

namespace ruby.domain.Entities
{
    public class Conversation
    {
        public Guid Id { get; set; }
        public string? Type { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
        public Guid? UpdatedBy { get; set; }

        // Navigation
        public ICollection<ConversationMember> Members { get; set; } = new List<ConversationMember>();
        public ICollection<Message> Messages { get; set; } = new List<Message>();
        public ICollection<Call> Calls { get; set; } = new List<Call>();
    }
}
