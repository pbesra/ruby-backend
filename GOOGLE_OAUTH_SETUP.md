# Google OAuth Authentication Setup Guide

## Overview

This guide explains how to configure and use Google OAuth authentication in the Ruby Backend application. The implementation includes proper JWT token validation with signature verification, issuer validation, and audience validation.

## Features

- ✅ **JWT Signature Verification**: Validates tokens using Google's public keys (JWKS)
- ✅ **Issuer Validation**: Ensures tokens are from Google
- ✅ **Audience Validation**: Ensures tokens are for your application
- ✅ **Expiration Checking**: Validates token lifetime
- ✅ **Key Caching**: Caches Google's public keys for 1 hour to reduce API calls
- ✅ **Email Verification**: Checks if email is verified by Google
- ✅ **Profile Sync**: Automatically syncs user name and profile picture from Google
- ✅ **Device Binding**: Supports optional device ID for enhanced security

## Setup Instructions

### 1. Get Google OAuth Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google+ API:
   - Navigate to "APIs & Services" > "Library"
   - Search for "Google+ API" and enable it
4. Create OAuth 2.0 credentials:
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "OAuth client ID"
   - Select "Web application" as the application type
   - Add authorized redirect URIs (for web):
	 - `http://localhost:3000` (for local development)
	 - Your production frontend URL
   - For mobile apps, select appropriate platform
5. Copy the **Client ID** (looks like: `123456789-abcdefg.apps.googleusercontent.com`)

### 2. Configure Application

Update `appsettings.json` or `appsettings.Development.json`:

```json
{
  "Authentication": {
	"Google": {
	  "ClientId": "YOUR-GOOGLE-CLIENT-ID.apps.googleusercontent.com"
	}
  },
  "Jwt": {
	"Key": "your-secret-key-at-least-32-characters-long",
	"Issuer": "ruby-backend",
	"Audience": "ruby-client"
  }
}
```

**Important**: 
- Replace `YOUR-GOOGLE-CLIENT-ID` with your actual Google Client ID
- Use a strong, random `Jwt.Key` in production (minimum 32 characters)
- Keep `Jwt.Key` secret and never commit it to version control

### 3. Environment Variables (Recommended for Production)

Instead of storing credentials in appsettings.json, use environment variables:

```bash
# Linux/macOS
export Authentication__Google__ClientId="YOUR-CLIENT-ID.apps.googleusercontent.com"
export Jwt__Key="your-production-secret-key"

# Windows PowerShell
$env:Authentication__Google__ClientId="YOUR-CLIENT-ID.apps.googleusercontent.com"
$env:Jwt__Key="your-production-secret-key"
```

## API Usage

### Endpoint

```
POST /api/v1/authentication/login/google
Content-Type: application/json
```

### Request Body

```json
{
  "idToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjU5Nzg...",
  "deviceId": "optional-device-identifier"
}
```

**Fields:**
- `idToken` (required): The Google ID token received from Google Sign-In
- `deviceId` (optional): Device identifier for token binding (recommended for mobile apps)

### Success Response (200 OK)

```json
{
  "success": true,
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "a1b2c3d4e5f6...",
  "error": null
}
```

### Error Responses (401 Unauthorized)

**Invalid Token Format:**
```json
{
  "success": false,
  "accessToken": "",
  "refreshToken": "",
  "error": "Invalid token format"
}
```

**Token Expired:**
```json
{
  "success": false,
  "accessToken": "",
  "refreshToken": "",
  "error": "Token has expired"
}
```

**Invalid Signature:**
```json
{
  "success": false,
  "accessToken": "",
  "refreshToken": "",
  "error": "Invalid token signature"
}
```

**Wrong Client ID (Audience Mismatch):**
```json
{
  "success": false,
  "accessToken": "",
  "refreshToken": "",
  "error": "Invalid audience - token not intended for this application"
}
```

## Client Implementation Examples

### Web (JavaScript/TypeScript)

