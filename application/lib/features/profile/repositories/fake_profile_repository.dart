import 'package:core/features/profile/models/profile.dart';
import 'package:core/features/profile/repositories/profile_repository.dart';

class FakeProfileRepository implements ProfileRepository {
  @override
  Future<Profile> fetchProfile() async {
    return const Profile(
      displayName: 'Demo User',
      email: 'demo@demo.com',
      phone: '88000000',
      groupName: 'Улаанбаатар - Төв',
      roleLabel: 'Аудитор',
    );
  }
}
