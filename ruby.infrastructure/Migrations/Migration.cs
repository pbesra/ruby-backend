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
            try
            {
                var evolve = new EvolveDb.Evolve((DbConnection)connection)
                {
                    Locations = new[] { migrationPath },
                    IsEraseDisabled = true,
                    CommandTimeout = 300
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
                //throw new CustomEvolveException(migrationPath, ex);
                throw new Exception(ex?.Message);
            }
        }
    }
}