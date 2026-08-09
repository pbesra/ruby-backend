using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using ruby.application.Ports.In.IServices;
using ruby.application.Services;

namespace ruby.application.Extensions
{
    public static class ApplicationBuilder
    {
        public static IServiceCollection AddApplicationBuilder(this IServiceCollection services)
        {
            services.AddHttpClient(); // Required for GoogleTokenValidator
            services.AddScoped<IAuthenticationService, AuthenticationService>();
            services.AddScoped<IHomeFeedService, HomeFeedService>();
            services.AddScoped<IProfileService, ProfileService>();
            services.AddScoped<IPhoneVerificationService, PhoneVerificationService>();
            services.AddScoped<IPasswordHasher, Pbkdf2PasswordHasher>();
            services.AddSingleton<IJwtTokenService, JwtTokenService>();
            services.AddScoped<IGoogleTokenValidator, GoogleTokenValidator>();
            return services;
        }
    }
}