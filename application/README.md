# core

Flutter app skeleton using `provider` with a simple feature-based structure:
fake authentication, a tabbed shell, profile loading, and theme settings.

## Requirements

- Flutter SDK (Dart `>=3.10.4`, per `pubspec.yaml`)

## Run

```bash
flutter pub get
flutter run
```

## Test / Lint

```bash
flutter test
flutter analyze
```

## App Flow

- Starts on **Login**
- **Sign in** navigates to a bottom-tab shell: **Home**, **Profile**, **Settings**
- **Profile** loads demo profile data
- **Settings** toggles theme mode and allows **Logout**

## Project Structure

- `lib/core/`: app theme, DI (`AppProviders`), global navigation keys
- `lib/features/<feature>/`: `models/`, `repositories/`, `services/`, `providers/`, `pages/`, `widgets/`

## Notes

- `FakeAuthRepository`, `FakeProfileRepository`, and `InMemorySettingsRepository` are placeholders; swap in real implementations for production.
- Settings are in-memory only (reset on restart) until a persistent `SettingsRepository` is implemented.
