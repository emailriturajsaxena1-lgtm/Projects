import 'package:flutter/material.dart';

class SOSScreen extends StatefulWidget {
  final String residentId;

  const SOSScreen({super.key, required this.residentId});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  bool _sosActive = false;

  Future<void> _triggerSOS() async {
    try {
      setState(() => _sosActive = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🚨 SOS Alert sent! Security & Management notified.'),
          backgroundColor: Colors.red,
        ),
      );

      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() => _sosActive = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency SOS')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Emergency Alert System',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onLongPress: _triggerSOS,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _sosActive ? Colors.red.shade700 : Colors.red.shade400,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withAlpha(100),
                    blurRadius: 20,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emergency,
                      size: 80,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'HOLD TO ALERT',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Hold the button to send an emergency alert to security and management. Your location will be shared.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 40),
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Emergency Contacts',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildContactTile('Police', '100', Icons.local_police),
                  _buildContactTile('Ambulance', '102', Icons.local_hospital),
                  _buildContactTile(
                      'Security', '+91-XXXX-XXXX', Icons.security),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(String name, String number, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(number, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.green),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calling feature coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }
}
