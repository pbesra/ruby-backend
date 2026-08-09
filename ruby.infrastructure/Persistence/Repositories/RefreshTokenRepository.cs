using Dapper;
using ruby.application.Ports.Out.Persistence.IRepositories;
using ruby.domain.Entities;
using ruby.infrastructure.Persistence.IRepositories;
using System.Security.Cryptography;
using System.Text;

namespace ruby.infrastructure.Persistence.Repositories
{
    public class RefreshTokenRepository : IRefreshTokenRepository
    {
        private readonly ISQLDatabase _database;

        public RefreshTokenRepository(ISQLDatabase database)
        {
            _database = database;
        }

        public async Task CreateAsync(RefreshToken refreshToken)
        {
            using var conn = await _database.GetConnection();
            var sql = @"INSERT INTO public.refreshtokens (id, userid, deviceid, token, expiresat, revokedat, createdat, updatedat, updatedby)
                         VALUES (@Id, @UserId, @DeviceId::uuid, @Token, @ExpiresAt, @RevokedAt, @CreatedAt, @UpdatedAt, @UpdatedBy)";
            var deviceGuid = ToDeviceGuidOrNull(refreshToken.DeviceId);

            var parameters = new
            {
                refreshToken.Id,
                refreshToken.UserId,
                DeviceId = deviceGuid,
                refreshToken.Token,
                refreshToken.ExpiresAt,
                refreshToken.RevokedAt,
                refreshToken.CreatedAt,
                refreshToken.UpdatedAt,
                refreshToken.UpdatedBy
            };

            await conn.ExecuteAsync(sql, parameters);
        }

        public async Task DeleteAsync(Guid id)
        {
            using var conn = await _database.GetConnection();
            var sql = "DELETE FROM public.refreshtokens WHERE id = @Id";
            await conn.ExecuteAsync(sql, new { Id = id });
        }

        public async Task<IEnumerable<RefreshToken>> GetByUserIdAsync(Guid userId)
        {
            using var conn = await _database.GetConnection();
            var sql = "SELECT * FROM public.refreshtokens WHERE userid = @UserId";
            return await conn.QueryAsync<RefreshToken>(sql, new { UserId = userId });
        }

        public async Task<RefreshToken?> GetByIdAsync(Guid id)
        {
            using var conn = await _database.GetConnection();
            var sql = "SELECT * FROM public.refreshtokens WHERE id = @Id LIMIT 1";
            return await conn.QueryFirstOrDefaultAsync<RefreshToken>(sql, new { Id = id });
        }

        public async Task<RefreshToken?> GetByTokenAsync(string token)
        {
            using var conn = await _database.GetConnection();
            var sql = "SELECT * FROM public.refreshtokens WHERE token = @Token LIMIT 1";
            return await conn.QueryFirstOrDefaultAsync<RefreshToken>(sql, new { Token = token });
        }

        public async Task UpdateAsync(RefreshToken refreshToken)
        {
            using var conn = await _database.GetConnection();
            var sql = @"UPDATE public.refreshtokens SET userid = @UserId, deviceid = @DeviceId::uuid, token = @Token, expiresat = @ExpiresAt, revokedat = @RevokedAt, updatedat = @UpdatedAt, updatedby = @UpdatedBy WHERE id = @Id";
            var deviceGuid = ToDeviceGuidOrNull(refreshToken.DeviceId);

            var parameters = new
            {
                refreshToken.Id,
                refreshToken.UserId,
                DeviceId = deviceGuid,
                refreshToken.Token,
                refreshToken.ExpiresAt,
                refreshToken.RevokedAt,
                refreshToken.UpdatedAt,
                refreshToken.UpdatedBy
            };

            await conn.ExecuteAsync(sql, parameters);
        }

        private static Guid? ToDeviceGuidOrNull(string? deviceId)
        {
            if (string.IsNullOrWhiteSpace(deviceId))
                return null;

            if (Guid.TryParse(deviceId, out var parsed))
                return parsed;

            // Map arbitrary device strings to a stable UUID so the same device id is stored consistently.
            using var md5 = MD5.Create();
            var hash = md5.ComputeHash(Encoding.UTF8.GetBytes(deviceId.Trim()));
            return new Guid(hash);
        }
    }
}
