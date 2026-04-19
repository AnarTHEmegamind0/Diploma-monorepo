import 'package:core/features/auth/models/user.dart';
import 'package:core/features/auth/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  static const loginFailedMessage = 'Нэвтрэх үйлдэл амжилтгүй боллоо';

  AuthProvider({required AuthService authService}) : _authService = authService;

  final AuthService _authService;

  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  User? _user;

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  User? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<void> restoreSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.restoreSession();
    } catch (_) {
      _user = null;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> login({required String phone, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.login(phone: phone, password: password);
    } catch (_) {
      _user = null;
      _error = loginFailedMessage;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  void clearError() {
    if (_error == null) {
      return;
    }
    _error = null;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }
}
