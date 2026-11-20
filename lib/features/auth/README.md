# Authentication System

Complete authentication implementation for IshqTalk following the API contract in `docs/docs/API_CONTRACT.md` and security requirements in `docs/docs/SECURITY_AND_PRIVACY.md`.

## Architecture

The auth system follows clean architecture principles:

```
features/auth/
├── domain/           # Business logic & interfaces
│   ├── auth_models.dart       # Account, Session, Credentials models
│   └── auth_repository.dart   # Repository interface
├── data/             # Implementation & infrastructure
│   ├── local_auth_repository.dart   # Local/fake auth for testing
│   ├── remote_auth_repository.dart  # Real API implementation
│   ├── auth_config.dart            # Environment configuration
│   └── auth_http_client.dart       # Authenticated HTTP client
└── presentation/     # UI & state management
    ├── auth_state.dart              # Provider state
    ├── screens/                     # Login, Register, etc.
    └── widgets/                     # Reusable UI components
```

## Features

### ✅ Implemented

- **Login** - Email/password authentication
- **Registration** - New account creation
- **Email Verification** - Account verification flow
- **Password Reset** - Forgot password recovery
- **Session Management** - Token refresh & persistence
- **Logout** - Session revocation
- **Account States** - All 6 states from domain model:
  - `pendingVerification`
  - `active`
  - `restricted`
  - `suspended`
  - `deletionPending`
  - `deleted`

### Backend Integration

#### API Endpoints

Following the API contract (`docs/docs/API_CONTRACT.md`):

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/v1/sessions` | POST | Login |
| `/v1/accounts` | POST | Registration |
| `/v1/accounts/verify` | POST | Email verification |
| `/v1/sessions/refresh` | POST | Token refresh |
| `/v1/sessions/revoke` | POST | Logout |
| `/v1/password-reset/request` | POST | Request password reset |
| `/v1/password-reset/confirm` | POST | Confirm password reset |

#### Request/Response Format

All requests use JSON with snake_case:

```dart
// Login request
POST /v1/sessions
{
  "email": "user@example.com",
  "password": "password123"
}

// Success response
{
  "data": {
    "access_token": "eyJ...",
    "refresh_token": "refresh_...",
    "expires_at": "2026-11-12T12:00:00Z",
    "account": {
      "id": "acc_...",
      "email": "user@example.com",
      "display_name": "User Name",
      "status": "active",
      "created_at": "2026-01-01T00:00:00Z"
    }
  }
}

// Error response
{
  "error": {
    "code": "invalid_credentials",
    "message": "Invalid email or password"
  }
}
```

## Configuration

### Environment Setup

The system supports multiple environments via `AuthConfig`:

```dart
// Default: auto-detects based on build mode
AuthConfig.current  // local in debug, production in release

// Override with environment variable:
// flutter run --dart-define=AUTH_ENV=development
```

Available environments:
- `local` - http://127.0.0.1:8000
- `development` - https://api-dev.ishqtalk.app
- `staging` - https://api-staging.ishqtalk.app
- `production` - https://api.ishqtalk.app

### Setup in main.dart

Already configured in `lib/app.dart`:

```dart
ChangeNotifierProvider(
  create: (_) => AuthState(
    repository: RemoteAuthRepository(
      baseUrl: AuthConfig.current.baseUrl,
      prefs: preferences!,
    ),
  )..restoreSession(),
),
```

## Usage

### In UI Screens

```dart
// Access auth state
final authState = context.watch<AuthState>();

// Check status
if (authState.status == AuthStatus.authenticated) {
  // User is logged in
  final account = authState.account;
}

// Login
await authState.login(
  email: 'user@example.com',
  password: 'password123',
);

// Check result
if (authState.status == AuthStatus.authenticated) {
  // Success
} else if (authState.error != null) {
  // Show error: authState.error!.message
}
```

### Making Authenticated API Calls

Use `AuthApiClient` for automatic token handling:

```dart
final apiClient = AuthApiClient(
  baseUrl: AuthConfig.current.baseUrl,
  getAccessToken: () async => authState.session?.accessToken,
  onTokenExpired: () async => await authState.refreshToken(),
);

// GET request
final response = await apiClient.get('/v1/me');

// POST request
final response = await apiClient.post(
  '/v1/profiles',
  body: {'display_name': 'New Name'},
);
```

## Security Features

Following `docs/docs/SECURITY_AND_PRIVACY.md`:

### ✅ Implemented Controls

- **Token Storage** - SharedPreferences (local persistence)
- **Token Expiry** - Automatic refresh before expiration
- **Session Revocation** - Server-side logout
- **Secure Transport** - HTTPS only (production/staging)
- **Error Handling** - No information leakage
- **Email Enumeration Prevention** - Password reset always succeeds
- **Network Error Handling** - User-friendly messages

### 🔒 Security Boundaries

```
Untrusted:
- User input
- Network responses
- Local storage
- Device state

Trusted:
- Server responses (after validation)
- Access tokens (bearer tokens)
- Backend authorization
```

## Error Codes

Standard error codes returned by the API:

| Code | Meaning | User Action |
|------|---------|-------------|
| `invalid_credentials` | Wrong email/password | Re-enter credentials |
| `account_suspended` | Account suspended | Contact support |
| `email_exists` | Email already registered | Use different email or login |
| `invalid_code` | Wrong verification code | Re-enter code |
| `network_error` | No internet | Check connection |
| `unknown_error` | Unexpected error | Try again or contact support |

## Testing

### Local Development

Use `LocalAuthRepository` for testing without backend:

```dart
// In tests or development
final authState = AuthState(
  repository: LocalAuthRepository(prefs: prefs),
);
```

Demo accounts:
- `demo@ishqtalk.app` / `demo123`
- `test@ishqtalk.app` / `test123`

### Integration Testing

Point to development environment:

```bash
flutter run --dart-define=AUTH_ENV=development
```

## Migration from Local to Remote

The app is currently configured to use `RemoteAuthRepository`. To switch back to local for testing:

```dart
// In app.dart
ChangeNotifierProvider(
  create: (_) => AuthState(
    repository: LocalAuthRepository(prefs: preferences!),
  )..restoreSession(),
),
```

## Next Steps

### Backend Setup Required

1. **Deploy Backend API** - Implement the endpoints in `API_CONTRACT.md`
2. **Configure Environments** - Set up dev/staging/prod environments
3. **SSL Certificates** - Ensure HTTPS for all non-local environments
4. **Test Authentication Flow** - End-to-end testing
5. **Monitor & Logging** - Request IDs, error tracking
6. **Rate Limiting** - Implement rate limits per API contract

### UI Integration Required

1. **Navigation Guards** - Redirect to login if unauthenticated
2. **Token Refresh** - Handle expired tokens in background
3. **Logout UI** - Add logout button in settings/profile
4. **Account Status UI** - Handle suspended/restricted accounts
5. **Loading States** - Show loading during auth operations
6. **Error Messages** - User-friendly error display

### Additional Features

- [ ] Social login (Google, Apple)
- [ ] Biometric authentication
- [ ] Remember me functionality
- [ ] Multi-device session management
- [ ] Account deletion workflow
- [ ] 2FA/MFA support

## References

- API Contract: `docs/docs/API_CONTRACT.md`
- Security & Privacy: `docs/docs/SECURITY_AND_PRIVACY.md`
- Domain Model: `docs/docs/DOMAIN_MODEL.md`
- Architecture: `docs/docs/ARCHITECTURE.md`
