using System.Data;
using Dapper;
using ruby.application.Ports.Out.Persistence.IRepositories;
using ruby.domain.Entities;
using ruby.infrastructure.Persistence.IRepositories;

namespace ruby.infrastructure.Persistence.Repositories
{
    public class ProfileRepository : IProfileRepository
    {
        private readonly ISQLDatabase _database;

        public ProfileRepository(ISQLDatabase database)
        {
            _database = database;
        }

        public async Task<Profile?> GetByUserIdAsync(Guid userId)
        {
            using var conn = await _database.GetConnection();
            var sql = "SELECT * FROM public.profiles WHERE userid = @UserId LIMIT 1";
            return await conn.QueryFirstOrDefaultAsync<Profile>(sql, new { UserId = userId });
        }

        public async Task CreateOrUpdateAsync(Profile profile)
        {
            using var conn = await _database.GetConnection();
            var sql = @"INSERT INTO public.profiles (userid, firstname, lastname, displayname, gender, dob, country, city, language, bio, avatarurl, isverified, createdat, updatedat, updatedby)
                         VALUES (@UserId, @FirstName, @LastName, @DisplayName, @Gender, @DOB, @Country, @City, @Language, @Bio, @AvatarUrl, @IsVerified, @CreatedAt, @UpdatedAt, @UpdatedBy)
                         ON CONFLICT (userid) DO UPDATE SET firstname = EXCLUDED.firstname, lastname = EXCLUDED.lastname, displayname = EXCLUDED.displayname, gender = EXCLUDED.gender, dob = EXCLUDED.dob, country = EXCLUDED.country, city = EXCLUDED.city, language = EXCLUDED.language, bio = EXCLUDED.bio, avatarurl = EXCLUDED.avatarurl, isverified = EXCLUDED.isverified, updatedat = EXCLUDED.updatedat, updatedby = EXCLUDED.updatedby";
            await conn.ExecuteAsync(sql, profile);
        }

        public async Task DeleteByUserIdAsync(Guid userId)
        {
            using var conn = await _database.GetConnection();
            var sql = "DELETE FROM public.profiles WHERE userid = @UserId";
            await conn.ExecuteAsync(sql, new { UserId = userId });
        }
    }
}
