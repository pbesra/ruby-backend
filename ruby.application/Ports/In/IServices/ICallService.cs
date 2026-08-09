using System;
using System.Threading.Tasks;
using ruby.domain.Entities;

namespace ruby.application.Ports.In.IServices
{
    public interface ICallService
    {
        Task<Call?> GetByIdAsync(Guid id);
        Task StartCallAsync(Call call);
        Task EndCallAsync(Guid id);
    }
}
