# Authentication Architecture Design

## Goals
- Secure API access using JWT bearer tokens.
- Support local credentials, Google, Apple, and phone login.
- Use refresh token rotation for session continuity.
- Keep auth logic layered, testable, and maintainable.
- Enable future role-based or claim-based authorization.

## Core components

1. `AuthenticationController`
   - Exposes public endpoints:
     - `POST /api/v1/authentication/register`
     - `POST /api/v1/authentication/login`
     - `POST /api/v1/authentication/login/google`
     - `POST /api/v1/authentication/login/apple`
     - `POST /api/v1/authentication/login/phone`
     - `POST /api/v1/authentication/refresh`
     - `POST /api/v1/authentication/logout`

2. `AuthenticationService`
   - Handles login/register/refresh/logout workflows.
   - Uses `IUserRepository`, `IRefreshTokenRepository`, `IPasswordHasher`, `IJwtTokenService`.
   - Generates access and refresh tokens.
   - Persists refresh token state.

3. `JwtTokenService`
   - Issues JWT access tokens.
   - Uses config values: `Jwt:Key`, `Jwt:Issuer`, `Jwt:Audience`.
   - Creates tokens with claims: `sub`, `email`, `roles`, `jti`, `iat`, `exp`.

4. `RefreshToken` persistence
   - Entity fields:
     - `Id`, `UserId`, `Token`, `DeviceId`
     - `CreatedAt`, `ExpiresAt`, `RevokedAt`, `UpdatedAt`, `UpdatedBy`
   - Stored in database via `IRefreshTokenRepository`.

5. ASP.NET Core auth middleware
   - Enable `app.UseAuthentication()` and `app.UseAuthorization()`.
   - Configure JWT bearer authentication.
   - Protect controllers/actions with `[Authorize]`.

## Token model

### Access token
- JWT bearer token.
- Short lifetime (recommended 15 minutes).
- Signed with a strong secret or managed signing key.
- Validated by middleware.
- Contains no refresh logic.

### Refresh token
- Stored server-side.
- Long lifetime (e.g. 30 days).
- Rotated on each refresh.
- Revoked on logout or misuse.
- Optionally bound to a device/session via `DeviceId`.
- Should be hashed in the database for extra security.

## Authentication flows

### Register
- Validate unique email.
- Hash password.
- Create user record.
- Return a success response with created user id.

### Login with credentials
- Lookup user by identifier (`username`, `email`, or phone).
- Verify password hash.
- Update `LastLoginAt`.
- Issue access and refresh tokens.

### Social login (Google / Apple)
- Validate provider id token against provider public keys.
- Extract stable identity from token (`sub`, `email`).
- Lookup existing user by email or provider identity.
- Create user if missing.
- Issue local access and refresh tokens.

### Phone login
- Assume OTP verification is handled externally.
- Lookup or create user by phone number.
- Issue tokens.
- Consider adding a dedicated phone verification flow later.

### Refresh
- Accept refresh token from client.
- Locate persistent refresh token record.
- Verify it is active and not expired.
- Optionally verify `DeviceId`.
- Revoke old refresh token.
- Issue new access and refresh tokens.
- Persist the new refresh token record.

### Logout
- Revoke the provided refresh token.
- Let the existing access token expire naturally.

## Security and hardening
- Add `UseAuthentication()` and JWT bearer config in `Program.cs`.
- Keep `Jwt:Key` out of source control.
- Use HTTPS exclusively.
- Enforce `Authorization` globally with exceptions for auth endpoints.
- Add monitoring for suspicious refresh activity.
- Consider adding:
  - `EmailConfirmed`
  - `PhoneConfirmed`
  - `AuthenticationProvider` metadata
  - `ReplacedByToken` on refresh records
  - an `IsActive` helper for refresh tokens

## Recommended repo-specific changes
- Configure auth middleware in `ruby.api/Program.cs`.
- Expand `JwtTokenService` to support additional claims and configuration.
- Harden `AuthenticationService` refresh logic with rotation.
- Add provider verification for Google and Apple tokens.
- Keep the existing `User` and `RefreshToken` entity design.
- Protect business endpoints with `[Authorize]`.

## High-level architecture
1. Client calls login/register/social login/refresh/logout.
2. `AuthenticationController` forwards request to `AuthenticationService`.
3. `AuthenticationService` validates credentials or provider tokens.
4. `JwtTokenService` issues access tokens.
5. `IRefreshTokenRepository` stores or revokes refresh tokens.
6. Protected API endpoints validate JWTs via middleware.

## Why this design fits
- Reuses existing service and repository structure.
- Preserves the current JWT plus refresh-token model.
- Closes the current gap of missing ASP.NET Core auth middleware.
- Improves refresh token lifecycle, security, and social login correctness.
