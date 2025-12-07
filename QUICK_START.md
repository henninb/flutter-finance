# Quick Start Guide - Flutter Finance App

This guide will help you get started building the Flutter version of your finance app.

---

## Prerequisites

- **Flutter SDK**: >= 3.16.0
- **Dart SDK**: >= 3.2.0
- **Android Studio** or **Xcode** (for simulators/emulators)
- **VS Code** or **IntelliJ IDEA** (recommended)
- **Git**

---

## Step 1: Project Setup

### Create Flutter Project

```bash
cd ~/projects/github.com/henninb
flutter create flutter-finance --org com.bhenning

cd flutter-finance
```

### Verify Flutter Setup

```bash
flutter doctor -v
```

Ensure all checks pass (or at least Android/iOS toolchain).

---

## Step 2: Update pubspec.yaml

Replace the dependencies section in `pubspec.yaml`:

```yaml
name: flutter_finance
description: Personal finance management app
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # Networking
  dio: ^5.4.0
  retrofit: ^4.0.0
  dio_cookie_manager: ^3.1.0
  cookie_jar: ^4.0.0

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Security
  flutter_secure_storage: ^9.0.0

  # UI/UX
  flutter_screenutil: ^5.9.0
  shimmer: ^3.0.0
  fl_chart: ^0.66.0

  # Navigation
  go_router: ^13.0.0

  # Utilities
  intl: ^0.19.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0
  logger: ^2.0.0
  uuid: ^4.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  retrofit_generator: ^8.0.0
  hive_generator: ^2.0.0

  # Linting
  flutter_lints: ^3.0.0

  # Testing
  mockito: ^5.4.0

flutter:
  uses-material-design: true
```

### Install Dependencies

```bash
flutter pub get
```

---

## Step 3: Create Project Structure

```bash
mkdir -p lib/{core,data,domain,presentation}
mkdir -p lib/core/{constants,theme,utils,errors}
mkdir -p lib/data/{models,repositories,data_sources}
mkdir -p lib/data/data_sources/{remote,local}
mkdir -p lib/domain/{entities,repositories,use_cases}
mkdir -p lib/presentation/{providers,screens,widgets}
mkdir -p lib/presentation/screens/{accounts,transactions,categories,auth}
mkdir -p lib/presentation/widgets/{common,finance}
```

---

## Step 4: Create Core Configuration Files

### 4.1: Environment Config (`lib/core/config/env_config.dart`)

```dart
enum Environment { development, production }

class EnvConfig {
  static Environment _env = Environment.development;

  static void setEnvironment(Environment env) {
    _env = env;
  }

  static String get apiBaseUrl {
    switch (_env) {
      case Environment.development:
        return 'https://finance.bhenning.com/api';
      case Environment.production:
        return 'https://finance.bhenning.com/api';
    }
  }

  static Duration get cacheDuration {
    switch (_env) {
      case Environment.development:
        return const Duration(minutes: 5);
      case Environment.production:
        return const Duration(minutes: 15);
    }
  }

  static bool get enableLogging {
    return _env == Environment.development;
  }
}
```

### 4.2: App Theme (`lib/core/theme/app_theme.dart`)

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3B82F6),        // Bright blue
        primaryContainer: Color(0xFF2563EB),
        secondary: Color(0xFF10B981),      // Emerald green
        secondaryContainer: Color(0xFF059669),
        surface: Color(0xFF1E293B),        // Dark slate for cards
        background: Color(0xFF0F172A),     // Very dark slate
        error: Color(0xFFEF4444),
        onPrimary: Color(0xFFF8FAFC),
        onSecondary: Color(0xFFF8FAFC),
        onSurface: Color(0xFFF8FAFC),
        onBackground: Color(0xFFF8FAFC),
        onError: Color(0xFFF8FAFC),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: const Color(0xFF1E293B),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F172A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF8FAFC),
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF8FAFC),
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF8FAFC),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFFF8FAFC),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFFCBD5E1),
        ),
      ),

      // Font Family
      fontFamily: 'Inter',
    );
  }
}
```

### 4.3: Constants (`lib/core/constants/app_constants.dart`)

```dart
class AppConstants {
  // API
  static const String contentTypeJson = 'application/json';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String usernameKey = 'username';

  // Hive Boxes
  static const String accountsBox = 'accounts';
  static const String transactionsBox = 'transactions';
  static const String categoriesBox = 'categories';
  static const String descriptionsBox = 'descriptions';
  static const String authBox = 'auth';

