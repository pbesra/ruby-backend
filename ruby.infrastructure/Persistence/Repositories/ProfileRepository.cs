using System.Data;
using Dapper;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.Abstractions;
using ruby.application.Ports.Out.Persistence.IRepositories;
using ruby.domain.Entities;
using ruby.domain.Models.Responses;
using ruby.infrastructure.Persistence.IRepositories;
using ruby.infrastructure.Services;

namespace ruby.infrastructure.Persistence.Repositories
{
    public class ProfileRepository : IProfileRepository
    {
        private readonly ISQLDatabase _database;
        private readonly IReferenceCacheService _referenceCacheService;
        private readonly ILogger<ProfileRepository> _logger;

        public ProfileRepository(ISQLDatabase database, IReferenceCacheService referenceCacheService, ILogger<ProfileRepository>? logger = null)
        {
            _database = database;
            _referenceCacheService = referenceCacheService;
            _logger = logger ?? NullLogger<ProfileRepository>.Instance;
        }

        public async Task<Profile?> GetByUserIdAsync(Guid userId)
        {
            _logger.LogInformation("GetByUserIdAsync started. UserId={UserId}", userId);
            using var conn = await _database.GetConnection();
            var sql = "SELECT * FROM public.profiles WHERE userid = @UserId LIMIT 1";
            return await conn.QueryFirstOrDefaultAsync<Profile>(sql, new { UserId = userId });
        }

        public async Task<bool> IsFollowingAsync(Guid currentUserId, Guid targetUserId)
        {
            if (currentUserId == Guid.Empty || targetUserId == Guid.Empty || currentUserId == targetUserId)
            {
                return false;
            }

            using var conn = await _database.GetConnection();
            var sql = @"
                SELECT COUNT(1)
                FROM (
                    SELECT userid, followinguserid
                    FROM public.followings
                    WHERE userid = @CurrentUserId AND followinguserid = @TargetUserId
                    UNION ALL
                    SELECT followeruserid AS userid, followinguserid
                    FROM public.followers
                    WHERE followeruserid = @CurrentUserId AND followinguserid = @TargetUserId
                ) rel
                LIMIT 1;";

            var count = await conn.ExecuteScalarAsync<int>(sql, new { CurrentUserId = currentUserId, TargetUserId = targetUserId });
            return count > 0;
        }

        public async Task<Address?> GetAddressByIdAsync(Guid? addressId)
        {
            if (addressId == null || addressId == Guid.Empty)
            {
                return null;
            }

            using var conn = await _database.GetConnection();
            var sql = "SELECT * FROM public.addresses WHERE id = @AddressId LIMIT 1";
            return await conn.QuerySingleOrDefaultAsync<Address>(sql, new { AddressId = addressId.Value });
        }

        public async Task<string?> GetGenderNameAsync(Guid? genderId)
        {
            if (genderId == null || genderId == Guid.Empty)
            {
                return null;
            }

            var cachedValue = await _referenceCacheService.GetNameAsync("genders", genderId);
            if (!string.IsNullOrWhiteSpace(cachedValue))
            {
                return cachedValue;
            }

            using var conn = await _database.GetConnection();
            var sql = "SELECT name FROM public.genders WHERE id = @GenderId LIMIT 1";
            return await conn.QuerySingleOrDefaultAsync<string?>(sql, new { GenderId = genderId.Value });
        }

        public async Task<string?> GetLanguageNameAsync(Guid? languageId)
        {
            if (languageId == null || languageId == Guid.Empty)
            {
                return null;
            }

            var cachedValue = await _referenceCacheService.GetNameAsync("languages", languageId);
            if (!string.IsNullOrWhiteSpace(cachedValue))
            {
                return cachedValue;
            }

            using var conn = await _database.GetConnection();
            var sql = "SELECT name FROM public.languages WHERE id = @LanguageId LIMIT 1";
            return await conn.QuerySingleOrDefaultAsync<string?>(sql, new { LanguageId = languageId.Value });
        }

        public async Task<string?> GetStatusNameAsync(Guid? statusId)
        {
            if (statusId == null || statusId == Guid.Empty)
            {
                return null;
            }

            var cachedValue = await _referenceCacheService.GetNameAsync("status", statusId);
            if (!string.IsNullOrWhiteSpace(cachedValue))
            {
                return cachedValue;
            }

            using var conn = await _database.GetConnection();
            var sql = "SELECT name FROM public.status WHERE id = @StatusId LIMIT 1";
            return await conn.QuerySingleOrDefaultAsync<string?>(sql, new { StatusId = statusId.Value });
        }

