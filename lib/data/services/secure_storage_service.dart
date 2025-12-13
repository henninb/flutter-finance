import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../models/auth_token.dart';
import '../models/csrf_token.dart';

/// Logger instance
final _logger = Logger();

/// Service for secure storage of sensitive data
class SecureStorageService {
  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'auth_token';
  static const String _tokenExpiresAtKey = 'auth_token_expires_at';
  static const String _savedUsernameKey = 'saved_username';
  static const String _csrfTokenKey = 'csrf_token';
  static const String _csrfHeaderNameKey = 'csrf_header_name';
  static const String _csrfParameterNameKey = 'csrf_parameter_name';

  SecureStorageService(this._storage);

  /// Save authentication token securely
  Future<void> saveAuthToken(AuthToken token) async {
    _logger.i('💾 SecureStorage: Saving auth token');
    _logger.d(
      '💾 SecureStorage: Token (first 20 chars): ${token.token.substring(0, 20)}...',
    );
    _logger.d('💾 SecureStorage: Expires at: ${token.expiresAt}');

    try {
      await _storage.write(key: _tokenKey, value: token.token);
      await _storage.write(
        key: _tokenExpiresAtKey,
        value: token.expiresAt.toIso8601String(),
      );

      _logger.i('✅ SecureStorage: Token saved successfully');
    } catch (e) {
      _logger.e('❌ SecureStorage: Failed to save token: $e');
      rethrow;
    }
  }

  /// Retrieve authentication token from secure storage
  Future<AuthToken?> getAuthToken() async {
    _logger.d('🔍 SecureStorage: Retrieving auth token');

    try {
      final token = await _storage.read(key: _tokenKey);
      final expiresAtStr = await _storage.read(key: _tokenExpiresAtKey);

      if (token == null || expiresAtStr == null) {
        _logger.d('ℹ️ SecureStorage: No token found in storage');
        return null;
      }

      final expiresAt = DateTime.parse(expiresAtStr);
      _logger.d('✅ SecureStorage: Token retrieved, expires at: $expiresAt');
      _logger.d(
        '🔍 SecureStorage: Token (first 20 chars): ${token.substring(0, 20)}...',
      );
      return AuthToken(token: token, expiresAt: expiresAt);
    } catch (e) {
      _logger.e('❌ SecureStorage: Failed to read or parse token: $e');
      // If reading or parsing fails, clear potentially corrupted data
      try {
        await clearAuthToken();
      } catch (clearError) {
        _logger.e('❌ SecureStorage: Failed to clear token: $clearError');
      }
      return null;
    }
  }

  /// Clear authentication token from secure storage
  Future<void> clearAuthToken() async {
    _logger.i('🗑️ SecureStorage: Clearing auth token');
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _tokenExpiresAtKey);
      _logger.i('✅ SecureStorage: Token cleared');
    } catch (e) {
      _logger.e('❌ SecureStorage: Failed to clear token: $e');
      // Don't rethrow - clearing should be best-effort
    }
  }

  /// Check if a valid (non-expired) token exists
  Future<bool> hasValidToken() async {
    _logger.d('🔍 SecureStorage: Checking for valid token');

    final token = await getAuthToken();
    if (token == null) {
      _logger.d('ℹ️ SecureStorage: No token exists');
      return false;
    }
    if (token.isExpired) {
      _logger.w('⚠️ SecureStorage: Token is expired, clearing');
      await clearAuthToken();
      return false;
    }

    _logger.i('✅ SecureStorage: Valid token exists');
    return true;
  }

  /// Clear all data from secure storage
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Save username for auto-fill
  Future<void> saveUsername(String username) async {
    _logger.i('💾 SecureStorage: Saving username');
    await _storage.write(key: _savedUsernameKey, value: username);
    _logger.i('✅ SecureStorage: Username saved successfully');
  }

  /// Retrieve saved username
  Future<String?> getSavedUsername() async {
    _logger.d('🔍 SecureStorage: Retrieving saved username');
    try {
      final username = await _storage.read(key: _savedUsernameKey);
      if (username != null) {
        _logger.d('✅ SecureStorage: Found saved username');
      } else {
        _logger.d('ℹ️ SecureStorage: No saved username found');
      }
      return username;
    } catch (e) {
      _logger.e('❌ SecureStorage: Failed to read saved username: $e');
      return null;
    }
  }

  /// Clear saved username
  Future<void> clearSavedUsername() async {
    _logger.i('🗑️ SecureStorage: Clearing saved username');
    await _storage.delete(key: _savedUsernameKey);
    _logger.i('✅ SecureStorage: Saved username cleared');
  }

  /// Save CSRF token securely
  Future<void> saveCsrfToken(CsrfToken csrfToken) async {
    _logger.i('💾 SecureStorage: Saving CSRF token');
    _logger.d(
      '💾 SecureStorage: CSRF Token (first 20 chars): ${csrfToken.token.substring(0, csrfToken.token.length > 20 ? 20 : csrfToken.token.length)}...',
    );

    try {
      await _storage.write(key: _csrfTokenKey, value: csrfToken.token);
      await _storage.write(
        key: _csrfHeaderNameKey,
        value: csrfToken.headerName,
      );
      await _storage.write(
        key: _csrfParameterNameKey,
        value: csrfToken.parameterName,
      );

      _logger.i('✅ SecureStorage: CSRF token saved successfully');
    } catch (e) {
      _logger.e('❌ SecureStorage: Failed to save CSRF token: $e');
      rethrow;
    }
  }

  /// Retrieve CSRF token from secure storage
  Future<CsrfToken?> getCsrfToken() async {
    _logger.d('🔍 SecureStorage: Retrieving CSRF token');

    try {
      final token = await _storage.read(key: _csrfTokenKey);
      final headerName = await _storage.read(key: _csrfHeaderNameKey);
      final parameterName = await _storage.read(key: _csrfParameterNameKey);

      if (token == null) {
        _logger.d('ℹ️ SecureStorage: No CSRF token found in storage');
        return null;
      }

      _logger.d('✅ SecureStorage: CSRF token retrieved');
      _logger.d(
        '🔍 SecureStorage: CSRF Token (first 20 chars): ${token.substring(0, token.length > 20 ? 20 : token.length)}...',
      );
      return CsrfToken(
        token: token,
        headerName: headerName ?? 'X-CSRF-TOKEN',
        parameterName: parameterName ?? '_csrf',
      );
    } catch (e) {
      _logger.e('❌ SecureStorage: Failed to read CSRF token: $e');
      return null;
    }
  }

  /// Clear CSRF token from secure storage
  Future<void> clearCsrfToken() async {
    _logger.i('🗑️ SecureStorage: Clearing CSRF token');
    try {
      await _storage.delete(key: _csrfTokenKey);
      await _storage.delete(key: _csrfHeaderNameKey);
      await _storage.delete(key: _csrfParameterNameKey);
      _logger.i('✅ SecureStorage: CSRF token cleared');
    } catch (e) {
      _logger.e('❌ SecureStorage: Failed to clear CSRF token: $e');
      // Don't rethrow - clearing should be best-effort
    }
  }
}

/// Provider for FlutterSecureStorage
final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    // LinuxOptions uses file-based storage by default
    lOptions: LinuxOptions(),
  );
});

/// Provider for SecureStorageService
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  final storage = ref.watch(flutterSecureStorageProvider);
  return SecureStorageService(storage);
});
