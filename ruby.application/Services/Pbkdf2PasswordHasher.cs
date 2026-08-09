using System.Security.Cryptography;
using System.Text;
using ruby.application.Ports.In.IServices;

namespace ruby.application.Services
{
    public class Pbkdf2PasswordHasher : IPasswordHasher
    {
        // PBKDF2 settings
        private const int Iterations = 100_000;
        private const int SaltSize = 16;
        private const int HashSize = 32;

        public string Hash(string password)
        {
            var salt = RandomNumberGenerator.GetBytes(SaltSize);
            var hash = Rfc2898DeriveBytes.Pbkdf2(Encoding.UTF8.GetBytes(password), salt, Iterations, HashAlgorithmName.SHA256, HashSize);
            var result = new byte[SaltSize + HashSize];
            Buffer.BlockCopy(salt, 0, result, 0, SaltSize);
            Buffer.BlockCopy(hash, 0, result, SaltSize, HashSize);
            return Convert.ToBase64String(result);
        }

        public bool Verify(string password, string hashedPassword)
        {
            var bytes = Convert.FromBase64String(hashedPassword);
            var salt = new byte[SaltSize];
            Buffer.BlockCopy(bytes, 0, salt, 0, SaltSize);
            var hash = new byte[HashSize];
            Buffer.BlockCopy(bytes, SaltSize, hash, 0, HashSize);
            var computed = Rfc2898DeriveBytes.Pbkdf2(Encoding.UTF8.GetBytes(password), salt, Iterations, HashAlgorithmName.SHA256, HashSize);
            return CryptographicOperations.FixedTimeEquals(computed, hash);
        }
    }
}
