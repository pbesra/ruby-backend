using System.Globalization;
using System.Linq;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.Abstractions;
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
        private readonly ILogger<ProfileService> _logger;

        public ProfileService(
            IUserRepository userRepository,
            IProfileRepository profileRepository,
            IProfileRatingRepository profileRatingRepository,
            ILogger<ProfileService>? logger = null)
        {
            _userRepository = userRepository;
            _profileRepository = profileRepository;
            _profileRatingRepository = profileRatingRepository;
            _logger = logger ?? NullLogger<ProfileService>.Instance;
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
                    Id = Guid.NewGuid(),
                    UserId = user.Id,
                    CreatedAt = now,
                    UpdatedAt = now,
                    IsVerified = false
                };
            }

            profile.UserId = user.Id;
            if (profile.Id == Guid.Empty)
            {
                profile.Id = Guid.NewGuid();
            }
            profile.FirstName = NormalizeName(request.FirstName) ?? profile.FirstName;
            profile.LastName = NormalizeName(request.LastName) ?? profile.LastName;
            profile.DisplayName = NormalizeName(request.DisplayName) ?? profile.DisplayName;
            profile.Bio = NormalizeBio(request.Bio) ?? profile.Bio;
            profile.AvatarUrl = !string.IsNullOrWhiteSpace(request.AvatarUrl)
                ? request.AvatarUrl.Trim()
                : (profile.AvatarUrl ?? EnsureAvatarUrl(string.Empty, user.Id));

            if (!string.IsNullOrWhiteSpace(request.BirthDate) && TryParseBirthDate(request.BirthDate, out var dob))
            {
                profile.DOB = dob;
            }

            profile.UpdatedAt = now;
            profile.UpdatedBy = user.Id;

            await _profileRepository.CreateOrUpdateAsync(profile);

            var profileReferenceId = request.ProfileId ?? profile.Id;
            await _profileRepository.UpdateProfileChipSelectionsAsync(profileReferenceId, "language", request.Languages ?? new List<string>());
            await _profileRepository.UpdateProfileChipSelectionsAsync(profileReferenceId, "preference", request.Preferences ?? new List<string>());
            await _profileRepository.UpdateProfileChipSelectionsAsync(profileReferenceId, "personality", request.Personalities ?? new List<string>());
            await _profileRepository.UpdateProfileChipSelectionsAsync(profileReferenceId, "interest", request.Interests ?? new List<string>());

            return new AuthenticationResponse
            {
                Success = true,
                UserId = user.Id,
                ProfileId = profile.Id,
                DisplayName = profile.DisplayName,
                FirstName = profile.FirstName,
                LastName = profile.LastName,
                AvatarUrl = profile.AvatarUrl
            };
        }

        public async Task<UserProfileResponse> GetProfileAsync(Guid userId, Guid currentUserId)
        {
            _logger.LogInformation("GetProfileAsync started. UserId={UserId}, CurrentUserId={CurrentUserId}", userId, currentUserId);

            var targetUser = await _userRepository.GetByIdAsync(userId);
            if (targetUser == null)
            {
                _logger.LogWarning("GetProfileAsync failed: user not found. UserId={UserId}", userId);
                return new UserProfileResponse
                {
                    Success = false,
                    Error = "User not found"
                };
            }

            var profile = await _profileRepository.GetByUserIdAsync(userId);
            var isFollowing = await _profileRepository.IsFollowingAsync(currentUserId, userId);

            var fullName = !string.IsNullOrWhiteSpace(profile?.DisplayName)
                ? profile.DisplayName
                : string.Join(' ', new[] { profile?.FirstName, profile?.LastName }.Where(x => !string.IsNullOrWhiteSpace(x))).Trim();

            if (string.IsNullOrWhiteSpace(fullName))
            {
                fullName = targetUser.UserName;
            }

            var address = await _profileRepository.GetAddressByIdAsync(profile?.AddressId);
            var countryCode = !string.IsNullOrWhiteSpace(address?.CountryCode)
                ? address.CountryCode.Trim().ToUpperInvariant()
                : "IN";
            var countryName = !string.IsNullOrWhiteSpace(address?.Country)
                ? address.Country.Trim()
                : "India";
            var cityName = !string.IsNullOrWhiteSpace(address?.City)
                ? address.City.Trim()
                : null;
            var genderName = await _profileRepository.GetGenderNameAsync(profile?.Gender);
            var languageName = await _profileRepository.GetLanguageNameAsync(profile?.Language);
            var profileChipDetails = (await _profileRepository.GetProfileChipsByProfileIdAsync(targetUser.Id) ?? new List<ProfileChipResponse>()).ToList();
            var profileChips = profileChipDetails
                .Select(x => x.Name)
                .Where(x => !string.IsNullOrWhiteSpace(x))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToList();
            var ratingSummary = await _profileRatingRepository.GetByProfileIdAsync(targetUser.Id);
            var ratingValue = ratingSummary != null ? ratingSummary.MeanRating : 4.2;
            var level = profile != null && profile.Level > 0
                ? profile.Level
                : 1;

            var statusName = profile?.StatusId is Guid statusId && statusId != Guid.Empty
                ? await _profileRepository.GetStatusNameAsync(statusId)
                : null;

            if (string.IsNullOrWhiteSpace(statusName))
            {
                statusName = targetUser.Status switch
                {
                    1 => "online",
                    2 => "live",
                    3 => "busy",
                    4 => "party",
                    _ => "away"
                };
            }

            statusName = statusName?.Trim().ToLowerInvariant();
            if (!new[] { "online", "live", "busy", "away", "party" }.Contains(statusName ?? string.Empty))
            {
                statusName = "away";
            }

            int? age = null;
            if (profile?.DOB is DateOnly dob)
            {
                var today = DateOnly.FromDateTime(DateTime.Today);
                var ageYears = today.Year - dob.Year;
                if (dob > today.AddYears(-ageYears))
                {
                    ageYears--;
                }

                age = ageYears;
            }

            return new UserProfileResponse
            {
                Success = true,
                UserId = targetUser.Id,
                ProfileId = profile.Id,
                UserName = targetUser.UserName,
                Name = fullName,
                FirstName = profile?.FirstName,
                LastName = profile?.LastName,
                DisplayName = profile?.DisplayName,
                Bio = profile?.Bio,
                CountryCode = countryCode ?? "IN",
                CountryName = string.IsNullOrWhiteSpace(countryName) ? "India" : countryName,
                City = string.IsNullOrWhiteSpace(cityName) ? null : cityName,
                Age = age,
                Gender = string.IsNullOrWhiteSpace(genderName) ? "Female" : genderName,
                Language = string.IsNullOrWhiteSpace(languageName) ? "English" : languageName,
                Status = statusName,
                Level = level,
                Rating = ratingValue,
                IsOnline = targetUser.Status == 1,
                AvatarUrl = EnsureAvatarUrl(profile?.AvatarUrl, targetUser.Id),
                IsFollowing = isFollowing,
                IsCallAvailable = true,
                ProfileChips = profileChips,
                ChipDetails = profileChipDetails
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

        private static string? NormalizeBio(string? value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return null;

            var normalized = value.Trim();
            return normalized.Length > 500 ? normalized.Substring(0, 500).Trim() : normalized;
        }

        private static bool TryParseBirthDate(string? value, out DateOnly dob)
        {
            dob = default;

            if (string.IsNullOrWhiteSpace(value))
                return false;

            var normalized = value.Trim();
            var formats = new[]
            {
                "yyyy-MM-dd",
                "dd/MM/yyyy",
                "dd-MM-yyyy",
                "MM/dd/yyyy",
                "M/d/yyyy",
                "d/M/yyyy",
                "yyyy/MM/dd"
            };

            if (DateOnly.TryParseExact(normalized, formats, CultureInfo.InvariantCulture, DateTimeStyles.None, out var exactDate))
            {
                dob = exactDate;
                return true;
            }

            if (DateOnly.TryParse(normalized, CultureInfo.InvariantCulture, DateTimeStyles.None, out var parsedDateOnly))
            {
                dob = parsedDateOnly;
                return true;
            }

            if (DateTime.TryParse(normalized, CultureInfo.InvariantCulture, DateTimeStyles.AssumeLocal, out var parsedDateTime))
            {
                dob = DateOnly.FromDateTime(parsedDateTime);
                return true;
            }

            return false;
        }
    }
}