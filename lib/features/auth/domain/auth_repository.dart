/// Auth repository interface following Clean Architecture
/// Based on docs/ARCHITECTURE.md and docs/SECURITY_AND_PRIVACY.md

import 'auth_models.dart';

/// Abstract auth repository interface for dependency inversion
abstract class AuthRepository {
  /// Get current authenticated session if exists
  Future<AuthSession?> getCurrentSession();

  /// Login with email and password
  /// Returns AuthResult with session or error
  Future<AuthResult<AuthSession>> login(LoginCredentials credentials);

  /// Register new account
  Future<AuthResult<AuthSession>> register(RegistrationData data);

  /// Logout and revoke current session
  Future<AuthResult<void>> logout();

  /// Refresh access token using refresh token
  Future<AuthResult<AuthSession>> refreshToken(String refreshToken);

  /// Request password recovery
  Future<AuthResult<void>> requestPasswordRecovery(
    PasswordRecoveryRequest request,
  );

  /// Verify email with code
  Future<AuthResult<void>> verifyEmail(String code);

  /// Send a sign-in one-time password to [email].
  Future<AuthResult<void>> sendEmailOtp(String email);

  /// Verify an email OTP code; returns the new session on success.
  Future<AuthResult<AuthSession>> verifyEmailOtp(String email, String code);

  /// Check if session is valid (not expired, account active)
  Future<bool> isSessionValid();

  /// Revoke all sessions
  Future<AuthResult<void>> revokeAllSessions();
}
