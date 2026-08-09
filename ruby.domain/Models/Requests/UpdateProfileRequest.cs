using System;
using System.ComponentModel.DataAnnotations;

namespace ruby.domain.Models.Requests
{
    public class UpdateProfileRequest
    {
        [Required]
        public Guid UserId { get; set; }

        public string? FirstName { get; set; }

        public string? LastName { get; set; }

        public string? DisplayName { get; set; }
    }
}