import 'package:core/features/profile/models/profile.dart';
import 'package:core/features/profile/services/profile_service.dart';
import 'package:flutter/foundation.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({required ProfileService profileService})
    : _profileService = profileService;

  final ProfileService _profileService;

  bool _isLoading = false;
  String? _error;
  Profile? _profile;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Profile? get profile => _profile;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _profileService.fetchProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

