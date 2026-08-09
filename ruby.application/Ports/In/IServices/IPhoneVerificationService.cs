using System.Threading.Tasks;

namespace ruby.application.Ports.In.IServices
{
    public interface IPhoneVerificationService
    {
        Task<bool> GenerateCodeAsync(string phoneNumber);
        Task<bool> ValidateCodeAsync(string phoneNumber, string code);
    }
}
