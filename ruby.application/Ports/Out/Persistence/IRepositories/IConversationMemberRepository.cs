using ruby.domain.Entities;

namespace ruby.application.Ports.Out.Persistence.IRepositories
{
    public interface IConversationMemberRepository
    {
        Task AddAsync(ConversationMember member);

        Task RemoveAsync(Guid conversationId, Guid userId);

        Task<IEnumerable<ConversationMember>> GetByConversationIdAsync(Guid conversationId);
    }
}