using ruby.domain.Entities;

namespace ruby.application.Ports.Out.Persistence
{
    public interface IMessageRepository
    {
        Task<Message?> GetByIdAsync(Guid id);

        Task<IEnumerable<Message>> GetByConversationIdAsync(Guid conversationId);

        Task CreateAsync(Message message);

        Task UpdateAsync(Message message);
    }
}