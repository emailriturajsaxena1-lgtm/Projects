import 'package:flutter/material.dart';
import 'package:gately_core/gately_core.dart';
import 'package:intl/intl.dart';
import '../community/helpdesk_screen.dart';
import '../dashboard/community_pulse_screen.dart';

class ServicesScreen extends StatefulWidget {
  final UserProfile userProfile;

  const ServicesScreen({super.key, required this.userProfile});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _bookings = [];
  bool _loading = true;

  static const _amenities = [
    {'id': 'gym', 'name': 'Gym', 'icon': Icons.fitness_center},
    {'id': 'clubhouse', 'name': 'Clubhouse', 'icon': Icons.weekend},
    {'id': 'court', 'name': 'Sports Court', 'icon': Icons.sports_basketball},
    {'id': 'pool', 'name': 'Swimming Pool', 'icon': Icons.pool},
  ];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _loading = true);
    try {
      final list = await _supabaseService.getAmenityBookings(widget.userProfile.id);
      if (mounted) {
        setState(() {
          _bookings = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showBookAmenityDialog() {
    String? amenityId;
    DateTime? selectedDate;
    String slotStart = '09:00';
    String slotEnd = '10:00';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Book Amenity',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: amenityId,
                      decoration: const InputDecoration(
                        labelText: 'Amenity',
                        border: OutlineInputBorder(),
                      ),
                      items: _amenities
                          .map((a) => DropdownMenuItem(
                                value: a['id'] as String,
                                child: Row(
                                  children: [
                                    Icon(a['icon'] as IconData, size: 20),
                                    const SizedBox(width: 8),
                                    Text(a['name'] as String),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (v) => setModalState(() => amenityId = v),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        selectedDate == null
                            ? 'Select date'
                            : DateFormat('EEEE, MMM d').format(selectedDate!),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 60)),
                        );
                        if (d != null) setModalState(() => selectedDate = d);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: slotStart,
                            decoration: const InputDecoration(
                              labelText: 'From',
                              border: OutlineInputBorder(),
                            ),
                            items: List.generate(
                              12,
                              (i) => '${(i + 8).toString().padLeft(2, '0')}:00',
                            ).map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => setModalState(() => slotStart = v ?? slotStart),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: slotEnd,
                            decoration: const InputDecoration(
                              labelText: 'To',
                              border: OutlineInputBorder(),
                            ),
                            items: List.generate(
                              12,
                              (i) => '${(i + 9).toString().padLeft(2, '0')}:00',
                            ).map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => setModalState(() => slotEnd = v ?? slotEnd),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () async {
                        if (amenityId == null || selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Select amenity and date')),
                          );
                          return;
                        }
                        try {
                          final name = _amenities.firstWhere(
                            (a) => a['id'] == amenityId,
                            orElse: () => {'name': amenityId},
                          )['name'] as String;
                          await _supabaseService.createAmenityBooking(
                            societyId: widget.userProfile.societyId,
                            residentId: widget.userProfile.id,
                            amenityName: name,
                            slotDate: selectedDate!,
                            slotStart: slotStart,
                            slotEnd: slotEnd,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Booking requested!')),
                            );
                            _loadBookings();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      child: const Text('Request Booking'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick access',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _ServiceTile(
                  icon: Icons.fitness_center,
                  label: 'Book Amenity',
                  color: Colors.blue,
                  onTap: _showBookAmenityDialog,
                ),
                _ServiceTile(
                  icon: Icons.support_agent,
                  label: 'Helpdesk',
                  color: Colors.orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HelpdeskScreen(
                        residentId: widget.userProfile.id,
                      ),
                    ),
                  ),
                ),
                _ServiceTile(
                  icon: Icons.campaign,
                  label: 'Community Pulse',
                  color: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommunityPulseScreen(
                        userProfile: widget.userProfile,
                      ),
                    ),
                  ),
                ),
                _ServiceTile(
                  icon: Icons.people,
                  label: 'Directory',
                  color: Colors.purple,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Directory – list your society members (coming soon)'),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My bookings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: _showBookAmenityDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Book'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ))
            else if (_bookings.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.event_busy,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No bookings yet',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: _showBookAmenityDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Book amenity'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ..._bookings.map((b) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(
                          Icons.calendar_today,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      title: Text(b['amenity_name'] ?? 'Amenity'),
                      subtitle: Text(
                        '${b['slot_date']} • ${b['slot_start']}–${b['slot_end']}',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          (b['status'] ?? 'confirmed').toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.08),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
