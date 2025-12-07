# Project Configuration

## Project Details

**Project Name:** Flutter Finance
**Package Name:** `com.bhenning.finance` (recommended)
**Backend API:** https://finance.bhenning.com/api
**Target Platforms:** iOS and Android
**State Management:** Riverpod
**Backend Framework:** Spring Boot (Kotlin)

---

## Authentication Configuration

### JWT Token Settings
- **Token Storage**: HttpOnly Cookie (production) or Authorization Bearer header
- **Token Name**: `token`
- **Token Expiration**: 1 hour
- **Cookie Domain**: `.bhenning.com` (production)
- **Cookie SameSite**: `Strict` (production), `Lax` (development)
- **Cookie Secure**: `true` (production), `false` (development)

### Password Requirements (for registration)
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one digit
- At least one special character (@$!%*?&)

---

## Theme & Branding

### Color Palette (Dark Theme)

#### Primary Colors
```dart
primary: Color(0xFF3B82F6),        // Modern bright blue
primaryLight: Color(0xFF60A5FA),
primaryDark: Color(0xFF2563EB),
```

#### Secondary Colors
```dart
secondary: Color(0xFF10B981),      // Modern emerald green
secondaryLight: Color(0xFF34D399),
secondaryDark: Color(0xFF059669),
```

#### Background Colors
```dart
backgroundDefault: Color(0xFF0F172A),  // Very dark slate
backgroundPaper: Color(0xFF1E293B),    // Dark slate for cards
```

#### Text Colors
```dart
textPrimary: Color(0xFFF8FAFC),        // Near white
textSecondary: Color(0xFFCBD5E1),      // Light slate
```

#### Semantic Colors
```dart
success: Color(0xFF22C55E),
successLight: Color(0xFF4ADE80),
successDark: Color(0xFF16A34A),

warning: Color(0xFFF59E0B),
warningLight: Color(0xFFFBBF24),
warningDark: Color(0xFFD97706),

error: Color(0xFFEF4444),
errorLight: Color(0xFFF87171),
errorDark: Color(0xFFDC2626),

info: Color(0xFF3B82F6),           // Same as primary
infoLight: Color(0xFF60A5FA),
infoDark: Color(0xFF2563EB),
```

#### Divider & Borders
```dart
divider: Color(0xFF334155),            // Medium slate
```

### Typography

```dart
fontFamily: ['Inter', 'Segoe UI', 'Roboto', 'Helvetica', 'Arial', 'sans-serif']

h1: fontSize: 40sp, fontWeight: 700, lineHeight: 1.2
h2: fontSize: 32sp, fontWeight: 600, lineHeight: 1.3
h3: fontSize: 24sp, fontWeight: 600, lineHeight: 1.4
h4: fontSize: 20sp, fontWeight: 600, lineHeight: 1.5
h5: fontSize: 18sp, fontWeight: 600, lineHeight: 1.5
h6: fontSize: 16sp, fontWeight: 600, lineHeight: 1.5
body1: fontSize: 16sp, fontWeight: 400, lineHeight: 1.6
body2: fontSize: 14sp, fontWeight: 400, lineHeight: 1.6
button: fontSize: 14sp, fontWeight: 500
caption: fontSize: 12sp, fontWeight: 400
```

### Shape & Borders
```dart
borderRadius: 12.0
cardBorderRadius: 20.0
buttonBorderRadius: 12.0
textFieldBorderRadius: 12.0
```

### Shadows
```dart
elevation2: BoxShadow(
  color: Colors.black.withOpacity(0.3),
  blurRadius: 6,
  offset: Offset(0, 4),
)
```

---

## Environment Configuration

### Development Environment
```dart
apiBaseUrl: 'https://finance.bhenning.com/api'
environment: 'development'
enableLogging: true
cacheDuration: Duration(minutes: 5)
```

### Staging Environment
```dart
apiBaseUrl: 'https://staging.finance.bhenning.com/api'  // If you have staging
environment: 'staging'
enableLogging: true
cacheDuration: Duration(minutes: 10)
```

### Production Environment
```dart
apiBaseUrl: 'https://finance.bhenning.com/api'
environment: 'production'
enableLogging: false
cacheDuration: Duration(minutes: 15)
```

---

## Data Validation Rules

