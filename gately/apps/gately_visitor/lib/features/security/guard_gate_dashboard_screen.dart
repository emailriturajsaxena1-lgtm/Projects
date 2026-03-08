import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:gately_core/gately_core.dart';

final logger = Logger();

class GuardGateDashboardScreen extends StatefulWidget {
  final UserProfile userProfile;

  const GuardGateDashboardScreen({super.key, required this.userProfile});

  @override
  State<GuardGateDashboardScreen> createState() =>
      _GuardGateDashboardScreenState();
}

class _GuardGateDashboardScreenState extends State<GuardGateDashboardScreen> {
  late UserProfile _userProfile;
  final _supabaseService = SupabaseService();
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _userProfile = widget.userProfile;
    logger.i('Guard Gate dashboard loaded for: ${_userProfile.fullName}');
  }

  Future<void> _handleLogout() async {
    try {
      await _supabaseService.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gately - Tower Gate'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon!')),
                ),
                child: const Text('Settings'),
              ),
              PopupMenuItem(
                onTap: _handleLogout,
                child: const Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: _selectedNavIndex == 0
          ? _buildGateScreen()
          : _buildRecentEntriesScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) => setState(() => _selectedNavIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_2),
            label: 'Gate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSOSAlert,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.emergency_share),
        label: const Text('SOS'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildGateScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          size: 32, color: Colors.blue.shade600),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'On Duty',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _userProfile.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Shift: 6:00 AM - 2:00 PM',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Scan Entry/Exit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.blue.shade300,
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code,
                          size: 80, color: Colors.blue.shade600),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _scanQR,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Tap to Scan QR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.person_add,
                    label: 'Manual Entry',
                    onTap: _manualEntry,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.exit_to_app,
                    label: 'Manual Exit',
                    onTap: _manualExit,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEntriesScreen() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        final names = [
          'Rajesh Kumar', 'Priya Sharma', 'Ahmed Hassan', 'Amit Patel',
          'Sarah Khan', 'John Doe', 'Maria Garcia', 'David Chen',
        ];
        final purposes = ['Delivery', 'Guest', 'Contractor', 'Maid', 'Visitor'];

        return Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.person, color: Colors.blue.shade600),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        names[index % names.length],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        purposes[index % purposes.length],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${(index + 1) * 30} mins ago',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: index % 2 == 0
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    index % 2 == 0 ? Icons.login : Icons.logout,
                    color: index % 2 == 0 ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
            borderRadius: BorderRadius.circular(12),
            color: color.withValues(alpha: 0.05),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scanQR() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Scanner - Coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _manualEntry() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Entry Log'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Visitor Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: 'Purpose',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: ['Delivery', 'Guest', 'Contractor', 'Maid', 'Other']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Entry logged successfully!')),
              );
            },
            child: const Text('Log Entry'),
          ),
        ],
      ),
    );
  }

  void _manualExit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Manual Exit logged'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSOSAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send SOS Alert?'),
        content: const Text(
          'This will notify the Security Supervisor immediately. Use only in emergencies.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SOS Alert sent to Supervisor!'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );
  }
}
