import 'package:flutter/material.dart';
import 'package:gately_core/gately_core.dart';

class HelpdeskScreen extends StatefulWidget {
  final String residentId;

  const HelpdeskScreen({super.key, required this.residentId});

  @override
  State<HelpdeskScreen> createState() => _HelpdeskScreenState();
}

class _HelpdeskScreenState extends State<HelpdeskScreen> {
  final _supabaseService = SupabaseService();
  late Future<List<HelpdeskTicket>> _tickets;
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _categories = [
    'Plumbing',
    'Electrical',
    'Security',
    'Maintenance',
    'Other',
  ];

  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tickets = _supabaseService.getHelpdeskTickets(widget.residentId);
    _selectedCategory = _categories.first;
  }

  Future<void> _createTicket() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    try {
      await _supabaseService.createHelpdeskTicket(
        residentId: widget.residentId,
        category: _selectedCategory ?? 'Other',
        description: _descriptionController.text,
      );

      _descriptionController.clear();

      setState(() {
        _tickets = _supabaseService.getHelpdeskTickets(widget.residentId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket created successfully!')),
        );
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
      appBar: AppBar(title: const Text('Helpdesk')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create a Support Ticket',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your issue in detail',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text(
                    'Create Ticket',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your Tickets',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<HelpdeskTicket>>(
                future: _tickets,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final tickets = snapshot.data ?? [];
                  if (tickets.isEmpty) {
                    return const Center(child: Text('No tickets yet'));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      final statusColor = ticket.status == TicketStatus.resolved
                          ? Colors.green
                          : ticket.status == TicketStatus.inProgress
                              ? Colors.blue
                              : Colors.orange;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withAlpha(50),
                            child:
                                Icon(Icons.support_agent, color: statusColor),
                          ),
                          title: Text(ticket.category),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                ticket.status.name.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            '${ticket.createdAt.day}/${ticket.createdAt.month}',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
