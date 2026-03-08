import 'package:flutter/material.dart';
import 'package:gately_core/gately_core.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile userProfile;
  final Future<void> Function() onLogout;

  const ProfileScreen({
    super.key,
    required this.userProfile,
    required this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _documents = [];
  bool _loadingDocs = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _loadingDocs = true);
    try {
      final list = await _supabaseService.getUserDocuments(widget.userProfile.id);
      if (mounted) {
        setState(() {
          _documents = list;
          _loadingDocs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingDocs = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading documents: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        p.fullName.isNotEmpty
                            ? p.fullName.substring(0, 1).toUpperCase()
                            : '?',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.fullName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (p.email != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              p.email!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                          if (p.phoneNumber != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              p.phoneNumber!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              p.role.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'My documents',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (_loadingDocs)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ))
            else if (_documents.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.folder_off,
                          size: 40, color: Colors.grey.shade400),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'No documents uploaded. Upload during signup or from Settings.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._documents.map((d) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(
                          Icons.description,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      title: Text(
                        (d['document_type'] ?? 'Document')
                            .toString()
                            .replaceAll('_', ' ')
                            .toUpperCase(),
                      ),
                      subtitle: d['uploaded_at'] != null
                          ? Text(
                              DateFormat('MMM d, y').format(
                                DateTime.parse(d['uploaded_at']),
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            )
                          : null,
                      trailing: (d['verified'] == true)
                          ? Icon(Icons.verified,
                              color: Colors.green.shade700, size: 20)
                          : null,
                    ),
                  )),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings – coming soon')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red.shade700),
              title: Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text(
                      'Are you sure you want to logout?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await widget.onLogout();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
