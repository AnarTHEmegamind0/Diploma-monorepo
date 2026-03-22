# AGENTS.md — Flutter Mobile App

> **Inventory Audit Mobile Application**
>
> Part of: Image-Based Product Recognition & Automated Audit System

---

## Quick Facts

| Item | Value |
|------|-------|
| **Framework** | Flutter 3.x |
| **State Management** | Riverpod |
| **Navigation** | Go Router |
| **HTTP Client** | Dio |
| **Code Generation** | Freezed |
| **Entry Point** | `lib/main.dart` |
| **Package Name** | `core` |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        FLUTTER APP                               │
└─────────────────────────────────────────────────────────────────┘

┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│  Pages   │ → │ Providers│ → │ Services │ → │Repository│
│   (UI)   │   │  (State) │   │ (Logic)  │   │  (API)   │
└──────────┘   └──────────┘   └──────────┘   └──────────┘
                                                  │
                                           ┌──────▼──────┐
                                           │   Backend   │
                                           │   FastAPI   │
                                           └─────────────┘
```

---

## Directory Structure

```
lib/
├── main.dart                    # App entry point
│
├── core/                        # Shared across features
│   ├── app_theme.dart           # Theme configuration
│   ├── constants.dart           # App constants
│   ├── dio_client.dart          # HTTP client setup
│   ├── di/
│   │   └── app_providers.dart   # DI + Router setup
│   ├── navigation/
│   │   └── global_keys.dart     # Navigator keys
│   └── widgets/                 # Shared widgets
│       ├── neo_button.dart
│       ├── neo_card.dart
│       └── status_badge.dart
│
└── features/                    # Feature modules
    ├── auth/                    # Authentication
    │   ├── models/user.dart
    │   ├── repositories/
    │   │   ├── auth_repository.dart      # Interface
    │   │   ├── api_auth_repository.dart  # Real API
    │   │   └── fake_auth_repository.dart # Mock
    │   ├── services/auth_service.dart
    │   ├── providers/auth_provider.dart
    │   ├── pages/login_page.dart
    │   └── widgets/login_form.dart
    │
    ├── audit/                   # Main audit flow
    │   ├── models/
    │   │   ├── campaign.dart
    │   │   └── customer.dart
    │   ├── services/
    │   │   ├── audit_service.dart
    │   │   ├── fake_audit_service.dart
    │   │   └── location_service.dart
    │   ├── providers/audit_provider.dart
    │   └── pages/
    │       ├── campaign_page.dart
    │       ├── customer_page.dart
    │       ├── category_page.dart
    │       ├── image_page.dart      # Camera capture
    │       ├── map_page.dart
    │       └── thank_you_page.dart
    │
    ├── home/                    # Dashboard
    │   └── pages/home_page.dart
    │
    ├── history/                 # Past audits
    │   ├── models/audit_history_item.dart
    │   └── pages/history_page.dart
    │
    ├── profile/                 # User profile
    │   ├── models/profile.dart
    │   ├── repositories/
    │   ├── services/profile_service.dart
    │   ├── providers/profile_provider.dart
    │   └── pages/profile_page.dart
    │
    ├── settings/                # App settings
    │   ├── models/app_settings.dart
    │   ├── repositories/
    │   ├── services/settings_service.dart
    │   ├── providers/settings_provider.dart
    │   └── pages/settings_page.dart
    │
    └── shell/                   # Bottom nav shell
        ├── pages/app_shell_page.dart
        └── service/navigation_controller.dart
