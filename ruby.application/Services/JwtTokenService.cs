using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using ruby.application.Ports.In.IServices;

namespace ruby.application.Services
{
    public class JwtTokenService : IJwtTokenService
    {
        private readonly IConfiguration _configuration;
        private readonly string _key;
        private readonly string _issuer;
        private readonly string _audience;

        public JwtTokenService(IConfiguration configuration)
        {
            _configuration = configuration;
            _key = _configuration["Jwt:Key"] ?? "dev-secret-key-change-me";
            _issuer = _configuration["Jwt:Issuer"] ?? "ruby";
            _audience = _configuration["Jwt:Audience"] ?? "ruby-client";
        }

        public string GenerateAccessToken(Guid userId, string? firstName = null, string? lastName = null)
        {
            var claimsList = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, userId.ToString()),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            if (!string.IsNullOrWhiteSpace(firstName))
                claimsList.Add(new Claim("firstname", firstName));

            if (!string.IsNullOrWhiteSpace(lastName))
                claimsList.Add(new Claim("lastname", lastName));

            var claims = claimsList.ToArray();

            // Ensure key material is at least 256 bits for HS256. If configured key is shorter,
            // derive a 256-bit key deterministically using SHA-256 of the configured value.
            var keyBytes = Encoding.UTF8.GetBytes(_key ?? string.Empty);
            if (keyBytes.Length < 32)
            {
                using var sha = System.Security.Cryptography.SHA256.Create();
                keyBytes = sha.ComputeHash(keyBytes);
            }

            var key = new SymmetricSecurityKey(keyBytes);
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _issuer,
                audience: _audience,
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(15),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