  // Pagination
  static const int defaultPageSize = 50;
  static const int maxPageSize = 100;

  // Validation
  static const int accountNameMinLength = 3;
  static const int accountNameMaxLength = 40;
  static const String accountNamePattern = r'^[a-z0-9_]+$';

  static const int descriptionMinLength = 1;
  static const int descriptionMaxLength = 75;

  static const int categoryMaxLength = 50;
  static const String categoryPattern = r'^[a-z0-9_]+$';

  static const int notesMaxLength = 100;

  // Currency
  static const String currencySymbol = '\$';
  static const int currencyDecimalPlaces = 2;
}
```

---

## Step 5: Create First Model (Account)

### `lib/data/models/account_model.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_model.freezed.dart';
part 'account_model.g.dart';

@freezed
class Account with _$Account {
  const factory Account({
    int? accountId,
    required String accountNameOwner,
    required String accountType,
    String? moniker,
    @Default(0.0) double cleared,
    @Default(0.0) double outstanding,
    @Default(0.0) double future,
    @Default(true) bool activeStatus,
    DateTime? validationDate,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);
}

extension AccountX on Account {
  double get total => cleared + outstanding + future;
}
```

### Generate Code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Step 6: Create Dio Provider

### `lib/data/data_sources/remote/dio_provider.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../core/config/env_config.dart';
import '../../../core/constants/app_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': AppConstants.contentTypeJson,
        'Accept': AppConstants.contentTypeJson,
      },
    ),
  );

  // Add logging interceptor in development
  if (EnvConfig.enableLogging) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => Logger().d(obj),
      ),
    );
  }

  // Add auth interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // TODO: Add auth token from secure storage
        // final token = await ref.read(authTokenProvider.future);
        // if (token != null) {
        //   options.headers['Authorization'] = 'Bearer $token';
        // }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 unauthorized
        if (error.response?.statusCode == 401) {
          // TODO: Handle logout or token refresh
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});
```

---

## Step 7: Run the App

### Update `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'core/config/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set environment
  EnvConfig.setEnvironment(Environment.development);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 11 Pro dimensions
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Finance',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: Center(
              child: Text(
                'Finance App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

### Run

```bash
# For iOS Simulator
flutter run -d iphone

# For Android Emulator
flutter run -d emulator

# For Chrome (web - for testing only)
flutter run -d chrome
```

---

## Step 8: Next Steps

Now that you have the basic project setup, follow these steps:

1. **Read the MIGRATION_PLAN.md** - Comprehensive migration plan
2. **Read the API_REFERENCE.md** - Complete API documentation
3. **Read the PROJECT_CONFIG.md** - All configuration details

### Recommended Order of Implementation:

1. ✅ Project setup (you're here!)
2. **Authentication** (`lib/presentation/screens/auth/`)
   - Login screen
   - Token management with Riverpod
   - Secure storage integration
3. **Account Management** (`lib/presentation/screens/accounts/`)
   - Account list screen
   - Account repository with Dio
   - Riverpod providers for state management
4. **Transaction Management** (`lib/presentation/screens/transactions/`)
   - Transaction list screen
   - Add/edit transaction
   - Filtering and search
5. **Categories & Descriptions**
6. **Testing & Polish**

---

## Useful Commands

```bash
# Run app
flutter run

# Run with specific device
flutter run -d <device_id>

# Hot reload (while app is running)
r

# Hot restart (while app is running)
R

# Generate code (after creating/modifying freezed/json models)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes (auto-regenerate)
flutter pub run build_runner watch --delete-conflicting-outputs

# Analyze code
flutter analyze

# Format code
dart format lib/

# Run tests
flutter test

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

---

## Troubleshooting

### Issue: Build runner fails
```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: CocoaPods issues (iOS)
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

### Issue: Android build fails
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

---

## Resources

- **Flutter Docs**: https://docs.flutter.dev/
- **Riverpod Docs**: https://riverpod.dev/
- **Dio Docs**: https://pub.dev/packages/dio
- **Freezed Docs**: https://pub.dev/packages/freezed
- **Your API Reference**: See `API_REFERENCE.md`
- **Your Project Config**: See `PROJECT_CONFIG.md`

---

## Getting Help

1. Check the documentation files in this project
2. Review the existing Next.js implementation for business logic reference
3. Check Flutter/Dart official documentation
4. Search on Stack Overflow with the `flutter` tag

---

Good luck with your Flutter migration! 🚀
