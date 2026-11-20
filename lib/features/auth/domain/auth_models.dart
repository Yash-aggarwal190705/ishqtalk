/// Authentication domain models based on docs/SECURITY_AND_PRIVACY.md
/// and docs/API_CONTRACT.md

/// Account status as per DOMAIN_MODEL.md section 5.1
enum AccountStatus {
  pendingVerification,
  active,
  restricted,
  suspended,
  deletionPending,
  deleted,
}

/// Authentication provider types
enum AuthProvider {
  email,
  google,
  apple,
  facebook,
}

/// User account model
class Account {
  const Account({
    required this.id,
    required this.status,
    required this.email,
    this.displayName,
    this.locale,
    this.roles = const ['user'],
    required this.createdAt,
    required this.updatedAt,
    this.emailVerifiedAt,
  });

  final String id;
  final AccountStatus status;
  final String email;
  final String? displayName;
  final String? locale;
  final List<String> roles;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? emailVerifiedAt;

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      status: AccountStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => AccountStatus.pendingVerification,
      ),
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      locale: json['locale'] as String?,
      roles: (json['roles'] as List<dynamic>?)?.cast<String>() ?? ['user'],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status.name,
        'email': email,
        'display_name': displayName,
        'locale': locale,
        'roles': roles,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'email_verified_at': emailVerifiedAt?.toIso8601String(),
      };

  Account copyWith({
    String? id,
    AccountStatus? status,
    String? email,
    String? displayName,
    String? locale,
    List<String>? roles,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? emailVerifiedAt,
  }) {
    return Account(
      id: id ?? this.id,
      status: status ?? this.status,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      locale: locale ?? this.locale,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
    );
  }
}

/// Session model for authentication tokens
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.account,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final Account account;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      account: Account.fromJson(json['account'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_at': expiresAt.toIso8601String(),
        'account': account.toJson(),
      };
}

/// Login credentials
class LoginCredentials {
  const LoginCredentials({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

/// Registration data
class RegistrationData {
  const RegistrationData({
    required this.email,
    required this.password,
    required this.displayName,
    this.locale,
  });

  final String email;
  final String password;
  final String displayName;
  final String? locale;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'display_name': displayName,
        if (locale != null) 'locale': locale,
      };
}

/// Password recovery request
class PasswordRecoveryRequest {
  const PasswordRecoveryRequest({required this.email});

  final String email;

  Map<String, dynamic> toJson() => {'email': email};
}

/// Authentication result wrapper
class AuthResult<T> {
  const AuthResult.success(this.data)
      : error = null,
        isSuccess = true;

  const AuthResult.failure(this.error)
      : data = null,
        isSuccess = false;

  final T? data;
  final AuthError? error;
  final bool isSuccess;
}

/// Authentication error model
class AuthError {
  const AuthError({
    required this.code,
    required this.message,
    this.retryable = false,
  });

  final String code;
  final String message;
  final bool retryable;

  factory AuthError.fromJson(Map<String, dynamic> json) {
    return AuthError(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      message: json['message'] as String? ?? 'An unknown error occurred',
      retryable: json['retryable'] as bool? ?? false,
    );
  }
}
