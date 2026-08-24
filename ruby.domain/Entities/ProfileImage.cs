using System;

namespace ruby.domain.Entities
{
    public class ProfileImage
    {
        public Guid Id { get; set; }
        public Guid ProfileId { get; set; }
        public string ImageUrl { get; set; } = string.Empty;
        public bool IsDefault { get; set; }
        public bool IsActive { get; set; } = true;
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
        public Guid? UpdatedBy { get; set; }

        public Profile? Profile { get; set; }
    }
}
