using ruby.domain.Entities;

namespace ruby.application.Ports.Out.Persistence
{
    public interface IGiftTransactionRepository
    {
        Task<GiftTransaction?> GetByIdAsync(Guid id);

        Task<IEnumerable<GiftTransaction>> GetByReceiverAsync(Guid receiverUserId);

        Task CreateAsync(GiftTransaction transaction);
    }
}