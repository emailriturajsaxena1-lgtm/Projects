import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Mock classes for Supabase testing
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockAuthClient extends Mock implements GoTrueClient {}

class MockRealtimeClient extends Mock implements RealtimeClient {}

class MockStorageClient extends Mock implements SupabaseStorageClient {}

class MockStorageBucket extends Mock {}

class MockPostgrestBuilder extends Mock implements PostgrestQueryBuilder {}

class MockPostgrestResponse extends Mock implements List {}

class MockUser extends Mock implements User {}

class MockSession extends Mock implements Session {}

class MockAuthState extends Mock implements AuthState {}

/// Setup mock Supabase instance for testing
class MockSupabaseHelper {
  static MockSupabaseClient createMockSupabaseClient() {
    final mockClient = MockSupabaseClient();
    final mockAuth = MockAuthClient();
    final mockStorage = MockStorageClient();

    // Mock auth client
    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(null);
    when(() => mockAuth.currentSession).thenReturn(null);

    // Mock storage client
    when(() => mockClient.storage).thenReturn(mockStorage);

    return mockClient;
  }

  static MockUser createMockUser({
    required String id,
    String? email,
    String? phone,
  }) {
    final mockUser = MockUser();
    when(() => mockUser.id).thenReturn(id);
    when(() => mockUser.email).thenReturn(email);
    when(() => mockUser.phone).thenReturn(phone);
    return mockUser;
  }

  static MockSession createMockSession(MockUser user) {
    final mockSession = MockSession();
    when(() => mockSession.user).thenReturn(user);
    when(() => mockSession.accessToken).thenReturn('mock_token_12345');
    return mockSession;
  }
}
