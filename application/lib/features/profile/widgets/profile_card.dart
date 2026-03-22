import 'package:core/features/profile/models/profile.dart';
import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(profile.displayName),
        subtitle: Text(profile.email ?? profile.phone),
      ),
    );
  }
}
