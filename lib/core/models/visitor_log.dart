class VisitorLog {
  final String id;
  final String unitId;
  final String visitorName;
  final String purpose;
  final String status;
  final String? entryGateId;
  final DateTime entryAt;
  final DateTime? exitAt;

  VisitorLog({
    required this.id,
    required this.unitId,
    required this.visitorName,
    required this.purpose,
    required this.status,
    this.entryGateId,
    required this.entryAt,
    this.exitAt,
  });

  factory VisitorLog.fromJson(Map<String, dynamic> json) {
    return VisitorLog(
      id: json['id'],
      unitId: json['unit_id'],
      visitorName: json['visitor_name'] ?? 'Unknown',
      purpose: json['purpose'] ?? '',
      status: json['status'] ?? 'pending',
      entryGateId: json['entry_gate_id'],
      entryAt: DateTime.parse(json['entry_at']),
      exitAt: json['exit_at'] != null ? DateTime.parse(json['exit_at']) : null,
    );
  }
}
