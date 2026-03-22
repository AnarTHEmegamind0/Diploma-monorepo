import 'package:core/features/auth/models/user.dart';
import 'package:core/features/auth/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<User> login({required String phone, required String password}) async {
    return User(
      id: 'user_1',
      phone: phone,
      email: 'demo@inventory.mn',
      name: 'Demo Auditor',
      token: 'fake-token',
      groupName: 'Улаанбаатар - Төв',
    );
  }

  @override
  Future<User?> restoreSession() async => null;

  @override
  Future<void> logout() async {}
}
