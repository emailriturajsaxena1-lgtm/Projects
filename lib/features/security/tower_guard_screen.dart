import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/supabase_service.dart';

final logger = Logger();

class TowerGuardScreen extends StatefulWidget {
  final UserProfile userProfile;

  const TowerGuardScreen({super.key, required this.userProfile});

  @override
  State<TowerGuardScreen> createState() => _TowerGuardScreenState();
}

class _TowerGuardScreenState extends State<TowerGuardScreen> {
  final _supabaseService = SupabaseService();
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _currentlyInside = [];
  List<Map<String, dynamic>> _filteredVisitors = [];
  bool _isLoading = false;
  String _filterType = 'all'; // all, vendor, guest, delivery, service

  @override
  void initState() {
    super.initState();
    _loadCurrentlyInsideVisitors();
    _searchController.addListener(_filterVisitors);
  }

  Future<void> _loadCurrentlyInsideVisitors() async {
    setState(() => _isLoading = true);
    try {
      final visitors = await _supabaseService
          .getCurrentlyInsideVisitors(widget.userProfile.societyId);
      setState(() {
        _currentlyInside = visitors;
        _filteredVisitors = visitors;
        _isLoading = false;
      });
    } catch (e) {
      logger.e('Error loading visitors: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _filterVisitors() {
    List<Map<String, dynamic>> filtered = _currentlyInside;

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where((v) =>
              (v['visitor_name']?.toString().toLowerCase().contains(query) ??
                  false) ||
              (v['flat_number']?.toString().toLowerCase().contains(query) ??
                  false))
          .toList();
    }

    // Filter by category
    if (_filterType != 'all') {
      filtered = filtered.where((v) => v['category'] == _filterType).toList();
    }

    setState(() => _filteredVisitors = filtered);
  }

  void _checkOutVisitor(Map<String, dynamic> visitor) async {
    final visitorId = visitor['id'];
    final visitorName = visitor['visitor_name'] ?? 'Unknown';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check Out Visitor'),
        content:
            Text('Check out $visitorName from flat ${visitor['flat_number']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _supabaseService.checkOutVisitor(visitorId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$visitorName checked out!')),
                );
                await _loadCurrentlyInsideVisitors();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Check Out'),
          ),
        ],
      ),
    );
  }

  void _showQuickCheckInDialog() {
    final nameController = TextEditingController();
    final flatController = TextEditingController();
    final blockController = TextEditingController();
    String selectedCategory = 'vendor';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Check-In'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Vendor/Guest Name',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: const [
                  DropdownMenuItem(value: 'vendor', child: Text('Vendor')),
                  DropdownMenuItem(value: 'guest', child: Text('Guest')),
                  DropdownMenuItem(value: 'delivery', child: Text('Delivery')),
                  DropdownMenuItem(value: 'service', child: Text('Service')),
                ]
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.value,
                        child: item.child,
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  selectedCategory = value ?? 'vendor';
                },
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
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
              if (nameController.text.isEmpty || flatController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill required fields')),
                );
                return;
              }

              Navigator.pop(context);
              try {
                final recordId = await _supabaseService.createVisitorRecord(
                  societyId: widget.userProfile.societyId,
                  blockNumber: blockController.text.isEmpty
                      ? null
                      : blockController.text,
                  flatNumber: flatController.text,
                  visitorName: nameController.text,
                  visitorPhone: null,
                  purpose: selectedCategory,
                  category: selectedCategory,
                );

                // Auto-approve and check-in
                await _supabaseService.approveVisitor(recordId);
                await _supabaseService.checkInVisitor(recordId);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${nameController.text} checked in!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  await _loadCurrentlyInsideVisitors();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Check In'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tower Guard - Vendor Management'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header stats
          Container(
            color: Colors.orange.shade50,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatIndicator(
                      label: 'Currently Inside',
                      value: '${_filteredVisitors.length}',
                      color: Colors.green,
                    ),
                    _buildStatIndicator(
                      label: 'Today Total',
                      value: '${_currentlyInside.length}',
                      color: Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or flat number...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          ),

          // Filter chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildFilterChip('all', 'All', Icons.public),
                _buildFilterChip('vendor', 'Vendors', Icons.business),
                _buildFilterChip('delivery', 'Delivery', Icons.local_shipping),
                _buildFilterChip('service', 'Service', Icons.settings),
                _buildFilterChip('guest', 'Guests', Icons.person),
              ],
            ),
          ),

          // Visitor list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredVisitors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            const Text('No vendors currently inside'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filteredVisitors.length,
                        itemBuilder: (context, index) {
                          final visitor = _filteredVisitors[index];
                          return _buildVendorCard(visitor);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQuickCheckInDialog,
        icon: const Icon(Icons.add_location),
        label: const Text('Quick Check-In'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildStatIndicator({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String type, String label, IconData icon) {
    final isSelected = _filterType == type;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _filterType = type);
          _filterVisitors();
        },
        avatar: Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.white : Colors.grey,
        ),
        label: Text(label),
        backgroundColor: Colors.grey.shade200,
        selectedColor: Colors.orange,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildVendorCard(Map<String, dynamic> visitor) {
    final entryTime = visitor['entry_time'] != null
        ? DateTime.parse(visitor['entry_time'])
        : DateTime.now();
    final now = DateTime.now();
    final duration = now.difference(entryTime);

    String durationText;
    if (duration.inHours > 0) {
      durationText = '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      durationText = '${duration.inMinutes}m';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name and Category Badge
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Flat: ${visitor['flat_number'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCategoryBadge(visitor['category'] ?? 'visitor'),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Time info: Entry time and duration
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Icon(Icons.login, color: Colors.green.shade600, size: 24),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(entryTime),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Entry Time',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(Icons.schedule,
                          color: Colors.orange.shade600, size: 24),
                      const SizedBox(height: 8),
                      Text(
                        durationText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Inside for',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(Icons.person, color: Colors.blue.shade600, size: 24),
                      const SizedBox(height: 8),
                      Text(
                        visitor['category']?.toUpperCase() ?? 'VISITOR',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Type',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Purpose (if available)
            if (visitor['purpose'] != null &&
                visitor['purpose'].isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.description,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Purpose: ${visitor['purpose']}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _checkOutVisitor(visitor),
                    icon: const Icon(Icons.logout),
                    label: const Text('CHECK OUT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    Color color;
    String label;

    switch (category.toLowerCase()) {
      case 'vendor':
        color = Colors.purple;
        label = 'VENDOR';
        break;
      case 'delivery':
        color = Colors.blue;
        label = 'DELIVERY';
        break;
      case 'service':
        color = Colors.cyan;
        label = 'SERVICE';
        break;
      case 'guest':
        color = Colors.teal;
        label = 'GUEST';
        break;
      default:
        color = Colors.grey;
        label = category.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
