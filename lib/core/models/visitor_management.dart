/// Enhanced Visitor Management Model for tracking vendors and guests
class VisitorManagement {
  final String id;
  final String societyId;
  final String? blockNumber;
  final String? flatNumber;
  final String visitorName;
  final String? visitorPhone;
  final String purpose;
  final String category; // 'vendor', 'guest', 'delivery', 'service', etc.
  final String status; // 'pending', 'approved', 'in', 'out', 'rejected'
  final DateTime createdAt;
  final DateTime? entryTime;
  final DateTime? exitTime;
  final String? entryGateId;
  final String? exitGateId;
  final String? createdByUserId; // Security admin who created this
  final String? approvedByUserId; // Security person who approved
  final Map<String, dynamic>? metadata; // Additional info like vehicle number

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

  // Status display helpers
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

  // Duration of visit
  Duration? get visitDuration {
    if (entryTime == null || exitTime == null) return null;
    return exitTime!.difference(entryTime!);
  }

  // Is currently inside
  bool get isInside => status == 'in';

  // Can check in
  bool get canCheckIn => status == 'approved';

  // Can check out
  bool get canCheckOut => status == 'in';

  // Copy with modifications
  VisitorManagement copyWith({
    String? id,
    String? societyId,
    String? blockNumber,
    String? flatNumber,
    String? visitorName,
    String? visitorPhone,
    String? purpose,
    String? category,
    String? status,
    DateTime? createdAt,
    DateTime? entryTime,
    DateTime? exitTime,
    String? entryGateId,
    String? exitGateId,
    String? createdByUserId,
    String? approvedByUserId,
    Map<String, dynamic>? metadata,
  }) {
    return VisitorManagement(
      id: id ?? this.id,
      societyId: societyId ?? this.societyId,
      blockNumber: blockNumber ?? this.blockNumber,
      flatNumber: flatNumber ?? this.flatNumber,
      visitorName: visitorName ?? this.visitorName,
      visitorPhone: visitorPhone ?? this.visitorPhone,
      purpose: purpose ?? this.purpose,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      entryGateId: entryGateId ?? this.entryGateId,
      exitGateId: exitGateId ?? this.exitGateId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      approvedByUserId: approvedByUserId ?? this.approvedByUserId,
      metadata: metadata ?? this.metadata,
    );
  }
}
