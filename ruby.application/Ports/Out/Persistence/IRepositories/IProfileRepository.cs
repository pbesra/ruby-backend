using ruby.domain.Entities;
using ruby.domain.Models.Responses;

namespace ruby.application.Ports.Out.Persistence.IRepositories
{
    public interface IProfileRepository
    {
        Task<Profile?> GetByUserIdAsync(Guid userId);

        Task<bool> IsFollowingAsync(Guid currentUserId, Guid targetUserId);

        Task<Address?> GetAddressByIdAsync(Guid? addressId);

        Task<string?> GetGenderNameAsync(Guid? genderId);

        Task<string?> GetLanguageNameAsync(Guid? languageId);

        Task<string?> GetStatusNameAsync(Guid? statusId);

        Task<List<string>> GetChipNamesByProfileIdAsync(Guid profileId);

        Task<List<ProfileChipResponse>> GetProfileChipsByProfileIdAsync(Guid profileId);

        Task UpdateProfileChipSelectionsAsync(Guid profileId, string category, IEnumerable<string> chipNames);

        Task CreateOrUpdateAsync(Profile profile);

        Task DeleteByUserIdAsync(Guid userId);
    }
}