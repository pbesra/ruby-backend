using ruby.domain.Entities;

namespace ruby.application.Ports.Out.Persistence
{
    public interface IRefreshTokenRepository
    {
        Task<RefreshToken?> GetByIdAsync(Guid id);

        Task<RefreshToken?> GetByTokenAsync(string token);

        Task<IEnumerable<RefreshToken>> GetByUserIdAsync(Guid userId);

        Task CreateAsync(RefreshToken refreshToken);

        Task UpdateAsync(RefreshToken refreshToken);

        Task DeleteAsync(Guid id);
    }
}