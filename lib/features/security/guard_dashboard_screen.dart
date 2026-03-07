import 'package:flutter/material.dart';

class GuardDashboardScreen extends StatelessWidget {
  const GuardDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guard Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logout feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Guard Status'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'ON DUTY',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.check_circle,
                        size: 60,
                        color: Colors.green.shade400,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildActionCard(
                    context,
                    Icons.qr_code_scanner,
                    'QR Checkpoint',
                    'Scan checkpoint QR',
                    () => _showFeatureDialog(context, 'QR Checkpoint'),
                  ),
                  _buildActionCard(
                    context,
                    Icons.person_add,
                    'Log Visitor',
                    'Register entry/exit',
                    () => _showFeatureDialog(context, 'Log Visitor'),
                  ),
                  _buildActionCard(
                    context,
                    Icons.security,
                    'Patrols',
                    'Start patrol round',
                    () => _showFeatureDialog(context, 'Patrols'),
                  ),
                  _buildActionCard(
                    context,
                    Icons.warning_amber,
                    'Alerts',
                    'View incidents',
                    () => _showFeatureDialog(context, 'Alerts'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Recent Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildActivityLog('Visitor logged: Delivery personnel', '14:32'),
              _buildActivityLog('Checkpoint A: Patrol completed', '13:45'),
              _buildActivityLog(
                  'Security: Unauthorized entry attempt', '12:10'),
              _buildActivityLog('Visitor approved: Guest entry', '11:20'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.orange),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityLog(String activity, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.history, color: Colors.orange),
        title: Text(activity),
        trailing: Text(time, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }

  void _showFeatureDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('Feature under development. Coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
