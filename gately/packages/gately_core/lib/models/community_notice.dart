class CommunityNotice {
  final String id;
  final String societyId;
  final String title;
  final String body;
  final String priority;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? expiresAt;

  CommunityNotice({
    required this.id,
    required this.societyId,
    required this.title,
    required this.body,
    this.priority = 'normal',
    this.createdBy,
    required this.createdAt,
    this.expiresAt,
  });

  factory CommunityNotice.fromJson(Map<String, dynamic> json) {
    return CommunityNotice(
      id: json['id'] as String,
      societyId: json['society_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      priority: json['priority'] as String? ?? 'normal',
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isUrgent => priority == 'urgent';
}
