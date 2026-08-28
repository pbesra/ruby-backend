using Serilog;
using ruby.api.Middleware;
using ruby.application.Extensions;
using ruby.infrastructure.Extensions;
using ruby.infrastructure.Persistence.IRepositories;
using ruby.infrastructure.Services;
using ruby.backend.Extensions;

var logDirectory = Path.Combine("C:\\source\\github-repos\\ruby-app", "logs");
Directory.CreateDirectory(logDirectory);

Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .WriteTo.Console()
    .WriteTo.File(
        Path.Combine(logDirectory, "ruby-api-.log"),
        rollingInterval: RollingInterval.Day,
        retainedFileCountLimit: 10)
    .CreateLogger();

var builder = WebApplication.CreateBuilder(args);
builder.Host.UseSerilog();

builder.Configuration.SetBasePath(builder.Environment.ContentRootPath)
    .AddJsonFile("appsettings.json", false)
    .AddJsonFile($"appsettings.{Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Prod"}.json", optional: true, reloadOnChange: true)
    .AddEnvironmentVariables()
    .AddCommandLine(args);

// Add services to the container.
builder.Services.AddPersistenceBuilderServices(builder.Configuration);

builder.Services.AddCors(options =>
{
    options.AddPolicy("LocalAppCors", policy =>
    {
        policy.WithOrigins("http://localhost:8080", "http://127.0.0.1:8080")
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

// Application services
builder.Services.AddApplicationBuilder();

builder.Services.AddMemoryCache();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// middleware 
var app = builder.Build();
app.UseExceptionMiddleware();
using (var scope = app.Services.CreateScope())
{
    await scope.UseMigrationScope();

    var cacheService = scope.ServiceProvider.GetRequiredService<IReferenceCacheService>();
    var database = scope.ServiceProvider.GetRequiredService<ISQLDatabase>();
    using var connection = await database.GetConnection();
    await cacheService.WarmUpAsync(connection);
}
// Configure the HTTP request pipeline.
if (app.Environment.IsLocal())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

if (!app.Environment.IsLocal())
{
    app.UseHttpsRedirection();
}

app.UseCors("LocalAppCors");
app.UseAuthorization();

app.MapControllers();

app.Run();