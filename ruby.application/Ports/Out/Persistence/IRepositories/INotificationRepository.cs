using ruby.domain.Entities;

namespace ruby.application.Ports.Out.Persistence.IRepositories
{
    public interface INotificationRepository
    {
        Task<Notification?> GetByIdAsync(Guid id);

        Task<IEnumerable<Notification>> GetByUserIdAsync(Guid userId);

        Task CreateAsync(Notification notification);

        Task MarkAsReadAsync(Guid id);
    }
}