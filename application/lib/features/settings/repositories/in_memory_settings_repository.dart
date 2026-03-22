import 'package:core/features/settings/models/app_settings.dart';
import 'package:core/features/settings/repositories/settings_repository.dart';
import 'package:flutter/material.dart';

class InMemorySettingsRepository implements SettingsRepository {
  AppSettings _settings = const AppSettings(themeMode: ThemeMode.system);

  @override
  Future<AppSettings> read() async => _settings;

  @override
  Future<void> write(AppSettings settings) async {
    _settings = settings;
  }
}

