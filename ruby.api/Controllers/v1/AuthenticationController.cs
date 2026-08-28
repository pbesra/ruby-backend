using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging.Abstractions;
using System.Text.Json;
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
        private readonly ILogger<AuthenticationController> _logger;

        public AuthenticationController(IAuthenticationService authenticationService, ILogger<AuthenticationController>? logger = null)
        {
            _authenticationService = authenticationService;
            _logger = logger ?? NullLogger<AuthenticationController>.Instance;
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
        public async Task<IActionResult> LoginWithDevice()
        {
            var request = await ParseDeviceLoginRequestAsync();
            var response = await _authenticationService.LoginWithDeviceAsync(request);
            if (!response.Success) return BadRequest(response);
            return Ok(response);
        }

        [HttpPost("login/quick")]
        public async Task<IActionResult> QuickLogin()
        {
            _logger.LogInformation(
                "Quick login request received. RemoteIp={RemoteIp}, UserAgent={UserAgent}",
                HttpContext.Connection.RemoteIpAddress,
                Request.Headers.UserAgent.ToString());

            var request = await ParseDeviceLoginRequestAsync();
            _logger.LogInformation(
                "Quick login parsed payload. DeviceId={DeviceId}, DeviceName={DeviceName}",
                request.DeviceId,
                request.DeviceName);

            var response = await _authenticationService.LoginWithDeviceAsync(request);
            if (!response.Success)
            {
                _logger.LogWarning("Quick login failed. DeviceId={DeviceId}, Error={Error}", request.DeviceId, response.Error);
                return BadRequest(response);
            }

            _logger.LogInformation("Quick login succeeded. DeviceId={DeviceId}, UserId={UserId}", request.DeviceId, response.UserId);
            return Ok(response);
        }

        private async Task<DeviceLoginRequest> ParseDeviceLoginRequestAsync()
        {
            var request = new DeviceLoginRequest();
            if (Request.Body == null || !Request.Body.CanRead)
            {
                _logger.LogWarning("Quick login request body is missing or unreadable.");
                return request;
            }

            Request.EnableBuffering();
            using var reader = new StreamReader(Request.Body, leaveOpen: true);
            var bodyText = await reader.ReadToEndAsync();
            if (Request.Body.CanSeek)
            {
                Request.Body.Position = 0;
            }

            _logger.LogInformation("Quick login raw request body: {Body}", bodyText);

            if (string.IsNullOrWhiteSpace(bodyText))
            {
                _logger.LogWarning("Quick login request body is empty.");
                return request;
            }

            try
            {
                using var document = JsonDocument.Parse(bodyText);
                var payload = document.RootElement;
                if (payload.ValueKind != JsonValueKind.Object)
                {
                    return request;
                }

                if (payload.TryGetProperty("deviceId", out var deviceIdProp))
                {
                    request.DeviceId = deviceIdProp.GetString() ?? string.Empty;
                }
                else if (payload.TryGetProperty("DeviceId", out var deviceIdPropPascal))
                {
                    request.DeviceId = deviceIdPropPascal.GetString() ?? string.Empty;
                }

                if (payload.TryGetProperty("deviceName", out var deviceNameProp))
                {
                    request.DeviceName = deviceNameProp.GetString();
                }
                else if (payload.TryGetProperty("DeviceName", out var deviceNamePropPascal))
                {
                    request.DeviceName = deviceNamePropPascal.GetString();
                }
            }
            catch (JsonException ex)
            {
                _logger.LogError(ex, "Quick login request body could not be parsed as JSON. Body={Body}", bodyText);
                request.DeviceId = string.Empty;
                request.DeviceName = null;
            }

            return request;
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