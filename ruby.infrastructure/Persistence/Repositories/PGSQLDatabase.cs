using System.Data;
using Npgsql;
using ruby.domain.ModelConfig;
using ruby.infrastructure.Persistence.IRepositories;

namespace ruby.infrastructure.Persistence.Repositories
{
    public class PGSQLDatabase : ISQLDatabase
    {
        private readonly IDatabaseConfiguration _databaseConfiguration;
        private readonly IDatabaseConfig _databaseConfig;

        public PGSQLDatabase(IDatabaseConfiguration databaseConfiguration)
        {
            _databaseConfiguration = databaseConfiguration;
            _databaseConfig = _databaseConfiguration.GetDatabaseConfig();
        }

        public async Task<IDbConnection> GetConnection()
        {
            return new NpgsqlConnection(await GetConnectionString());
        }

        private async Task<string> GetConnectionString()
        {
            var builder = new NpgsqlConnectionStringBuilder
            {
                Host = _databaseConfig.Host,
                Port = _databaseConfig.Port,
                Database = _databaseConfig.Database,
                Username = _databaseConfig.Username,
                Password = _databaseConfig.Password,
                Pooling = true,
                TrustServerCertificate = true
            };
            return builder.ConnectionString;
        }
    }
}
