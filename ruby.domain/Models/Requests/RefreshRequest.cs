using System.ComponentModel.DataAnnotations;

namespace ruby.domain.Models.Requests
{
    public class RefreshRequest
    {
        [Required]
        public string RefreshToken { get; set; } = string.Empty;

        // Optional device identifier to bind refresh tokens to a device
        public string? DeviceId { get; set; }
    }
}
