using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging.Abstractions;
using ruby.application.Ports.In.IServices;
using ruby.domain.Models.Requests;

namespace ruby.api.Controllers.v1
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class ProfileController : ControllerBase
    {
        private readonly IProfileService _profileService;
        private readonly ILogger<ProfileController> _logger;

        public ProfileController(IProfileService profileService, ILogger<ProfileController>? logger = null)
        {
            _profileService = profileService;
            _logger = logger ?? NullLogger<ProfileController>.Instance;
        }

        [HttpGet("{userId:guid}")]
        public async Task<IActionResult> GetProfile([FromRoute] Guid userId, [FromQuery] Guid currentUserId)
        {
            _logger.LogInformation("GetProfile request received. UserId={UserId}, CurrentUserId={CurrentUserId}", userId, currentUserId);
            var response = await _profileService.GetProfileAsync(userId, currentUserId);
            if (!response.Success)
            {
                _logger.LogWarning("GetProfile failed. UserId={UserId}, Error={Error}", userId, response.Error);
                return NotFound(response);
            }

            _logger.LogInformation("GetProfile completed. UserId={UserId}, Name={Name}", userId, response.Name);
            return Ok(response);
        }

        [HttpPost("update")]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileRequest request)
        {
            _logger.LogInformation("UpdateProfile request received. UserId={UserId}, ProfileId={ProfileId}", request.UserId, request.ProfileId);
            var response = await _profileService.UpdateProfileAsync(request);
            if (!response.Success)
            {
                _logger.LogWarning("UpdateProfile failed. UserId={UserId}, ProfileId={ProfileId}, Error={Error}", request.UserId, request.ProfileId, response.Error);
                return BadRequest(response);
            }

            _logger.LogInformation("UpdateProfile completed successfully. UserId={UserId}, ProfileId={ProfileId}, DisplayName={DisplayName}", request.UserId, request.ProfileId, response.DisplayName);
            return Ok(response);
        }

        [HttpPost("rate")]
        public async Task<IActionResult> RateProfile([FromBody] RateProfileRequest request)
        {
            _logger.LogInformation("RateProfile request received. ProfileId={ProfileId}, RatedByUserId={RatedByUserId}, Rating={Rating}", request.ProfileId, request.RatedByUserId, request.Rating);
            var response = await _profileService.AddRatingAsync(request);
            if (!response.Success)
            {
                _logger.LogWarning("RateProfile failed. ProfileId={ProfileId}, Error={Error}", request.ProfileId, response.Error);
                return BadRequest(response);
            }

            _logger.LogInformation("RateProfile completed. ProfileId={ProfileId}, CurrentRating={CurrentRating}", request.ProfileId, response.CurrentRating);
            return Ok(response);
        }
    }
}
