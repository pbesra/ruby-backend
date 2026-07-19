using System.Data;

namespace ruby.infrastructure.Interfaces
{
    public interface IMigration
    {
        Task<bool> RunMigration(IDbConnection connection, string migrationPath);
    }
}