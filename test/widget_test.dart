// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:life_vault/main.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LifeVaultApp());

    // Verify that the splash screen shows the App Name.
    expect(find.text('LifeVault'), findsOneWidget);
    
    // We can't easily wait for the 3.5s timer in a simple pumpWidget test without pumping specific durations,
    // but verifying the splash screen rendering is enough for a smoke test.
  });
}
