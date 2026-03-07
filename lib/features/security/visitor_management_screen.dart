import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/supabase_service.dart';

final logger = Logger();

class VisitorManagementScreen extends StatefulWidget {
  final UserProfile userProfile;

  const VisitorManagementScreen({super.key, required this.userProfile});

  @override
  State<VisitorManagementScreen> createState() =>
      _VisitorManagementScreenState();
}

class _VisitorManagementScreenState extends State<VisitorManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabaseService = SupabaseService();

  List<Map<String, dynamic>> _pendingVisitors = [];
  List<Map<String, dynamic>> _allVisitors = [];
  Map<String, dynamic> _dailyReport = {};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final pending = await _supabaseService
          .getPendingVisitors(widget.userProfile.societyId);
      final all =
          await _supabaseService.getTodayVisitors(widget.userProfile.societyId);
      final report = await _supabaseService
          .getDailyVisitorReport(widget.userProfile.societyId);

      setState(() {
        _pendingVisitors = pending;
        _allVisitors = all;
        _dailyReport = report;
        _isLoading = false;
      });
    } catch (e) {
      logger.e('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _approveVisitor(String visitorId) async {
    try {
      await _supabaseService.approveVisitor(visitorId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visitor approved!')),
      );
      await _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _rejectVisitor(String visitorId) async {
    try {
      await _supabaseService.rejectVisitor(visitorId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visitor rejected!')),
      );
      await _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Management'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(icon: Icon(Icons.pending_actions), text: 'Pending'),
            const Tab(icon: Icon(Icons.today), text: 'Today'),
            const Tab(icon: Icon(Icons.assessment), text: 'Report'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPendingTab(),
                _buildTodayTab(),
                _buildReportTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewVisitorDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Visitor'),
      ),
    );
  }

  Widget _buildPendingTab() {
    if (_pendingVisitors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('No pending visitors'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingVisitors.length,
      itemBuilder: (context, index) {
        final visitor = _pendingVisitors[index];
        return _buildVisitorCard(visitor, isPending: true);
      },
    );
  }

  Widget _buildTodayTab() {
    if (_allVisitors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('No visitors today'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allVisitors.length,
      itemBuilder: (context, index) {
        final visitor = _allVisitors[index];
        return _buildVisitorCard(visitor);
      },
    );
  }

  Widget _buildReportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Summary cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total',
                  value: '${_dailyReport['total'] ?? 0}',
                  color: Colors.blue,
                  icon: Icons.people,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Approved',
                  value: '${_dailyReport['approved'] ?? 0}',
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Inside',
                  value: '${_dailyReport['currently_inside'] ?? 0}',
                  color: Colors.orange,
                  icon: Icons.login,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Checked Out',
                  value: '${_dailyReport['checked_out'] ?? 0}',
                  color: Colors.purple,
                  icon: Icons.logout,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Pending',
                  value: '${_dailyReport['pending'] ?? 0}',
                  color: Colors.amber,
                  icon: Icons.access_time,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Rejected',
                  value: '${_dailyReport['rejected'] ?? 0}',
                  color: Colors.red,
                  icon: Icons.cancel,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Text(
            'Key Metrics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Metrics list
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMetricRow(
                    'Entry Rate',
                    '${_dailyReport['checked_in'] ?? 0} entries',
                    Colors.green,
                  ),
                  const Divider(),
                  _buildMetricRow(
                    'Exit Rate',
                    '${_dailyReport['checked_out'] ?? 0} exits',
                    Colors.purple,
                  ),
                  const Divider(),
                  _buildMetricRow(
                    'Approval Rate',
                    '${(((_dailyReport['approved'] ?? 0) / ((_dailyReport['total'] ?? 1) > 0 ? _dailyReport['total'] : 1)) * 100).toStringAsFixed(1)}%',
                    Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorCard(Map<String, dynamic> visitor,
      {bool isPending = false}) {
    final flatNumber = visitor['flat_number'] ?? 'N/A';
    final block =
        visitor['block_number'] != null ? '${visitor['block_number']}-' : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visitor['visitor_name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Flat: $block$flatNumber',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(visitor['status']),
              ],
            ),
            const SizedBox(height: 12),

            // Details
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  visitor['category'] ?? 'Guest',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 16),
                if (visitor['visitor_phone'] != null) ...[
                  Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    visitor['visitor_phone'] ?? '',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            Text(
              'Purpose: ${visitor['purpose'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),

            // Time info
            Row(
              children: [
                Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  _formatDateTime(visitor['created_at']),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),

            if (visitor['entry_time'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.login, size: 14, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'In: ${_formatDateTime(visitor['entry_time'])}',
                    style:
                        TextStyle(fontSize: 11, color: Colors.green.shade600),
                  ),
                ],
              ),
            ],

            if (visitor['exit_time'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.logout, size: 14, color: Colors.red.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Out: ${_formatDateTime(visitor['exit_time'])}',
                    style: TextStyle(fontSize: 11, color: Colors.red.shade600),
                  ),
                ],
              ),
            ],

            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _rejectVisitor(visitor['id']),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _approveVisitor(visitor['id']),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'pending':
        color = Colors.amber;
        icon = Icons.access_time;
        break;
      case 'approved':
        color = Colors.blue;
        icon = Icons.check_circle_outline;
        break;
      case 'in':
        color = Colors.green;
        icon = Icons.login;
        break;
      case 'out':
        color = Colors.purple;
        icon = Icons.logout;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateTimeStr);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  void _showNewVisitorDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final purposeController = TextEditingController();
    final flatController = TextEditingController();
    final blockController = TextEditingController();
    String selectedCategory = 'guest';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Visitor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Visitor Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: flatController,
                decoration: const InputDecoration(
                  labelText: 'Flat Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: blockController,
                decoration: const InputDecoration(
                  labelText: 'Block/Tower (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: purposeController,
                decoration: const InputDecoration(
                  labelText: 'Purpose',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: const [
                  DropdownMenuItem(value: 'guest', child: Text('Guest')),
                  DropdownMenuItem(value: 'vendor', child: Text('Vendor')),
                  DropdownMenuItem(value: 'delivery', child: Text('Delivery')),
                  DropdownMenuItem(value: 'service', child: Text('Service')),
                  DropdownMenuItem(
                      value: 'contractor', child: Text('Contractor')),
                ]
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.value,
                        child: item.child,
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  selectedCategory = value ?? 'guest';
                },
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  flatController.text.isEmpty ||
                  purposeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please fill all required fields')),
                );
                return;
              }

              try {
                await _supabaseService.createVisitorRecord(
                  societyId: widget.userProfile.societyId,
                  blockNumber: blockController.text.isEmpty
                      ? null
                      : blockController.text,
                  flatNumber: flatController.text,
                  visitorName: nameController.text,
                  visitorPhone: phoneController.text.isEmpty
                      ? null
                      : phoneController.text,
                  purpose: purposeController.text,
                  category: selectedCategory,
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Visitor added successfully!')),
                  );
                  await _loadData();
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Add Visitor'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
