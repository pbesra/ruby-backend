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
                            UPPER(COALESCE(NULLIF(a.countrycode, ''), 'IN')) AS CountryCode,
                            CASE
                                WHEN p.dob IS NULL THEN NULL
                                ELSE date_part('year', age(current_date, p.dob))::int
                            END AS Age,
                            COALESCE(
                                lower(s.name),
                                CASE u.status
                                    WHEN 1 THEN 'online'
                                    WHEN 2 THEN 'live'
                                    WHEN 3 THEN 'busy'
                                    WHEN 4 THEN 'party'
                                    WHEN 0 THEN 'offline'
                                    ELSE 'away'
                                END
                            ) AS Status,
                            CASE
                                WHEN lower(COALESCE(s.name,
                                    CASE u.status
                                        WHEN 1 THEN 'online'
                                        WHEN 2 THEN 'live'
                                        WHEN 3 THEN 'busy'
                                        WHEN 4 THEN 'party'
                                        WHEN 0 THEN 'offline'
                                        ELSE 'away'
                                    END)) = 'online' THEN true
                                ELSE false
                            END AS IsOnline,
                            p.avatarurl AS AvatarUrl,
                            CASE WHEN rel.userid IS NOT NULL THEN true ELSE false END AS IsFollowing
                        FROM public.useraccount u
                        LEFT JOIN public.profiles p ON p.userid = u.id
                        LEFT JOIN public.status s ON s.id = p.statusid
                        LEFT JOIN public.addresses a ON a.id = p.addressid
                        LEFT JOIN (
                            SELECT DISTINCT userid, followinguserid
                            FROM public.followings
                            UNION
                            SELECT DISTINCT followeruserid AS userid, followinguserid
                            FROM public.followers
                        ) rel
                            ON rel.userid = @CurrentUserId
                           AND rel.followinguserid = u.id
                        WHERE u.id <> @CurrentUserId
                        ORDER BY
                            CASE WHEN lower(COALESCE(s.name,
                                CASE u.status
                                    WHEN 1 THEN 'online'
                                    WHEN 2 THEN 'live'
                                    WHEN 3 THEN 'busy'
                                    WHEN 4 THEN 'party'
                                    WHEN 0 THEN 'offline'
                                    ELSE 'away'
                                END)) = 'online' THEN 0 ELSE 1 END,
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
                            UPPER(COALESCE(NULLIF(a.countrycode, ''), 'IN')) AS CountryCode,
                            CASE
                                WHEN p.dob IS NULL THEN NULL
                                ELSE date_part('year', age(current_date, p.dob))::int
                            END AS Age,
                            COALESCE(
                                lower(s.name),
                                CASE u.status
                                    WHEN 1 THEN 'online'
                                    WHEN 2 THEN 'live'
                                    WHEN 3 THEN 'busy'
                                    WHEN 4 THEN 'party'
                                    WHEN 0 THEN 'offline'
                                    ELSE 'away'
                                END
                            ) AS Status,
                            CASE
                                WHEN lower(COALESCE(s.name,
                                    CASE u.status
                                        WHEN 1 THEN 'online'
                                        WHEN 2 THEN 'live'
                                        WHEN 3 THEN 'busy'
                                        WHEN 4 THEN 'party'
                                        WHEN 0 THEN 'offline'
                                        ELSE 'away'
                                    END)) = 'online' THEN true
                                ELSE false
                            END AS IsOnline,
                            p.avatarurl AS AvatarUrl,
                            true AS IsFollowing
                        FROM (
                            SELECT DISTINCT userid, followinguserid
                            FROM public.followings
                            UNION
                            SELECT DISTINCT followeruserid AS userid, followinguserid
                            FROM public.followers
                        ) rel
                        JOIN public.useraccount u ON u.id = rel.followinguserid
                        LEFT JOIN public.profiles p ON p.userid = u.id
                        LEFT JOIN public.status s ON s.id = p.statusid
                        LEFT JOIN public.addresses a ON a.id = p.addressid
                        WHERE rel.userid = @CurrentUserId
                        ORDER BY
                            CASE WHEN lower(COALESCE(s.name,
                                CASE u.status
                                    WHEN 1 THEN 'online'
                                    WHEN 2 THEN 'live'
                                    WHEN 3 THEN 'busy'
                                    WHEN 4 THEN 'party'
                                    WHEN 0 THEN 'offline'
                                    ELSE 'away'
                                END)) = 'online' THEN 0 ELSE 1 END,
                            COALESCE(NULLIF(p.displayname, ''), u.username);";

            return await conn.QueryAsync<UserPreviewResponse>(sql, new { CurrentUserId = currentUserId });
        }
    }
}