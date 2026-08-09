using ruby.api.Middleware;
using ruby.application.Extensions;
using ruby.infrastructure.Extensions;
using ruby.backend.Extensions;

var builder = WebApplication.CreateBuilder(args);
builder.Configuration.SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json", false)
    .AddJsonFile($"appsettings.{Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Prod"}.json", optional: true, reloadOnChange: true)
    .AddEnvironmentVariables()
    .AddCommandLine(args);

// Add services to the container.
builder.Services.AddPersistenceBuilderServices(builder.Configuration);

// Application services
builder.Services.AddApplicationBuilder();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// middleware 
var app = builder.Build();
app.UseExceptionMiddleware();
using (var scope = app.Services.CreateScope())
{
    await scope.UseMigrationScope();
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

app.UseAuthorization();

app.MapControllers();

app.Run();