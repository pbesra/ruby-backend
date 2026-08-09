using System;
using System.Threading.Tasks;
using ruby.domain.Entities;

namespace ruby.application.Ports.In.IServices
{
    public interface IWalletService
    {
        Task<Wallet?> GetByIdAsync(Guid id);
        Task<Wallet?> GetByUserIdAsync(Guid userId);
        Task CreateAsync(Wallet wallet);
        Task UpdateAsync(Wallet wallet);
    }
}
