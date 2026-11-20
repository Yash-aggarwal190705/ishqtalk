import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/auth_models.dart';
import '../domain/auth_repository.dart';

/// Production authentication repository that connects to the IshqTalk API
/// Implements the API contract from docs/API_CONTRACT.md
class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository({
    required this.baseUrl,
    required this.prefs,
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client();

  final String baseUrl;
  final SharedPreferences prefs;
  final http.Client _client;

  static const String _sessionKey = 'ishqtalk.auth.session';
  static const String _accountKey = 'ishqtalk.auth.account';

  @override
  Future<AuthResult<AuthSession>> login(LoginCredentials credentials) async {
    try {
      // POST /v1/sessions
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/sessions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': credentials.email,
          'password': credentials.password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final sessionData = data['data'] as Map<String, dynamic>;

        final session = AuthSession(
          accessToken: sessionData['access_token'] as String,
          refreshToken: sessionData['refresh_token'] as String?,
          expiresAt: DateTime.parse(sessionData['expires_at'] as String),
          account: _parseAccount(
            sessionData['account'] as Map<String, dynamic>,
          ),
        );

        // Save session locally
        await _saveSession(session);

        return AuthResult.success(session);
      } else if (response.statusCode == 401) {
        return AuthResult.failure(
          AuthError(
            code: 'invalid_credentials',
            message: 'Invalid email or password',
          ),
        );
      } else if (response.statusCode == 403) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final error = data['error'] as Map<String, dynamic>?;
        return AuthResult.failure(
          AuthError(
            code: error?['code'] as String? ?? 'account_suspended',
            message:
                error?['message'] as String? ??
                'Account is suspended or restricted',
          ),
        );
      } else {
        return AuthResult.failure(
          AuthError(
            code: 'login_failed',
            message: 'Login failed. Please try again.',
          ),
        );
      }
    } on SocketException {
      return AuthResult.failure(
        AuthError(
          code: 'network_error',
          message: 'No internet connection. Please check your network.',
        ),
      );
    } on FormatException {
      return AuthResult.failure(
        AuthError(
          code: 'invalid_response',
          message: 'Invalid response from server',
        ),
      );
    } catch (e) {
      return AuthResult.failure(
        AuthError(
          code: 'unknown_error',
          message: 'An unexpected error occurred: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<AuthResult<AuthSession>> register(RegistrationData data) async {
    try {
      // POST /v1/accounts (registration endpoint)
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/accounts'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': data.email,
          'password': data.password,
          'display_name': data.displayName,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final accountData = responseData['data'] as Map<String, dynamic>;

        final account = _parseAccount(accountData);

        // Registration successful but needs verification
        // Create a pending session (no tokens yet)
        final session = AuthSession(
          accessToken: '', // Empty until verified
          refreshToken: null,
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          account: account,
        );

        return AuthResult.success(session);
      } else if (response.statusCode == 409) {
        return AuthResult.failure(
          AuthError(
            code: 'email_exists',
            message: 'An account with this email already exists',
          ),
        );
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final error = responseData['error'] as Map<String, dynamic>?;
        return AuthResult.failure(
          AuthError(
            code: error?['code'] as String? ?? 'invalid_input',
            message:
                error?['message'] as String? ?? 'Invalid registration data',
          ),
        );
      } else {
        return AuthResult.failure(
          AuthError(
            code: 'registration_failed',
            message: 'Registration failed. Please try again.',
          ),
        );
      }
    } on SocketException {
      return AuthResult.failure(
        AuthError(
          code: 'network_error',
          message: 'No internet connection. Please check your network.',
        ),
      );
    } catch (e) {
      return AuthResult.failure(
        AuthError(
          code: 'unknown_error',
          message: 'An unexpected error occurred: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<AuthResult<void>> verifyEmail(String email, String code) async {
    try {
      // POST /v1/accounts/verify
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/accounts/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'verification_code': code}),
      );

      if (response.statusCode == 200) {
        // After verification, log the user in automatically
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['data'] != null) {
          final sessionData = data['data'] as Map<String, dynamic>;
          final session = AuthSession(
            accessToken: sessionData['access_token'] as String,
            refreshToken: sessionData['refresh_token'] as String?,
            expiresAt: DateTime.parse(sessionData['expires_at'] as String),
            account: _parseAccount(
              sessionData['account'] as Map<String, dynamic>,
            ),
          );
          await _saveSession(session);
        }
        return AuthResult.success(null);
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        return AuthResult.failure(
          AuthError(code: 'invalid_code', message: 'Invalid verification code'),
        );
      } else {
        return AuthResult.failure(
          AuthError(
            code: 'verification_failed',
            message: 'Verification failed. Please try again.',
          ),
        );
      }
    } on SocketException {
      return AuthResult.failure(
        AuthError(code: 'network_error', message: 'No internet connection'),
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
    return const AuthResult.failure(
      AuthError(
        code: 'not_implemented',
        message: 'Email OTP is not implemented for this repository',
      ),
    );
  }

  @override
  Future<AuthResult<AuthSession>> verifyEmailOtp(
    String email,
    String code,
  ) async {
    return const AuthResult.failure(
      AuthError(
        code: 'not_implemented',
        message: 'Email OTP is not implemented for this repository',
      ),
    );
  }

  @override
  Future<AuthResult<void>> requestPasswordReset(
    PasswordRecoveryRequest request,
  ) async {
    try {
      // POST /v1/password-reset/request
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/password-reset/request'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': request.email}),
      );

      // Always return success to prevent email enumeration
      if (response.statusCode == 200 || response.statusCode == 202) {
        return AuthResult.success(null);
      } else {
        // Still return success for security
        return AuthResult.success(null);
      }
    } on SocketException {
      return AuthResult.failure(
        AuthError(code: 'network_error', message: 'No internet connection'),
      );
    } catch (e) {
      // For password reset requests, we don't expose errors
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
      // POST /v1/password-reset/confirm
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/password-reset/confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'reset_code': code,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return AuthResult.success(null);
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        return AuthResult.failure(
          AuthError(
            code: 'invalid_code',
            message: 'Invalid or expired reset code',
          ),
        );
      } else {
        return AuthResult.failure(
          AuthError(
            code: 'reset_failed',
            message: 'Password reset failed. Please try again.',
          ),
        );
      }
    } on SocketException {
      return AuthResult.failure(
        AuthError(code: 'network_error', message: 'No internet connection'),
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
  Future<AuthResult<AuthSession>> refreshSession(String refreshToken) async {
    try {
      // POST /v1/sessions/refresh
      final response = await _client.post(
        Uri.parse('$baseUrl/v1/sessions/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final sessionData = data['data'] as Map<String, dynamic>;

        final session = AuthSession(
          accessToken: sessionData['access_token'] as String,
          refreshToken: sessionData['refresh_token'] as String?,
          expiresAt: DateTime.parse(sessionData['expires_at'] as String),
          account: _parseAccount(
            sessionData['account'] as Map<String, dynamic>,
          ),
        );

        await _saveSession(session);
        return AuthResult.success(session);
      } else {
        return AuthResult.failure(
          AuthError(
            code: 'refresh_failed',
            message: 'Session refresh failed. Please log in again.',
          ),
        );
      }
    } catch (e) {
      return AuthResult.failure(
        AuthError(code: 'refresh_failed', message: 'Session refresh failed'),
      );
    }
  }

  @override
  Future<AuthResult<void>> logout(String accessToken) async {
    try {
      // POST /v1/sessions/revoke
      await _client.post(
        Uri.parse('$baseUrl/v1/sessions/revoke'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      // Clear local session regardless of response
      await _clearSession();
      return AuthResult.success(null);
    } catch (e) {
      // Always clear local session even if API call fails
      await _clearSession();
      return AuthResult.success(null);
    }
  }

  @override
  Future<AuthSession?> getStoredSession() async {
    try {
      final sessionJson = prefs.getString(_sessionKey);
      if (sessionJson == null) return null;

      final data = jsonDecode(sessionJson) as Map<String, dynamic>;
      return AuthSession(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String?,
        expiresAt: DateTime.parse(data['expires_at'] as String),
        account: _parseAccount(data['account'] as Map<String, dynamic>),
      );
    } catch (e) {
      return null;
    }
  }

  // Private helper methods

  Future<void> _saveSession(AuthSession session) async {
    final sessionData = {
      'access_token': session.accessToken,
      'refresh_token': session.refreshToken,
      'expires_at': session.expiresAt.toIso8601String(),
      'account': {
        'id': session.account.id,
        'email': session.account.email,
        'display_name': session.account.displayName,
        'status': session.account.status.name,
        'created_at': session.account.createdAt.toIso8601String(),
      },
    };

    await prefs.setString(_sessionKey, jsonEncode(sessionData));
  }

  Future<void> _clearSession() async {
    await prefs.remove(_sessionKey);
    await prefs.remove(_accountKey);
  }

  Account _parseAccount(Map<String, dynamic> data) {
    return Account(
      id: data['id'] as String,
      email: data['email'] as String,
      displayName: data['display_name'] as String?,
      status: _parseAccountStatus(data['status'] as String),
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }

  AccountStatus _parseAccountStatus(String status) {
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
      default:
        return AccountStatus.active;
    }
  }
}
