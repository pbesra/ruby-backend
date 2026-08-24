using System.ComponentModel.DataAnnotations;
using System.Text;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Moq;
using ruby.api.Controllers.v1;
using ruby.application.Ports.In.IServices;
using ruby.application.Ports.Out.Persistence.IRepositories;
using ruby.application.Services;
using ruby.domain.Entities;
using ruby.domain.Models.Requests;
using ruby.domain.Models.Responses;

namespace ruby.api.tests;

public class AuthenticationControllerTests
{
    [Fact]
    public async Task QuickLogin_ReturnsOk_WhenAuthenticationSucceeds()
    {
        var authService = new Mock<IAuthenticationService>();
        authService
            .Setup(service => service.LoginWithDeviceAsync(It.IsAny<DeviceLoginRequest>()))
            .ReturnsAsync(new AuthenticationResponse
            {
                Success = true,
                AccessToken = "access-token",
                RefreshToken = "refresh-token",
                UserId = Guid.NewGuid(),
                DisplayName = "Ruby User"
            });

        var controller = CreateAuthenticationController(authService.Object);
        controller.ControllerContext = new ControllerContext
        {
            HttpContext = new DefaultHttpContext
            {
                Request =
                {
                    Body = new MemoryStream(Encoding.UTF8.GetBytes("{\"deviceId\":\"device-123\",\"deviceName\":\"ruby-test-device\"}"))
                }
            }
        };

        var result = await controller.QuickLogin();

        var okResult = Assert.IsType<OkObjectResult>(result);
        var response = Assert.IsType<AuthenticationResponse>(okResult.Value);
        Assert.True(response.Success);
        Assert.Equal("access-token", response.AccessToken);
    }

    [Fact]
    public async Task QuickLogin_ReturnsBadRequest_WhenAuthenticationFails()
    {
        var authService = new Mock<IAuthenticationService>();
        authService
            .Setup(service => service.LoginWithDeviceAsync(It.IsAny<DeviceLoginRequest>()))
            .ReturnsAsync(new AuthenticationResponse { Success = false, Error = "DeviceId is required" });

        var controller = CreateAuthenticationController(authService.Object);
        controller.ControllerContext = new ControllerContext
        {
            HttpContext = new DefaultHttpContext
            {
                Request =
                {
                    Body = new MemoryStream(Encoding.UTF8.GetBytes("{\"deviceId\":\"\"}"))
                }
            }
        };

        var result = await controller.QuickLogin();

        var badRequest = Assert.IsType<BadRequestObjectResult>(result);
        var response = Assert.IsType<AuthenticationResponse>(badRequest.Value);
        Assert.False(response.Success);
        Assert.Equal("DeviceId is required", response.Error);
    }

    private static AuthenticationController CreateAuthenticationController(IAuthenticationService authService)
    {
        return new AuthenticationController(authService);
    }

    [Fact]
    public void DeviceLoginRequest_RequiresDeviceId()
    {
        var request = new DeviceLoginRequest();
        var validationResults = new List<ValidationResult>();

        var isValid = Validator.TryValidateObject(
            request,
            new ValidationContext(request),
            validationResults,
            validateAllProperties: true);

        Assert.False(isValid);
        Assert.Contains(validationResults, result => result.MemberNames.Contains(nameof(DeviceLoginRequest.DeviceId)));
    }
}

public class HomeControllerTests
{
    [Fact]
    public async Task GetDiscoverUsers_ReturnsOk_WithUserPreviewList()
    {
        var service = new Mock<IHomeFeedService>();
        service.Setup(s => s.GetDiscoverUsersAsync(It.IsAny<Guid>()))
            .ReturnsAsync(new[]
            {
                new UserPreviewResponse { UserId = Guid.NewGuid(), UserName = "maria", Name = "Maria" },
                new UserPreviewResponse { UserId = Guid.NewGuid(), UserName = "omar", Name = "Omar" }
            });

        var controller = new HomeController(service.Object);

        var result = await controller.GetDiscoverUsers(Guid.NewGuid());

        var okResult = Assert.IsType<OkObjectResult>(result);
        var users = Assert.IsAssignableFrom<IEnumerable<UserPreviewResponse>>(okResult.Value);
        Assert.Equal(2, users.Count());
    }

    [Fact]
    public async Task GetFollowingUsers_ReturnsOk_WithUserPreviewList()
    {
        var service = new Mock<IHomeFeedService>();
        service.Setup(s => s.GetFollowingUsersAsync(It.IsAny<Guid>()))
            .ReturnsAsync(new[]
            {
                new UserPreviewResponse { UserId = Guid.NewGuid(), UserName = "nina", Name = "Nina", IsFollowing = true }
            });

        var controller = new HomeController(service.Object);

        var result = await controller.GetFollowingUsers(Guid.NewGuid());

        var okResult = Assert.IsType<OkObjectResult>(result);
        var users = Assert.IsAssignableFrom<IEnumerable<UserPreviewResponse>>(okResult.Value);
        Assert.Single(users);
        Assert.True(users.First().IsFollowing);
    }
}

