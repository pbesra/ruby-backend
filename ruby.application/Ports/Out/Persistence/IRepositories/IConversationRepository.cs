using ruby.domain.Entities;

namespace ruby.application.Ports.Out.Persistence.IRepositories
{
    public interface IConversationRepository
    {
        Task<Conversation?> GetByIdAsync(Guid id);

        Task CreateAsync(Conversation conversation);

        Task UpdateAsync(Conversation conversation);
    }
}