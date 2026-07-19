using ruby.domain.Entities;

namespace ruby.application.Ports.Out.Persistence
{
    public interface IGiftRepository
    {
        Task<Gift?> GetByIdAsync(Guid id);

        Task<IEnumerable<Gift>> GetActiveAsync();

        Task CreateAsync(Gift gift);

        Task UpdateAsync(Gift gift);
    }
}