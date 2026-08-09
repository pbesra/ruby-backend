using ruby.domain.Entities;

namespace ruby.application.Ports.Out.Persistence.IRepositories
{
    public interface IWalletRepository
    {
        Task<Wallet?> GetByIdAsync(Guid id);

        Task<Wallet?> GetByUserIdAsync(Guid userId);

        Task CreateAsync(Wallet wallet);

        Task UpdateAsync(Wallet wallet);

        Task DeleteAsync(Guid id);
    }
}