```javascript
// 1. Initialize Google Sign-In
google.accounts.id.initialize({
  client_id: 'YOUR-CLIENT-ID.apps.googleusercontent.com',
  callback: handleGoogleLogin
});

// 2. Handle login response
async function handleGoogleLogin(response) {
  try {
	const result = await fetch('/api/v1/authentication/login/google', {
	  method: 'POST',
	  headers: {
		'Content-Type': 'application/json'
	  },
	  body: JSON.stringify({
		idToken: response.credential,
		deviceId: getDeviceId() // Optional
	  })
	});

	const data = await result.json();

	if (data.success) {
	  // Store tokens
	  localStorage.setItem('accessToken', data.accessToken);
	  localStorage.setItem('refreshToken', data.refreshToken);
	  // Redirect to dashboard
	  window.location.href = '/dashboard';
	} else {
	  console.error('Login failed:', data.error);
	}
  } catch (error) {
	console.error('Login error:', error);
  }
}
```

### React

```typescript
import { GoogleLogin, CredentialResponse } from '@react-oauth/google';

function LoginPage() {
  const handleGoogleLogin = async (credentialResponse: CredentialResponse) => {
	try {
	  const response = await fetch('/api/v1/authentication/login/google', {
		method: 'POST',
		headers: { 'Content-Type': 'application/json' },
		body: JSON.stringify({
		  idToken: credentialResponse.credential
		})
	  });

	  const data = await response.json();

	  if (data.success) {
		// Save tokens and redirect
		localStorage.setItem('accessToken', data.accessToken);
		localStorage.setItem('refreshToken', data.refreshToken);
		navigate('/dashboard');
	  }
	} catch (error) {
	  console.error('Login failed:', error);
	}
  };

  return (
	<div>
	  <h1>Login</h1>
	  <GoogleLogin
		onSuccess={handleGoogleLogin}
		onError={() => console.log('Login Failed')}
	  />
	</div>
  );
}
```

### Android (Kotlin)

```kotlin
// 1. Configure Google Sign-In
val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
	.requestIdToken("YOUR-CLIENT-ID.apps.googleusercontent.com")
	.requestEmail()
	.build()

val googleSignInClient = GoogleSignIn.getClient(this, gso)

// 2. Launch sign-in intent
val signInIntent = googleSignInClient.signInIntent
startActivityForResult(signInIntent, RC_SIGN_IN)

// 3. Handle result
override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
	super.onActivityResult(requestCode, resultCode, data)

	if (requestCode == RC_SIGN_IN) {
		val task = GoogleSignIn.getSignedInAccountFromIntent(data)
		try {
			val account = task.getResult(ApiException::class.java)
			val idToken = account?.idToken

			// Send to backend
			loginWithGoogle(idToken, getDeviceId())
		} catch (e: ApiException) {
			Log.e(TAG, "Google sign in failed", e)
		}
	}
}

// 4. Backend call
suspend fun loginWithGoogle(idToken: String?, deviceId: String) {
	val response = api.loginWithGoogle(
		GoogleLoginRequest(
			idToken = idToken ?: return,
			deviceId = deviceId
		)
	)

	if (response.success) {
		// Save tokens
		tokenManager.saveTokens(response.accessToken, response.refreshToken)
		// Navigate to main screen
	}
}
```

### iOS (Swift)

```swift
// 1. Configure Google Sign-In
GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: "YOUR-CLIENT-ID.apps.googleusercontent.com")

// 2. Start sign-in flow
GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
	guard error == nil else { return }
	guard let user = result?.user,
		  let idToken = user.idToken?.tokenString else { return }

	// Send to backend
	loginWithGoogle(idToken: idToken, deviceId: getDeviceId())
}

// 3. Backend call
func loginWithGoogle(idToken: String, deviceId: String) {
	let request = GoogleLoginRequest(idToken: idToken, deviceId: deviceId)

	apiClient.loginWithGoogle(request) { result in
		switch result {
		case .success(let response):
			if response.success {
				// Save tokens
				TokenManager.shared.save(
					accessToken: response.accessToken,
					refreshToken: response.refreshToken
				)
				// Navigate to main screen
			}
		case .failure(let error):
			print("Login failed: \(error)")
		}
	}
}
```

