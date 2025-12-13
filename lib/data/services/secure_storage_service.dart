import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../models/auth_token.dart';

/// Logger instance
final _logger = Logger();

/// Service for secure storage of sensitive data
class SecureStorageService {
  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'auth_token';
  static const String _tokenExpiresAtKey = 'auth_token_expires_at';
  static const String _savedUsernameKey = 'saved_username';

  SecureStorageService(this._storage);

  /// Save authentication token securely
  Future<void> saveAuthToken(AuthToken token) async {
    _logger.i('💾 SecureStorage: Saving auth token');
    _logger.d(
      '💾 SecureStorage: Token (first 20 chars): ${token.token.substring(0, 20)}...',
    );
    _logger.d('💾 SecureStorage: Expires at: ${token.expiresAt}');

    await _storage.write(key: _tokenKey, value: token.token);
    await _storage.write(
      key: _tokenExpiresAtKey,
      value: token.expiresAt.toIso8601String(),
    );

    _logger.i('✅ SecureStorage: Token saved successfully');
  }

  /// Retrieve authentication token from secure storage
  Future<AuthToken?> getAuthToken() async {
    _logger.d('🔍 SecureStorage: Retrieving auth token');

    final token = await _storage.read(key: _tokenKey);
    final expiresAtStr = await _storage.read(key: _tokenExpiresAtKey);

    if (token == null || expiresAtStr == null) {
      _logger.d('ℹ️ SecureStorage: No token found in storage');
      return null;
    }

    try {
      final expiresAt = DateTime.parse(expiresAtStr);
      _logger.d('✅ SecureStorage: Token retrieved, expires at: $expiresAt');
      _logger.d(
        '🔍 SecureStorage: Token (first 20 chars): ${token.substring(0, 20)}...',
      );
      return AuthToken(token: token, expiresAt: expiresAt);
    } catch (e) {
      _logger.e('❌ SecureStorage: Failed to parse token data: $e');
      // If parsing fails, clear corrupted data
      await clearAuthToken();
      return null;
    }
  }

  /// Clear authentication token from secure storage
  Future<void> clearAuthToken() async {
    _logger.i('🗑️ SecureStorage: Clearing auth token');
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _tokenExpiresAtKey);
    _logger.i('✅ SecureStorage: Token cleared');
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
    final username = await _storage.read(key: _savedUsernameKey);
    if (username != null) {
      _logger.d('✅ SecureStorage: Found saved username');
    } else {
      _logger.d('ℹ️ SecureStorage: No saved username found');
    }
    return username;
  }

  /// Clear saved username
  Future<void> clearSavedUsername() async {
    _logger.i('🗑️ SecureStorage: Clearing saved username');
    await _storage.delete(key: _savedUsernameKey);
    _logger.i('✅ SecureStorage: Saved username cleared');
  }
}

/// Provider for FlutterSecureStorage
final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(aOptions: AndroidOptions());
});

/// Provider for SecureStorageService
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  final storage = ref.watch(flutterSecureStorageProvider);
  return SecureStorageService(storage);
});
