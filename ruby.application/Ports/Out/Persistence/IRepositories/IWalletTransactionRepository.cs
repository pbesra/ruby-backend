using ruby.domain.Entities;

namespace ruby.application.Ports.Out.Persistence.IRepositories
{
    public interface IWalletTransactionRepository
    {
        Task<WalletTransaction?> GetByIdAsync(Guid id);

        Task<IEnumerable<WalletTransaction>> GetByWalletIdAsync(Guid walletId);

        Task CreateAsync(WalletTransaction transaction);

        Task UpdateAsync(WalletTransaction transaction);
    }
}