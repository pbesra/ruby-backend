using System.Data;
using Dapper;
using ruby.application.Ports.Out.Persistence.IRepositories;
using ruby.domain.Entities;
using ruby.infrastructure.Persistence.IRepositories;

namespace ruby.infrastructure.Persistence.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly ISQLDatabase _database;

        public UserRepository(ISQLDatabase database)
        {
            _database = database;
        }

        public async Task CreateAsync(User user)
        {
            using var conn = await _database.GetConnection();
            var sql = @"INSERT INTO public.Users (id, username, email, phonenumber, passwordhash, status, createdat, updatedat, userstatusid, userroleid)
                         VALUES (@Id, @UserName, @Email, @PhoneNumber, @PasswordHash, @Status, @CreatedAt, @UpdatedAt, @UserStatusId, @UserRoleId)";
            await conn.ExecuteAsync(sql, user);
        }

        public async Task DeleteAsync(Guid id)
        {
            using var conn = await _database.GetConnection();
            var sql = "DELETE FROM public.Users WHERE id = @Id";
            await conn.ExecuteAsync(sql, new { Id = id });
        }

        public async Task<IEnumerable<User>> GetByStatusAsync(Guid statusId)
        {
            using var conn = await _database.GetConnection();
            var sql = "SELECT * FROM public.Users WHERE userstatusid = @StatusId";
            return await conn.QueryAsync<User>(sql, new { StatusId = statusId });
        }

        public async Task<User?> GetByEmailAsync(string email)
        {
            using var conn = await _database.GetConnection();
            var sql = "SELECT * FROM public.Users WHERE email = @Email LIMIT 1";
            return await conn.QueryFirstOrDefaultAsync<User>(sql, new { Email = email });
        }

        public async Task<User?> GetByPhoneNumberAsync(string phoneNumber)
        {
            using var conn = await _database.GetConnection();
            var sql = "SELECT * FROM public.Users WHERE phonenumber = @PhoneNumber LIMIT 1";
            return await conn.QueryFirstOrDefaultAsync<User>(sql, new { PhoneNumber = phoneNumber });
        }

        public async Task<User?> GetByIdAsync(Guid id)
        {
            using var conn = await _database.GetConnection();
            var sql = "SELECT * FROM public.Users WHERE id = @Id LIMIT 1";
            return await conn.QueryFirstOrDefaultAsync<User>(sql, new { Id = id });
        }

        public async Task<User?> GetByUsernameAsync(string username)
        {
            using var conn = await _database.GetConnection();
            var sql = "SELECT * FROM public.Users WHERE username = @Username LIMIT 1";
            return await conn.QueryFirstOrDefaultAsync<User>(sql, new { Username = username });
        }

        public async Task UpdateAsync(User user)
        {
            using var conn = await _database.GetConnection();
            var sql = @"UPDATE public.Users SET username = @UserName, email = @Email, phonenumber = @PhoneNumber, passwordhash = @PasswordHash, status = @Status, updatedat = @UpdatedAt, updatedby = @UpdatedBy, userstatusid = @UserStatusId, userroleid = @UserRoleId WHERE id = @Id";
            await conn.ExecuteAsync(sql, user);
        }
    }
}
