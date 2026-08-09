using Dapper;
using ruby.application.Ports.Out.Persistence.IRepositories;
using ruby.domain.Models.Responses;
using ruby.infrastructure.Persistence.IRepositories;

namespace ruby.infrastructure.Persistence.Repositories
{
    public class HomeFeedRepository : IHomeFeedRepository
    {
        private readonly ISQLDatabase _database;

        public HomeFeedRepository(ISQLDatabase database)
        {
            _database = database;
        }

        public async Task<IEnumerable<UserPreviewResponse>> GetDiscoverUsersAsync(Guid currentUserId)
        {
            using var conn = await _database.GetConnection();
            var sql = @"SELECT
                            u.id AS UserId,
                            u.username AS UserName,
                            COALESCE(
                                NULLIF(p.displayname, ''),
                                NULLIF(trim(concat_ws(' ', p.firstname, p.lastname)), ''),
                                u.username
                            ) AS Name,
                            UPPER(COALESCE(NULLIF(c.isocode, ''), 'IN')) AS CountryCode,
                            CASE
                                WHEN p.dob IS NULL THEN NULL
                                ELSE date_part('year', age(current_date, p.dob))::int
                            END AS Age,
                            CASE WHEN COALESCE(u.status, 0) = 1 THEN true ELSE false END AS IsOnline,
                            p.avatarurl AS AvatarUrl,
                            CASE WHEN f.userid IS NULL THEN false ELSE true END AS IsFollowing
                        FROM public.users u
                        LEFT JOIN public.profiles p ON p.userid = u.id
                        LEFT JOIN public.countries c ON c.id = p.country
                        LEFT JOIN public.followings f
                            ON f.userid = @CurrentUserId
                           AND f.followinguserid = u.id
                        WHERE u.id <> @CurrentUserId
                        ORDER BY
                            CASE WHEN COALESCE(u.status, 0) = 1 THEN 0 ELSE 1 END,
                            COALESCE(NULLIF(p.displayname, ''), u.username);";

            return await conn.QueryAsync<UserPreviewResponse>(sql, new { CurrentUserId = currentUserId });
        }

        public async Task<IEnumerable<UserPreviewResponse>> GetFollowingUsersAsync(Guid currentUserId)
        {
            using var conn = await _database.GetConnection();
            var sql = @"SELECT
                            u.id AS UserId,
                            u.username AS UserName,
                            COALESCE(
                                NULLIF(p.displayname, ''),
                                NULLIF(trim(concat_ws(' ', p.firstname, p.lastname)), ''),
                                u.username
                            ) AS Name,
                            UPPER(COALESCE(NULLIF(c.isocode, ''), 'IN')) AS CountryCode,
                            CASE
                                WHEN p.dob IS NULL THEN NULL
                                ELSE date_part('year', age(current_date, p.dob))::int
                            END AS Age,
                            CASE WHEN COALESCE(u.status, 0) = 1 THEN true ELSE false END AS IsOnline,
                            p.avatarurl AS AvatarUrl,
                            true AS IsFollowing
                        FROM public.followings f
                        JOIN public.users u ON u.id = f.followinguserid
                        LEFT JOIN public.profiles p ON p.userid = u.id
                        LEFT JOIN public.countries c ON c.id = p.country
                        WHERE f.userid = @CurrentUserId
                        ORDER BY
                            CASE WHEN COALESCE(u.status, 0) = 1 THEN 0 ELSE 1 END,
                            COALESCE(NULLIF(p.displayname, ''), u.username);";

            return await conn.QueryAsync<UserPreviewResponse>(sql, new { CurrentUserId = currentUserId });
        }
    }
}