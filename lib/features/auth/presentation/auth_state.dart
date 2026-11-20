/// Authentication state management using Provider
/// Based on docs/ARCHITECTURE.md presentation layer

import 'package:flutter/foundation.dart';

import '../domain/auth_models.dart';
import '../domain/auth_repository.dart';

/// Authentication state
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends ChangeNotifier {
  AuthState({required AuthRepository repository}) : _repository = repository {
    _initializeAuth();
  }

  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.initial;
  AuthSession? _session;
  AuthError? _error;
  bool _isLoading = false;

  // Getters
  AuthStatus get status => _status;
  AuthSession? get session => _session;
  Account? get account => _session?.account;
  AuthError? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated && _session != null;
  bool get hasError => _error != null;

  /// Initialize authentication state
  Future<void> _initializeAuth() async {
    _setLoading(true);
    try {
      final session = await _repository.getCurrentSession();
      if (session != null) {
        final isValid = await _repository.isSessionValid();
        if (isValid) {
          _session = session;
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      if (kDebugMode) {
        debugPrint('[AUTH] Initialization error: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Public method to initialize auth (called from app.dart)
  Future<void> initialize() async {
    await _initializeAuth();
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _clearError();
    _setLoading(true);

    try {
      final credentials = LoginCredentials(email: email, password: password);
      final result = await _repository.login(credentials);

      if (result.isSuccess && result.data != null) {
        _session = result.data;
        _status = AuthStatus.authenticated;
        _setLoading(false);
        return true;
      } else {
        _error = result.error;
        _status = AuthStatus.error;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = AuthError(
        code: 'UNKNOWN_ERROR',
        message: 'An unexpected error occurred: $e',
      );
      _status = AuthStatus.error;
      _setLoading(false);
      return false;
    }
  }

  /// Register new account
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    String? locale,
  }) async {
    _clearError();
    _setLoading(true);

    try {
      final data = RegistrationData(
        email: email,
        password: password,
        displayName: displayName,
        locale: locale,
      );
      final result = await _repository.register(data);

      if (result.isSuccess && result.data != null) {
        _session = result.data;
        _status = AuthStatus.authenticated;
        _setLoading(false);
        return true;
      } else {
        _error = result.error;
        _status = AuthStatus.error;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = AuthError(
        code: 'UNKNOWN_ERROR',
        message: 'An unexpected error occurred: $e',
      );
      _status = AuthStatus.error;
      _setLoading(false);
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _repository.logout();
      _session = null;
      _status = AuthStatus.unauthenticated;
      _clearError();
    } catch (e) {
      _error = AuthError(code: 'LOGOUT_ERROR', message: 'Failed to logout: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Request password recovery
  Future<bool> requestPasswordRecovery(String email) async {
    _clearError();
    _setLoading(true);

    try {
      final request = PasswordRecoveryRequest(email: email);
      final result = await _repository.requestPasswordRecovery(request);

      if (result.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _error = result.error;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = AuthError(
        code: 'RECOVERY_ERROR',
        message: 'Failed to request password recovery: $e',
      );
      _setLoading(false);
      return false;
    }
  }

  /// Verify email with code
  Future<bool> verifyEmail(String code) async {
    _clearError();
    _setLoading(true);

    try {
      final result = await _repository.verifyEmail(code);

      if (result.isSuccess) {
        // Refresh session to get updated account
        final session = await _repository.getCurrentSession();
        if (session != null) {
          _session = session;
        }
        _setLoading(false);
        return true;
      } else {
        _error = result.error;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = AuthError(
        code: 'VERIFICATION_ERROR',
        message: 'Failed to verify email: $e',
      );
      _setLoading(false);
      return false;
    }
  }

  /// Send a sign-in email OTP (Supabase: no prior session needed).
  Future<bool> sendEmailOtp(String email) async {
    _clearError();
    _setLoading(true);

    try {
      final result = await _repository.sendEmailOtp(email);
      if (result.isSuccess) {
        _setLoading(false);
        return true;
      }
      _error = result.error;
      _status = AuthStatus.error;
      _setLoading(false);
      return false;
    } catch (e) {
      _error = AuthError(
        code: 'OTP_SEND_ERROR',
        message: 'Failed to send code: $e',
      );
      _status = AuthStatus.error;
      _setLoading(false);
      return false;
    }
  }

  /// Verify an email OTP code and store the resulting session.
  Future<bool> verifyEmailOtp(String email, String code) async {
    _clearError();
    _setLoading(true);

    try {
      final result = await _repository.verifyEmailOtp(email, code);
      if (result.isSuccess && result.data != null) {
        _session = result.data;
        _status = AuthStatus.authenticated;
        _setLoading(false);
        return true;
      }
      _error = result.error;
      _status = AuthStatus.error;
      _setLoading(false);
      return false;
    } catch (e) {
      _error = AuthError(
        code: 'OTP_VERIFY_ERROR',
        message: 'Failed to verify code: $e',
      );
      _status = AuthStatus.error;
      _setLoading(false);
      return false;
    }
  }

  /// Refresh current session
  Future<bool> refreshSession() async {
    if (_session == null) return false;

    try {
      final result = await _repository.refreshToken(_session!.refreshToken);

      if (result.isSuccess && result.data != null) {
        _session = result.data;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AUTH] Token refresh failed: $e');
      }
      return false;
    }
  }

  /// Revoke all sessions (security action)
  Future<void> revokeAllSessions() async {
    _setLoading(true);
    try {
      await _repository.revokeAllSessions();
      _session = null;
      _status = AuthStatus.unauthenticated;
      _clearError();
    } catch (e) {
      _error = AuthError(
        code: 'REVOKE_ERROR',
        message: 'Failed to revoke sessions: $e',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Clear current error
  void clearError() {
    _clearError();
  }

  // Private helper methods

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
