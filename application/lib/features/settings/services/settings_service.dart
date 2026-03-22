import 'package:core/features/settings/models/app_settings.dart';
import 'package:core/features/settings/repositories/settings_repository.dart';

class SettingsService {
  SettingsService({required SettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository;

  final SettingsRepository _settingsRepository;

  Future<AppSettings> read() => _settingsRepository.read();
  Future<void> write(AppSettings settings) => _settingsRepository.write(settings);
}

