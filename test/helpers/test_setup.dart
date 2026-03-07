import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test setup utilities for MyGate application
class TestSetup {
  /// Create a test app wrapper with Material and necessary providers
  Widget createTestApp(Widget home) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.orange,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
      ),
      home: home,
    );
  }
}

/// Extension methods for WidgetTester to simplify common operations
extension WidgetTesterExtension on WidgetTester {
  /// Find and tap a button by text
  Future<void> tapButtonWithText(String text) async {
    await tap(find.byWidgetPredicate(
      (widget) =>
          widget is ElevatedButton &&
          widget.child is Text &&
          (widget.child as Text).data == text,
    ));
    await pumpAndSettle();
  }

  /// Find and enter text in a TextField
  Future<void> enterTextInField(String value, {int index = 0}) async {
    await tap(find.byType(TextField).at(index));
    await pump();
    await enterText(find.byType(TextField).at(index), value);
    await pump();
  }

  /// Wait and pump for async operations
  Future<void> pumpUntilFound(Finder finder,
      {Duration timeout = const Duration(seconds: 10)}) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    while (!finder.evaluate().isNotEmpty) {
      await pump(const Duration(milliseconds: 100));
      if (stopwatch.elapsed > timeout) {
        throw Exception('Did not find $finder in $timeout');
      }
    }
  }

  /// Verify a message is shown via SnackBar
  bool verifySnackBarMessage(String message) {
    try {
      expect(find.byType(SnackBar), findsWidgets);
      expect(find.text(message), findsWidgets);
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Utility for verifying dialog content
class DialogHelper {
  static Future<void> verifyDialogShown(
    WidgetTester tester,
    String title,
  ) async {
    expect(find.byType(AlertDialog), findsWidgets);
    expect(find.text(title), findsWidgets);
  }

  static Future<void> tapDialogButton(
    WidgetTester tester,
    String buttonText,
  ) async {
    final button = find.byWidgetPredicate(
      (widget) =>
          widget is TextButton &&
          widget.child is Text &&
          (widget.child as Text).data == buttonText,
    );
    expect(button, findsWidgets);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }
}
