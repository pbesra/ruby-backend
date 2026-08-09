using System.ComponentModel.DataAnnotations;

namespace ruby.domain.Models.Requests
{
    public class PhoneVerificationRequest
    {
        [Required]
        public string PhoneNumber { get; set; } = string.Empty;
    }
}
