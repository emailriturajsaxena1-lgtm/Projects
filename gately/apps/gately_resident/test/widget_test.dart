import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gately_resident/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GatelyResidentApp());

    // Verify that the login screen shows up.
    expect(find.text('Login with Email'), findsOneWidget);
    expect(find.text('Login with Phone Number'), findsOneWidget);
  });
}
