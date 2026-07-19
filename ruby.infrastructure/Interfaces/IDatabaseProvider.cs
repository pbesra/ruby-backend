using System.Data;

namespace ruby.infrastructure.Interfaces
{
    public interface IDatabaseProvider
    {
        IDbConnection GetDatabaseProvider();
    }
}