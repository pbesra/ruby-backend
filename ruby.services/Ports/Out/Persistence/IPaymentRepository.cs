using ruby.domain.Entities;

namespace ruby.application.Ports.Out.Persistence
{
    public interface IPaymentRepository
    {
        Task<Payment?> GetByIdAsync(Guid id);

        Task<IEnumerable<Payment>> GetByUserIdAsync(Guid userId);

        Task CreateAsync(Payment payment);

        Task UpdateAsync(Payment payment);
    }
}