using System;

namespace ruby.domain.Entities
{
    public class ProfileAddress
    {
        public Guid Id { get; set; }
        public Guid ProfileId { get; set; }
        public Guid AddressId { get; set; }
        public bool IsPrimary { get; set; }
        public bool IsCurrent { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset UpdatedAt { get; set; }
        public Guid? UpdatedBy { get; set; }

        public Profile? Profile { get; set; }
        public Address? Address { get; set; }
    }
}
