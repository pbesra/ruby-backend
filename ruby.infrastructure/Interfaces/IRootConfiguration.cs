using Microsoft.Extensions.Configuration;

namespace ruby.infrastructure.Interfaces
{
    public interface IRootConfiguration
    {
        Task<bool> ValidMigrationConfigurationPath(IConfiguration configuration);
    }
}