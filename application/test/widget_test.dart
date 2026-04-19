import 'package:core/features/auth/pages/login_page.dart';
import 'package:core/features/auth/models/user.dart';
import 'package:core/features/auth/providers/auth_provider.dart';
import 'package:core/features/auth/repositories/auth_repository.dart';
import 'package:core/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:core/core/di/app_providers.dart';
import 'package:core/main.dart';

class FailingAuthRepository implements AuthRepository {
  @override
  Future<User> login({required String phone, required String password}) async {
    throw Exception('Unauthorized');
  }

  @override
  Future<void> logout() async {}

  @override
  Future<User?> restoreSession() async => null;
}

void main() {
  testWidgets('Login and tab navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: AppProviders.build(useMocks: true),
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('QSF Audit'), findsOneWidget);

    await tester.tap(find.text('Нэвтрэх'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Сайн уу,'), findsOneWidget);
    expect(find.text('Идэвхтэй кампанит ажлууд'), findsOneWidget);

    await tester.tap(find.text('Профайл'));
    await tester.pumpAndSettle();
    expect(find.text('Профайл'), findsWidgets);
    expect(find.text('Гарах'), findsOneWidget);

    await tester.ensureVisible(find.text('Гарах'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Гарах'));
    await tester.pumpAndSettle();
    expect(find.text('QSF Audit'), findsOneWidget);
  });

  testWidgets('Shows auth failure modal on login error', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthRepository>(create: (_) => FailingAuthRepository()),
          Provider<AuthService>(
            create: (context) => AuthService(authRepository: context.read()),
          ),
          ChangeNotifierProvider<AuthProvider>(
            create: (context) => AuthProvider(authService: context.read()),
          ),
        ],
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    await tester.tap(find.text('Нэвтрэх'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Нэвтрэх үйлдэл амжилтгүй боллоо'), findsOneWidget);
  });
}
