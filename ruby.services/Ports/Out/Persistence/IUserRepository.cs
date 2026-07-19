namespace ruby.application.Ports.Out.Persistence
{
    public interface IUserRepository
    {
        Task<ruby.domain.Entities.User?> GetByIdAsync(Guid id);

        Task<ruby.domain.Entities.User?> GetByUsernameAsync(string username);

        Task<ruby.domain.Entities.User?> GetByEmailAsync(string email);

        Task<IEnumerable<ruby.domain.Entities.User>> GetByStatusAsync(Guid statusId);

        Task CreateAsync(ruby.domain.Entities.User user);

        Task UpdateAsync(ruby.domain.Entities.User user);

        Task DeleteAsync(System.Guid id);
    }
}