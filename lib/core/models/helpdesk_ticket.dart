enum TicketStatus { open, inProgress, resolved, closed }

class HelpdeskTicket {
  final String id;
  final String residentId;
  final String category;
  final String description;
  final TicketStatus status;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  HelpdeskTicket({
    required this.id,
    required this.residentId,
    required this.category,
    required this.description,
    required this.status,
    this.assignedTo,
    required this.createdAt,
    this.resolvedAt,
  });

  factory HelpdeskTicket.fromJson(Map<String, dynamic> json) {
    return HelpdeskTicket(
      id: json['id'],
      residentId: json['resident_id'],
      category: json['category'] ?? 'General',
      description: json['description'] ?? '',
      status: TicketStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'open'),
        orElse: () => TicketStatus.open,
      ),
      assignedTo: json['assigned_to'],
      createdAt: DateTime.parse(json['created_at']),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
    );
  }
}