public class ProfileControllerTests
{
    [Fact]
    public async Task GetProfile_ReturnsOk_WithProfileDetails()
    {
        var service = new Mock<IProfileService>();
        service.Setup(s => s.GetProfileAsync(It.IsAny<Guid>(), It.IsAny<Guid>()))
            .ReturnsAsync(new UserProfileResponse
            {
                UserId = Guid.NewGuid(),
                UserName = "ruby-user",
                Name = "Ruby User",
                CountryName = "India",
                City = "Delhi",
                Gender = "Female",
                Language = "English",
                Level = 3,
                Rating = 4.8,
                ProfileChips = new List<string> { "🇮🇳 India . Delhi", "Female", "English" },
                IsFollowing = true,
                IsCallAvailable = true
            });

        var controller = new ProfileController(service.Object);

        var result = await controller.GetProfile(Guid.NewGuid(), Guid.NewGuid());

        var okResult = Assert.IsType<OkObjectResult>(result);
        var profile = Assert.IsType<UserProfileResponse>(okResult.Value);
        Assert.Equal("India", profile.CountryName);
        Assert.Equal("Delhi", profile.City);
        Assert.Equal(3, profile.Level);
        Assert.Contains("🇮🇳 India . Delhi", profile.ProfileChips);
        Assert.DoesNotContain(profile.ProfileChips, chip => chip.StartsWith("Level ", StringComparison.OrdinalIgnoreCase));
        Assert.DoesNotContain(profile.ProfileChips, chip => chip.StartsWith("Ratings ", StringComparison.OrdinalIgnoreCase));
        Assert.True(profile.IsCallAvailable);
    }

    [Fact]
    public async Task GetProfile_DoesNotInjectSyntheticProfileChips_WhenRepositoryReturnsEmptyList()
    {
        var userId = Guid.NewGuid();
        var currentUserId = Guid.NewGuid();

        var userRepository = new Mock<IUserRepository>();
        userRepository.Setup(x => x.GetByIdAsync(userId)).ReturnsAsync(new User
        {
            Id = userId,
            UserName = "ruby-user",
            Status = 1
        });

        var profileRepository = new Mock<IProfileRepository>();
        profileRepository.Setup(x => x.GetByUserIdAsync(userId)).ReturnsAsync(new Profile
        {
            UserId = userId,
            DisplayName = "Ruby User",
            AddressId = Guid.Empty,
            Gender = Guid.Empty,
            Language = Guid.Empty
        });
        profileRepository.Setup(x => x.GetAddressByIdAsync(It.IsAny<Guid?>())).ReturnsAsync((Address?)null);
        profileRepository.Setup(x => x.GetGenderNameAsync(It.IsAny<Guid?>())).ReturnsAsync((string?)null);
        profileRepository.Setup(x => x.GetLanguageNameAsync(It.IsAny<Guid?>())).ReturnsAsync((string?)null);
        profileRepository.Setup(x => x.GetProfileChipsByProfileIdAsync(userId)).ReturnsAsync(new List<ProfileChipResponse>());
        profileRepository.Setup(x => x.IsFollowingAsync(currentUserId, userId)).ReturnsAsync(false);

        var ratingRepository = new Mock<IProfileRatingRepository>();
        ratingRepository.Setup(x => x.GetByProfileIdAsync(userId)).ReturnsAsync((ProfileRating?)null);

        var service = new ProfileService(userRepository.Object, profileRepository.Object, ratingRepository.Object);

        var response = await service.GetProfileAsync(userId, currentUserId);

        Assert.True(response.Success);
        Assert.Empty(response.ProfileChips);
        Assert.Equal("India", response.CountryName);
        Assert.Equal("Female", response.Gender);
        Assert.Equal("English", response.Language);
    }

    [Fact]
    public async Task GetProfile_ReturnsNotFound_WhenServiceFails()
    {
        var service = new Mock<IProfileService>();
        service.Setup(s => s.GetProfileAsync(It.IsAny<Guid>(), It.IsAny<Guid>()))
            .ReturnsAsync(new UserProfileResponse { Success = false, Error = "Profile not found" });

        var controller = new ProfileController(service.Object);

        var result = await controller.GetProfile(Guid.NewGuid(), Guid.NewGuid());

        var notFound = Assert.IsType<NotFoundObjectResult>(result);
        var response = Assert.IsType<UserProfileResponse>(notFound.Value);
        Assert.False(response.Success);
        Assert.Equal("Profile not found", response.Error);
    }

