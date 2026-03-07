import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mygate_clone/features/auth/authentication_screen.dart';
import '../helpers/test_setup.dart';

void main() {
  group('Widget Tests - Authentication Screen', () {
    testWidgets('AuthenticationScreen renders with basic structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestSetup().createTestApp(const AuthenticationScreen()),
      );

      // Verify main widgets are present
      expect(find.byType(AuthenticationScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('AuthenticationScreen shows MyGate branding',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestSetup().createTestApp(const AuthenticationScreen()),
      );

      // Verify branding is shown
      expect(find.text('MyGate'), findsOneWidget);
      expect(find.text('Society Management Made Easy'), findsOneWidget);
    });

    testWidgets('Email login screen shows required fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestSetup().createTestApp(const AuthenticationScreen()),
      );

      // Verify text fields exist
      expect(find.byType(TextField), findsWidgets);

      // Verify hint texts
      expect(find.text('Enter email'), findsOneWidget);
      expect(find.text('Enter password'), findsOneWidget);
    });

    testWidgets('Email login button is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestSetup().createTestApp(const AuthenticationScreen()),
      );

      // Verify login button
      expect(find.text('Login with Email'), findsOneWidget);
    });

    testWidgets('Phone login option is accessible',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestSetup().createTestApp(const AuthenticationScreen()),
      );

      // Verify phone login button exists
      expect(find.text('Login with Phone Number'), findsOneWidget);
    });

    testWidgets('TextField accepts email input', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestSetup().createTestApp(const AuthenticationScreen()),
      );

      // Find first text field (email)
      final emailField = find.byType(TextField).first;

      // Enter text
      await tester.tap(emailField);
      await tester.pump();
      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();

      // Verify text was entered
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Can switch to phone login', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestSetup().createTestApp(const AuthenticationScreen()),
      );

      // Verify in email login initially
      expect(find.text('Login with Email'), findsOneWidget);

      // Tap phone login button
      await tester.tap(find.text('Login with Phone Number'));
      await tester.pumpAndSettle();

      // Verify we're in phone login (should have Send OTP button)
      expect(find.text('Send OTP'), findsOneWidget);
    });

    testWidgets('Can access Sign Up from login', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestSetup().createTestApp(const AuthenticationScreen()),
      );

      // Find and tap Sign Up button
      final signUpButtons = find.text('Sign Up');
      if (signUpButtons.evaluate().isNotEmpty) {
        await tester.tap(signUpButtons.first);
        await tester.pumpAndSettle();

        // Verify Create Account text appears in signup
        expect(find.text('Create Account'), findsOneWidget);
      }
    });

    testWidgets('Login button is visible and enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestSetup().createTestApp(const AuthenticationScreen()),
      );

      final loginButton = find.byType(ElevatedButton).first;
      expect(loginButton, findsOneWidget);

      // Button should be enabled
      final button = tester.widget<ElevatedButton>(loginButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Theme colors are applied correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestSetup().createTestApp(const AuthenticationScreen()),
      );

      // Verify orange branding color is used
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
      expect(materialApp.theme!.primaryColor, Colors.orange);
    });

    testWidgets('Sign Up link is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestSetup().createTestApp(const AuthenticationScreen()),
      );

      // Verify Sign Up link exists
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('AuthenticationScreen has app logo',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestSetup().createTestApp(const AuthenticationScreen()),
      );

      // Verify logo icon is present
      expect(find.byIcon(Icons.gps_fixed), findsOneWidget);
    });
  });
}
