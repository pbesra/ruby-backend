using System;
using System.ComponentModel.DataAnnotations;

namespace ruby.domain.Models.Requests
{
    public class RateProfileRequest
    {
        [Required]
        public Guid ProfileId { get; set; }

        [Required]
        public Guid RatedByUserId { get; set; }

        [Range(0.0, 5.0)]
        public double Rating { get; set; }
    }
}