### Account Validation
```dart
accountNameOwner:
  - Min length: 3
  - Max length: 40
  - Pattern: ^[a-z0-9_]+$ (lowercase alphanumeric + underscore only)
  - Converted to lowercase automatically

accountType:
  - Values: 'credit', 'debit'
  - Case insensitive

moniker:
  - Pattern: ^\d{4}$ (exactly 4 digits)
  - Example: '1234'

activeStatus:
  - Type: boolean
  - Default: true
```

### Transaction Validation
```dart
guid:
  - Pattern: UUID v4
  - Must be generated via /api/uuid/generate endpoint

accountNameOwner:
  - Same rules as Account.accountNameOwner

transactionDate:
  - Format: yyyy-MM-dd (LocalDate)
  - Must be valid date

description:
  - Min length: 1
  - Max length: 75
  - Pattern: ASCII characters only
  - Converted to lowercase

category:
  - Max length: 50
  - Pattern: ^[a-z0-9_]+$ (alphanumeric + underscore, no spaces)
  - Converted to lowercase

amount:
  - Type: Decimal(8,2)
  - Range: -99999999.99 to 99999999.99
  - Precision: 2 decimal places

transactionState:
  - Values: 'cleared', 'outstanding', 'future'
  - Case insensitive

transactionType:
  - Values: 'expense', 'income', 'transfer', 'undefined'
  - Case insensitive
  - Default: 'undefined'

reoccurringType:
  - Values: 'onetime', 'weekly', 'fortnightly', 'monthly', 'quarterly', 'bi_annually', 'annually'
  - Default: 'onetime'

notes:
  - Max length: 100
  - Pattern: ASCII characters only
  - Converted to lowercase
```

### Category Validation
```dart
categoryName:
  - Min length: 1
  - Max length: 255
  - Pattern: ^[a-zA-Z0-9 _-]+$ (alphanumeric + space + underscore + hyphen)
  - NOT converted to lowercase (preserves case)

activeStatus:
  - Type: boolean
  - Default: true
```

### Description Validation
```dart
descriptionName:
  - Min length: 1
  - Max length: 255
  - Pattern: ^[a-zA-Z0-9 _-]+$ (alphanumeric + space + underscore + hyphen)
  - NOT converted to lowercase (preserves case)

activeStatus:
  - Type: boolean
  - Default: true
```

---

## API Client Configuration

### HTTP Client Settings
```dart
connectTimeout: Duration(seconds: 30)
receiveTimeout: Duration(seconds: 30)
sendTimeout: Duration(seconds: 30)

headers:
  - Content-Type: application/json
  - Accept: application/json
  - Authorization: Bearer {token} (if using headers instead of cookies)

retryPolicy:
  - Max retries: 3
  - Retry on: 5xx errors, network errors
  - Backoff: Exponential (1s, 2s, 4s)
```

### Cookie Handling
For development, you may need to handle cookies manually:
```dart
// Option 1: Use dio_cookie_manager package
final cookieJar = CookieJar();
dio.interceptors.add(CookieManager(cookieJar));

// Option 2: Extract token from cookie and use Authorization header
// This is recommended for mobile apps
```

---

## Local Storage (Hive) Configuration

### Box Names
```dart
const String accountsBox = 'accounts';
const String transactionsBox = 'transactions';
const String categoriesBox = 'categories';
const String descriptionsBox = 'descriptions';
const String userBox = 'user';
const String authBox = 'auth';
```

### Type Adapters
```dart
Hive.registerAdapter(AccountAdapter());        // typeId: 0
Hive.registerAdapter(TransactionAdapter());    // typeId: 1
Hive.registerAdapter(CategoryAdapter());       // typeId: 2
Hive.registerAdapter(DescriptionAdapter());    // typeId: 3
Hive.registerAdapter(UserAdapter());           // typeId: 4
Hive.registerAdapter(AuthTokenAdapter());      // typeId: 5
```

---

## Routing Configuration

### Named Routes
```dart
const String loginRoute = '/login';
const String registerRoute = '/register';
const String accountsRoute = '/accounts';
const String accountDetailRoute = '/accounts/:accountNameOwner';
const String transactionsRoute = '/accounts/:accountNameOwner/transactions';
const String categoriesRoute = '/categories';
const String descriptionsRoute = '/descriptions';
const String settingsRoute = '/settings';
const String profileRoute = '/profile';
```

---

## Feature Flags

### MVP Features (Enabled)
```dart
const bool enableAccounts = true;
const bool enableTransactions = true;
const bool enableCategories = true;
const bool enableDescriptions = true;
const bool enableAuthentication = true;
const bool enableOfflineMode = true;
```

