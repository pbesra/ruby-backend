using System;

namespace ruby.domain.Entities
{
    public class Profile
    {
        public Guid UserId { get; set; }
        public string? DisplayName { get; set; }
        public Guid? Gender { get; set; }
        public DateTime? DOB { get; set; }
        public Guid? Country { get; set; }
        public string? City { get; set; }
        public Guid? Language { get; set; }
        public string? Bio { get; set; }
        public string? AvatarUrl { get; set; }
        public bool IsVerified { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
        public Guid? UpdatedBy { get; set; }

        // Navigation
        public User? User { get; set; }
        public Gender? GenderRef { get; set; }
    }
}
