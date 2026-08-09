using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ruby.domain.Entities;

namespace ruby.application.Ports.In.IServices
{
    public interface IChatService
    {
        Task<Conversation?> GetConversationAsync(Guid id);
        Task<IEnumerable<Message>> GetMessagesAsync(Guid conversationId);
        Task SendMessageAsync(Message message);
    }
}
