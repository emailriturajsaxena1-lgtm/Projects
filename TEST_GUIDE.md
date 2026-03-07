# MyGate Testing Guide

## Overview

This guide explains how to test your MyGate Flutter application. The test suite includes unit tests, widget tests, and integration tests.

## Quick Start

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/unit/models_test.dart
```

### Run Tests with Verbose Output
```bash
flutter test --verbose
```

### Run Tests and Generate Coverage Report
```bash
flutter test --coverage
```

## Test Structure

```
test/
├── helpers/
│   ├── mock_supabase.dart        # Supabase mocking utilities
│   └── test_setup.dart           # Test setup and extensions
├── unit/
│   ├── models_test.dart          # Model unit tests (Society, Unit, VisitorManagement)
│   └── service_logic_test.dart   # Business logic tests
├── widget/
│   └── auth_screen_test.dart     # Authentication screen widget tests
└── widget_test.dart              # General widget and theme tests
```

## Test Categories

### 1. Unit Tests (test/unit/)

**models_test.dart**: Tests for data models
- Society model serialization/deserialization
- Unit model string representations
- VisitorManagement model logic (status, duration, transitions)
- copyWith method behavior

**service_logic_test.dart**: Tests for business logic
- Status transitions
- Duration calculations
- Visitor state checks

Run unit tests:
```bash
flutter test test/unit/
```

### 2. Widget Tests (test/widget/)

**auth_screen_test.dart**: Tests for authentication UI
- Email/phone login form rendering
- Form field validation
- Navigation between screens
- User input handling
- Theme application

**widget_test.dart**: General app structure tests
- Theme configuration
- Material 3 setup
- Color scheme

Run widget tests:
```bash
flutter test test/widget/
```

### 3. Test Helpers (test/helpers/)

**mock_supabase.dart**: Mocking utilities
- MockSupabaseClient for service testing
- Mock user/session creation
- Mock storage and auth clients

**test_setup.dart**: Test utilities
- TestSetup class for app creation
- WidgetTesterExtension for common operations
- DialogHelper for dialog testing

## Running Tests by Category

### Run Only Model Tests
```bash
flutter test test/unit/models_test.dart
```

### Run Only Authentication Tests
```bash
flutter test test/widget/auth_screen_test.dart
```

### Run All Unit Tests
```bash
flutter test test/unit/
```

### Run All Widget Tests
```bash
flutter test test/widget/
```

## Test Naming Convention

Tests follow this naming pattern:
- **Unit Tests**: `[ClassName] [Method/Feature] [Expected Behavior]`
  - Example: `Society.toJson converts instance correctly`
  
- **Widget Tests**: `[ScreenName] [Action] [Expected Result]`
  - Example: `AuthenticationScreen renders email login form initially`

## Example Test Cases

### Unit Test Example
```dart
test('Society.fromJson creates instance correctly', () {
  final json = {
    'id': 'soc_001',
    'name': 'Spring Valley',
    'config': {'towers': 3}
  };

  final society = Society.fromJson(json);

  expect(society.id, 'soc_001');
  expect(society.name, 'Spring Valley');
  expect(society.config, {'towers': 3});
});
```

### Widget Test Example
```dart
testWidgets('Can tap "Login with Phone Number" button',
    (WidgetTester tester) async {
  await tester.pumpWidget(
    TestSetup.createTestApp(const AuthenticationScreen()),
  );

  await tester.tap(find.text('Login with Phone Number'));
  await tester.pumpAndSettle();

  expect(find.text('Login with Phone'), findsOneWidget);
});
```

## Mocking Supabase

Since tests don't initialize actual Supabase, use mock services:

```dart
import 'test/helpers/mock_supabase.dart';

final mockClient = MockSupabaseHelper.createMockSupabaseClient();
final mockUser = MockSupabaseHelper.createMockUser(
  id: 'user_123',
  email: 'test@example.com',
);
```

## Common Test Commands

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run with specific pattern
flutter test --name "Society"

# Run in verbose mode
flutter test --verbose

# Generate test report
flutter test --file-reporter=json:test-results.json

# Watch mode (reruns tests on file changes)
flutter test --watch

# Run specific test group
flutter test test/unit/models_test.dart --name "Society Model"
```

## Coverage Reports

After running tests with coverage:
```bash
# Generate coverage report
flutter test --coverage

# View coverage (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Fixing Failed Tests

1. **Check console output** for specific failure reason
2. **Run test in verbose mode**: `flutter test --verbose test/widget/auth_screen_test.dart`
3. **Verify mocks are set up correctly** in helper files
4. **Check for timing issues** with `pumpAndSettle()` or `pump(Duration)`

## Best Practices

✅ **Do:**
- Use descriptive test names
- Test one thing per test
- Use meaningful assertions
- Mock external dependencies
- Use test helpers for common operations
- Keep tests focused and small

❌ **Don't:**
- Make tests dependent on each other
- Test implementation details
- Use magic numbers without explanation
- Skip tests - mark with `@Skip` instead

## Adding New Tests

1. Create test file in appropriate directory (unit/ or widget/)
2. Use consistent naming pattern
3. Import test helpers: `import '../helpers/test_setup.dart';`
4. Follow group structure:
   ```dart
   void main() {
     group('[Feature Name] Tests', () {
       setUp(() {
         // Setup code
       });

       test('[Specific test]', () {
         // Test code
       });
     });
   }
   ```

## Test Coverage Goals

- **Models**: 90%+ coverage
- **Core Services**: 80%+ coverage
- **UI Screens**: 60%+ coverage (basic validation)
- **Business Logic**: 85%+ coverage

## Troubleshooting

### Tests fail with "Supabase not initialized"
- Solution: Tests use mock Supabase, not real initialization
- Check: Are you importing correct mock helpers?

### WidgetTester timeout errors
- Solution: Add more `pump()` or `pumpAndSettle()` calls
- Use: `pumpUntilFound()` for delayed widgets

### TextField not found in tests
- Solution: Make sure you're using correct find patterns
- Example: `find.byType(TextField).first` for first field

## Continuous Integration

Add to CI/CD pipeline:
```bash
flutter test --coverage
flutter test --file-reporter=json:test-results.json
```

## Resources

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Mockito Package](https://pub.dev/packages/mockito)
- [Widget Testing Guide](https://flutter.dev/docs/testing/widget-test-introduction)
