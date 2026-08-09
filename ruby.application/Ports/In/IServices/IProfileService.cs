using System.Threading.Tasks;
using ruby.domain.Models.Requests;
using ruby.domain.Models.Responses;

namespace ruby.application.Ports.In.IServices
{
    public interface IProfileService
    {
        Task<AuthenticationResponse> UpdateProfileAsync(UpdateProfileRequest request);

        Task<ProfileRatingResponse> AddRatingAsync(RateProfileRequest request);
    }
}