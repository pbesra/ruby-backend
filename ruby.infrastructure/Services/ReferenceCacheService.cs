using Dapper;
using Microsoft.Extensions.Caching.Memory;
using System.Data;

namespace ruby.infrastructure.Services
{
    public interface IReferenceCacheService
    {
        Task WarmUpAsync(IDbConnection connection);
        Task<string?> GetNameAsync(string tableName, Guid? id);
        Task<string?> GetCodeAsync(string tableName, Guid? id);
    }

    public sealed class ReferenceCacheService : IReferenceCacheService
    {
        private static readonly string[] CacheableTables =
        {
            "countries",
            "languages",
            "messagetypes",
            "messagestatuses",
            "callstatuses",
            "paymentstatuses",
            "wallettransactiontypes",
            "genders",
            "userroles",
            "giftcategories",
            "status",
            "accountstatus"
        };

        private readonly IMemoryCache _cache;

        public ReferenceCacheService(IMemoryCache cache)
        {
            _cache = cache;
        }

        public async Task WarmUpAsync(IDbConnection connection)
        {
            foreach (var tableName in CacheableTables)
            {
                var hasCacheColumn = await connection.ExecuteScalarAsync<bool>(
                    @"SELECT EXISTS (
                        SELECT 1
                        FROM information_schema.columns
                        WHERE table_schema = 'public'
                          AND table_name = @TableName
                          AND column_name = 'iscache')",
                    new { TableName = tableName });

                var sql = hasCacheColumn
                    ? $@"SELECT id, name, NULL::text AS isocode
                         FROM public.{tableName}
                         WHERE isactive = true OR iscache = true"
                    : $@"SELECT id, name, NULL::text AS isocode
                         FROM public.{tableName}
                         WHERE isactive = true";

                var rows = (await connection.QueryAsync<ReferenceCacheEntry>(sql)).ToList();
                if (rows.Count == 0)
                {
                    continue;
                }

                var dictionary = rows.ToDictionary(x => x.Id, x => new ReferenceCacheValue
                {
                    Name = x.Name,
                    Code = x.Isocode
                });

                _cache.Set(GetCacheKey(tableName), dictionary, TimeSpan.FromMinutes(60));
            }
        }

        public Task<string?> GetNameAsync(string tableName, Guid? id)
        {
            if (id == null || id == Guid.Empty)
            {
                return Task.FromResult<string?>(null);
            }

            var cacheKey = GetCacheKey(tableName);
            if (!_cache.TryGetValue(cacheKey, out Dictionary<Guid, ReferenceCacheValue>? values) || values == null)
            {
                return Task.FromResult<string?>(null);
            }

            return Task.FromResult(values.TryGetValue(id.Value, out var value) ? value.Name : null);
        }

        public Task<string?> GetCodeAsync(string tableName, Guid? id)
        {
            if (id == null || id == Guid.Empty)
            {
                return Task.FromResult<string?>(null);
            }

            var cacheKey = GetCacheKey(tableName);
            if (!_cache.TryGetValue(cacheKey, out Dictionary<Guid, ReferenceCacheValue>? values) || values == null)
            {
                return Task.FromResult<string?>(null);
            }

            return Task.FromResult(values.TryGetValue(id.Value, out var value) ? value.Code : null);
        }

        private static string GetCacheKey(string tableName)
        {
            return $"reference-cache:{tableName.ToLowerInvariant()}";
        }

        private sealed class ReferenceCacheEntry
        {
            public Guid Id { get; set; }
            public string? Name { get; set; }
            public string? Isocode { get; set; }
        }

        private sealed class ReferenceCacheValue
        {
            public string? Name { get; set; }
            public string? Code { get; set; }
        }
    }
}
