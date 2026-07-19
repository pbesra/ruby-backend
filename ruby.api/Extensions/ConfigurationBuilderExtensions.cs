namespace ruby_backend.Extensions
{
    public static class ConfigurationBuilderExtensions
    {
        public static IConfigurationRoot BuildConfiguration(this IConfigurationBuilder builder, string[] args)
        {
            return builder
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", false)
                .AddJsonFile($"appsettings.{Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Prod"}.json", optional: true, reloadOnChange: true)
                .AddEnvironmentVariables()
                .AddCommandLine(args)
                .Build();
        }

        public static bool IsLocal(this IHostEnvironment hostEnvironment)
        {
            return hostEnvironment.EnvironmentName.Equals("Local", StringComparison.OrdinalIgnoreCase);
        }
    }
}