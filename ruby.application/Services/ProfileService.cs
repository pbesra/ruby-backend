using ruby.application.Ports.In.IServices;
using ruby.application.Ports.Out.Persistence.IRepositories;
using ruby.domain.Entities;
using ruby.domain.Models.Requests;
using ruby.domain.Models.Responses;

namespace ruby.application.Services
{
    public class ProfileService : IProfileService
    {
        private readonly IUserRepository _userRepository;
        private readonly IProfileRepository _profileRepository;
        private readonly IProfileRatingRepository _profileRatingRepository;

        public ProfileService(
            IUserRepository userRepository,
            IProfileRepository profileRepository,
            IProfileRatingRepository profileRatingRepository)
        {
            _userRepository = userRepository;
            _profileRepository = profileRepository;
            _profileRatingRepository = profileRatingRepository;
        }

        public async Task<AuthenticationResponse> UpdateProfileAsync(UpdateProfileRequest request)
        {
            var user = await _userRepository.GetByIdAsync(request.UserId);
            if (user == null)
                return new AuthenticationResponse { Success = false, Error = "User not found" };

            var now = DateTimeOffset.UtcNow;
            var profile = await _profileRepository.GetByUserIdAsync(user.Id);

            if (profile == null)
            {
                profile = new Profile
                {
                    UserId = user.Id,
                    CreatedAt = now,
                    UpdatedAt = now,
                    IsVerified = false
                };
            }

            profile.FirstName = NormalizeName(request.FirstName);
            profile.LastName = NormalizeName(request.LastName);
            profile.DisplayName = NormalizeName(request.DisplayName);
            profile.AvatarUrl = EnsureAvatarUrl(profile.AvatarUrl, user.Id);
            profile.UpdatedAt = now;

            await _profileRepository.CreateOrUpdateAsync(profile);

            return new AuthenticationResponse
            {
                Success = true,
                UserId = user.Id,
                DisplayName = profile.DisplayName,
                FirstName = profile.FirstName,
                LastName = profile.LastName,
                AvatarUrl = profile.AvatarUrl
            };
        }

        public async Task<ProfileRatingResponse> AddRatingAsync(RateProfileRequest request)
        {
            if (request.Rating < 0 || request.Rating > 5)
            {
                return new ProfileRatingResponse
                {
                    Success = false,
                    Error = "Rating must be between 0 and 5",
                    ProfileId = request.ProfileId
                };
            }

            var profile = await _profileRepository.GetByUserIdAsync(request.ProfileId);
            if (profile == null)
            {
                return new ProfileRatingResponse
                {
                    Success = false,
                    Error = "Profile not found",
                    ProfileId = request.ProfileId
                };
            }

            if (request.ProfileId == request.RatedByUserId)
            {
                return new ProfileRatingResponse
                {
                    Success = false,
                    Error = "You cannot rate your own profile",
                    ProfileId = request.ProfileId
                };
            }

            var rater = await _userRepository.GetByIdAsync(request.RatedByUserId);
            if (rater == null)
            {
                return new ProfileRatingResponse
                {
                    Success = false,
                    Error = "Rater user not found",
                    ProfileId = request.ProfileId
                };
            }

            var aggregate = await _profileRatingRepository.AddRatingAsync(
                request.ProfileId,
                request.RatedByUserId,
                request.Rating);
            if (aggregate == null)
            {
                return new ProfileRatingResponse
                {
                    Success = false,
                    Error = "Unable to save profile rating",
                    ProfileId = request.ProfileId
                };
            }

            return new ProfileRatingResponse
            {
                Success = true,
                ProfileId = aggregate.ProfileId,
                CurrentRating = aggregate.CurrentRating,
                MeanRating = aggregate.MeanRating,
                LeastRating = aggregate.LeastRating,
                RatingCount = aggregate.RatingCount
            };
        }

        private static string EnsureAvatarUrl(string? avatarUrl, Guid userId)
        {
            if (!string.IsNullOrWhiteSpace(avatarUrl))
                return avatarUrl;

            return $"https://i.pravatar.cc/300?u={userId}";
        }

        private static string? NormalizeName(string? value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return null;

            return value.Trim();
        }
    }
}