import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'core/services/supabase_service.dart';
import 'core/models/user_profile.dart';
import 'features/auth/authentication_screen.dart';
import 'features/dashboard/smart_dashboard_screen.dart';
import 'features/security/supervisor_dashboard_screen.dart';
import 'features/security/guard_gate_dashboard_screen.dart';
import 'features/resident/smart_dashboard_screen.dart';
import 'features/visitor/visitor_management_screen.dart';

final logger = Logger();

// 1. GLOBAL INITIALIZATION
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load();

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'YOUR_URL';
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'YOUR_KEY';

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  // Test connection
  final supabaseService = SupabaseService();
  final isConnected = await supabaseService.testConnection();
  if (isConnected) {
    logger.i('✅ Supabase connection successful!');
  } else {
    logger.w('⚠️ Supabase connection failed!');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gatelly',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example logic to determine user type
    final bool isResident = true; // Replace with actual logic

    return isResident
        ? const SmartDashboardScreen(userProfile: UserProfile(...))
        : const VisitorManagementScreen(userProfile: UserProfile(...));
  }
}

// 2. ROLE-BASED NAVIGATION - StreamBuilder for reactive auth
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // While loading auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Get current session
        final session = Supabase.instance.client.auth.currentSession;

        // No session = Show Login
        if (session == null) {
          return const AuthenticationScreen();
        }

        // Has session = Load user profile and show appropriate dashboard
        return FutureBuilder<UserProfile?>(
          future: SupabaseService().getOrCreateUserProfile(
            session.user.id,
            fallbackName: session.user.email?.split('@').first,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              logger.e('Error loading profile: ${snapshot.error}');
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error loading profile: ${snapshot.error}'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () =>
                            Supabase.instance.client.auth.signOut(),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final profile = snapshot.data;
            if (profile == null) {
              // Profile doesn't exist - redirect to login
              logger.w('Profile not found for user ${session.user.id}');
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'User profile not found.',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Your account exists but your profile is missing from the database.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'User ID: ${session.user.id}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () =>
                            Supabase.instance.client.auth.signOut(),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout & Try Again'),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'If this persists, contact admin.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Show appropriate dashboard based on role
            if (profile.role == UserRole.supervisor) {
              return SupervisorDashboardScreen(userProfile: profile);
            } else if (profile.role == UserRole.guard) {
              return GuardGateDashboardScreen(userProfile: profile);
            } else {
              return SmartDashboardScreen(userProfile: profile);
            }
          },
        );
      },
    );
  }
}
