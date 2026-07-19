using Microsoft.Data.SqlClient;
using Npgsql;
using ruby.infrastructure.Interfaces;
using System.Data;

namespace ruby.infrastructure.Providers
{
    public class DatabaseProvider : IDatabaseProvider
    {
        private readonly string _provider;
        private readonly string _connectionString;

        public DatabaseProvider(string provider, string connectionString)
        {
            _provider = provider;
            _connectionString = connectionString;
        }

        public IDbConnection GetDatabaseProvider()
        {
            switch (_provider)
            {
                case "sqlserver":
                    return new SqlConnection(_connectionString);

                case "postgres":
                    return new NpgsqlConnection(_connectionString);

                default:
                    throw new NotSupportedException($"The provider '{_provider}' is not supported.");
            }
        }
    }
}