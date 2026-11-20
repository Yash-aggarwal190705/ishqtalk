import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/auth_models.dart';
import '../domain/auth_repository.dart';

/// Supabase-based authentication repository
///
/// Implements authentication using Supabase Auth API
/// Follows the IshqTalk API contract and domain model
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({SupabaseClient? client}) : _client = client;

  /// Resolved lazily so the repository can be constructed before
  /// `Supabase.initialize()` finishes (tests, early startup). Every use is
  /// wrapped in a try/catch in the methods below.
  final SupabaseClient? _client;
  SupabaseClient get _c => _client ?? Supabase.instance.client;

  @override
  Future<AuthSession?> getCurrentSession() async {
    try {
      final session = _c.auth.currentSession;
      final user = _c.auth.currentUser;

      if (session != null && user != null) {
        return _mapToAuthSession(session, user);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthResult<AuthSession>> login(LoginCredentials credentials) async {
    try {
      final response = await _c.auth.signInWithPassword(
        email: credentials.email,
        password: credentials.password,
      );

      if (response.session != null && response.user != null) {
        final session = _mapToAuthSession(response.session!, response.user!);
        return AuthResult.success(session);
      } else {
        return AuthResult.failure(
          AuthError(
            code: 'login_failed',
            message: 'Login failed. Please try again.',
          ),
        );
      }
    } on AuthException catch (e) {
      return AuthResult.failure(
        AuthError(
          code: e.statusCode ?? 'auth_error',
          message: _getErrorMessage(e.message),
        ),
      );
    } catch (e) {
      return AuthResult.failure(
        AuthError(
          code: 'unknown_error',
          message: 'An unexpected error occurred',
        ),
      );
    }
  }

  @override
  Future<AuthResult<AuthSession>> register(RegistrationData data) async {
    try {
      final response = await _c.auth.signUp(
        email: data.email,
        password: data.password,
        data: {'display_name': data.displayName},
      );

      if (response.user != null) {
        // Check if email confirmation is required
        if (response.session == null) {
          // Email confirmation required
          final now = DateTime.now();
          final account = Account(
            id: response.user!.id,
            email: data.email,
            displayName: data.displayName,
            status: AccountStatus.pendingVerification,
            createdAt: DateTime.parse(response.user!.createdAt),
            updatedAt: now,
          );

          final session = AuthSession(
            accessToken: '',
            refreshToken: '',
            expiresAt: now.add(const Duration(hours: 1)),
            account: account,
          );

          return AuthResult.success(session);
        } else {
          // Auto-confirmed (if email confirmation is disabled)
          final session = _mapToAuthSession(response.session!, response.user!);
          return AuthResult.success(session);
        }
      } else {
        return AuthResult.failure(
          AuthError(
            code: 'registration_failed',
            message: 'Registration failed. Please try again.',
          ),
        );
      }
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('already registered')) {
        return AuthResult.failure(
          AuthError(
            code: 'email_exists',
            message: 'An account with this email already exists',
          ),
        );
      }
      return AuthResult.failure(
        AuthError(
          code: e.statusCode ?? 'registration_error',
          message: _getErrorMessage(e.message),
        ),
      );
    } catch (e) {
      return AuthResult.failure(
        AuthError(
          code: 'unknown_error',
          message: 'An unexpected error occurred',
        ),
      );
    }
  }

  @override
  Future<AuthResult<void>> verifyEmail(String code) async {
    try {
      final user = _c.auth.currentUser;
      if (user == null || user.email == null) {
        return AuthResult.failure(
          AuthError(code: 'no_user', message: 'No user logged in'),
        );
      }

      // Supabase handles email verification via magic link or OTP
      // For OTP verification:
      final response = await _c.auth.verifyOTP(
        type: OtpType.email,
        email: user.email!,
        token: code,
      );

      if (response.session != null) {
        return AuthResult.success(null);
      } else {
        return AuthResult.failure(
          AuthError(
            code: 'verification_failed',
            message: 'Verification failed',
          ),
        );
      }
    } on AuthException catch (e) {
      return AuthResult.failure(
        AuthError(code: 'invalid_code', message: _getErrorMessage(e.message)),
      );
    } catch (e) {
      return AuthResult.failure(
        AuthError(
          code: 'unknown_error',
          message: 'An unexpected error occurred',
        ),
      );
    }
  }

  @override
  Future<AuthResult<void>> sendEmailOtp(String email) async {
    final String clean = email.trim().toLowerCase();
    try {
      // Sends a sign-in email OTP. `shouldCreateUser: true` lets new users
      // receive a code; `emailRedirectTo` is intentionally unset so the
      // project's default Site URL is used (no redirect allow-list needed).
      await _c.auth.signInWithOtp(email: clean, shouldCreateUser: true);
      return const AuthResult.success(null);
    } on AuthException catch (e) {
      // Keep the raw message so the UI can show the real reason; also log
      // the full details for diagnosis (rate limits, template errors, ...).
      if (kDebugMode) {
        debugPrint(
          '[AUTH] sendEmailOtp failed: ${e.message} '
          '(status=${e.statusCode}, code=${e.code})',
        );
      }
      return AuthResult.failure(
        AuthError(
          code: e.code ?? e.statusCode ?? 'otp_error',
          message: e.message,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AUTH] sendEmailOtp threw: $e');
      }
      return AuthResult.failure(
        AuthError(
          code: 'network_error',
          message: 'No internet connection. Please check your network.',
        ),
      );
    }
  }

  @override
  Future<AuthResult<AuthSession>> verifyEmailOtp(
    String email,
    String code,
  ) async {
    try {
      final response = await _c.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: code,
      );
      if (response.session != null && response.user != null) {
        final session = _mapToAuthSession(response.session!, response.user!);
        return AuthResult.success(session);
      }
      return const AuthResult.failure(
        AuthError(code: 'verification_failed', message: 'Verification failed'),
      );
    } on AuthException catch (e) {
      return AuthResult.failure(
        AuthError(code: 'invalid_code', message: _getErrorMessage(e.message)),
      );
    } catch (e) {
      return const AuthResult.failure(
        AuthError(
          code: 'unknown_error',
          message: 'An unexpected error occurred',
        ),
      );
    }
  }

  @override
  Future<AuthResult<void>> requestPasswordRecovery(
    PasswordRecoveryRequest request,
  ) async {
    try {
      await _c.auth.resetPasswordForEmail(request.email);
      // Always return success to prevent email enumeration
      return AuthResult.success(null);
    } catch (e) {
      // Still return success for security
      return AuthResult.success(null);
    }
  }

  @override
  Future<AuthResult<void>> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      // First verify the OTP
      final verifyResponse = await _c.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: code,
      );

      if (verifyResponse.session == null) {
        return AuthResult.failure(
          AuthError(
            code: 'invalid_code',
            message: 'Invalid or expired reset code',
          ),
        );
      }

      // Then update the password
      final response = await _c.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user != null) {
        return AuthResult.success(null);
      } else {
        return AuthResult.failure(
          AuthError(code: 'reset_failed', message: 'Password reset failed'),
        );
      }
    } on AuthException catch (e) {
      return AuthResult.failure(
        AuthError(
          code: e.statusCode ?? 'reset_error',
          message: _getErrorMessage(e.message),
        ),
      );
    } catch (e) {
      return AuthResult.failure(
        AuthError(
          code: 'unknown_error',
          message: 'An unexpected error occurred',
        ),
      );
    }
  }

  @override
  Future<AuthResult<AuthSession>> refreshToken(String refreshToken) async {
    try {
      final response = await _c.auth.refreshSession();

      if (response.session != null && response.user != null) {
        final session = _mapToAuthSession(response.session!, response.user!);
        return AuthResult.success(session);
      } else {
        return AuthResult.failure(
          AuthError(code: 'refresh_failed', message: 'Session refresh failed'),
        );
      }
    } on AuthException catch (e) {
      return AuthResult.failure(
        AuthError(code: 'refresh_failed', message: _getErrorMessage(e.message)),
      );
    } catch (e) {
      return AuthResult.failure(
        AuthError(code: 'refresh_failed', message: 'Session refresh failed'),
      );
    }
  }

  @override
  Future<AuthResult<void>> logout() async {
    try {
      await _c.auth.signOut();
      return AuthResult.success(null);
    } catch (e) {
      // Still consider it success locally
      return AuthResult.success(null);
    }
  }

  @override
  Future<bool> isSessionValid() async {
    try {
      final session = _c.auth.currentSession;
      if (session == null) return false;

      // Check if token is expired
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        session.expiresAt! * 1000,
      );
      if (DateTime.now().isAfter(expiresAt)) return false;

      // Check if user exists and is active
      final user = _c.auth.currentUser;
      if (user == null) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthResult<void>> revokeAllSessions() async {
    try {
      await _c.auth.signOut(scope: SignOutScope.global);
      return AuthResult.success(null);
    } catch (e) {
      return AuthResult.success(null); // Still consider it success locally
    }
  }

  // Helper methods

  AuthSession _mapToAuthSession(Session session, User user) {
    final now = DateTime.now();
    return AuthSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken ?? '',
      expiresAt: DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000),
      account: Account(
        id: user.id,
        email: user.email ?? '',
        displayName: user.userMetadata?['display_name'] as String?,
        status: _getAccountStatus(user),
        createdAt: DateTime.parse(user.createdAt),
        updatedAt: now,
        emailVerifiedAt: user.emailConfirmedAt != null
            ? DateTime.parse(user.emailConfirmedAt!)
            : null,
      ),
    );
  }

  AccountStatus _getAccountStatus(User user) {
    // Check user metadata or custom claims for status
    final status = user.userMetadata?['status'] as String?;

    if (status != null) {
      switch (status) {
        case 'pending_verification':
          return AccountStatus.pendingVerification;
        case 'active':
          return AccountStatus.active;
        case 'restricted':
          return AccountStatus.restricted;
        case 'suspended':
          return AccountStatus.suspended;
        case 'deletion_pending':
          return AccountStatus.deletionPending;
        case 'deleted':
          return AccountStatus.deleted;
      }
    }

    // Check email confirmation
    if (user.emailConfirmedAt == null) {
      return AccountStatus.pendingVerification;
    }

    return AccountStatus.active;
  }

  String _getErrorMessage(String originalMessage) {
    // Map Supabase error messages to user-friendly messages
    final lower = originalMessage.toLowerCase();

    if (lower.contains('invalid login credentials')) {
      return 'Invalid email or password';
    } else if (lower.contains('email not confirmed')) {
      return 'Please verify your email address';
    } else if (lower.contains('already registered')) {
      return 'An account with this email already exists';
    } else if (lower.contains('password')) {
      return 'Password must be at least 6 characters';
    } else if (lower.contains('network')) {
      return 'No internet connection. Please check your network.';
    }

    return originalMessage;
  }
}
