namespace ruby.domain.Models.Responses
{
    public class AuthenticationResponse
    {
        // Indicates whether authentication operation succeeded. Some controllers expect this flag.
        public bool Success { get; set; } = true;

        // Optional error message when Success is false
        public string? Error { get; set; }
        public Guid? UserId { get; set; }
        public Guid? ProfileId { get; set; }
        public string? DisplayName { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? AvatarUrl { get; set; }
        public string AccessToken { get; set; } = string.Empty;
        public string RefreshToken { get; set; } = string.Empty;
    }
}
