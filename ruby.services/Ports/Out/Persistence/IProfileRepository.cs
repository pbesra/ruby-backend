using ruby.domain.Entities;

namespace ruby.application.Ports.Out.Persistence
{
    public interface IProfileRepository
    {
        Task<Profile?> GetByUserIdAsync(Guid userId);

        Task CreateOrUpdateAsync(Profile profile);

        Task DeleteByUserIdAsync(Guid userId);
    }
}