```

---

## Key Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App bootstrap |
| `lib/core/di/app_providers.dart` | All providers + GoRouter |
| `lib/core/dio_client.dart` | API base URL, interceptors |
| `lib/features/auth/providers/auth_provider.dart` | Auth state |
| `lib/features/audit/pages/image_page.dart` | Camera + detection |

---

## Layer Responsibilities

### Pages (UI)
- Display widgets
- Listen to providers
- Trigger provider methods
- NO business logic

### Providers (State)
- Extend `ChangeNotifier`
- Hold UI state (loading, error, data)
- Call services
- Notify listeners

### Services (Business Logic)
- Orchestrate operations
- Transform data
- Call repositories
- NO state

### Repositories (Data)
- API calls via Dio
- Database operations
- Return models
- Abstract interface + implementation

---

## Patterns

### Provider Example
```dart
class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthService service}) : _service = service;
  final AuthService _service;

  bool _isLoading = false;
  String? _error;
  User? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;

  Future<void> login(String phone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _service.login(phone, password);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### Repository Pattern
```dart
// Interface
abstract interface class AuthRepository {
  Future<User> login(String phone, String password);
}

// Implementation
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({required Dio dio}) : _dio = dio;
  final Dio _dio;

  @override
  Future<User> login(String phone, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'phone': phone,
      'password': password,
    });
    return User.fromJson(response.data);
  }
}
```

---

## Navigation (Go Router)

```dart
// Defined in app_providers.dart
GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => LoginPage()),
    ShellRoute(
      builder: (_, __, child) => AppShellPage(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => HomePage()),
        GoRoute(path: '/history', builder: (_, __) => HistoryPage()),
        GoRoute(path: '/profile', builder: (_, __) => ProfilePage()),
        GoRoute(path: '/settings', builder: (_, __) => SettingsPage()),
      ],
    ),
    // Audit flow
    GoRoute(path: '/campaigns', builder: (_, __) => CampaignPage()),
    GoRoute(path: '/customers', builder: (_, __) => CustomerPage()),
    GoRoute(path: '/categories', builder: (_, __) => CategoryPage()),
    GoRoute(path: '/capture', builder: (_, __) => ImagePage()),
  ],
)
```

---

## API Configuration

```dart
// lib/core/dio_client.dart
final dio = Dio(BaseOptions(
  baseUrl: 'http://localhost:8000/api',
  connectTimeout: Duration(seconds: 10),
  receiveTimeout: Duration(seconds: 10),
));

// Add auth interceptor
dio.interceptors.add(AuthInterceptor(tokenProvider: tokenProvider));
```

---

## Commands

```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Run on specific device
flutter run -d chrome     # Web
flutter run -d ios        # iOS simulator
flutter run -d android    # Android emulator

# Build
flutter build apk         # Android
flutter build ios         # iOS

# Code generation (Freezed)
dart run build_runner build --delete-conflicting-outputs

# Analyze
flutter analyze

# Test
flutter test
```

---

## Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter_riverpod: ^2.4.0   # State management
  go_router: ^13.0.0         # Navigation
  dio: ^5.4.0                # HTTP client
  freezed_annotation: ^2.4.0 # Code generation
  image_picker: ^1.0.0       # Camera
  geolocator: ^10.0.0        # GPS
  sqflite: ^2.3.0            # Local DB

dev_dependencies:
  freezed: ^2.4.0
  build_runner: ^2.4.0
  mocktail: ^1.0.0           # Mocking
```

---

## Audit Flow

```
1. Login → /login
      ↓
2. Home → /home
      ↓
3. Select Campaign → /campaigns
      ↓
4. Select Customer/Tradeshop → /customers
      ↓
5. Select Category → /categories
      ↓
6. Capture Image → /capture
      ↓
7. Backend Detection → API call
      ↓
8. Review Results
      ↓
9. Submit Audit
      ↓
10. Thank You → /thank-you
```

---

## Testing

```dart
// test/widget_test.dart
void main() {
  testWidgets('Login shows form', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginPage())),
    );

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Login'), findsOneWidget);
  });
}
```

---

## Agent Guidelines

### Do
- Follow feature-first structure
- Use abstract repositories for testability
- Keep providers focused (single responsibility)
- Use `const` constructors where possible

### Don't
- Put business logic in pages
- Import across features directly
- Modify platform files (android/, ios/) unless required
- Use relative imports across features

### When Adding New Feature
```bash
# Create structure
mkdir -p lib/features/new_feature/{models,repositories,services,providers,pages,widgets}

# Add to app_providers.dart
# Add route to GoRouter
```

---

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Files | snake_case | `auth_provider.dart` |
| Classes | PascalCase | `AuthProvider` |
| Variables | camelCase | `isLoading` |
| Constants | SCREAMING_SNAKE | `API_TIMEOUT` |
| Features | snake_case | `user_profile/` |

---

*Part of Inventory Audit System — МУИС 2026*
