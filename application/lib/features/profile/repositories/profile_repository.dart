import 'package:core/features/profile/models/profile.dart';

abstract interface class ProfileRepository {
  Future<Profile> fetchProfile();
}

