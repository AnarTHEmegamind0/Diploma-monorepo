import 'package:core/features/auth/models/user.dart';

abstract interface class AuthRepository {
  Future<User> login({required String phone, required String password});
  Future<User?> restoreSession();
  Future<void> logout();
}
