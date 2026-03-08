/// Enhanced Visitor Management Model for tracking vendors and guests
class VisitorManagement {
  final String id;
  final String societyId;
  final String? blockNumber;
  final String? flatNumber;
  final String visitorName;
  final String? visitorPhone;
  final String purpose;
  final String category;
  final String status;
  final DateTime createdAt;
  final DateTime? entryTime;
  final DateTime? exitTime;
  final String? entryGateId;
  final String? exitGateId;
  final String? createdByUserId;
  final String? approvedByUserId;
  final Map<String, dynamic>? metadata;

  VisitorManagement({
    required this.id,
    required this.societyId,
    this.blockNumber,
    required this.flatNumber,
    required this.visitorName,
    this.visitorPhone,
    required this.purpose,
    required this.category,
    required this.status,
    required this.createdAt,
    this.entryTime,
    this.exitTime,
    this.entryGateId,
    this.exitGateId,
    this.createdByUserId,
    this.approvedByUserId,
    this.metadata,
  });

  factory VisitorManagement.fromJson(Map<String, dynamic> json) {
    return VisitorManagement(
      id: json['id'] as String,
      societyId: json['society_id'] as String,
      blockNumber: json['block_number'] as String?,
      flatNumber: json['flat_number'] as String? ?? json['flat_no'] as String?,
      visitorName: json['visitor_name'] ?? 'Unknown',
      visitorPhone: json['visitor_phone'] as String?,
      purpose: json['purpose'] ?? '',
      category: json['category'] ?? 'guest',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      entryTime: json['entry_time'] != null
          ? DateTime.parse(json['entry_time'])
          : null,
      exitTime:
          json['exit_time'] != null ? DateTime.parse(json['exit_time']) : null,
      entryGateId: json['entry_gate_id'] as String?,
      exitGateId: json['exit_gate_id'] as String?,
      createdByUserId: json['created_by_user_id'] as String?,
      approvedByUserId: json['approved_by_user_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'society_id': societyId,
      'block_number': blockNumber,
      'flat_number': flatNumber,
      'visitor_name': visitorName,
      'visitor_phone': visitorPhone,
      'purpose': purpose,
      'category': category,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'entry_time': entryTime?.toIso8601String(),
      'exit_time': exitTime?.toIso8601String(),
      'entry_gate_id': entryGateId,
      'exit_gate_id': exitGateId,
      'created_by_user_id': createdByUserId,
      'approved_by_user_id': approvedByUserId,
      'metadata': metadata,
    };
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Awaiting Approval';
      case 'approved':
        return 'Approved';
      case 'in':
        return 'Currently Inside';
      case 'out':
        return 'Checked Out';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  Duration? get visitDuration {
    if (entryTime == null || exitTime == null) return null;
    return exitTime!.difference(entryTime!);
  }

  bool get isInside => status == 'in';
  bool get canCheckIn => status == 'approved';
  bool get canCheckOut => status == 'in';
}
