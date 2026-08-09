using Microsoft.AspNetCore.Mvc;
using ruby.application.Ports.In.IServices;
using ruby.domain.Models.Requests;

namespace ruby.api.Controllers.v1
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class ProfileController : ControllerBase
    {
        private readonly IProfileService _profileService;

        public ProfileController(IProfileService profileService)
        {
            _profileService = profileService;
        }

        [HttpPost("update")]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileRequest request)
        {
            var response = await _profileService.UpdateProfileAsync(request);
            if (!response.Success)
            {
                return BadRequest(response);
            }

            return Ok(response);
        }

        [HttpPost("rate")]
        public async Task<IActionResult> RateProfile([FromBody] RateProfileRequest request)
        {
            var response = await _profileService.AddRatingAsync(request);
            if (!response.Success)
            {
                return BadRequest(response);
            }

            return Ok(response);
        }
    }
}
