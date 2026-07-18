using Microsoft.AspNetCore.Mvc;

namespace ruby_backend.Controllers.v1
{
    public class AuthController : ControllerBase
    {
        public async Task<IActionResult> Index()
        {
            return Ok();
        }
    }
}