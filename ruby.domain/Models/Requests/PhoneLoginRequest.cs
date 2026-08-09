using System.ComponentModel.DataAnnotations;

namespace ruby.domain.Models.Requests
{
    public class PhoneLoginRequest
    {
        [Required]
        public string PhoneNumber { get; set; } = string.Empty;

        [Required]
        public string Code { get; set; } = string.Empty;

        public string? DeviceId { get; set; }
    }
}
