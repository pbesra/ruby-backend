using System.Data;

namespace ruby.infrastructure.Persistence.IRepositories
{
    public interface ISQLDatabase
    {
        Task<IDbConnection> GetConnection();
    }
}