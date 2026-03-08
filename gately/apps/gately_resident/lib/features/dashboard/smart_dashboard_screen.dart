import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:gately_core/gately_core.dart';
import '../payments/payments_screen.dart';
import '../community/helpdesk_screen.dart';
import '../community/community_pulse_screen.dart';
import '../security/sos_screen.dart';
import '../services/services_screen.dart';
import '../accounts/accounts_screen.dart';
import '../profile/profile_screen.dart';

final logger = Logger();

class SmartDashboardScreen extends StatefulWidget {
  final UserProfile userProfile;

  const SmartDashboardScreen({super.key, required this.userProfile});

  @override
  State<SmartDashboardScreen> createState() => _SmartDashboardScreenState();
}

class _SmartDashboardScreenState extends State<SmartDashboardScreen> {
  late UserProfile _userProfile;
  final _supabaseService = SupabaseService();
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _userProfile = widget.userProfile;
    logger.i('Smart Dashboard loaded for: ${_userProfile.fullName}');
  }

  String _getTimeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Widget _buildContextualHeader() {
    final hour = DateTime.now().hour;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: hour < 12
                ? [Colors.blue.shade300, Colors.blue.shade100]
                : hour < 18
                    ? [Colors.orange.shade300, Colors.orange.shade100]
                    : [Colors.indigo.shade300, Colors.indigo.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getTimeOfDayGreeting()}, ${_userProfile.fullName.split(' ').first}!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            if (hour < 12) ...[
              _buildInsightRow(Icons.person_outline, 'Maid Status',
                  'On Schedule - 10:00 AM'),
              const SizedBox(height: 8),
              _buildInsightRow(
                  Icons.local_shipping, 'Milk Delivery', 'Expected - 8:30 AM'),
            ] else if (hour < 18) ...[
              _buildInsightRow(Icons.delivery_dining, 'Expected Deliveries',
                  '2 packages arriving'),
              const SizedBox(height: 8),
              _buildInsightRow(
                  Icons.sports_basketball, 'Amenity Bookings', 'Gym: 6:00 PM'),
            ] else ...[
              _buildInsightRow(
                  Icons.people, 'Guest Invites', 'Weekend party planning'),
              const SizedBox(height: 8),
              _buildInsightRow(
                  Icons.security, 'Security Patrol', 'Active - All Clear'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsightRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionQuadrant() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          _buildQuickActionButton(
            icon: Icons.qr_code_2,
            label: 'Gate Pass',
            color: Colors.blue,
            onTap: () => _showGatePassDialog(),
          ),
          _buildQuickActionButton(
            icon: Icons.payment,
            label: 'Pay Now',
            color: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentsScreen(
                  unitId: _userProfile.unitId ?? 'demo-unit-1',
                ),
              ),
            ),
          ),
          _buildQuickActionButton(
            icon: Icons.support_agent,
            label: 'Helpdesk',
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HelpdeskScreen(
                  residentId: _userProfile.id,
                ),
              ),
            ),
          ),
          _buildQuickActionButton(
            icon: Icons.emergency,
            label: 'SOS',
            color: Colors.red,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SOSScreen(
                  residentId: _userProfile.id,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
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

  Widget _buildCommunityPulseFeed() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Community Pulse',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommunityPulseScreen(
                      userProfile: _userProfile,
                    ),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommunityPulseScreen(
                    userProfile: _userProfile,
                  ),
                ),
              ),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade50,
                      Colors.orange.shade100.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.campaign,
                        color: Colors.orange.shade800,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Notices, polls & classifieds',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to view society notices, vote in polls, and browse classifieds.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGatePassDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Gate Pass'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select gate pass type:'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text('Guest Entry'),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Guest QR generated!')),
                );
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.delivery_dining),
              label: const Text('Delivery'),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Delivery QR generated!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedNavIndex,
      onTap: (index) => setState(() => _selectedNavIndex = index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.miscellaneous_services),
          label: 'Services',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Accounts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
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
        title: const Text('Gately - Smart Dashboard'),
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
          ? SingleChildScrollView(
              child: Column(
                children: [
                  _buildContextualHeader(),
                  const SizedBox(height: 8),
                  _buildQuickActionQuadrant(),
                  const SizedBox(height: 24),
                  _buildCommunityPulseFeed(),
                  const SizedBox(height: 32),
                ],
              ),
            )
          : _selectedNavIndex == 1
              ? ServicesScreen(userProfile: _userProfile)
              : _selectedNavIndex == 2
                  ? AccountsScreen(userProfile: _userProfile)
                  : ProfileScreen(
                      userProfile: _userProfile,
                      onLogout: _handleLogout,
                    ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
}
