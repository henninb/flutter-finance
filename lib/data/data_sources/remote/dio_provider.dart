import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../../core/config/env_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../services/secure_storage_service.dart';

/// Logger instance
final _logger = Logger();

/// Cookie jar provider for managing cookies
final cookieJarProvider = Provider<CookieJar>((ref) {
  return CookieJar();
});

/// Auth interceptor for adding JWT token to requests
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    _logger.d('🔒 AuthInterceptor: Intercepting request to ${options.uri}');

    // Get auth token from secure storage
    final authToken = await _secureStorage.getAuthToken();

    if (authToken != null && !authToken.isExpired) {
      // Add Authorization header with Bearer token
      options.headers['Authorization'] = 'Bearer ${authToken.token}';
      _logger.i(
        '✅ AuthInterceptor: Added Bearer token to request: ${options.uri}',
      );
      _logger.d(
        '🔑 AuthInterceptor: Token (first 20 chars): ${authToken.token.substring(0, 20)}...',
      );
    } else {
      _logger.w(
        '⚠️ AuthInterceptor: No valid token available for request: ${options.uri}',
      );
    }

    return handler.next(options);
  }
}

/// CSRF interceptor for adding CSRF token to mutation requests
class CsrfInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  CsrfInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Only add CSRF token for mutation requests (POST, PUT, DELETE, PATCH)
    final isMutation = [
      'POST',
      'PUT',
      'DELETE',
      'PATCH',
    ].contains(options.method.toUpperCase());

    // Skip CSRF for login and register endpoints as they're exempt
    final isExemptPath =
        options.path.contains('/login') ||
        options.path.contains('/register') ||
        options.path.contains('/csrf');

    if (isMutation && !isExemptPath) {
      _logger.d(
        '🔒 CsrfInterceptor: Intercepting ${options.method} request to ${options.uri}',
      );

      // Get CSRF token from secure storage
      final csrfToken = await _secureStorage.getCsrfToken();

      if (csrfToken != null) {
        // Add CSRF token header
        options.headers[csrfToken.headerName] = csrfToken.token;
        _logger.i(
          '✅ CsrfInterceptor: Added ${csrfToken.headerName} header to request: ${options.uri}',
        );
        _logger.d(
          '🔑 CsrfInterceptor: Token (first 20 chars): ${csrfToken.token.substring(0, csrfToken.token.length > 20 ? 20 : csrfToken.token.length)}...',
        );
      } else {
        _logger.w(
          '⚠️ CsrfInterceptor: No CSRF token available for mutation request: ${options.uri}',
        );
      }
    }

    return handler.next(options);
  }
}

/// Dio provider for HTTP requests
final dioProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final cookieJar = ref.watch(cookieJarProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: EnvConfig.connectTimeout,
      receiveTimeout: EnvConfig.receiveTimeout,
      headers: {
        'Content-Type': AppConstants.contentTypeJson,
        'Accept': AppConstants.contentTypeJson,
      },
    ),
  );

  // Add cookie manager (MUST be first to handle cookies)
  dio.interceptors.add(CookieManager(cookieJar));
  _logger.i('🍪 Dio: Cookie manager added');

  // Add auth interceptor (for Bearer token fallback)
  dio.interceptors.add(AuthInterceptor(secureStorage));
  _logger.i('🔐 Dio: Auth interceptor added');

  // Add CSRF interceptor (for CSRF protection on mutations)
  dio.interceptors.add(CsrfInterceptor(secureStorage));
  _logger.i('🔒 Dio: CSRF interceptor added');

  // Add logging interceptor in development
  if (EnvConfig.enableLogging) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  // Add error handling interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.i('🌐 HTTP Request: ${options.method} ${options.uri}');
        _logger.d('📤 Request headers: ${options.headers}');
        _logger.d('📤 Request data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.i(
          '📥 HTTP Response: ${response.statusCode} ${response.requestOptions.uri}',
        );
        _logger.d('📥 Response headers: ${response.headers}');
        _logger.d('📥 Response data: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) async {
        _logger.e(
          '❌ HTTP Error: ${error.response?.statusCode} ${error.requestOptions.uri}',
        );
        _logger.e('   Error type: ${error.type}');
        _logger.e('   Error message: ${error.message}');
        _logger.e('   Response data: ${error.response?.data}');

        // Handle 401 unauthorized
        if (error.response?.statusCode == 401) {
          _logger.w('⚠️ Unauthorized (401) - clearing expired token');
          await secureStorage.clearAuthToken();
          await secureStorage.clearCsrfToken();
        }

        // Handle 403 forbidden (might be CSRF token issue)
        if (error.response?.statusCode == 403) {
          _logger.w('⚠️ Forbidden (403) - might be CSRF token issue');
          _logger.w('   Consider refreshing CSRF token');
        }

        return handler.next(error);
      },
    ),
  );

  return dio;
});
