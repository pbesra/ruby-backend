using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Options;
using Npgsql;
using ruby.domain.ModelConfig;
using ruby.infrastructure.Persistence.IRepositories;

namespace ruby.infrastructure.Persistence.Repositories
{
    public class PGDatabaseConfiguration : IDatabaseConfiguration
    {
        private readonly PGDatabaseConfig _config;
        private readonly IConfiguration _configuration;

        public PGDatabaseConfiguration(IOptions<PGDatabaseConfig> options, IConfiguration configuration)
        {
            _config = options.Value ?? new PGDatabaseConfig();
            _configuration = configuration;
        }

        public IDatabaseConfig GetDatabaseConfig()
        {
            var section = _configuration.GetSection("DatabaseConnection");
            var sectionConfig = section.Get<PGDatabaseConfig>() ?? new PGDatabaseConfig();

            _config.Host = string.IsNullOrWhiteSpace(_config.Host) ? sectionConfig.Host : _config.Host;
            _config.Database = string.IsNullOrWhiteSpace(_config.Database) ? sectionConfig.Database : _config.Database;
            _config.Username = string.IsNullOrWhiteSpace(_config.Username) ? sectionConfig.Username : _config.Username;
            _config.Password = string.IsNullOrWhiteSpace(_config.Password) ? sectionConfig.Password : _config.Password;
            _config.Port = _config.Port <= 0 ? sectionConfig.Port : _config.Port;

            if (string.IsNullOrWhiteSpace(_config.Host) || string.IsNullOrWhiteSpace(_config.Database) || string.IsNullOrWhiteSpace(_config.Username))
            {
                var connectionString = _configuration.GetConnectionString("DefaultConnection");
                if (!string.IsNullOrWhiteSpace(connectionString))
                {
                    var builder = new NpgsqlConnectionStringBuilder(connectionString);
                    _config.Host = string.IsNullOrWhiteSpace(_config.Host) ? builder.Host : _config.Host;
                    _config.Port = _config.Port <= 0 ? builder.Port : _config.Port;
                    _config.Database = string.IsNullOrWhiteSpace(_config.Database) ? builder.Database : _config.Database;
                    _config.Username = string.IsNullOrWhiteSpace(_config.Username) ? builder.Username : _config.Username;
                    _config.Password = string.IsNullOrWhiteSpace(_config.Password) ? builder.Password : _config.Password;
                }
            }

            _config.Host = string.IsNullOrWhiteSpace(_config.Host) ? "localhost" : _config.Host;
            _config.Database = string.IsNullOrWhiteSpace(_config.Database) ? "ruby" : _config.Database;
            _config.Username = string.IsNullOrWhiteSpace(_config.Username) ? "postgres" : _config.Username;
            _config.Password = string.IsNullOrWhiteSpace(_config.Password) ? "root" : _config.Password;
            _config.Port = _config.Port <= 0 ? 5432 : _config.Port;

            return _config;
        }
    }
}