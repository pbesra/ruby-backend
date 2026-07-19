using Microsoft.Extensions.Configuration;
using ruby.infrastructure.Interfaces;

namespace ruby.infrastructure.Configurations
{
    public class RootConfiguration:IRootConfiguration
    {
        public async Task<bool> ValidMigrationConfigurationPath(IConfiguration configuration)
        {
            var path = configuration.GetSection("RootConfiguration")["MigrationPath"];
            var directory = new DirectoryInfo(path);
            if (directory.Exists && directory.GetFiles().Length > 0)
            {
                return true;
            }
            return false;
        }
    }
}