using Microsoft.Extensions.Configuration;
using ruby.infrastructure.Interfaces;

namespace ruby.infrastructure.Configurations
{
    public class RootConfiguration : IRootConfiguration
    {
        public async Task<bool> ValidMigrationConfigurationPath(IConfiguration configuration)
        {
            var path = configuration.GetSection("RootConfiguration")["MigrationPath"];
            var migrationPath = string.IsNullOrWhiteSpace(path) ? "MigrationScripts" : path;

            try
            {
                var directory = new DirectoryInfo(migrationPath);
                if (directory.Exists && directory.GetFiles().Length > 0)
                {
                    return true;
                }
            }
            catch
            {
                return false;
            }

            return false;
        }
    }
}