using ruby.domain.Entities;

namespace ruby.application.Ports.Out.Persistence.IRepositories
{
    public interface IProfileRatingRepository
    {
        Task<ProfileRating?> AddRatingAsync(Guid profileId, Guid ratedByUserId, double newRating);

        Task<ProfileRating?> GetByProfileIdAsync(Guid profileId);
    }
}
