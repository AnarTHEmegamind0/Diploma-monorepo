import 'package:flutter/material.dart';

class ThemeModePicker extends StatelessWidget {
  const ThemeModePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ThemeMode>(
      decoration: const InputDecoration(labelText: 'Theme'),
      initialValue: value,
      items: const [
        DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
        DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
        DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
      ],
      onChanged: (mode) {
        if (mode == null) return;
        onChanged(mode);
      },
    );
  }
}
