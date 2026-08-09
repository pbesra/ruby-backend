using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ruby.domain.Entities;

namespace ruby.application.Ports.In.IServices
{
    public interface INotificationService
    {
        Task<Notification?> GetByIdAsync(Guid id);
        Task<IEnumerable<Notification>> GetByUserIdAsync(Guid userId);
        Task SendNotificationAsync(Notification notification);
    }
}
