using System.Data;
using Dapper;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.Abstractions;
using ruby.application.Ports.Out.Persistence.IRepositories;
using ruby.domain.Entities;
using ruby.infrastructure.Persistence.IRepositories;
using ruby.infrastructure.Services;

namespace ruby.infrastructure.Persistence.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly ISQLDatabase _database;
        private readonly IReferenceCacheService _referenceCacheService;
        private readonly ILogger<UserRepository> _logger;

        public UserRepository(ISQLDatabase database, IReferenceCacheService referenceCacheService, ILogger<UserRepository>? logger = null)
        {
            _database = database;
            _referenceCacheService = referenceCacheService;
            _logger = logger ?? NullLogger<UserRepository>.Instance;
        }

        public async Task CreateAsync(User user)
        {
            _logger.LogInformation("CreateAsync user={UserId}, Email={Email}", user.Id, user.Email);
            using var conn = await _database.GetConnection();
            var sql = @"INSERT INTO public.useraccount (id, username, email, phonenumber, passwordhash, status, createdat, updatedat, userstatusid, accountstatusid, userroleid)
                         VALUES (@Id, @UserName, @Email, @PhoneNumber, @PasswordHash, @Status, @CreatedAt, @UpdatedAt, @UserStatusId, @AccountStatusId, @UserRoleId)";
            await conn.ExecuteAsync(sql, user);
        }

        public async Task DeleteAsync(Guid id)
        {
            using var conn = await _database.GetConnection();
            var sql = "DELETE FROM public.useraccount WHERE id = @Id";
            await conn.ExecuteAsync(sql, new { Id = id });
        }

        public async Task<IEnumerable<User>> GetByStatusAsync(Guid statusId)
        {
            using var conn = await _database.GetConnection();
            var sql = "SELECT * FROM public.useraccount WHERE userstatusid = @StatusId";
            return await conn.QueryAsync<User>(sql, new { StatusId = statusId });
        }

        public async Task<string?> GetAccountStatusNameAsync(Guid? accountStatusId)
        {
            if (accountStatusId == null || accountStatusId == Guid.Empty)
            {
                return null;
            }

            var cachedValue = await _referenceCacheService.GetNameAsync("accountstatus", accountStatusId);
            if (!string.IsNullOrWhiteSpace(cachedValue))
            {
                return cachedValue;
            }

            using var conn = await _database.GetConnection();
            var sql = "SELECT name FROM public.accountstatus WHERE id = @AccountStatusId LIMIT 1";
            return await conn.QuerySingleOrDefaultAsync<string?>(sql, new { AccountStatusId = accountStatusId.Value });
        }

        public async Task<User?> GetByEmailAsync(string email)
        {
            using var conn = await _database.GetConnection();
            var sql = "SELECT * FROM public.useraccount WHERE email = @Email LIMIT 1";
            return await conn.QueryFirstOrDefaultAsync<User>(sql, new { Email = email });
        }

        public async Task<User?> GetByPhoneNumberAsync(string phoneNumber)
        {
            using var conn = await _database.GetConnection();
            var sql = "SELECT * FROM public.useraccount WHERE phonenumber = @PhoneNumber LIMIT 1";
            return await conn.QueryFirstOrDefaultAsync<User>(sql, new { PhoneNumber = phoneNumber });
        }

        public async Task<User?> GetByIdAsync(Guid id)
        {
            using var conn = await _database.GetConnection();
            var sql = "SELECT * FROM public.useraccount WHERE id = @Id LIMIT 1";
            return await conn.QueryFirstOrDefaultAsync<User>(sql, new { Id = id });
        }

        public async Task<User?> GetByUsernameAsync(string username)
        {
            using var conn = await _database.GetConnection();
            var sql = "SELECT * FROM public.useraccount WHERE username = @Username LIMIT 1";
            return await conn.QueryFirstOrDefaultAsync<User>(sql, new { Username = username });
        }

        public async Task UpdateAsync(User user)
        {
            _logger.LogInformation("UpdateAsync user={UserId}, Email={Email}", user.Id, user.Email);
            using var conn = await _database.GetConnection();
            var sql = @"UPDATE public.useraccount SET username = @UserName, email = @Email, phonenumber = @PhoneNumber, passwordhash = @PasswordHash, status = @Status, updatedat = @UpdatedAt, updatedby = @UpdatedBy, userstatusid = @UserStatusId, accountstatusid = @AccountStatusId, userroleid = @UserRoleId WHERE id = @Id";
            await conn.ExecuteAsync(sql, user);
        }
    }
}
