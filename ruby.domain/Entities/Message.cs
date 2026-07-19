using System;

namespace ruby.domain.Entities
{
    public class Message
    {
        public Guid Id { get; set; }
        public Guid ConversationId { get; set; }
        public Guid SenderUserId { get; set; }
        public string? Type { get; set; }
        public string? Content { get; set; }
        public short? Status { get; set; }
        public DateTimeOffset SentAt { get; set; }
        public DateTimeOffset? EditedAt { get; set; }
        public DateTimeOffset? DeletedAt { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
        public Guid? UpdatedBy { get; set; }
        public Guid? MessageTypeId { get; set; }
        public Guid? MessageStatusId { get; set; }

        // Navigation
        public Conversation? Conversation { get; set; }
        public User? Sender { get; set; }
        public MessageType? MessageType { get; set; }
        public MessageStatus? MessageStatus { get; set; }
    }
}
