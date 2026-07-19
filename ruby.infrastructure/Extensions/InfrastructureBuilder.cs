using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using ruby.domain.Constants;
using ruby.infrastructure.Configurations;
using ruby.infrastructure.Interfaces;
using ruby.infrastructure.Migrations;
using ruby.infrastructure.Providers;
using System.Data;

namespace ruby.infrastructure.Extensions
{
    public static class InfrastructureBuilder
    {
        public static IServiceCollection AddPersistenceBuilderServices(this IServiceCollection services, IConfiguration configuration)
        {
            services.AddSingleton<IMigration, Migration>();
            services.AddSingleton<IRootConfiguration, RootConfiguration>();
            services.AddSingleton<IDatabaseProvider>(sp =>
            {
                return new DatabaseProvider(configuration.GetSection("DatabaseProvider")["Provider"], configuration.GetConnectionString(DBConstant.ConnectionStringName));
            });
            return services;
        }

        private static IDbConnection GetAuthDBConnection(IServiceProvider serviceProvider)
        {
            var rootConfiguration = serviceProvider.GetRequiredService<IDatabaseProvider>();
            return rootConfiguration.GetDatabaseProvider();
        }

        public static async Task<bool> UseMigrationScope(this IServiceScope scope)
        {
            var serviceProvider = scope.ServiceProvider;
            var rootConfiguration = serviceProvider.GetRequiredService<IRootConfiguration>();
            var configuration = serviceProvider.GetRequiredService<IConfiguration>();
            var migrationService = serviceProvider.GetRequiredService<IMigration>();
            var migrationPath = configuration.GetSection("RootConfiguration")["MigrationPath"];
            var dbConnection = GetAuthDBConnection(serviceProvider);
            if (await rootConfiguration.ValidMigrationConfigurationPath(configuration))
            {
                return await migrationService.RunMigration(dbConnection, migrationPath);
            }
            return false;
        }
    }
}