using Riok.Mapperly.Abstractions;
using ruby.domain.Models.Requests;
using ruby.domain.Entities;

namespace ruby.application.Mappers
{
    [Mapper]
    public static partial class DomainMappers
    {
        // Map simple properties from RegisterRequest -> User (Email -> Email)
        public static partial User ToUser(RegisterRequest request);
        public static partial ruby.domain.Entities.Profile ToProfile(RegisterRequest request);
    }
}
