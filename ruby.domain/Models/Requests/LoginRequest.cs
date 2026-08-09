using System.ComponentModel.DataAnnotations;

namespace ruby.domain.Models.Requests
{
    public class LoginRequest
    {
        [Required]
        public string Identifier { get; set; } = string.Empty; // username, email or phone

        [Required]
        public string Password { get; set; } = string.Empty;

        public string? DeviceId { get; set; }
    }
}
