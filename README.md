# Flutter Finance - Mobile App

A native mobile application (iOS/Android) for personal finance management, built with Flutter. This app connects to your existing Spring Boot backend at https://finance.bhenning.com.

---

## 📋 Project Overview

**Status:** Planning & Setup Phase
**Target Platforms:** iOS and Android
**Backend:** Spring Boot (Kotlin) - https://finance.bhenning.com/api
**State Management:** Riverpod
**Architecture:** Clean Architecture (Data/Domain/Presentation)

---

## 🎯 MVP Features

The initial version will include:

- ✅ **Authentication** - JWT-based login/logout
- ✅ **Account Management** - View, add, edit, delete accounts
- ✅ **Transaction Management** - Full CRUD operations, filtering, search
- ✅ **Categories** - Manage transaction categories
- ✅ **Descriptions** - Manage transaction descriptions
- ✅ **Offline Support** - Local caching with Hive
- ✅ **Dark Theme** - Matching your existing web app design

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [MIGRATION_PLAN.md](./MIGRATION_PLAN.md) | Comprehensive migration plan with phases, architecture, and timeline |
| [API_REFERENCE.md](./API_REFERENCE.md) | Complete API documentation for your Spring Boot backend |
| [PROJECT_CONFIG.md](./PROJECT_CONFIG.md) | All configuration details: theme, validation, environments |
| [QUICK_START.md](./QUICK_START.md) | Step-by-step guide to get started immediately |

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK >= 3.16.0
- Dart SDK >= 3.2.0
- Android Studio or Xcode
- Your Spring Boot backend running at https://finance.bhenning.com

### Setup

```bash
# 1. Create project (if not done)
flutter create flutter-finance --org com.bhenning
cd flutter-finance

# 2. Copy configuration from QUICK_START.md to pubspec.yaml

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run
```

**👉 See [QUICK_START.md](./QUICK_START.md) for detailed setup instructions.**

---

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── constants/        # App-wide constants
│   ├── theme/            # Dark theme matching web app
│   ├── utils/            # Utility functions
│   └── errors/           # Error handling
├── data/
│   ├── models/           # Freezed data models
│   ├── repositories/     # Repository implementations
│   └── data_sources/
│       ├── remote/       # API clients (Dio + Retrofit)
│       └── local/        # Hive local storage
├── domain/
│   ├── entities/         # Business entities
│   ├── repositories/     # Repository interfaces
│   └── use_cases/        # Business logic
└── presentation/
    ├── providers/        # Riverpod providers
    ├── screens/          # App screens
    │   ├── accounts/
    │   ├── transactions/
    │   ├── categories/
    │   └── auth/
    └── widgets/          # Reusable widgets
        ├── common/
        └── finance/
