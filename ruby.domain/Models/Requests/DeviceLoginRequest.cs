using System.ComponentModel.DataAnnotations;

namespace ruby.domain.Models.Requests
{
    public class DeviceLoginRequest
    {
        [Required]
        public string DeviceId { get; set; } = string.Empty;

        public string? DeviceName { get; set; }
    }
}
