import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:core/features/audit/providers/audit_provider.dart';
import 'package:core/features/audit/services/audit_service.dart';
import 'package:core/features/audit/services/fake_audit_service.dart';
import 'package:core/features/audit/services/location_service.dart';
import 'package:core/features/auth/providers/auth_provider.dart';
import 'package:core/features/auth/repositories/auth_repository.dart';
import 'package:core/features/auth/repositories/api_auth_repository.dart';
import 'package:core/features/auth/repositories/fake_auth_repository.dart';
import 'package:core/features/auth/services/auth_service.dart';
import 'package:core/features/profile/providers/profile_provider.dart';
import 'package:core/features/profile/repositories/api_profile_repository.dart';
import 'package:core/features/profile/repositories/fake_profile_repository.dart';
import 'package:core/features/profile/repositories/profile_repository.dart';
import 'package:core/features/profile/services/profile_service.dart';
import 'package:core/features/settings/providers/settings_provider.dart';
import 'package:core/features/settings/repositories/in_memory_settings_repository.dart';
import 'package:core/features/settings/repositories/settings_repository.dart';
import 'package:core/features/settings/services/settings_service.dart';
import 'package:core/features/shell/service/navigation_controller.dart';

class AppProviders {
  static List<SingleChildWidget> build({bool useMocks = false}) {
    return [
      // ── Auth ──
      Provider<AuthRepository>(
        create: (_) => useMocks ? FakeAuthRepository() : ApiAuthRepository(),
      ),
      Provider<AuthService>(
        create: (context) => AuthService(authRepository: context.read()),
      ),
      ChangeNotifierProvider<AuthProvider>(
        create: (context) =>
            AuthProvider(authService: context.read())..restoreSession(),
      ),

      // ── Profile ──
      Provider<ProfileRepository>(
        create: (_) =>
            useMocks ? FakeProfileRepository() : ApiProfileRepository(),
      ),
      Provider<ProfileService>(
        create: (context) => ProfileService(profileRepository: context.read()),
      ),
      ChangeNotifierProvider<ProfileProvider>(
        create: (context) => ProfileProvider(profileService: context.read()),
      ),

      // ── Settings ──
      Provider<SettingsRepository>(create: (_) => InMemorySettingsRepository()),
      Provider<SettingsService>(
        create: (context) =>
            SettingsService(settingsRepository: context.read()),
      ),
      ChangeNotifierProvider<SettingsProvider>(
        create: (context) =>
            SettingsProvider(settingsService: context.read())..load(),
      ),

      // ── Navigation ──
      ChangeNotifierProvider(create: (_) => NavigationController()),

      // ── Audit ──
      Provider<AuditService>(
        create: (_) => useMocks ? FakeAuditService() : AuditService(),
      ),
      Provider<LocationService>(create: (_) => LocationService()),
      ChangeNotifierProvider<AuditProvider>(
        create: (context) =>
            AuditProvider(
              auditService: context.read<AuditService>(),
              locationService: context.read<LocationService>(),
            ),
      ),
    ];
  }
}