### Post-MVP Features (Disabled for now)
```dart
const bool enableTransfers = false;
const bool enablePayments = false;
const bool enableMedicalExpenses = false;
const bool enableTrends = false;
const bool enableDataImport = false;
const bool enableDataExport = false;
const bool enableReceiptImages = false;
const bool enablePushNotifications = false;
const bool enableBiometricAuth = false;
```

---

## Performance Targets

### App Performance
- **App startup time**: < 2 seconds
- **Screen transition**: 60 fps (16.67ms per frame)
- **API response time**: < 1 second for most operations
- **Offline availability**: Full read access to cached data

### Data Limits
- **Transaction page size**: 50 items
- **Account list**: Load all (typically < 100 accounts)
- **Category list**: Load all (typically < 200 categories)
- **Description list**: Load all (typically < 500 descriptions)
- **Cache expiration**: 15 minutes for production, 5 minutes for dev

---

## Security Configuration

### Secure Storage Keys
```dart
const String tokenKey = 'auth_token';
const String refreshTokenKey = 'refresh_token';
const String userIdKey = 'user_id';
const String usernameKey = 'username';
```

### TLS/SSL
- **Require HTTPS**: true (production)
- **Certificate pinning**: Consider implementing for production
- **Allow self-signed certs**: false (always)

---

## Analytics & Monitoring

### MVP: No Analytics
- No analytics for MVP
- Console logging in development
- No crash reporting for MVP

### Post-MVP: Consider
- Firebase Analytics
- Sentry for crash reporting
- Custom event tracking for user flows

---

## Build Configuration

### Android
```gradle
applicationId: "com.bhenning.finance"
minSdkVersion: 21
targetSdkVersion: 34
compileSdkVersion: 34

buildTypes:
  - debug
  - release

productFlavors:
  - development
  - production
```

### iOS
```yaml
Bundle Identifier: com.bhenning.finance
Deployment Target: iOS 13.0
Supported Devices: iPhone, iPad
Orientations: Portrait only (for MVP)
```

---

## Testing Configuration

### Unit Tests
- Coverage target: > 80%
- Focus areas: Repositories, Services, Validators

### Widget Tests
- Coverage target: > 60%
- Focus areas: Custom widgets, Forms, Lists

### Integration Tests
- Key user flows: Login, View Accounts, View Transactions, Add Transaction
- Target: All critical paths covered

---

## Continuous Integration

### Build Checks
- Flutter analyze (no errors)
- Unit tests pass
- Widget tests pass
- Build succeeds for both iOS and Android

### Code Quality
- No lint errors
- Follow Flutter/Dart style guide
- Code formatted with `dart format`

---

## App Metadata

### App Name
- **Display Name**: Finance
- **Package Name**: com.bhenning.finance

### Version
- **Initial Version**: 1.0.0
- **Build Number**: 1

### Description
A personal finance management app for tracking accounts, transactions, and budgets across multiple accounts.

### Keywords (for App Store)
finance, budget, transactions, money, accounts, expense tracker, personal finance

---

## Known Backend Behaviors

### Case Conversion
- `accountNameOwner`: Automatically converted to lowercase
- `description`: Automatically converted to lowercase
- `category`: Automatically converted to lowercase
- `notes`: Automatically converted to lowercase
- `categoryName`: Preserves case
- `descriptionName`: Preserves case

### Computed Fields
- Account totals (cleared, outstanding, future) are computed server-side
- Transaction totals are computed per account
- Global totals are computed across all accounts

### Unique Constraints
- `accountNameOwner` + `accountType` must be unique
- Transaction `guid` must be unique
- Category `categoryName` must be unique
- Description `descriptionName` must be unique

---

## Development Tools

### Recommended VS Code Extensions
- Dart
- Flutter
- Flutter Widget Snippets
- Awesome Flutter Snippets
- Error Lens
- GitLens

### Recommended IntelliJ/Android Studio Plugins
- Flutter
- Dart
- Rainbow Brackets
- Key Promoter X

---

## Git Configuration

### Branch Strategy
- `main`: Production-ready code
- `develop`: Development branch
- `feature/*`: Feature branches
- `fix/*`: Bug fix branches

### Commit Message Format
```
type(scope): subject

body (optional)

🤖 Generated with Claude Code (if applicable)
```

Types: feat, fix, docs, style, refactor, test, chore