    [Fact]
    public async Task UpdateProfile_ReturnsOk_WhenServiceSucceeds()
    {
        var service = new Mock<IProfileService>();
        service.Setup(s => s.UpdateProfileAsync(It.IsAny<UpdateProfileRequest>()))
            .ReturnsAsync(new AuthenticationResponse { Success = true, UserId = Guid.NewGuid() });

        var controller = new ProfileController(service.Object);

        var result = await controller.UpdateProfile(new UpdateProfileRequest
        {
            UserId = Guid.NewGuid(),
            FirstName = "Ruby",
            LastName = "User",
            DisplayName = "ruby-user"
        });

        var okResult = Assert.IsType<OkObjectResult>(result);
        var response = Assert.IsType<AuthenticationResponse>(okResult.Value);
        Assert.True(response.Success);
    }

    [Fact]
    public async Task UpdateProfileAsync_PersistsProfileDetailsAndChipSelections()
    {
        var userId = Guid.NewGuid();
        var userRepository = new Mock<IUserRepository>();
        userRepository.Setup(x => x.GetByIdAsync(userId)).ReturnsAsync(new User
        {
            Id = userId,
            UserName = "ruby-user",
            Status = 1
        });

        var profileRepository = new Mock<IProfileRepository>();
        Guid? createdProfileId = null;
        profileRepository.Setup(x => x.GetByUserIdAsync(userId)).ReturnsAsync((Profile?)null);
        profileRepository.Setup(x => x.CreateOrUpdateAsync(It.IsAny<Profile>()))
            .Callback<Profile>(p => createdProfileId = p.Id)
            .Returns(Task.CompletedTask);
        profileRepository.Setup(x => x.UpdateProfileChipSelectionsAsync(It.IsAny<Guid>(), "language", It.IsAny<IEnumerable<string>>()))
            .Returns(Task.CompletedTask);
        profileRepository.Setup(x => x.UpdateProfileChipSelectionsAsync(It.IsAny<Guid>(), "preference", It.IsAny<IEnumerable<string>>()))
            .Returns(Task.CompletedTask);
        profileRepository.Setup(x => x.UpdateProfileChipSelectionsAsync(It.IsAny<Guid>(), "personality", It.IsAny<IEnumerable<string>>()))
            .Returns(Task.CompletedTask);
        profileRepository.Setup(x => x.UpdateProfileChipSelectionsAsync(It.IsAny<Guid>(), "interest", It.IsAny<IEnumerable<string>>()))
            .Returns(Task.CompletedTask);

        var service = new ProfileService(userRepository.Object, profileRepository.Object, new Mock<IProfileRatingRepository>().Object);

        var request = new UpdateProfileRequest
        {
            UserId = userId,
            FirstName = "Ruby",
            LastName = "User",
            DisplayName = "ruby-user",
            Bio = "Hi there",
            BirthDate = "15/03/1998",
            AvatarUrl = "https://example.com/avatar.jpg",
            Languages = new List<string> { "English", "Hindi" },
            Preferences = new List<string> { "Casual" },
            Personalities = new List<string> { "Introvert" },
            Interests = new List<string> { "Travel" }
        };

        var response = await service.UpdateProfileAsync(request);

        Assert.True(response.Success);
        Assert.NotNull(createdProfileId);
        Assert.Equal(createdProfileId, response.ProfileId);
        profileRepository.Verify(x => x.CreateOrUpdateAsync(It.Is<Profile>(p =>
            p.UserId == userId &&
            p.FirstName == "Ruby" &&
            p.LastName == "User" &&
            p.DisplayName == "ruby-user" &&
            p.Bio == "Hi there" &&
            p.AvatarUrl == "https://example.com/avatar.jpg" &&
            p.DOB == new DateOnly(1998, 3, 15))), Times.Once);
        profileRepository.Verify(x => x.UpdateProfileChipSelectionsAsync(createdProfileId!.Value, "language", It.Is<IEnumerable<string>>(v => v.SequenceEqual(new[] { "English", "Hindi" }))), Times.Once);
        profileRepository.Verify(x => x.UpdateProfileChipSelectionsAsync(createdProfileId!.Value, "preference", It.Is<IEnumerable<string>>(v => v.SequenceEqual(new[] { "Casual" }))), Times.Once);
        profileRepository.Verify(x => x.UpdateProfileChipSelectionsAsync(createdProfileId!.Value, "personality", It.Is<IEnumerable<string>>(v => v.SequenceEqual(new[] { "Introvert" }))), Times.Once);
        profileRepository.Verify(x => x.UpdateProfileChipSelectionsAsync(createdProfileId!.Value, "interest", It.Is<IEnumerable<string>>(v => v.SequenceEqual(new[] { "Travel" }))), Times.Once);
    }

