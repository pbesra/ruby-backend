using ruby.domain.Entities;

namespace ruby.application.Ports.Out.Persistence
{
    public interface ICallParticipantRepository
    {
        Task AddAsync(CallParticipant participant);

        Task RemoveAsync(Guid callId, Guid userId);

        Task<IEnumerable<CallParticipant>> GetByCallIdAsync(Guid callId);
    }
}