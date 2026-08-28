using ruby.domain.Entities;

namespace ruby.application.Ports.Out.Persistence.IRepositories
{
    public interface IUserRepository
    {
        Task<User?> GetByIdAsync(Guid id);

        Task<User?> GetByUsernameAsync(string username);

        Task<User?> GetByEmailAsync(string email);

        Task<User?> GetByPhoneNumberAsync(string phoneNumber);

        Task<IEnumerable<User>> GetByStatusAsync(Guid statusId);

        Task<string?> GetAccountStatusNameAsync(Guid? accountStatusId);

        Task CreateAsync(User user);

        Task UpdateAsync(User user);

        Task DeleteAsync(Guid id);
    }
}