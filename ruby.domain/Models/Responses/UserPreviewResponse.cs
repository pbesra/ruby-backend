using System;

namespace ruby.domain.Models.Responses
{
    public class UserPreviewResponse
    {
        public Guid UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string CountryCode { get; set; } = "IN";
        public int? Age { get; set; }
        public bool IsOnline { get; set; }
        public string? AvatarUrl { get; set; }
        public bool IsFollowing { get; set; }
    }
}