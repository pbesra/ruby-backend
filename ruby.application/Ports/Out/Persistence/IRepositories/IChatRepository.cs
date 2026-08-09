using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ruby.domain.Entities;

namespace ruby.application.Ports.Out.Persistence.IRepositories
{
    public interface IChatRepository
    {
        Task<Conversation?> GetConversationByIdAsync(Guid id);
        Task<IEnumerable<Conversation>> GetByUserIdAsync(Guid userId);
        Task CreateConversationAsync(Conversation conversation);
        Task<IEnumerable<Message>> GetMessagesAsync(Guid conversationId);
        Task CreateMessageAsync(Message message);
    }
}