        public async Task<List<string>> GetChipNamesByProfileIdAsync(Guid profileId)
        {
            var chips = await GetProfileChipsByProfileIdAsync(profileId);
            return chips
                .Select(x => x.Name)
                .Where(x => !string.IsNullOrWhiteSpace(x))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToList();
        }

        public async Task<List<ProfileChipResponse>> GetProfileChipsByProfileIdAsync(Guid profileId)
        {
            using var conn = await _database.GetConnection();
            var sql = @"
                SELECT c.name AS Name,
                       NULLIF(trim(c.avatarurl), '') AS AvatarUrl,
                       cc.code AS Category
                FROM public.profilechips pc
                INNER JOIN public.chips c ON c.id = pc.chipid
                LEFT JOIN public.chipcategories cc ON cc.id = c.chipcategoryid
                WHERE pc.profileid = @ProfileId
                ORDER BY c.sortorder, c.name";

            var chips = await conn.QueryAsync<ProfileChipResponse>(sql, new { ProfileId = profileId });
            return chips
                .Where(x => !string.IsNullOrWhiteSpace(x.Name))
                .GroupBy(x => x.Name, StringComparer.OrdinalIgnoreCase)
                .Select(g =>
                {
                    var chip = g.First();
                    chip.AvatarUrl = ResolveChipAvatarUrl(chip.Name, chip.Category, chip.AvatarUrl);
                    return chip;
                })
                .ToList();
        }

        private static string? ResolveChipAvatarUrl(string? chipName, string? category, string? fallbackAvatarUrl)
        {
            var normalizedCategory = (category ?? string.Empty).Trim();
            var normalizedName = (chipName ?? string.Empty).Trim();

            if (!string.IsNullOrWhiteSpace(fallbackAvatarUrl) && fallbackAvatarUrl.StartsWith("assets/", StringComparison.OrdinalIgnoreCase))
            {
                return fallbackAvatarUrl.Trim();
            }

            var categoryKey = normalizedCategory.ToLowerInvariant();
            var assetPath = categoryKey switch
            {
                "language" => "assets/icons/chips/language.svg",
                "location" => "assets/icons/chips/location.svg",
                "preference" => "assets/icons/chips/preference.svg",
                "personality" => "assets/icons/chips/personality.svg",
                "interest" => "assets/icons/chips/interest.svg",
                _ => null
            };

            if (!string.IsNullOrWhiteSpace(assetPath))
            {
                return assetPath;
            }

            var nameKey = normalizedName.ToLowerInvariant();
            if (nameKey.Contains("english") || nameKey.Contains("hindi") || nameKey.Contains("spanish") || nameKey.Contains("french") || nameKey.Contains("german") || nameKey.Contains("arabic") || nameKey.Contains("japanese"))
            {
                return "assets/icons/chips/language.svg";
            }

            if (nameKey.Contains("india") || nameKey.Contains("delhi") || nameKey.Contains("berlin") || nameKey.Contains("germany") || nameKey.Contains("london") || nameKey.Contains("paris") || nameKey.Contains("singapore") || nameKey.Contains("tokyo") || nameKey.Contains("sydney") || nameKey.Contains("new york"))
            {
                return "assets/icons/chips/location.svg";
            }

            if (nameKey.Contains("friend") || nameKey.Contains("relationship") || nameKey.Contains("chat") || nameKey.Contains("travel") || nameKey.Contains("meetup") || nameKey.Contains("buddy"))
            {
                return "assets/icons/chips/preference.svg";
            }

            if (nameKey.Contains("introvert") || nameKey.Contains("extrovert") || nameKey.Contains("thoughtful") || nameKey.Contains("adventurous") || nameKey.Contains("calm") || nameKey.Contains("fun"))
            {
                return "assets/icons/chips/personality.svg";
            }

            if (nameKey.Contains("film") || nameKey.Contains("dancing") || nameKey.Contains("dog") || nameKey.Contains("singing") || nameKey.Contains("fitness") || nameKey.Contains("reading") || nameKey.Contains("cooking") || nameKey.Contains("travel") || nameKey.Contains("movie"))
            {
                return "assets/icons/chips/interest.svg";
            }

            return string.IsNullOrWhiteSpace(fallbackAvatarUrl)
                ? "assets/icons/chips/interest.svg"
                : fallbackAvatarUrl.Trim();
        }

