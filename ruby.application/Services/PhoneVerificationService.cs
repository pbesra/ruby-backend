using System;
using System.Collections.Concurrent;
using System.Threading.Tasks;
using ruby.application.Ports.In.IServices;

namespace ruby.application.Services
{
    public class PhoneVerificationService : IPhoneVerificationService
    {
        private static readonly ConcurrentDictionary<string, PhoneCodeEntry> _codes = new();
        private static readonly TimeSpan CodeValidity = TimeSpan.FromMinutes(5);

        public Task<bool> GenerateCodeAsync(string phoneNumber)
        {
            if (string.IsNullOrWhiteSpace(phoneNumber))
                return Task.FromResult(false);

            var code = new Random().Next(100000, 999999).ToString();
            var entry = new PhoneCodeEntry
            {
                Code = code,
                ExpiresAt = DateTimeOffset.UtcNow.Add(CodeValidity)
            };

            _codes.AddOrUpdate(phoneNumber, entry, (_, __) => entry);
            // TODO: Send the code by SMS using an external provider.
            return Task.FromResult(true);
        }

        public Task<bool> ValidateCodeAsync(string phoneNumber, string code)
        {
            if (string.IsNullOrWhiteSpace(phoneNumber) || string.IsNullOrWhiteSpace(code))
                return Task.FromResult(false);

            if (!_codes.TryGetValue(phoneNumber, out var entry))
                return Task.FromResult(false);

            if (entry.ExpiresAt <= DateTimeOffset.UtcNow)
            {
                _codes.TryRemove(phoneNumber, out _);
                return Task.FromResult(false);
            }

            if (!string.Equals(entry.Code, code, StringComparison.Ordinal))
                return Task.FromResult(false);

            _codes.TryRemove(phoneNumber, out _);
            return Task.FromResult(true);
        }

        private sealed class PhoneCodeEntry
        {
            public string Code { get; set; } = string.Empty;
            public DateTimeOffset ExpiresAt { get; set; }
        }
    }
}
