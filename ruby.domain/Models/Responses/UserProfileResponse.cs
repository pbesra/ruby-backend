namespace ruby.domain.Models.Responses
{
    public class ProfileChipResponse
    {
        public string Name { get; set; } = string.Empty;
        public string? AvatarUrl { get; set; }
        public string? Category { get; set; }
    }

    public class UserProfileResponse
    {
        public bool Success { get; set; } = true;
        public string? Error { get; set; }

        public Guid UserId { get; set; }
        public Guid? ProfileId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? DisplayName { get; set; }
        public string? Bio { get; set; }
        public string CountryCode { get; set; } = "IN";
        public string CountryName { get; set; } = "India";
        public string? City { get; set; }
        public int? Age { get; set; }
        public string Gender { get; set; } = "Female";
        public string Language { get; set; } = "English";
        public string? Status { get; set; }
        public int Level { get; set; } = 1;
        public double Rating { get; set; } = 0;
        public bool IsOnline { get; set; }
        public string? AvatarUrl { get; set; }
        public bool IsFollowing { get; set; }
        public bool IsCallAvailable { get; set; } = true;
        public List<string> ProfileChips { get; set; } = new();
        public List<ProfileChipResponse> ChipDetails { get; set; } = new();
    }
}