        public async Task UpdateProfileChipSelectionsAsync(Guid profileId, string category, IEnumerable<string> chipNames)
        {
            var normalizedCategory = (category ?? string.Empty).Trim();
            if (string.IsNullOrWhiteSpace(normalizedCategory))
            {
                return;
            }

            var names = (chipNames ?? Enumerable.Empty<string>())
                .Where(x => !string.IsNullOrWhiteSpace(x))
                .Select(x => x.Trim())
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToArray();

            using var conn = await _database.GetConnection();
            var categoryId = await conn.QuerySingleOrDefaultAsync<Guid?>(
                @"SELECT id FROM public.chipcategories WHERE lower(code) = lower(@Category) LIMIT 1",
                new { Category = normalizedCategory });

            if (categoryId == null || categoryId == Guid.Empty)
            {
                return;
            }

            if (names.Length == 0)
            {
                await conn.ExecuteAsync(
                    @"DELETE FROM public.profilechips
                      WHERE profileid = @ProfileId
                        AND chipid IN (SELECT id FROM public.chips WHERE chipcategoryid = @CategoryId)",
                    new { ProfileId = profileId, CategoryId = categoryId.Value });
                return;
            }

            var lookupNames = names.Select(x => x.ToLowerInvariant()).ToArray();

            await conn.ExecuteAsync(
                @"DELETE FROM public.profilechips
                  WHERE profileid = @ProfileId
                    AND chipid IN (SELECT id FROM public.chips WHERE chipcategoryid = @CategoryId)",
                new { ProfileId = profileId, CategoryId = categoryId.Value });

            await conn.ExecuteAsync(
                @"INSERT INTO public.profilechips (id, profileid, chipid, createdat)
                  SELECT gen_random_uuid(), @ProfileId, c.id, now()
                  FROM public.chips c
                  WHERE c.chipcategoryid = @CategoryId
                    AND lower(c.name) = ANY(@Names)",
                new { ProfileId = profileId, CategoryId = categoryId.Value, Names = lookupNames });
        }

        public async Task CreateOrUpdateAsync(Profile profile)
        {
            _logger.LogInformation("CreateOrUpdateAsync started. UserId={UserId}, DisplayName={DisplayName}", profile.UserId, profile.DisplayName);
            using var conn = await _database.GetConnection();
            var profileId = profile.Id == Guid.Empty ? Guid.NewGuid() : profile.Id;
            var sql = @"INSERT INTO public.profiles (id, userid, firstname, lastname, displayname, gender, dob, addressid, language, level, bio, statusid, avatarurl, isverified, createdat, updatedat, updatedby)
                         VALUES (@Id, @UserId, @FirstName, @LastName, @DisplayName, @Gender, @DOB, @AddressId, @Language, @Level, @Bio, @StatusId, @AvatarUrl, @IsVerified, @CreatedAt, @UpdatedAt, @UpdatedBy)
                         ON CONFLICT (userid) DO UPDATE SET id = EXCLUDED.id, firstname = EXCLUDED.firstname, lastname = EXCLUDED.lastname, displayname = EXCLUDED.displayname, gender = EXCLUDED.gender, dob = EXCLUDED.dob, addressid = EXCLUDED.addressid, language = EXCLUDED.language, level = EXCLUDED.level, bio = EXCLUDED.bio, statusid = EXCLUDED.statusid, avatarurl = EXCLUDED.avatarurl, isverified = EXCLUDED.isverified, updatedat = EXCLUDED.updatedat, updatedby = EXCLUDED.updatedby";

            var dobValue = profile.DOB.HasValue
                ? profile.DOB.Value.ToDateTime(TimeOnly.MinValue, DateTimeKind.Utc)
                : (DateTime?)null;

            await conn.ExecuteAsync(sql, new
            {
                Id = profileId,
                profile.UserId,
                profile.FirstName,
                profile.LastName,
                profile.DisplayName,
                profile.Gender,
                DOB = dobValue,
                profile.AddressId,
                profile.Language,
                profile.Level,
                profile.Bio,
                profile.StatusId,
                profile.AvatarUrl,
                profile.IsVerified,
                profile.CreatedAt,
                profile.UpdatedAt,
                profile.UpdatedBy
            });

            profile.Id = profileId;
        }

        public async Task DeleteByUserIdAsync(Guid userId)
        {
            using var conn = await _database.GetConnection();
            var sql = "DELETE FROM public.profiles WHERE userid = @UserId";
            await conn.ExecuteAsync(sql, new { UserId = userId });
        }
    }
}
