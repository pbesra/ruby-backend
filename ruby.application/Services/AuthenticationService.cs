using System;
using System.Linq;
using System.Threading.Tasks;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.Abstractions;
using ruby.application.Ports.In.IServices;
using ruby.domain.Models.Requests;
using ruby.domain.Models.Responses;
using ruby.application.Ports.Out.Persistence.IRepositories;
using ruby.domain.Entities;
using ruby.application.Mappers;

namespace ruby.application.Services
{
    public class AuthenticationService : IAuthenticationService
    {
        private readonly IUserRepository _userRepository;
        private readonly IRefreshTokenRepository _refreshTokenRepository;
        private readonly IPasswordHasher _passwordHasher;
        private readonly IJwtTokenService _jwtTokenService;
        private readonly IPhoneVerificationService _phoneVerificationService;
        private readonly IProfileRepository _profileRepository;
        private readonly IGoogleTokenValidator _googleTokenValidator;
        private readonly ILogger<AuthenticationService> _logger;

        public AuthenticationService(
            IUserRepository userRepository, 
            IRefreshTokenRepository refreshTokenRepository, 
            IPasswordHasher passwordHasher, 
            IJwtTokenService jwtTokenService, 
            IPhoneVerificationService phoneVerificationService, 
            IProfileRepository profileRepository,
            IGoogleTokenValidator googleTokenValidator,
            ILogger<AuthenticationService>? logger = null)
        {
            _userRepository = userRepository;
            _refreshTokenRepository = refreshTokenRepository;
            _passwordHasher = passwordHasher;
            _jwtTokenService = jwtTokenService;
            _phoneVerificationService = phoneVerificationService;
            _profileRepository = profileRepository;
            _googleTokenValidator = googleTokenValidator;
            _logger = logger ?? NullLogger<AuthenticationService>.Instance;
        }

        public async Task<RegisterResponse> RegisterAsync(RegisterRequest req)
        {
            _logger.LogInformation("RegisterAsync started for email={Email}", req.Email);

            // simple uniqueness check by email
            var existing = await _userRepository.GetByEmailAsync(req.Email);
            if (existing != null)
            {
                _logger.LogWarning("RegisterAsync rejected duplicate email={Email}", req.Email);
                throw new ApplicationException("User with the same email already exists");
            }

            var now = DateTimeOffset.UtcNow;
            // Use Mapperly-generated mapper to map request -> entity for common properties
            var user = DomainMappers.ToUser(req);
            user.Id = Guid.NewGuid();
            user.UserName = req.Email;
            user.PasswordHash = _passwordHasher.Hash(req.Password);
            user.Status = 1;
            user.CreatedAt = now;
            user.UpdatedAt = now;

            await _userRepository.CreateAsync(user);
            // create initial profile for the user
            var profile = DomainMappers.ToProfile(req);
            profile.UserId = user.Id;
            profile.CreatedAt = now;
            profile.UpdatedAt = now;
            await _profileRepository.CreateOrUpdateAsync(profile);
            return new RegisterResponse { Id = user.Id };
        }

        public async Task<AuthenticationResponse> LoginAsync(LoginRequest loginRequest)
        {
            _logger.LogInformation("LoginAsync started. Identifier={Identifier}, DeviceId={DeviceId}", loginRequest.Identifier, loginRequest.DeviceId);

            User? user = null;
            var usernameOrEmailOrPhone = loginRequest.Identifier;
            if (!string.IsNullOrWhiteSpace(usernameOrEmailOrPhone))
            {
                user = await _userRepository.GetByUsernameAsync(usernameOrEmailOrPhone)
                    ?? await _userRepository.GetByEmailAsync(usernameOrEmailOrPhone);
            }

            if (user == null)
            {
                _logger.LogWarning("LoginAsync failed: invalid identifier={Identifier}", usernameOrEmailOrPhone);
                return new AuthenticationResponse { Success = false, Error = "Invalid credentials" };
            }

            if (!_passwordHasher.Verify(loginRequest.Password, user.PasswordHash))
            {
                _logger.LogWarning("LoginAsync failed: invalid password for userId={UserId}", user.Id);
                return new AuthenticationResponse { Success = false, Error = "Invalid credentials" };
            }

            // update last login
            user.LastLoginAt = DateTimeOffset.UtcNow;
            user.UpdatedAt = DateTimeOffset.UtcNow;
            await _userRepository.UpdateAsync(user);

            return await GenerateAndStoreTokensAsync(user.Id, NormalizeDeviceId(loginRequest.DeviceId));
        }