```

---

## 🎨 Design System

### Color Palette

**Dark Theme** (matching your web app):

- **Primary:** #3B82F6 (Bright Blue)
- **Secondary:** #10B981 (Emerald Green)
- **Background:** #0F172A (Very Dark Slate)
- **Surface:** #1E293B (Dark Slate)
- **Success:** #22C55E
- **Warning:** #F59E0B
- **Error:** #EF4444

**Typography:** Inter font family

---

## 🔐 Authentication

The app uses JWT token authentication with your Spring Boot backend:

1. User logs in via `/api/login`
2. JWT token received (stored securely)
3. Token sent with all API requests via `Authorization: Bearer <token>`
4. Token expires after 1 hour
5. User can logout via `/api/logout`

---

## 📱 Key Screens

### 1. Login Screen
- Username/password input
- JWT authentication
- Auto-login if token exists

### 2. Account List
- Grid/Table view toggle
- Search and filters
- Summary cards (Total, Cleared, Outstanding, Future)
- Pull-to-refresh

### 3. Transaction List (by Account)
- Filterable by state, type, date range
- Searchable
- State quick-toggle (cleared/outstanding/future)
- Add/Edit/Delete/Clone/Move operations

### 4. Categories & Descriptions
- CRUD operations
- Merge functionality
- Used for autocomplete in transactions

---

## 🛠️ Technology Stack

### Core
- **Flutter** - UI framework
- **Dart** - Programming language

### State Management
- **Riverpod** - State management with code generation

### Networking
- **Dio** - HTTP client
- **Retrofit** - Type-safe REST client

### Local Storage
- **Hive** - NoSQL database for offline caching
- **Flutter Secure Storage** - Secure token storage

### Code Generation
- **Freezed** - Immutable models
- **json_serializable** - JSON serialization
- **build_runner** - Code generation

### UI/UX
- **flutter_screenutil** - Responsive sizing
- **shimmer** - Loading skeletons
- **fl_chart** - Charts (future)
- **go_router** - Navigation

---

## 🗺️ Development Roadmap

### Phase 1: Setup (Week 1-2) ✅
- [x] Create project structure
- [x] Setup dependencies
- [x] Configure theme
- [x] Setup API client
- [ ] **YOU ARE HERE** 👈

### Phase 2: Authentication (Week 3-4)
- [ ] Login screen UI
- [ ] JWT token management
- [ ] Secure storage integration
- [ ] Auto-login
- [ ] Logout functionality

### Phase 3: Account Management (Week 5-6)
- [ ] Account list screen
- [ ] Account repository
- [ ] Riverpod providers
- [ ] Add/Edit/Delete accounts
- [ ] Search and filters

### Phase 4: Transaction Management (Week 7-9)
- [ ] Transaction list screen
- [ ] Transaction CRUD
- [ ] Filters and search
- [ ] State management
- [ ] Clone/Move operations

### Phase 5: Categories & Descriptions (Week 10)
- [ ] Category management
- [ ] Description management
- [ ] Autocomplete integration

### Phase 6: Testing & Polish (Week 11-12)
- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests
- [ ] Bug fixes
- [ ] Performance optimization

### Phase 7: Deployment
- [ ] App store assets
- [ ] Beta testing
- [ ] App Store submission
- [ ] Google Play submission

---

## 🧪 Testing Strategy

### Unit Tests
- Repositories
- Use cases
- Validators
- Utility functions

### Widget Tests
- Custom widgets
- Forms
- Lists
- Dialogs

### Integration Tests
- Login flow
- Account CRUD
- Transaction CRUD
- Offline mode

**Target Coverage:** 80%+ for critical paths

---

## 📦 Build & Deployment

### Development Build
```bash
flutter run --debug
```

### Release Build (Android)
```bash
flutter build apk --release
flutter build appbundle --release  # For Play Store
```

### Release Build (iOS)
```bash
flutter build ios --release
```

### Distribution
- **Android:** Google Play Console
- **iOS:** App Store Connect via TestFlight

---

## 🔧 Configuration

### Development
- API: https://finance.bhenning.com/api
- Logging: Enabled
- Cache: 5 minutes

### Production
- API: https://finance.bhenning.com/api
- Logging: Disabled
- Cache: 15 minutes

See [PROJECT_CONFIG.md](./PROJECT_CONFIG.md) for complete configuration details.

---

## 🐛 Known Issues & Limitations

### MVP Limitations
- No push notifications
- No biometric authentication
- No data export/import
- No receipt image upload
- No trends/analytics
- Portrait orientation only

### Post-MVP Features
See [MIGRATION_PLAN.md](./MIGRATION_PLAN.md) Phase 8 for planned enhancements.

---

## 📖 API Documentation

Your Spring Boot backend provides these key endpoints:

**Authentication:**
- `POST /api/login` - Login
- `POST /api/logout` - Logout
- `GET /api/me` - Current user

**Accounts:**
- `GET /api/account/active` - List accounts
- `POST /api/account` - Create account
- `PUT /api/account/{id}` - Update account
- `DELETE /api/account/{id}` - Delete account
- `GET /api/account/totals` - Get totals

**Transactions:**
- `GET /api/transaction/account/select/{accountNameOwner}` - List transactions
- `POST /api/transaction` - Create transaction
- `PUT /api/transaction/{guid}` - Update transaction
- `DELETE /api/transaction/{guid}` - Delete transaction

**Full API documentation:** [API_REFERENCE.md](./API_REFERENCE.md)

---

## 🤝 Contributing

### Code Style
- Follow Dart/Flutter style guide
- Use `dart format` before committing
- Run `flutter analyze` to catch issues

### Commit Messages
```
type(scope): subject

🤖 Generated with Claude Code
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

---

## 📝 License

[Your License Here]

---

## 🙋 Support

For questions or issues:
1. Check the documentation files
2. Review existing Next.js implementation
3. Consult Flutter official docs
4. Open an issue on GitHub

---

## 🎯 Success Criteria

The MVP will be considered complete when:

- ✅ User can authenticate
- ✅ User can view all accounts with totals
- ✅ User can add/edit/delete accounts
- ✅ User can view transactions by account
- ✅ User can add/edit/delete transactions
- ✅ User can filter and search transactions
- ✅ App works offline with cached data
- ✅ App maintains 60fps performance
- ✅ All critical paths are tested
- ✅ App is deployed to TestFlight and Play Console

---

## 🚀 Getting Started

**Ready to start?** Follow the [QUICK_START.md](./QUICK_START.md) guide!

---

**Built with ❤️ using Flutter**

Backend: Spring Boot (Kotlin) • Frontend: Flutter • State: Riverpod • Storage: Hive
