using System;
using System.ComponentModel.DataAnnotations;

namespace ruby.domain.Models.Requests
{
    public class LogoutRequest
    {
        [Required]
        public Guid UserId { get; set; }

        [Required]
        public string RefreshToken { get; set; } = string.Empty;
    }
}
