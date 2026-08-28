using Dapper;
using ruby.application.Ports.Out.Persistence.IRepositories;
using ruby.domain.Entities;
using ruby.infrastructure.Persistence.IRepositories;
using System.Data;

namespace ruby.infrastructure.Persistence.Repositories
{
    public class ProfileRatingRepository : IProfileRatingRepository
    {
        private readonly ISQLDatabase _database;

        public ProfileRatingRepository(ISQLDatabase database)
        {
            _database = database;
        }

        public async Task<ProfileRating?> GetByProfileIdAsync(Guid profileId)
        {
            using var conn = await _database.GetConnection();
            var sql = @"SELECT * FROM public.profileratings WHERE profileid = @ProfileId LIMIT 1";
            return await conn.QueryFirstOrDefaultAsync<ProfileRating>(sql, new { ProfileId = profileId });
        }

        public async Task<ProfileRating?> AddRatingAsync(Guid profileId, Guid ratedByUserId, double newRating)
        {
            using var conn = await _database.GetConnection();
            if (conn.State != ConnectionState.Open)
            {
                conn.Open();
            }

            using var tx = conn.BeginTransaction();

            var existingVote = await conn.QueryFirstOrDefaultAsync<double?>(
                @"SELECT rating
                  FROM public.profileratingvotes
                  WHERE profileid = @ProfileId AND ratedbyuserid = @RatedByUserId
                  FOR UPDATE;",
                new { ProfileId = profileId, RatedByUserId = ratedByUserId },
                tx);

            if (existingVote == null)
            {
                await conn.ExecuteAsync(
                    @"INSERT INTO public.profileratingvotes (id, profileid, ratedbyuserid, rating, createdat, updatedat)
                      VALUES (gen_random_uuid(), @ProfileId, @RatedByUserId, @NewRating, now(), now());",
                    new { ProfileId = profileId, RatedByUserId = ratedByUserId, NewRating = newRating },
                    tx);

                var inserted = await conn.QueryFirstOrDefaultAsync<ProfileRating>(
                    @"INSERT INTO public.profileratings (id, profileid, currentrating, meanrating, leastrating, ratingcount, createdat, updatedat)
                      VALUES (gen_random_uuid(), @ProfileId, @NewRating, @NewRating, @NewRating, 1, now(), now())
                      ON CONFLICT (profileid)
                      DO UPDATE SET
                          currentrating = EXCLUDED.currentrating,
                          meanrating = ROUND((((public.profileratings.meanrating * public.profileratings.ratingcount) + EXCLUDED.currentrating)
                              / (public.profileratings.ratingcount + 1))::numeric, 2)::double precision,
                          leastrating = LEAST(public.profileratings.leastrating, EXCLUDED.currentrating),
                          ratingcount = public.profileratings.ratingcount + 1,
                          updatedat = now()
                      RETURNING id, profileid, currentrating, meanrating, leastrating, ratingcount, createdat, updatedat, updatedby;",
                    new { ProfileId = profileId, NewRating = newRating },
                    tx);

                tx.Commit();
                return inserted;
            }

            await conn.ExecuteAsync(
                @"UPDATE public.profileratingvotes
                  SET rating = @NewRating,
                      updatedat = now()
                  WHERE profileid = @ProfileId AND ratedbyuserid = @RatedByUserId;",
                new { ProfileId = profileId, RatedByUserId = ratedByUserId, NewRating = newRating },
                tx);

            var updated = await conn.QueryFirstOrDefaultAsync<ProfileRating>(
                @"UPDATE public.profileratings pr
                  SET
                      currentrating = @NewRating,
                      meanrating = ROUND((((pr.meanrating * pr.ratingcount) - @OldRating + @NewRating)
                          / pr.ratingcount)::numeric, 2)::double precision,
                      leastrating = (
                          SELECT MIN(v.rating)
                          FROM public.profileratingvotes v
                          WHERE v.profileid = @ProfileId
                      ),
                      updatedat = now()
                  WHERE pr.profileid = @ProfileId
                  RETURNING id, profileid, currentrating, meanrating, leastrating, ratingcount, createdat, updatedat, updatedby;",
                new
                {
                    ProfileId = profileId,
                    OldRating = existingVote.Value,
                    NewRating = newRating
                },
                tx);

            tx.Commit();
            return updated;
        }
    }
}