        public async Task<AuthenticationResponse> LoginWithGoogleAsync(GoogleLoginRequest request)
        {
            // Validate Google ID token with proper signature and claim validation
            var validationResult = await _googleTokenValidator.ValidateTokenAsync(request.IdToken);

            if (!validationResult.IsValid)
            {
                return new AuthenticationResponse { Success = false, Error = validationResult.Error ?? "Invalid Google id token" };
            }

            // Prefer email, fallback to subject if email not provided
            var email = validationResult.Email;
            var subject = validationResult.Subject;

            if (string.IsNullOrWhiteSpace(email) && string.IsNullOrWhiteSpace(subject))
                return new AuthenticationResponse { Success = false, Error = "Unable to extract user information from Google token" };

            // Use actual email if available and verified, otherwise use subject with oauth suffix
            var lookupEmail = !string.IsNullOrWhiteSpace(email) && validationResult.EmailVerified
                ? email
                : (subject + "@google.oauth");

            var user = await _userRepository.GetByEmailAsync(lookupEmail);
            if (user == null)
            {
                var now = DateTimeOffset.UtcNow;
                user = new User
                {
                    Id = Guid.NewGuid(),
                    Email = lookupEmail,
                    UserName = email ?? lookupEmail,
                    PasswordHash = _passwordHasher.Hash(Guid.NewGuid().ToString()),
                    Status = 1,
                    CreatedAt = now,
                    UpdatedAt = now
                };
                await _userRepository.CreateAsync(user);

                // Create profile for OAuth user with name from Google
                var displayName = validationResult.Name ?? email ?? lookupEmail;
                var oauthProfile = new Profile 
                { 
                    UserId = user.Id, 
                    DisplayName = displayName,
                    AvatarUrl = validationResult.Picture,
                    CreatedAt = now, 
                    UpdatedAt = now 
                };
                await _profileRepository.CreateOrUpdateAsync(oauthProfile);
            }
            else
            {
                // Update profile picture if newer one is available from Google
                if (!string.IsNullOrWhiteSpace(validationResult.Picture))
                {
                    var existingProfile = await _profileRepository.GetByUserIdAsync(user.Id);
                    if (existingProfile != null && existingProfile.AvatarUrl != validationResult.Picture)
                    {
                        existingProfile.AvatarUrl = validationResult.Picture;
                        existingProfile.UpdatedAt = DateTimeOffset.UtcNow;
                        await _profileRepository.CreateOrUpdateAsync(existingProfile);
                    }
                }
            }

            user.LastLoginAt = DateTimeOffset.UtcNow;
            user.UpdatedAt = DateTimeOffset.UtcNow;
            await _userRepository.UpdateAsync(user);

            return await GenerateAndStoreTokensAsync(user.Id, NormalizeDeviceId(request.DeviceId));
        }

        public async Task<AuthenticationResponse> RequestPhoneLoginCodeAsync(PhoneVerificationRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.PhoneNumber))
                return new AuthenticationResponse { Success = false, Error = "Phone number is required" };

            var success = await _phoneVerificationService.GenerateCodeAsync(request.PhoneNumber);
            if (!success)
                return new AuthenticationResponse { Success = false, Error = "Unable to generate phone verification code" };

