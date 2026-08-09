using System;

namespace ruby.domain.Entities
{
    public class ProfileRatingVote
    {
        public Guid Id { get; set; }
        public Guid ProfileId { get; set; }
        public Guid RatedByUserId { get; set; }
        public double Rating { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
    }
}