    [Fact]
    public async Task UpdateProfile_UsesProfileId_WhenProvided()
    {
        var userId = Guid.NewGuid();
        var profileId = Guid.NewGuid();
        var userRepository = new Mock<IUserRepository>();
        userRepository.Setup(x => x.GetByIdAsync(userId)).ReturnsAsync(new User { Id = userId, UserName = "ruby-user" });

        var profileRepository = new Mock<IProfileRepository>();
        profileRepository.Setup(x => x.GetByUserIdAsync(userId)).ReturnsAsync(new Profile
        {
            Id = profileId,
            UserId = userId,
            DisplayName = "old name",
            FirstName = "Old",
            LastName = "Name",
            AvatarUrl = "https://example.com/old.jpg",
            CreatedAt = DateTimeOffset.UtcNow,
            UpdatedAt = DateTimeOffset.UtcNow
        });

        var profileRatingRepository = new Mock<IProfileRatingRepository>();
        var service = new ProfileService(userRepository.Object, profileRepository.Object, profileRatingRepository.Object);

        var request = new UpdateProfileRequest
        {
            UserId = userId,
            ProfileId = profileId,
            FirstName = "Ruby",
            LastName = "User",
            DisplayName = "ruby-user",
            Bio = "Hi there",
            BirthDate = "1998-03-15",
            AvatarUrl = "https://example.com/avatar.jpg",
            Languages = new List<string> { "English", "Hindi" },
            Preferences = new List<string> { "Casual" },
            Personalities = new List<string> { "Introvert" },
            Interests = new List<string> { "Travel" }
        };

        var response = await service.UpdateProfileAsync(request);

        Assert.True(response.Success);
        Assert.Equal(profileId, response.ProfileId);
        profileRepository.Verify(x => x.CreateOrUpdateAsync(It.Is<Profile>(p => p.UserId == userId)), Times.Once);
        profileRepository.Verify(x => x.UpdateProfileChipSelectionsAsync(profileId, "language", It.Is<IEnumerable<string>>(v => v.SequenceEqual(new[] { "English", "Hindi" }))), Times.Once);
        profileRepository.Verify(x => x.UpdateProfileChipSelectionsAsync(profileId, "preference", It.Is<IEnumerable<string>>(v => v.SequenceEqual(new[] { "Casual" }))), Times.Once);
        profileRepository.Verify(x => x.UpdateProfileChipSelectionsAsync(profileId, "personality", It.Is<IEnumerable<string>>(v => v.SequenceEqual(new[] { "Introvert" }))), Times.Once);
        profileRepository.Verify(x => x.UpdateProfileChipSelectionsAsync(profileId, "interest", It.Is<IEnumerable<string>>(v => v.SequenceEqual(new[] { "Travel" }))), Times.Once);
    }

    [Fact]
    public async Task UpdateProfile_ReturnsBadRequest_WhenServiceFails()
    {
        var service = new Mock<IProfileService>();
        service.Setup(s => s.UpdateProfileAsync(It.IsAny<UpdateProfileRequest>()))
            .ReturnsAsync(new AuthenticationResponse { Success = false, Error = "Validation failed" });

        var controller = new ProfileController(service.Object);

        var result = await controller.UpdateProfile(new UpdateProfileRequest { UserId = Guid.NewGuid() });

        var badRequest = Assert.IsType<BadRequestObjectResult>(result);
        var response = Assert.IsType<AuthenticationResponse>(badRequest.Value);
        Assert.False(response.Success);
        Assert.Equal("Validation failed", response.Error);
    }

    [Fact]
    public async Task RateProfile_ReturnsOk_WhenServiceSucceeds()
    {
        var service = new Mock<IProfileService>();
        service.Setup(s => s.AddRatingAsync(It.IsAny<RateProfileRequest>()))
            .ReturnsAsync(new ProfileRatingResponse { Success = true, MeanRating = 4.9, CurrentRating = 4.9 });

        var controller = new ProfileController(service.Object);

        var result = await controller.RateProfile(new RateProfileRequest
        {
            ProfileId = Guid.NewGuid(),
            RatedByUserId = Guid.NewGuid(),
            Rating = 4.9
        });

        var okResult = Assert.IsType<OkObjectResult>(result);
        var response = Assert.IsType<ProfileRatingResponse>(okResult.Value);
        Assert.True(response.Success);
        Assert.Equal(4.9, response.MeanRating);
    }
}
