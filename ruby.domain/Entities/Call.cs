using System;
using System.Collections.Generic;

namespace ruby.domain.Entities
{
    public class Call
    {
        public Guid Id { get; set; }
        public Guid? ConversationId { get; set; }
        public DateTimeOffset? StartedAt { get; set; }
        public DateTimeOffset? EndedAt { get; set; }
        public int? Duration { get; set; }
        public short? Status { get; set; }
        public decimal? CoinsCharged { get; set; }
        public Guid? EndedBy { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
        public Guid? UpdatedBy { get; set; }
        public Guid? CallStatusId { get; set; }

        // Navigation
        public Conversation? Conversation { get; set; }
        public ICollection<CallParticipant> Participants { get; set; } = new List<CallParticipant>();
    }
}
