using System;

namespace ruby.domain.Models.Responses
{
    public class ProfileRatingResponse
    {
        public bool Success { get; set; } = true;
        public string? Error { get; set; }
        public Guid ProfileId { get; set; }
        public double CurrentRating { get; set; }
        public double MeanRating { get; set; }
        public double LeastRating { get; set; }
        public int RatingCount { get; set; }
    }
}
