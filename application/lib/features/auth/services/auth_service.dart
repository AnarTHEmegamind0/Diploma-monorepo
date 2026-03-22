import 'package:core/features/auth/models/user.dart';
import 'package:core/features/auth/repositories/auth_repository.dart';

class AuthService {
  AuthService({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  Future<User> login({required String phone, required String password}) {
    return _authRepository.login(phone: phone, password: password);
  }

  Future<User?> restoreSession() => _authRepository.restoreSession();
  Future<void> logout() => _authRepository.logout();
}
