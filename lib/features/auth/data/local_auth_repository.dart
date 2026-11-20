/// Local/fake auth repository for development and testing
/// Based on docs/ARCHITECTURE.md section 3.1 (fake adapter testing)
/// This is a mock implementation for MVP - no real backend yet

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/auth_models.dart';
import '../domain/auth_repository.dart';

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository({SharedPreferences? preferences})
    : _preferences = preferences;

  static const String _sessionKey = 'ishqtalk.auth.session';
  final SharedPreferences? _preferences;
  AuthSession? _currentSession;

  // Fake users for local testing
  static final Map<String, Map<String, dynamic>> _fakeUsers = {
    'demo@ishqtalk.app': {
      'id': 'user_demo_001',
      'email': 'demo@ishqtalk.app',
      'password': 'demo123', // In real app, this would be hashed server-side
      'display_name': 'Demo User',
      'locale': 'en-US',
    },
    'test@ishqtalk.app': {
      'id': 'user_test_002',
      'email': 'test@ishqtalk.app',
      'password': 'test123',
      'display_name': 'Test User',
      'locale': 'en-US',
    },
  };

  @override
  Future<AuthSession?> getCurrentSession() async {
    if (_currentSession != null) {
      return _currentSession;
    }

    // Try to restore from SharedPreferences
    final String? sessionJson = _preferences?.getString(_sessionKey);
    if (sessionJson == null) {
      return null;
    }

    try {
      final Map<String, dynamic> data = jsonDecode(sessionJson);
      _currentSession = AuthSession.fromJson(data);

      // Check if expired
      if (_currentSession!.isExpired) {
        await _clearSession();
        return null;
      }

      return _currentSession;
    } catch (e) {
      await _clearSession();
      return null;
    }
  }

  @override
  Future<AuthResult<AuthSession>> login(LoginCredentials credentials) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Validate credentials against fake users
    final fakeUser = _fakeUsers[credentials.email];
    if (fakeUser == null) {
      return const AuthResult.failure(
        AuthError(
          code: 'INVALID_CREDENTIALS',
          message: 'Invalid email or password',
          retryable: false,
        ),
      );
    }

    if (fakeUser['password'] != credentials.password) {
      return const AuthResult.failure(
        AuthError(
          code: 'INVALID_CREDENTIALS',
          message: 'Invalid email or password',
          retryable: false,
        ),
      );
    }

    // Create fake session
    final account = Account(
      id: fakeUser['id'] as String,
      status: AccountStatus.active,
      email: fakeUser['email'] as String,
      displayName: fakeUser['display_name'] as String,
      locale: fakeUser['locale'] as String?,
      roles: const ['user'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      emailVerifiedAt: DateTime.now().subtract(const Duration(days: 29)),
    );

    final session = AuthSession(
      accessToken: _generateFakeToken(),
      refreshToken: _generateFakeToken(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      account: account,
    );

    // Store session
    await _saveSession(session);
    _currentSession = session;

    return AuthResult.success(session);
  }

  @override
  Future<AuthResult<AuthSession>> register(RegistrationData data) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // Check if email already exists
    if (_fakeUsers.containsKey(data.email)) {
      return const AuthResult.failure(
        AuthError(
          code: 'EMAIL_ALREADY_EXISTS',
          message: 'This email is already registered',
          retryable: false,
        ),
      );
    }

    // Validate email format
    if (!_isValidEmail(data.email)) {
      return const AuthResult.failure(
        AuthError(
          code: 'INVALID_EMAIL',
          message: 'Please enter a valid email address',
          retryable: false,
        ),
      );
    }

    // Validate password strength (minimum 6 characters for demo)
    if (data.password.length < 6) {
      return const AuthResult.failure(
        AuthError(
          code: 'WEAK_PASSWORD',
          message: 'Password must be at least 6 characters',
          retryable: false,
        ),
      );
    }

    // Create new user
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final account = Account(
      id: userId,
      status: AccountStatus.pendingVerification,
      email: data.email,
      displayName: data.displayName,
      locale: data.locale ?? 'en-US',
      roles: const ['user'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      emailVerifiedAt: null,
    );

    // Create session
    final session = AuthSession(
      accessToken: _generateFakeToken(),
      refreshToken: _generateFakeToken(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      account: account,
    );

    // Add to fake users (in memory only for this session)
    _fakeUsers[data.email] = {
      'id': userId,
      'email': data.email,
      'password': data.password,
      'display_name': data.displayName,
      'locale': data.locale,
    };

    await _saveSession(session);
    _currentSession = session;

    return AuthResult.success(session);
  }

  @override
  Future<AuthResult<void>> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _clearSession();
    _currentSession = null;
    return const AuthResult.success(null);
  }

  @override
  Future<AuthResult<AuthSession>> refreshToken(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final currentSession = await getCurrentSession();
    if (currentSession == null) {
      return const AuthResult.failure(
        AuthError(
          code: 'NO_SESSION',
          message: 'No active session found',
          retryable: false,
        ),
      );
    }

    // Create new session with refreshed tokens
    final newSession = AuthSession(
      accessToken: _generateFakeToken(),
      refreshToken: _generateFakeToken(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      account: currentSession.account,
    );

    await _saveSession(newSession);
    _currentSession = newSession;

    return AuthResult.success(newSession);
  }

  @override
  Future<AuthResult<void>> requestPasswordRecovery(
    PasswordRecoveryRequest request,
  ) async {
    await Future.delayed(const Duration(milliseconds: 700));

    // For local testing, always return success
    // In real app, server would send recovery email
    return const AuthResult.success(null);
  }

  @override
  Future<AuthResult<void>> verifyEmail(String code) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final session = await getCurrentSession();
    if (session == null) {
      return const AuthResult.failure(
        AuthError(
          code: 'NO_SESSION',
          message: 'No active session found',
          retryable: false,
        ),
      );
    }

    // Update account to verified
    final updatedAccount = session.account.copyWith(
      status: AccountStatus.active,
      emailVerifiedAt: DateTime.now(),
    );

    final updatedSession = AuthSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      expiresAt: session.expiresAt,
      account: updatedAccount,
    );

    await _saveSession(updatedSession);
    _currentSession = updatedSession;

    return const AuthResult.success(null);
  }

  @override
  Future<AuthResult<void>> sendEmailOtp(String email) async {
    // Demo: every address accepts the demo code below.
    return const AuthResult.success(null);
  }

  @override
  Future<AuthResult<AuthSession>> verifyEmailOtp(
    String email,
    String code,
  ) async {
    if (code != '123456') {
      return const AuthResult.failure(
        AuthError(
          code: 'invalid_code',
          message: 'Invalid verification code',
          retryable: false,
        ),
      );
    }
    final account = Account(
      id: 'user_otp_${DateTime.now().millisecondsSinceEpoch}',
      status: AccountStatus.active,
      email: email,
      displayName: email.split('@').first,
      locale: 'en-US',
      roles: const ['user'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      emailVerifiedAt: DateTime.now(),
    );
    final session = AuthSession(
      accessToken: _generateFakeToken(),
      refreshToken: _generateFakeToken(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      account: account,
    );
    await _saveSession(session);
    _currentSession = session;
    return AuthResult.success(session);
  }

  @override
  Future<bool> isSessionValid() async {
    final session = await getCurrentSession();
    if (session == null) return false;
    if (session.isExpired) return false;
    if (session.account.status == AccountStatus.deleted ||
        session.account.status == AccountStatus.suspended) {
      return false;
    }
    return true;
  }

  @override
  Future<AuthResult<void>> revokeAllSessions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    await _clearSession();
    _currentSession = null;
    return const AuthResult.success(null);
  }

  // Private helper methods

  Future<void> _saveSession(AuthSession session) async {
    final sessionJson = jsonEncode(session.toJson());
    await _preferences?.setString(_sessionKey, sessionJson);
  }

  Future<void> _clearSession() async {
    await _preferences?.remove(_sessionKey);
  }

  String _generateFakeToken() {
    // Generate a fake JWT-like token for local testing
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.hashCode.toRadixString(36);
    return 'fake_token_$random';
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
