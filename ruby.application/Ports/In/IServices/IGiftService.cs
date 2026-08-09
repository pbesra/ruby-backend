using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ruby.domain.Entities;

namespace ruby.application.Ports.In.IServices
{
    public interface IGiftService
    {
        Task<Gift?> GetByIdAsync(Guid id);
        Task<IEnumerable<Gift>> GetActiveAsync();
        Task SendGiftAsync(GiftTransaction transaction);
    }
}
