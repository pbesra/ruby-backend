# App Architecture Design

## App concept
This app is a live social interaction platform where users can:
- authenticate via email/password, phone verification, Google, or Apple
- chat one-on-one with other users
- make video calls between users
- buy coins/tokens and spend them on calls or gifts
- send gifts and trigger wallet/payment transactions

The backend is structured to support secure authentication, session management, and token-based purchasing for premium actions.

## High-level domains

### Authentication
- JWT access tokens for API authorization
- refresh tokens for session continuity
- `DeviceId` support for device-bound refresh
- passwordless phone login and social login support

### Users
- core `User` entity stores identity, profile, phone, email, and status
- user status controls whether a user can access calls, chat, or purchase flows
- roles and claims can be added later for moderation, host/guest, or premium tiers

### Wallet & tokens
- `Wallet` or `WalletTransaction` tracks coin balances
- `CoinPackage` defines purchasable token bundles
- `Payment` records purchase events and payment status
- spend logic verifies balance before enabling calls or gifts

### Chat & call
- chat and call endpoints require authenticated users
- authorization checks ensure the user has sufficient tokens or permission
- video call initiation should create a session record and deduct tokens only after the call starts successfully

### Gifts
- gifts are cataloged by `Gift` and `GiftCategory`
- gifting a user requires wallet token deduction and a `GiftTransaction`
- gifts can emit notifications and update recipient wallet or gift history

## Recommended API design

### Public/auth endpoints
- `POST /api/v1/authentication/register`
- `POST /api/v1/authentication/login`
- `POST /api/v1/authentication/login/phone/request-code`
- `POST /api/v1/authentication/login/phone`
- `POST /api/v1/authentication/login/google`
- `POST /api/v1/authentication/login/apple`
- `POST /api/v1/authentication/refresh`
- `POST /api/v1/authentication/logout`

### Protected user endpoints
- `GET /api/v1/users/me`
- `PUT /api/v1/users/me`
- `GET /api/v1/users/{id}/profile`

### Wallet and purchase endpoints
- `GET /api/v1/wallet/balance`
- `GET /api/v1/coin-packages`
- `POST /api/v1/wallet/purchase`
- `POST /api/v1/wallet/transactions`

### Chat and call endpoints
- `POST /api/v1/chat/conversations`
- `GET /api/v1/chat/conversations/{id}`
- `POST /api/v1/chat/messages`
- `POST /api/v1/calls/start`
- `POST /api/v1/calls/end`
- `GET /api/v1/calls/{id}`

### Gift endpoints
- `GET /api/v1/gifts`
- `POST /api/v1/gifts/send`
- `GET /api/v1/gifts/received`

## Security and flow considerations

- Use HTTPS for all requests.
- Store secrets and JWT signing keys securely outside source control.
- Protect endpoints with bearer authentication and `[Authorize]`.
- Ensure refresh tokens are revoked on logout and rotation.
- Enforce token balance checks before gifting or calling.
- Add auditing for payments, transactions, and gift activity.

## User session model

- Client obtains access token and refresh token at login.
- Client sends `DeviceId` on login and refresh.
- The backend binds refresh tokens to devices to reduce token theft risk.
- Access tokens are short-lived; refresh tokens are rotated on each refresh.

## Why this architecture fits

- It separates authentication from business operations.
- It keeps expensive operations like video calls behind secure, authorized APIs.
- It supports mobile-friendly device-bound sessions.
- It tracks user spend through wallet and gift transactions.
- It is compatible with the existing Ruby backend service and repository structure.
