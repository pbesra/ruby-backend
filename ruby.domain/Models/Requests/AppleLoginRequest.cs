using System.ComponentModel.DataAnnotations;

namespace ruby.domain.Models.Requests
{
    public class AppleLoginRequest
    {
        [Required]
        public string IdToken { get; set; } = string.Empty;

        public string? DeviceId { get; set; }
    }
}
