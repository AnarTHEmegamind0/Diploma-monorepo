import 'package:core/features/settings/models/app_settings.dart';

abstract interface class SettingsRepository {
  Future<AppSettings> read();
  Future<void> write(AppSettings settings);
}

