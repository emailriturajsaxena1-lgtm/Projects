import 'package:flutter/material.dart';
import 'package:mygate_clone/core/models/user_profile.dart';

class SmartDashboardScreen extends StatelessWidget {
  final UserProfile userProfile;

  const SmartDashboardScreen({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Dashboard')),
      body: Center(
        child: Text('Welcome ${userProfile.fullName}'),
      ),
    );
  }
}
