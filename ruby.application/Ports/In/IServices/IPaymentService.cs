using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ruby.domain.Entities;

namespace ruby.application.Ports.In.IServices
{
    public interface IPaymentService
    {
        Task<Payment?> GetByIdAsync(Guid id);
        Task<IEnumerable<Payment>> GetByUserIdAsync(Guid userId);
        Task ProcessPaymentAsync(Payment payment);
    }
}
