using ruby.domain.Entities;

namespace ruby.application.Ports.Out.Persistence.IRepositories
{
    public interface ICoinPackageRepository
    {
        Task<CoinPackage?> GetByIdAsync(Guid id);

        Task<IEnumerable<CoinPackage>> GetAllAsync();

        Task CreateAsync(CoinPackage package);

        Task UpdateAsync(CoinPackage package);
    }
}