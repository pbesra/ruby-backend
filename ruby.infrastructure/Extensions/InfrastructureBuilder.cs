using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using ruby.domain.ModelConfig;
using ruby.infrastructure.Configurations;
using ruby.infrastructure.Interfaces;
using ruby.infrastructure.Migrations;
using ruby.infrastructure.Persistence.IRepositories;
using ruby.infrastructure.Persistence.Repositories;
using System.Data;

namespace ruby.infrastructure.Extensions
{
    public static class InfrastructureBuilder
    {
        public static IServiceCollection AddPersistenceBuilderServices(this IServiceCollection services, IConfiguration configuration)
        {
            services.Configure<PGDatabaseConfig>(configuration.GetSection("DatabaseConnection"));
            services.AddMemoryCache();
            services.AddSingleton<IDatabaseConfiguration, PGDatabaseConfiguration>();
            services.AddScoped<ISQLDatabase, PGSQLDatabase>();
            services.AddScoped<IMigration, Migration>();
            services.AddSingleton<IRootConfiguration, RootConfiguration>();
            services.AddSingleton<IDatabaseConfig, PGDatabaseConfig>();
            services.AddSingleton<ruby.infrastructure.Services.IReferenceCacheService, ruby.infrastructure.Services.ReferenceCacheService>();

            // persistence repositories
            services.AddScoped<ruby.application.Ports.Out.Persistence.IRepositories.IUserRepository, ruby.infrastructure.Persistence.Repositories.UserRepository>();
            services.AddScoped<ruby.application.Ports.Out.Persistence.IRepositories.IRefreshTokenRepository, ruby.infrastructure.Persistence.Repositories.RefreshTokenRepository>();
            services.AddScoped<ruby.application.Ports.Out.Persistence.IRepositories.IProfileRepository, ruby.infrastructure.Persistence.Repositories.ProfileRepository>();
            services.AddScoped<ruby.application.Ports.Out.Persistence.IRepositories.IProfileRatingRepository, ruby.infrastructure.Persistence.Repositories.ProfileRatingRepository>();
            services.AddScoped<ruby.application.Ports.Out.Persistence.IRepositories.IHomeFeedRepository, ruby.infrastructure.Persistence.Repositories.HomeFeedRepository>();

            return services;
        }

        private static Task<IDbConnection> GetDBConnection(IServiceProvider serviceProvider)
        {
            var databaseProvider = serviceProvider.GetRequiredService<ISQLDatabase>();
            return databaseProvider.GetConnection();
        }

        public static async Task<bool> UseMigrationScope(this IServiceScope scope)
        {
            var serviceProvider = scope.ServiceProvider;
            var rootConfiguration = serviceProvider.GetRequiredService<IRootConfiguration>();
            var configuration = serviceProvider.GetRequiredService<IConfiguration>();
            var migrationService = serviceProvider.GetRequiredService<IMigration>();
            var migrationPath = configuration.GetSection("RootConfiguration")["MigrationPath"];

            if (string.IsNullOrWhiteSpace(migrationPath) || !await rootConfiguration.ValidMigrationConfigurationPath(configuration))
            {
                return false;
            }

            using var dbConnection = await GetDBConnection(serviceProvider);
            return await migrationService.RunMigration(dbConnection, migrationPath);
        }
    }
}