            return new AuthenticationResponse { Success = true };
        }

        public async Task<AuthenticationResponse> LoginWithPhoneAsync(PhoneLoginRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.PhoneNumber) || string.IsNullOrWhiteSpace(request.Code))
                return new AuthenticationResponse { Success = false, Error = "Phone number and code are required" };

            var codeValid = await _phoneVerificationService.ValidateCodeAsync(request.PhoneNumber, request.Code);
            if (!codeValid)
                return new AuthenticationResponse { Success = false, Error = "Invalid phone verification code" };

            var phoneNumber = request.PhoneNumber;
            var user = await _userRepository.GetByPhoneNumberAsync(phoneNumber)
                ?? await _userRepository.GetByUsernameAsync(phoneNumber)
                ?? await _userRepository.GetByEmailAsync(phoneNumber);

            if (user == null)
            {
                var now = DateTimeOffset.UtcNow;
                user = new User
                {
                    Id = Guid.NewGuid(),
                    Email = phoneNumber + "@phone.local",
                    UserName = phoneNumber,
                    PhoneNumber = phoneNumber,
                    PasswordHash = _passwordHasher.Hash(Guid.NewGuid().ToString()),
                    Status = 1,
                    CreatedAt = now,
                    UpdatedAt = now
                };
                await _userRepository.CreateAsync(user);
                
                    var phoneProfile = new Profile { UserId = user.Id, DisplayName = phoneNumber, CreatedAt = now, UpdatedAt = now };
                    await _profileRepository.CreateOrUpdateAsync(phoneProfile);
            }
            else if (string.IsNullOrWhiteSpace(user.PhoneNumber))
            {
                user.PhoneNumber = phoneNumber;
            }

            user.LastLoginAt = DateTimeOffset.UtcNow;
            user.UpdatedAt = DateTimeOffset.UtcNow;
            await _userRepository.UpdateAsync(user);

            return await GenerateAndStoreTokensAsync(user.Id, NormalizeDeviceId(request.DeviceId));
        }

        public async Task<AuthenticationResponse> LoginWithAppleAsync(AppleLoginRequest request)
        {
            // Validate JWT token and extract email or subject
            string? subject = null;
            string? email = null;
            try
            {
                var handler = new JwtSecurityTokenHandler();
                var jwt = handler.ReadJwtToken(request.IdToken);
                email = jwt.Claims.FirstOrDefault(c => c.Type == "email")?.Value;
                subject = jwt.Claims.FirstOrDefault(c => c.Type == JwtRegisteredClaimNames.Sub)?.Value;
            }
            catch
            {
                return new AuthenticationResponse { Success = false, Error = "Invalid Apple id token" };
            }

            var key = email ?? subject;
            if (string.IsNullOrWhiteSpace(key))
                return new AuthenticationResponse { Success = false, Error = "Unable to extract subject from Apple id token" };

            var lookupEmail = email ?? (subject + "@apple.oauth");
            var user = await _userRepository.GetByEmailAsync(lookupEmail);
            if (user == null)
            {
                var now = DateTimeOffset.UtcNow;
                user = new User
                {
                    Id = Guid.NewGuid(),
                    Email = lookupEmail,
                    UserName = lookupEmail,
                    PasswordHash = _passwordHasher.Hash(Guid.NewGuid().ToString()),
                    Status = 1,
                    CreatedAt = now,
                    UpdatedAt = now
                };
                await _userRepository.CreateAsync(user);
                
                    var appleProfile = new Profile { UserId = user.Id, DisplayName = lookupEmail, CreatedAt = now, UpdatedAt = now };
                    await _profileRepository.CreateOrUpdateAsync(appleProfile);
            }

            user.LastLoginAt = DateTimeOffset.UtcNow;
            user.UpdatedAt = DateTimeOffset.UtcNow;
            await _userRepository.UpdateAsync(user);

            return await GenerateAndStoreTokensAsync(user.Id, null);
        }

        public async Task<AuthenticationResponse> LoginWithDeviceAsync(ruby.domain.Models.Requests.DeviceLoginRequest request)
        {
            _logger.LogInformation("LoginWithDeviceAsync started. DeviceId={DeviceId}, DeviceName={DeviceName}", request.DeviceId, request.DeviceName);

            if (string.IsNullOrWhiteSpace(request.DeviceId))
            {
                _logger.LogWarning("LoginWithDeviceAsync failed: DeviceId missing.");
                return new AuthenticationResponse { Success = false, Error = "DeviceId is required" };
            }

            var deviceKey = "device:" + request.DeviceId;
            var fakeName = GenerateQuickLoginName(request.DeviceId);

            // Try find an existing device-bound user by username or email
            var user = await _userRepository.GetByUsernameAsync(deviceKey)
                ?? await _userRepository.GetByEmailAsync(deviceKey + "@device.local");

            if (user == null)
            {
                var now = DateTimeOffset.UtcNow;
                user = new User
                {
                    Id = Guid.NewGuid(),
                    Email = deviceKey + "@device.local",
                    UserName = deviceKey,
                    PasswordHash = _passwordHasher.Hash(Guid.NewGuid().ToString()),
                    Status = 1,
                    CreatedAt = now,
                    UpdatedAt = now
                };

                await _userRepository.CreateAsync(user);
            }

            var profile = await _profileRepository.GetByUserIdAsync(user.Id);
            if (profile == null)
            {
                var now = DateTimeOffset.UtcNow;
                profile = new Profile
                {
                    UserId = user.Id,
                    DisplayName = null,
                    FirstName = fakeName.FirstName,
                    LastName = fakeName.LastName,
                    CreatedAt = now,
                    UpdatedAt = now
                };
            }
            else
            {
                var shouldUpdate = false;

                // Legacy quick-login profiles may have display names derived from device metadata.
                // Clear those so UI can fall back to firstName + lastName.
                if (!string.IsNullOrWhiteSpace(profile.DisplayName))
                {
                    var isLegacyDeviceDisplayName =
                        string.Equals(profile.DisplayName, request.DeviceName, StringComparison.OrdinalIgnoreCase)
                        || string.Equals(profile.DisplayName, request.DeviceId, StringComparison.OrdinalIgnoreCase)
                        || profile.DisplayName.StartsWith("ruby-", StringComparison.OrdinalIgnoreCase);

                    if (isLegacyDeviceDisplayName)
                    {
                        profile.DisplayName = null;
                        shouldUpdate = true;
                    }
                }

                if (string.IsNullOrWhiteSpace(profile.FirstName))
                {
                    profile.FirstName = fakeName.FirstName;
                    shouldUpdate = true;
                }

                if (string.IsNullOrWhiteSpace(profile.LastName))
                {
                    profile.LastName = fakeName.LastName;
                    shouldUpdate = true;
                }

                if (shouldUpdate)
                {
                    profile.UpdatedAt = DateTimeOffset.UtcNow;
                }
            }

            await _profileRepository.CreateOrUpdateAsync(profile);

            user.LastLoginAt = DateTimeOffset.UtcNow;
            user.UpdatedAt = DateTimeOffset.UtcNow;
            await _userRepository.UpdateAsync(user);

            return await GenerateAndStoreTokensAsync(user.Id, NormalizeDeviceId(request.DeviceId));
        }

        public async Task<AuthenticationResponse> RefreshAsync(RefreshRequest request)
        {
            var existing = await _refreshTokenRepository.GetByTokenAsync(request.RefreshToken);
            if (existing == null)
                return new AuthenticationResponse { Success = false, Error = "Invalid refresh token" };

            if (existing.RevokedAt != null || existing.ExpiresAt <= DateTimeOffset.UtcNow)
                return new AuthenticationResponse { Success = false, Error = "Refresh token expired or revoked" };

            // If DeviceId provided, ensure it matches. This helps mitigate token theft.
            // Extend RefreshRequest with optional DeviceId if needed; when not provided, skip this check.
            var requestDeviceId = NormalizeDeviceId(request.DeviceId);

            if (!string.IsNullOrWhiteSpace(requestDeviceId) && !string.Equals(requestDeviceId, existing.DeviceId, StringComparison.Ordinal))
            {
                // possible token misuse - revoke
                existing.RevokedAt = DateTimeOffset.UtcNow;
                existing.UpdatedAt = DateTimeOffset.UtcNow;
                await _refreshTokenRepository.UpdateAsync(existing);
                return new AuthenticationResponse { Success = false, Error = "Device mismatch for refresh token" };
            }

            // revoke old
            existing.RevokedAt = DateTimeOffset.UtcNow;
            existing.UpdatedAt = DateTimeOffset.UtcNow;
            await _refreshTokenRepository.UpdateAsync(existing);

            return await GenerateAndStoreTokensAsync(existing.UserId, requestDeviceId);
        }

        public async Task LogoutAsync(LogoutRequest request)
        {
            var existing = await _refreshTokenRepository.GetByTokenAsync(request.RefreshToken);
            if (existing == null) return;
            existing.RevokedAt = DateTimeOffset.UtcNow;
            existing.UpdatedAt = DateTimeOffset.UtcNow;
            await _refreshTokenRepository.UpdateAsync(existing);
        }

        private async Task<AuthenticationResponse> GenerateAndStoreTokensAsync(Guid userId, string? deviceId = null)
        {
            _logger.LogInformation("GenerateAndStoreTokensAsync started. UserId={UserId}, DeviceId={DeviceId}", userId, deviceId);

            var profile = await _profileRepository.GetByUserIdAsync(userId);
            var accessToken = _jwtTokenService.GenerateAccessToken(userId, profile?.FirstName, profile?.LastName);
            var refreshToken = Guid.NewGuid().ToString("N");

            var now = DateTimeOffset.UtcNow;
            var rt = new RefreshToken
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                Token = refreshToken,
                DeviceId = deviceId,
                CreatedAt = now,
                UpdatedAt = now,
                ExpiresAt = now.AddDays(30)
            };

            await _refreshTokenRepository.CreateAsync(rt);

            _logger.LogInformation("Tokens generated for userId={UserId}. RefreshTokenCreated={Created}", userId, rt.Id != Guid.Empty);

            return new AuthenticationResponse
            {
                UserId = userId,
                ProfileId = profile != null && profile.Id != Guid.Empty ? profile.Id : null,
                DisplayName = profile?.DisplayName,
                FirstName = profile?.FirstName,
                LastName = profile?.LastName,
                AvatarUrl = ResolveAvatarUrl(profile?.AvatarUrl, userId),
                AccessToken = accessToken,
                RefreshToken = refreshToken
            };
        }

        private static string ResolveAvatarUrl(string? avatarUrl, Guid userId)
        {
            if (!string.IsNullOrWhiteSpace(avatarUrl))
                return avatarUrl;

            return $"https://i.pravatar.cc/300?u={userId}";
        }

        private static (string FirstName, string LastName) GenerateQuickLoginName(string seed)
        {
            var firstNames = new[]
            {
                "Alex", "Jamie", "Taylor", "Jordan", "Riley", "Casey", "Sky", "Mika", "Drew", "Parker"
            };
            var lastNames = new[]
            {
                "Blake", "Turner", "Hayes", "Rowan", "Reed", "Brooks", "Quinn", "Flynn", "Ellis", "Carter"
            };

            using var md5 = MD5.Create();
            var hash = md5.ComputeHash(Encoding.UTF8.GetBytes(seed));

            var firstIndex = hash[0] % firstNames.Length;
            var lastIndex = hash[1] % lastNames.Length;

            return (firstNames[firstIndex], lastNames[lastIndex]);
        }

        private static string? NormalizeDeviceId(string? deviceId)
        {
            if (string.IsNullOrWhiteSpace(deviceId))
                return null;

            if (Guid.TryParse(deviceId, out var parsed))
                return parsed.ToString("D");

            using var md5 = MD5.Create();
            var hash = md5.ComputeHash(Encoding.UTF8.GetBytes(deviceId.Trim()));
            return new Guid(hash).ToString("D");
        }

    }
}
