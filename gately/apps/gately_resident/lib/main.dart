import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'package:gately_core/gately_core.dart';
import 'features/auth/authentication_screen.dart';
import 'features/dashboard/smart_dashboard_screen.dart';

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'YOUR_URL';
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'YOUR_KEY';

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  final supabaseService = SupabaseService();
  final isConnected = await supabaseService.testConnection();
  if (isConnected) {
    logger.i('✅ Supabase connection successful!');
  } else {
    logger.w('⚠️ Supabase connection failed!');
  }

  runApp(const GatelyResidentApp());
}

class GatelyResidentApp extends StatelessWidget {
  const GatelyResidentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gately Resident',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = Supabase.instance.client.auth.currentSession;

        if (session == null) {
          return const AuthenticationScreen();
        }

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
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('User profile not found.',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () =>
                            Supabase.instance.client.auth.signOut(),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout & Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SmartDashboardScreen(userProfile: profile);
          },
        );
      },
    );
  }
}
