import 'package:core/features/profile/models/profile.dart';
import 'package:core/features/profile/repositories/profile_repository.dart';

class ProfileService {
  ProfileService({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository;

  final ProfileRepository _profileRepository;

  Future<Profile> fetchProfile() => _profileRepository.fetchProfile();
}

