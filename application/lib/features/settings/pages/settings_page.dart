import 'package:core/features/auth/providers/auth_provider.dart';
import 'package:core/features/settings/providers/settings_provider.dart';
import 'package:core/features/settings/widgets/theme_mode_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select(
      (SettingsProvider p) => p.settings.themeMode,
    );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ThemeModePicker(
            value: themeMode,
            onChanged: context.read<SettingsProvider>().setThemeMode,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: context.read<AuthProvider>().logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
