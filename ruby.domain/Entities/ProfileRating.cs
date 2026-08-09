using System;

namespace ruby.domain.Entities
{
    public class ProfileRating
    {
        public Guid Id { get; set; }
        public Guid ProfileId { get; set; }
        public double CurrentRating { get; set; }
        public double MeanRating { get; set; }
        public double LeastRating { get; set; }
        public int RatingCount { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
        public Guid? UpdatedBy { get; set; }
    }
}
