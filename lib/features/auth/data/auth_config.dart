/// Authentication configuration for different environments
class AuthConfig {
  const AuthConfig._({
    required this.baseUrl,
    required this.environment,
  });

  final String baseUrl;
  final String environment;

  /// Local development environment
  static const local = AuthConfig._(
    baseUrl: 'http://127.0.0.1:8000',
    environment: 'local',
  );

  /// Development environment
  static const development = AuthConfig._(
    baseUrl: 'https://api-dev.ishqtalk.app',
    environment: 'development',
  );

  /// Staging environment
  static const staging = AuthConfig._(
    baseUrl: 'https://api-staging.ishqtalk.app',
    environment: 'staging',
  );

  /// Production environment
  static const production = AuthConfig._(
    baseUrl: 'https://api.ishqtalk.app',
    environment: 'production',
  );

  /// Get the current configuration based on build mode and environment variables
  /// 
  /// Priority:
  /// 1. Environment variable AUTH_ENV (local|development|staging|production)
  /// 2. Debug mode defaults to local
  /// 3. Release mode defaults to production
  static AuthConfig get current {
    const env = String.fromEnvironment('AUTH_ENV', defaultValue: '');
    
    switch (env.toLowerCase()) {
      case 'local':
        return local;
      case 'development':
      case 'dev':
        return development;
      case 'staging':
      case 'stage':
        return staging;
      case 'production':
      case 'prod':
        return production;
      default:
        // Default based on build mode
        return const bool.fromEnvironment('dart.vm.product')
            ? production  // Release build
            : local;      // Debug build
    }
  }

  @override
  String toString() => 'AuthConfig($environment: $baseUrl)';
}
