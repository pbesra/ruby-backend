using ruby.domain.Entities;

namespace ruby.application.Ports.Out.Persistence
{
    public interface ICallRepository
    {
        Task<Call?> GetByIdAsync(Guid id);

        Task CreateAsync(Call call);

        Task UpdateAsync(Call call);
    }
}