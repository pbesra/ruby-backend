namespace ruby.domain.Entities
{
    public abstract class LookupEntity
    {
        public short Id { get; set; }

        public string Name { get; set; } = string.Empty;

        public string? Description { get; set; }

        public bool IsActive { get; set; } = true;

        public short SortOrder { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}