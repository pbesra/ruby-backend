using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging.Abstractions;
using ruby.application.Ports.In.IServices;
using System.Linq;

namespace ruby.api.Controllers.v1
{
    [ApiController]
    [Route("api/v1/[controller]")]
    public class HomeController : ControllerBase
    {
        private readonly IHomeFeedService _homeFeedService;
        private readonly ILogger<HomeController> _logger;

        public HomeController(IHomeFeedService homeFeedService, ILogger<HomeController>? logger = null)
        {
            _homeFeedService = homeFeedService;
            _logger = logger ?? NullLogger<HomeController>.Instance;
        }

        [HttpGet("discover")]
        public async Task<IActionResult> GetDiscoverUsers([FromQuery] Guid userId)
        {
            _logger.LogInformation("GetDiscoverUsers request received. UserId={UserId}", userId);
            var users = await _homeFeedService.GetDiscoverUsersAsync(userId);
            var count = users == null ? 0 : users.Count();
            _logger.LogInformation("GetDiscoverUsers completed. UserId={UserId}, Count={Count}", userId, count);
            return Ok(users);
        }

        [HttpGet("following")]
        public async Task<IActionResult> GetFollowingUsers([FromQuery] Guid userId)
        {
            _logger.LogInformation("GetFollowingUsers request received. UserId={UserId}", userId);
            var users = await _homeFeedService.GetFollowingUsersAsync(userId);
            var count = users == null ? 0 : users.Count();
            _logger.LogInformation("GetFollowingUsers completed. UserId={UserId}, Count={Count}", userId, count);
            return Ok(users);
        }
    }
}
