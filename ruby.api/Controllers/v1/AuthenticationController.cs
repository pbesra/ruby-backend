using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using ruby.application.Ports.In.IServices;
using ruby.domain.Models.Requests;
using ruby.domain.Models.Responses;

namespace ruby.api.Controllers.v1
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class AuthenticationController : ControllerBase
    {
        private readonly IAuthenticationService _authenticationService;

        public AuthenticationController(IAuthenticationService authenticationService)
        {
            _authenticationService = authenticationService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            var response = await _authenticationService.RegisterAsync(request);
            return Ok(response);
        }

        [HttpPost("login/google")]
        public async Task<IActionResult> LoginWithGoogle([FromBody] GoogleLoginRequest request)
        {
            var response = await _authenticationService.LoginWithGoogleAsync(request);
            if (!response.Success) return Unauthorized(response);
            return Ok(response);
        }

        [HttpPost("login/phone/request-code")]
        public async Task<IActionResult> RequestPhoneLoginCode([FromBody] PhoneVerificationRequest request)
        {
            var response = await _authenticationService.RequestPhoneLoginCodeAsync(request);
            if (!response.Success) return BadRequest(response);
            return Ok(response);
        }

        [HttpPost("login/phone")]
        public async Task<IActionResult> LoginWithPhone([FromBody] PhoneLoginRequest request)
        {
            var response = await _authenticationService.LoginWithPhoneAsync(request);
            if (!response.Success) return Unauthorized(response);
            return Ok(response);
        }

        [HttpPost("login/apple")]
        public async Task<IActionResult> LoginWithApple([FromBody] AppleLoginRequest request)
        {
            var response = await _authenticationService.LoginWithAppleAsync(request);
            if (!response.Success) return Unauthorized(response);
            return Ok(response);
        }

        [HttpPost("login/device")]
        public async Task<IActionResult> LoginWithDevice([FromBody] ruby.domain.Models.Requests.DeviceLoginRequest request)
        {
            var response = await _authenticationService.LoginWithDeviceAsync(request);
            if (!response.Success) return BadRequest(response);
            return Ok(response);
        }

        [HttpPost("login/quick")]
        public async Task<IActionResult> QuickLogin([FromBody] DeviceLoginRequest request)
        {
            var response = await _authenticationService.LoginWithDeviceAsync(request);
            if (!response.Success) return BadRequest(response);
            return Ok(response);
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            var response = await _authenticationService.LoginAsync(request);
            if (!response.Success) return Unauthorized(response);
            return Ok(response);
        }

        [HttpPost("refresh")]
        public async Task<IActionResult> Refresh([FromBody] RefreshRequest request)
        {
            var response = await _authenticationService.RefreshAsync(request);
            if (!response.Success) return Unauthorized(response);
            return Ok(response);
        }

        [HttpPost("logout")]
        public async Task<IActionResult> Logout([FromBody] LogoutRequest request)
        {
            await _authenticationService.LogoutAsync(request);
            return NoContent();
        }
    }
}