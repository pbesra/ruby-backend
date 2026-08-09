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
            _config = options.Value;
            _configuration = configuration;
        }

        public IDatabaseConfig GetDatabaseConfig()
        {
            if (string.IsNullOrWhiteSpace(_config.Host) || _config.Port <= 0)
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

            if (_config.Port <= 0)
            {
                _config.Port = 5432;
            }

            return _config;
        }
    }
}