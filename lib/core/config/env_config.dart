/// Environment configuration for the app
enum Environment { development, production }

class EnvConfig {
  static Environment _env = Environment.development;

  static void setEnvironment(Environment env) {
    _env = env;
  }

  static Environment get environment => _env;

  /// API base URL for the finance backend
  static String get apiBaseUrl {
    switch (_env) {
      case Environment.development:
        return 'https://finance.bhenning.com/api';
      case Environment.production:
        return 'https://finance.bhenning.com/api';
    }
  }

  /// Cache duration for offline storage
  static Duration get cacheDuration {
    switch (_env) {
      case Environment.development:
        return const Duration(minutes: 5);
      case Environment.production:
        return const Duration(minutes: 15);
    }
  }

  /// Whether to enable logging
  static bool get enableLogging {
    return _env == Environment.development;
  }

  /// Connect timeout for HTTP requests
  static Duration get connectTimeout => const Duration(seconds: 30);

  /// Receive timeout for HTTP requests
  static Duration get receiveTimeout => const Duration(seconds: 30);
}
