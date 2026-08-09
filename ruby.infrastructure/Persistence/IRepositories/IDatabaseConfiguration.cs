using ruby.domain.ModelConfig;

namespace ruby.infrastructure.Persistence.IRepositories
{
    public interface IDatabaseConfiguration
    {
        public IDatabaseConfig GetDatabaseConfig();
    }
}