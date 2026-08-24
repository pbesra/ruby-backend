using System;
using System.ComponentModel.DataAnnotations;

namespace ruby.domain.Models.Requests
{
    public class UpdateProfileRequest
    {
        [Required]
        public Guid UserId { get; set; }

        public Guid? ProfileId { get; set; }

        public string? FirstName { get; set; }

        public string? LastName { get; set; }

        public string? DisplayName { get; set; }

        public string? Bio { get; set; }

        public string? BirthDate { get; set; }

        public string? AvatarUrl { get; set; }

        public List<string>? Languages { get; set; } = new();

        public List<string>? Preferences { get; set; } = new();

        public List<string>? Personalities { get; set; } = new();

        public List<string>? Interests { get; set; } = new();
    }
}