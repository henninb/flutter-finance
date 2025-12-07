# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter Finance is a native mobile application (iOS/Android) for personal finance management built with Flutter. It connects to a Spring Boot backend at https://finance.bhenning.com/api.

- **State Management:** Riverpod (flutter_riverpod)
- **Architecture:** Clean Architecture (data/domain/presentation layers)
- **Backend:** Spring Boot (Kotlin) - JWT-based authentication
- **Current Status:** MVP phase with authentication and account management implemented

## Development Commands

### Run & Build

```bash
# Run in development mode
flutter run

# Run on specific device
flutter devices
flutter run -d <device-id>

# Build Android release
flutter build apk --release
flutter build appbundle --release

# Build iOS release
flutter build ios --release

# Fast release bundle (uses script)
./run-bundle-fast.sh
```

### Code Analysis & Testing

```bash
# Analyze code for issues
flutter analyze

# Format code
dart format .

# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

### Dependency Management

```bash
# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Clean build artifacts
flutter clean
```

### Development

```bash
# Check Flutter version
flutter --version

# Check connected devices
flutter devices

# Clean and reinstall dependencies
flutter clean && flutter pub get
```

## Architecture

### Clean Architecture Structure

The codebase follows clean architecture with three main layers:

**Data Layer (`lib/data/`):**
- `models/` - Data models with JSON serialization (Account, Transaction, User, etc.)
- `repositories/` - Repository implementations (AuthRepository, AccountRepository, TransactionRepository)
- `data_sources/remote/` - API clients and Dio configuration
- `services/` - Services like SecureStorageService for token management

**Presentation Layer (`lib/presentation/`):**
- `providers/` - Riverpod state management (authProvider, accountProvider, transactionProvider)
- `screens/` - Full-page screens organized by feature (auth/, accounts/, transactions/)
- `widgets/` - Reusable UI components

**Core Layer (`lib/core/`):**
- `config/` - Environment configuration (EnvConfig with dev/prod environments)
- `theme/` - App theming (AppTheme, AppColors - dark theme matching web app)
- `constants/` - App-wide constants
- `utils/` - Utility functions (formatters, validators)

### Key Architectural Patterns

1. **Riverpod Providers Pattern**: State is managed through Riverpod providers. The main providers are:
   - `authProvider` - Authentication state (StateNotifierProvider)
   - `accountProvider` - Account management state
   - `transactionProvider` - Transaction management state
   - `dioProvider` - HTTP client with interceptors

2. **Repository Pattern**: All API calls go through repository classes that use Dio for HTTP requests. Repositories are provided via Riverpod providers.

3. **Secure Token Management**: JWT tokens are stored using `flutter_secure_storage` and automatically added to requests via `AuthInterceptor` in the Dio client.

4. **Router-based Navigation**: Uses `go_router` with authentication-aware routing that redirects based on `authProvider` state.

## Authentication Flow

The app uses JWT authentication with dual token support:

1. **Login**: POST to `/api/login` with username/password
2. **Token Storage**: Token extracted from either:
   - Response body (`token` or `access_token` field)
   - Set-Cookie header (`token=<jwt>`)
3. **Token Usage**: Automatically added to all requests via two methods:
   - Cookie (via CookieManager interceptor)
   - Bearer token (via AuthInterceptor)
4. **Auto-login**: On app start, checks for valid token and fetches user info
5. **Token Expiration**: Default 1 hour, cleared automatically on 401 responses

**Critical Implementation Details:**
- Cookie interceptor MUST be added before Auth interceptor in dio_provider.dart:443-471
- Tokens are stored/retrieved via SecureStorageService
- Router redirects are handled in main.dart:48-83 based on authProvider state

## State Management with Riverpod

### Provider Types Used

- `Provider` - For dependency injection (repositories, services)
- `StateNotifierProvider` - For mutable state (auth, accounts, transactions)
- `FutureProvider` - For async data loading

### State Pattern Example

```dart
// State class with Equatable for equality comparison
class AuthState extends Equatable {
  final User? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;
  // ... copyWith, props
}

// StateNotifier for state management
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  // ... methods update state via: state = state.copyWith(...)
}

// Provider declaration
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
```

## API Integration

**Base URL:** `https://finance.bhenning.com/api`

### Key Endpoints

