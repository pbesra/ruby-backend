using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Net.Http;
using System.Security.Claims;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace ruby.application.Services
{
    public interface IGoogleTokenValidator
    {
        Task<GoogleTokenValidationResult> ValidateTokenAsync(string idToken);
    }

    public class GoogleTokenValidationResult
    {
        public bool IsValid { get; set; }
        public string? Error { get; set; }
        public string? Email { get; set; }
        public string? Subject { get; set; }
        public string? Name { get; set; }
        public string? Picture { get; set; }
        public bool EmailVerified { get; set; }
    }

    public class GoogleTokenValidator : IGoogleTokenValidator
    {
        private readonly IConfiguration _configuration;
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly string _googleClientId;
        private static readonly string GoogleJwksUri = "https://www.googleapis.com/oauth2/v3/certs";
        private static JsonWebKeySet? _cachedJwks;
        private static DateTime _jwksCacheExpiry = DateTime.MinValue;

        public GoogleTokenValidator(IConfiguration configuration, IHttpClientFactory httpClientFactory)
        {
            _configuration = configuration;
            _httpClientFactory = httpClientFactory;
            _googleClientId = _configuration["Authentication:Google:ClientId"] ?? throw new InvalidOperationException("Google ClientId not configured");
        }

        public async Task<GoogleTokenValidationResult> ValidateTokenAsync(string idToken)
        {
            try
            {
                var handler = new JwtSecurityTokenHandler();

                // Parse token without validation first to check basic structure
                if (!handler.CanReadToken(idToken))
                {
                    return new GoogleTokenValidationResult { IsValid = false, Error = "Invalid token format" };
                }

                var jwt = handler.ReadJwtToken(idToken);

                // Get Google's signing keys
                var jwks = await GetGooglePublicKeysAsync();
                if (jwks == null)
                {
                    return new GoogleTokenValidationResult { IsValid = false, Error = "Failed to retrieve Google public keys" };
                }

                // Set up validation parameters
                var validationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidIssuers = new[] { "https://accounts.google.com", "accounts.google.com" },
                    ValidateAudience = true,
                    ValidAudience = _googleClientId,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKeys = jwks.GetSigningKeys(),
                    ClockSkew = TimeSpan.FromMinutes(5) // Allow 5 minutes clock skew
                };

                // Validate token
                var principal = handler.ValidateToken(idToken, validationParameters, out var validatedToken);

                // Extract claims
                var email = principal.FindFirst(ClaimTypes.Email)?.Value 
                    ?? principal.FindFirst("email")?.Value;
                var subject = principal.FindFirst(ClaimTypes.NameIdentifier)?.Value 
                    ?? principal.FindFirst(JwtRegisteredClaimNames.Sub)?.Value;
                var name = principal.FindFirst(ClaimTypes.Name)?.Value 
                    ?? principal.FindFirst("name")?.Value;
                var picture = principal.FindFirst("picture")?.Value;
                var emailVerifiedClaim = principal.FindFirst("email_verified")?.Value;
                var emailVerified = emailVerifiedClaim != null && (emailVerifiedClaim == "true" || emailVerifiedClaim == "True");

                return new GoogleTokenValidationResult
                {
                    IsValid = true,
                    Email = email,
                    Subject = subject,
                    Name = name,
                    Picture = picture,
                    EmailVerified = emailVerified
                };
            }
            catch (SecurityTokenExpiredException)
            {
                return new GoogleTokenValidationResult { IsValid = false, Error = "Token has expired" };
            }
            catch (SecurityTokenInvalidSignatureException)
            {
                return new GoogleTokenValidationResult { IsValid = false, Error = "Invalid token signature" };
            }
            catch (SecurityTokenInvalidAudienceException)
            {
                return new GoogleTokenValidationResult { IsValid = false, Error = "Invalid audience - token not intended for this application" };
            }
            catch (SecurityTokenInvalidIssuerException)
            {
                return new GoogleTokenValidationResult { IsValid = false, Error = "Invalid issuer - token not from Google" };
            }
            catch (Exception ex)
            {
                return new GoogleTokenValidationResult { IsValid = false, Error = $"Token validation failed: {ex.Message}" };
            }
        }

        private async Task<JsonWebKeySet?> GetGooglePublicKeysAsync()
        {
            // Return cached keys if still valid (cache for 1 hour)
            if (_cachedJwks != null && DateTime.UtcNow < _jwksCacheExpiry)
            {
                return _cachedJwks;
            }

            try
            {
                var httpClient = _httpClientFactory.CreateClient();
                var response = await httpClient.GetStringAsync(GoogleJwksUri);
                _cachedJwks = new JsonWebKeySet(response);
                _jwksCacheExpiry = DateTime.UtcNow.AddHours(1);
                return _cachedJwks;
            }
            catch
            {
                // If we can't refresh, return cached keys if available
                return _cachedJwks;
            }
        }
    }
}
