using System;

namespace ruby.domain.Entities
{
    public class Profile
    {
        public Guid Id { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public Guid UserId { get; set; }
        public string? DisplayName { get; set; }
        public Guid? Gender { get; set; }
        public DateOnly? DOB { get; set; }
        public Guid? AddressId { get; set; }
        public Guid? Language { get; set; }
        public int Level { get; set; } = 1;
        public Guid? StatusId { get; set; }
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