**Authentication:**
- `POST /login` - Login (returns JWT in cookie or body)
- `POST /logout` - Logout
- `GET /me` - Get current user

**Accounts:**
- `GET /account/active` - List all active accounts
- `POST /account` - Create account
- `PUT /account/{id}` - Update account
- `DELETE /account/{id}` - Delete account

**Transactions:**
- `GET /transaction/account/select/{accountNameOwner}` - List transactions for account
- `POST /transaction` - Create transaction
- `PUT /transaction/{guid}` - Update transaction
- `DELETE /transaction/{guid}` - Delete transaction

See `API_REFERENCE.md` for complete API documentation.

## Configuration

### Environment Configuration

Set environment in `main.dart`:
```dart
EnvConfig.setEnvironment(Environment.development);
```

**Development:**
- API: https://finance.bhenning.com/api
- Logging: Enabled (verbose Dio logging)
- Cache: 5 minutes

**Production:**
- API: https://finance.bhenning.com/api
- Logging: Disabled
- Cache: 15 minutes

### Theme

Dark theme matching the web app:
- Primary: #3B82F6 (Bright Blue)
- Secondary: #10B981 (Emerald Green)
- Background: #0F172A (Very Dark Slate)
- Surface: #1E293B (Dark Slate)

All colors defined in `lib/core/theme/app_colors.dart`.

## Data Models

Models use manual JSON serialization (not code generation):

```dart
class Account extends Equatable {
  // Properties with defaults
  final int? accountId;
  final String accountNameOwner;
  final double cleared;

  // JSON serialization
  factory Account.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }

  // Immutability
  Account copyWith({ ... }) { ... }

  // Equality
  @override
  List<Object?> get props => [...];
}
```

## Logging

The app uses the `logger` package extensively. Look for emoji-prefixed logs:
- 🔐 Authentication operations
- 🌐 HTTP requests
- 📥 HTTP responses
- ❌ Errors
- ✅ Success
- ⚠️ Warnings
- 🍪 Cookie operations
- 🔑 Token operations

Logs are only enabled in development mode (EnvConfig.enableLogging).

## Important Implementation Notes

1. **Dio Interceptor Order Matters**: In `dio_provider.dart`, CookieManager MUST be added before AuthInterceptor to properly handle cookie-based authentication.

2. **Router Refresh on Auth Changes**: The router listens to `authProvider` changes via `_RouterRefreshNotifier` to trigger route redirects when authentication state changes.

3. **Model Serialization**: Models use manual fromJson/toJson methods (not freezed or json_serializable) despite those packages being in pubspec.yaml dependencies.

4. **Equatable for State**: All state classes and models extend Equatable for proper equality comparison in Riverpod.

5. **Null Safety**: The project uses Dart null safety. All models handle null values appropriately with nullable types and default values.

6. **Screen Responsiveness**: UI uses `flutter_screenutil` with design size 375x812 (iPhone 11 Pro dimensions) for responsive sizing.

## Common Development Patterns

### Adding a New Feature Screen

1. Create model in `lib/data/models/`
2. Create repository in `lib/data/repositories/`
3. Create provider in `lib/presentation/providers/`
4. Create screen in `lib/presentation/screens/feature_name/`
5. Add route in `main.dart` router
6. Add widgets in `lib/presentation/widgets/` if needed

### Making API Calls

Always use repositories, never call Dio directly from providers:

```dart
// In repository
Future<Account> getAccount(String name) async {
  final response = await _dio.get('/account/$name');
  return Account.fromJson(response.data);
}

// In provider/notifier
final account = await _accountRepository.getAccount(name);
```

### Error Handling

- Repositories throw exceptions with user-friendly messages
- Providers catch exceptions and update state with error messages
- UI displays errors from state via snackbars or error widgets

## Documentation

- `README.md` - Project overview and quick start
- `API_REFERENCE.md` - Complete backend API documentation
- `MIGRATION_PLAN.md` - Full migration plan and architecture details
- `PROJECT_CONFIG.md` - Configuration details (theme, validation, etc.)
- `QUICK_START.md` - Step-by-step setup guide

## Testing

Currently minimal testing infrastructure. When adding tests:
- Unit tests for repositories and models
- Widget tests for custom widgets
- Integration tests for critical flows
- Use `mockito` for mocking dependencies
