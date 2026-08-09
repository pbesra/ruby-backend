using Microsoft.AspNetCore.Mvc;
using ruby.application.Ports.In.IServices;

namespace ruby.api.Controllers.v1
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class HomeController : ControllerBase
    {
        private readonly IHomeFeedService _homeFeedService;

        public HomeController(IHomeFeedService homeFeedService)
        {
            _homeFeedService = homeFeedService;
        }

        [HttpGet("discover")]
        public async Task<IActionResult> GetDiscoverUsers([FromQuery] Guid userId)
        {
            var users = await _homeFeedService.GetDiscoverUsersAsync(userId);
            return Ok(users);
        }

        [HttpGet("following")]
        public async Task<IActionResult> GetFollowingUsers([FromQuery] Guid userId)
        {
            var users = await _homeFeedService.GetFollowingUsersAsync(userId);
            return Ok(users);
        }
    }
}
