namespace ruby.application.Ports.In.IServices
{
    public interface IJwtTokenService
    {
        string GenerateAccessToken(Guid userId, string? firstName = null, string? lastName = null);
    }
}