namespace ruby.infrastructure.Services
{
    public static class DateOnlyMapping
    {
        public static DateTime? ToDateTimeUtc(DateOnly? value)
        {
            if (!value.HasValue)
            {
                return null;
            }

            return value.Value.ToDateTime(TimeOnly.MinValue, DateTimeKind.Utc);
        }
    }
}