### Flutter (Dart)

```dart
// 1. Add google_sign_in package
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: 'YOUR-CLIENT-ID.apps.googleusercontent.com',
);

// 2. Sign in
Future<void> signInWithGoogle() async {
  try {
	final GoogleSignInAccount? account = await _googleSignIn.signIn();
	if (account == null) return;

	final GoogleSignInAuthentication auth = await account.authentication;
	final String? idToken = auth.idToken;

	// Send to backend
	final response = await dio.post(
	  '/api/v1/authentication/login/google',
	  data: {
		'idToken': idToken,
		'deviceId': await getDeviceId(),
	  },
	);

	if (response.data['success']) {
	  // Save tokens
	  await secureStorage.write(key: 'accessToken', value: response.data['accessToken']);
	  await secureStorage.write(key: 'refreshToken', value: response.data['refreshToken']);
	  // Navigate to home
	}
  } catch (error) {
	print('Google sign-in failed: $error');
  }
}
```

## Security Considerations

1. **Token Validation**: The backend validates:
   - JWT signature using Google's public keys
   - Token issuer (must be Google)
   - Token audience (must match your Client ID)
   - Token expiration

2. **Key Caching**: Google's public keys are cached for 1 hour to balance security and performance

3. **Email Verification**: Only verified emails from Google are used for user lookup. Unverified emails use the subject ID with @google.oauth suffix

4. **HTTPS**: Always use HTTPS in production to protect tokens in transit

5. **Client ID Security**: 
   - Client ID can be public (it's in your frontend code)
   - Client Secret should NEVER be in frontend code
   - This implementation only needs Client ID (not Client Secret)

6. **Device Binding**: Using deviceId provides additional security:
   - Binds refresh tokens to specific devices
   - Prevents token reuse from different devices

## Testing

### Using cURL

```bash
# Replace with actual Google ID token
curl -X POST http://localhost:5000/api/v1/authentication/login/google \
  -H "Content-Type: application/json" \
  -d '{
	"idToken": "YOUR-GOOGLE-ID-TOKEN-HERE",
	"deviceId": "test-device-123"
  }'
```

### Using Postman

1. Get a Google ID token:
   - Use Google OAuth Playground: https://developers.google.com/oauthplayground/
   - Or use a test app with Google Sign-In

2. Send POST request to `/api/v1/authentication/login/google`
3. Include the ID token in the request body

## Troubleshooting

### "Invalid audience" Error

**Problem**: Token was generated for a different Client ID

**Solution**: 
- Verify your Client ID in appsettings.json matches the one used in your frontend
- Ensure you're using the web client ID (not iOS or Android client ID)

### "Invalid issuer" Error

**Problem**: Token issuer doesn't match expected Google issuers

**Solution**: Token might not be from Google. Verify you're using Google Sign-In SDK correctly

### "Token has expired" Error

**Problem**: Token expired before reaching the backend

**Solution**:
- Ensure clocks are synchronized
- ID tokens are short-lived (typically 1 hour)
- Get a fresh token from Google

### "Failed to retrieve Google public keys" Error

**Problem**: Backend can't reach Google's JWKS endpoint

**Solution**:
- Check internet connectivity
- Verify firewall rules allow outbound HTTPS to googleapis.com
- Check proxy settings if behind corporate firewall

## User Flow

1. **New User** (first-time Google login):
   - User is created with email from Google
   - Profile is created with name and picture from Google
   - Access and refresh tokens are generated
   - User is logged in

2. **Existing User**:
   - User is found by verified email
   - Profile picture is updated if changed in Google
   - Last login timestamp is updated
   - New tokens are generated

3. **Email Not Verified**:
   - Uses subject@google.oauth as email
   - User can still log in
   - Profile uses subject ID for display

## Next Steps

To implement Apple Sign-In, follow a similar pattern with Apple's JWT validation requirements.

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review Google OAuth documentation: https://developers.google.com/identity/sign-in/web/backend-auth
3. Check application logs for detailed error messages
