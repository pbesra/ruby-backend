using System;
using System.Threading.Tasks;
using ruby.domain.Models.Requests;
using ruby.domain.Models.Responses;

namespace ruby.application.Ports.In.IServices
{
    public interface IAuthenticationService
    {
        Task<RegisterResponse> RegisterAsync(RegisterRequest req);

        Task<AuthenticationResponse> LoginAsync(LoginRequest request);

        Task<AuthenticationResponse> LoginWithGoogleAsync(GoogleLoginRequest request);

        Task<AuthenticationResponse> RequestPhoneLoginCodeAsync(PhoneVerificationRequest request);

        Task<AuthenticationResponse> LoginWithPhoneAsync(PhoneLoginRequest request);

        Task<AuthenticationResponse> LoginWithAppleAsync(AppleLoginRequest request);

        Task<AuthenticationResponse> LoginWithDeviceAsync(ruby.domain.Models.Requests.DeviceLoginRequest request);

        Task<AuthenticationResponse> RefreshAsync(RefreshRequest request);

        Task LogoutAsync(LogoutRequest request);
    }
}
