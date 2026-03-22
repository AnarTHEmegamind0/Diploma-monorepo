import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:core/core/di/app_providers.dart';
import 'package:core/main.dart';

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
}
