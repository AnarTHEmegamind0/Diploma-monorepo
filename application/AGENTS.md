# AGENTS.md

This file defines how coding agents should work in this repository.

## Project Overview

- App name/package: `core`
- Stack: Flutter + Dart + `provider`
- Entry point: `lib/main.dart`
- Dependency wiring: `lib/core/di/app_providers.dart`
- App flow today:
  - Login
  - App shell tabs: Home, Profile, Settings

## Architecture Rules

- Use feature-first structure under `lib/features/<feature>/`.
- Keep cross-cutting/shared code in `lib/core/`.
- Use `package:core/...` imports (not relative imports across features).
- Prefer immutable models with `const` constructors and `final` fields.
- Keep dependency direction one-way:
  - `pages/widgets` -> `providers` -> `services` -> `repositories` -> `models`
- Repository contracts use `abstract interface class`.
- Provider classes use `ChangeNotifier`.

## Current Folder Structure

- `lib/core/`
  - `app_theme.dart`
  - `di/app_providers.dart`
  - `navigation/global_keys.dart`
- `lib/features/auth/`
  - `models/`, `repositories/`, `services/`, `providers/`, `pages/`, `widgets/`
- `lib/features/home/`
  - `pages/`
- `lib/features/profile/`
  - `models/`, `repositories/`, `services/`, `providers/`, `pages/`, `widgets/`
- `lib/features/settings/`
  - `models/`, `repositories/`, `services/`, `providers/`, `pages/`, `widgets/`
- `lib/features/shell/`
  - `pages/`, `service/`

## Naming Conventions

- File names: `snake_case.dart`
- Class names: `PascalCase`
- One primary class per file.
- Feature folder names: `snake_case` (example: `user_profile`)

## How To Create New Files In The Correct Structure

1. Choose feature and layer.
2. Create (or reuse) folders under `lib/features/<feature>/`.
3. Add files with matching names and layers.
4. Wire dependencies in `lib/core/di/app_providers.dart`.
5. Connect UI routes/shell only if required by the feature.
6. Add or update tests in `test/`.
7. Run `flutter analyze` and `flutter test`.

Use this command pattern for a new feature skeleton:

```bash
mkdir -p lib/features/<feature>/{models,repositories,services,providers,pages,widgets}
```

## Layer Templates

Model (`lib/features/<feature>/models/item.dart`):

```dart
class Item {
  const Item({required this.id});
  final String id;
}
```

Repository contract (`lib/features/<feature>/repositories/item_repository.dart`):

```dart
import 'package:core/features/<feature>/models/item.dart';

abstract interface class ItemRepository {
  Future<Item> fetch();
}
```

Service (`lib/features/<feature>/services/item_service.dart`):

```dart
import 'package:core/features/<feature>/models/item.dart';
import 'package:core/features/<feature>/repositories/item_repository.dart';

class ItemService {
  ItemService({required ItemRepository repository}) : _repository = repository;
  final ItemRepository _repository;
  Future<Item> fetch() => _repository.fetch();
}
```

Provider (`lib/features/<feature>/providers/item_provider.dart`):

```dart
import 'package:core/features/<feature>/models/item.dart';
import 'package:core/features/<feature>/services/item_service.dart';
import 'package:flutter/foundation.dart';

class ItemProvider extends ChangeNotifier {
  ItemProvider({required ItemService service}) : _service = service;
  final ItemService _service;

  bool _isLoading = false;
  String? _error;
  Item? _item;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Item? get item => _item;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _item = await _service.fetch();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

## Wiring Checklist For New Features

- Add repository provider in `AppProviders.build()`.
- Add service provider in `AppProviders.build()`.
- Add `ChangeNotifierProvider` for the feature provider.
- If UI entry is needed:
  - Add page in `pages/`.
  - Add reusable UI in `widgets/`.
  - Connect from shell or existing navigation flow.
- If feature state must persist, replace in-memory repositories with real persistence.

## Testing Guidelines

- Keep widget tests in `test/`.
- Add tests for:
  - provider state transitions (`loading/success/error`)
  - key user flows for page interactions
- Reuse existing pattern from `test/widget_test.dart` for app-level flow tests.

## Agent Guardrails

- Do not modify generated platform files unless task explicitly requires it.
- Avoid changing `android/`, `ios/`, `macos/`, `linux/`, `windows/` for feature work.
- Keep changes focused; do not refactor unrelated features.
- Validate with:
  - `flutter analyze`
  - `flutter test`
