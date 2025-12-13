import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../data/models/login_request.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/secure_storage_service.dart';

/// Logger instance
final _logger = Logger();

/// Authentication state
class AuthState extends Equatable {
  final User? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [user, isLoading, isAuthenticated, errorMessage];
}

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final SecureStorageService _secureStorage;

  AuthNotifier(this._authRepository, this._secureStorage)
    : super(const AuthState()) {
    _checkAuthStatus();
  }

  /// Check if user is already authenticated on app start
  Future<void> _checkAuthStatus() async {
    _logger.i('🔍 AuthNotifier: Checking authentication status on startup');
    state = state.copyWith(isLoading: true);

    try {
      final hasValidToken = await _secureStorage.hasValidToken();
      _logger.d('🔍 AuthNotifier: Has valid token: $hasValidToken');

      if (hasValidToken) {
        // Try to get current user info
        final token = await _secureStorage.getAuthToken();
        if (token != null) {
          _logger.i('✅ AuthNotifier: Valid token found, fetching user info');
          // Set token in dio headers (this will be done via interceptor)
          final user = await _authRepository.getCurrentUser();
          state = AuthState(
            user: user,
            isLoading: false,
            isAuthenticated: true,
          );
          _logger.i('✅ AuthNotifier: Auto-login successful');
          return;
        }
      }

      _logger.i('ℹ️ AuthNotifier: No valid token, user needs to login');
      state = const AuthState(isLoading: false);
    } catch (e) {
      _logger.e('❌ AuthNotifier: Auto-login failed: $e');
      // If fetching user fails, clear token and set unauthenticated state
      await _secureStorage.clearAuthToken();
      state = const AuthState(isLoading: false);
    }
  }

  /// Login with username and password
  Future<void> login(String username, String password) async {
    _logger.i('🔐 AuthNotifier: Login started for user: $username');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final loginRequest = LoginRequest(username: username, password: password);

      _logger.d('📤 AuthNotifier: Calling auth repository login');
      final authToken = await _authRepository.login(loginRequest);

      _logger.d('💾 AuthNotifier: Saving token to secure storage');
      await _secureStorage.saveAuthToken(authToken);

      // Get user information
      _logger.d('👤 AuthNotifier: Fetching user information');
      final user = await _authRepository.getCurrentUser();

      state = AuthState(user: user, isLoading: false, isAuthenticated: true);

      _logger.i('✅ AuthNotifier: Login successful for user: ${user.username}');
    } catch (e) {
      _logger.e('❌ AuthNotifier: Login failed: $e');
      state = AuthState(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Logout current user
  Future<void> logout() async {
    _logger.i('🚪 AuthNotifier: Logout started');
    state = state.copyWith(isLoading: true);

    try {
      await _authRepository.logout();
    } catch (e) {
      _logger.w(
        '⚠️ AuthNotifier: Logout API call failed, clearing local session anyway: $e',
      );
      // Continue with logout even if API call fails
    } finally {
      await _secureStorage.clearAuthToken();
      state = const AuthState(isLoading: false);
      _logger.i('✅ AuthNotifier: Logout complete');
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AuthNotifier(authRepository, secureStorage);
});
