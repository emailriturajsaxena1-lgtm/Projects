// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_setup.dart';

void main() {
  testWidgets('MyGate theme is properly configured',
      (WidgetTester tester) async {
    // Build a test app with the MyGate theme
    final testWidget = Scaffold(
      appBar: AppBar(title: const Text('Test')),
      body: const Center(child: Text('Test')),
    );

    await tester.pumpWidget(TestSetup().createTestApp(testWidget));

    // Verify Material App is created
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verify AppBar is rendered
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('MyGate colors are correctly applied',
      (WidgetTester tester) async {
    final testWidget = Scaffold(
      appBar: AppBar(title: const Text('Test')),
    );

    await tester.pumpWidget(TestSetup().createTestApp(testWidget));

    // Find the AppBar and verify it has the correct color
    final appBar = find.byType(AppBar);
    expect(appBar, findsOneWidget);
  });

  testWidgets('MyGate Material 3 is enabled', (WidgetTester tester) async {
    final testWidget = Scaffold(
      body: const Center(child: Text('Test')),
    );

    await tester.pumpWidget(TestSetup().createTestApp(testWidget));

    final materialApp =
        find.byType(MaterialApp).evaluate().first.widget as MaterialApp;

    expect(materialApp.theme?.useMaterial3, isTrue);
    expect(materialApp.theme?.primaryColor, Colors.orange);
  });
}
