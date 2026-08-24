using EvolveDb;
using ruby.infrastructure.Interfaces;
using System.Data;
using System.Data.Common;

namespace ruby.infrastructure.Migrations
{
    public class Migration: IMigration
    {
        public async Task<bool> RunMigration(IDbConnection connection, string migrationPath)
        {
            if (string.IsNullOrWhiteSpace(migrationPath))
            {
                throw new ArgumentException("Migration path cannot be null or empty.");
            }

            try
            {
                var evolve = new EvolveDb.Evolve((DbConnection)connection)
                {
                    Locations = new[] { migrationPath },
                    IsEraseDisabled = true,
                    CommandTimeout = 500
                };
                evolve.Migrate();
                return true;
            }
            catch (EvolveSqlException ex)
            {
                throw new Exception(ex?.Message);
            }
            catch (EvolveException ex)
            {
                throw new Exception(ex?.Message);
            }
            catch (Exception ex)
            {
                throw new Exception(ex?.Message);
            }
        }
    }
}