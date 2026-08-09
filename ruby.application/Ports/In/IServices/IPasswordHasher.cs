namespace ruby.application.Ports.In.IServices
{
    public interface IPasswordHasher
    {
        string Hash(string password);

        bool Verify(string password, string hashedPassword);
    }
}
