import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../data_sources/remote/dio_provider.dart';
import '../models/auth_token.dart';
import '../models/login_request.dart';
import '../models/user_model.dart';

/// Logger instance
final _logger = Logger();

/// Repository for authentication-related API calls
class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  /// Login with username and password
  /// Returns AuthToken on success
  Future<AuthToken> login(LoginRequest request) async {
    _logger.i('🔐 AuthRepository: Starting login for user: ${request.username}');

    try {
      _logger.d('📤 AuthRepository: Sending POST /login request');
      final response = await _dio.post(
        '/login',
        data: request.toJson(),
      );

      _logger.i('📥 AuthRepository: Login response received - Status: ${response.statusCode}');
      _logger.d('📥 AuthRepository: Response data type: ${response.data.runtimeType}');
      _logger.d('📥 AuthRepository: Response data: ${response.data}');
      _logger.d('📥 AuthRepository: Response headers: ${response.headers}');

      // Extract token from response body OR cookie header
      String token = '';

      // Try response body first
      if (response.data is Map<String, dynamic>) {
        token = response.data['token'] as String? ??
                response.data['access_token'] as String? ??
                '';
      }

      // If not in body, check Set-Cookie header
      if (token.isEmpty) {
        _logger.d('🔍 AuthRepository: Token not in body, checking cookies');
        final cookies = response.headers['set-cookie'];
        if (cookies != null && cookies.isNotEmpty) {
          _logger.d('🍪 AuthRepository: Found ${cookies.length} cookies');
          // Look for token in cookies
          for (final cookie in cookies) {
            _logger.d('🍪 AuthRepository: Cookie: ${cookie.substring(0, 50)}...');
            if (cookie.startsWith('token=')) {
              // Extract token value from cookie string
              final tokenStart = 'token='.length;
              final tokenEnd = cookie.indexOf(';');
              token = cookie.substring(
                tokenStart,
                tokenEnd != -1 ? tokenEnd : null,
              );
              _logger.i('✅ AuthRepository: Extracted token from cookie');
              break;
            }
          }
        }
      }

      _logger.d('🔑 AuthRepository: Extracted token: ${token.isEmpty ? "EMPTY" : "${token.substring(0, 20)}..."}');

      if (token.isEmpty) {
        _logger.e('❌ AuthRepository: No token found in response body or cookies');
        throw Exception('No token received from server');
      }

      // Calculate expiration (default 1 hour if not provided)
      final expiresIn = response.data['expiresIn'] as int? ?? 3600;
      final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

      _logger.i('✅ AuthRepository: Token extracted successfully, expires at: $expiresAt');

      return AuthToken(
        token: token,
        expiresAt: expiresAt,
      );
    } on DioException catch (e) {
      _logger.e('❌ AuthRepository: DioException during login');
      _logger.e('   Status code: ${e.response?.statusCode}');
      _logger.e('   Response data: ${e.response?.data}');
      _logger.e('   Message: ${e.message}');

      if (e.response?.statusCode == 401) {
        throw Exception('Invalid username or password');
      }
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      _logger.e('❌ AuthRepository: Unexpected error during login: $e');
      throw Exception('Login failed: $e');
    }
  }

  /// Logout current user
  Future<void> logout() async {
    _logger.i('🚪 AuthRepository: Starting logout');

    try {
      await _dio.post('/logout');
      _logger.i('✅ AuthRepository: Logout successful');
    } on DioException catch (e) {
      _logger.e('❌ AuthRepository: Logout failed - ${e.message}');
      // Even if logout fails on server, we'll clear local session
      throw Exception('Logout failed: ${e.message}');
    }
  }

  /// Get current user information
  /// Requires valid JWT token in headers
  Future<User> getCurrentUser() async {
    _logger.i('👤 AuthRepository: Fetching current user info');

    try {
      final response = await _dio.get('/me');
      _logger.d('📥 AuthRepository: User info response: ${response.data}');

      final user = User.fromJson(response.data as Map<String, dynamic>);
      _logger.i('✅ AuthRepository: User info retrieved - Username: ${user.username}');

      return user;
    } on DioException catch (e) {
      _logger.e('❌ AuthRepository: Failed to get user info');
      _logger.e('   Status code: ${e.response?.statusCode}');
      _logger.e('   Response data: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        throw Exception('Not authenticated');
      }
      throw Exception('Failed to get user info: ${e.message}');
    } catch (e) {
      _logger.e('❌ AuthRepository: Unexpected error getting user info: $e');
      throw Exception('Failed to get user info: $e');
    }
  }
}

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});
