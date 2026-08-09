using EvolveDb;
using Microsoft.AspNetCore.Authentication;
using ruby.domain.Models;
using System.Text.Json;

namespace ruby.api.Middleware
{
    public class ExceptionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ExceptionMiddleware> _logger;

        public ExceptionMiddleware(RequestDelegate next, ILogger<ExceptionMiddleware> logger)
        {
            _next = next ?? throw new ArgumentNullException(nameof(next));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unhandled exception while processing request");
                await HandleExceptionAsync(context, ex);
            }
        }

        private static async Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            context.Response.ContentType = "application/problem+json";
            context.Response.StatusCode = GetStatusCode(exception);
            var errorResponse = new ErrorResponse { Message = exception.Message ?? $"Exception occured. exception={exception}" };
            var result = JsonSerializer.Serialize(new { errors = errorResponse });
            await context.Response.WriteAsync(result);
        }

        private static int GetStatusCode(Exception exception) =>
        exception switch
        {
            BadHttpRequestException => StatusCodes.Status400BadRequest,
            AuthenticationFailureException => StatusCodes.Status401Unauthorized,
            UnauthorizedAccessException => StatusCodes.Status401Unauthorized,
            ApplicationException => StatusCodes.Status500InternalServerError,
            EvolveSqlException => StatusCodes.Status500InternalServerError,
            EvolveException => StatusCodes.Status500InternalServerError,
            NotImplementedException => StatusCodes.Status501NotImplemented,
            _ => StatusCodes.Status500InternalServerError
        };
    }

    public static class ExceptionMiddlewareExtensions
    {
        public static IApplicationBuilder UseExceptionMiddleware(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<ExceptionMiddleware>();
        }
    }
}