import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banking_dashboard/main.dart';
import 'package:banking_dashboard/providers/bank_provider.dart';

void main() {
  testWidgets('Dashboard loads and tabs work on mobile', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ChangeNotifierProvider(create: (_) => BankProvider(), child: const NovaBankApp()));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Transactions').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Analytics').last);
    await tester.pumpAndSettle();

  });
}
