class CommunityClassified {
  final String id;
  final String societyId;
  final String title;
  final String? description;
  final String category;
  final String? contactPhone;
  final String? contactName;
  final String? createdBy;
  final DateTime createdAt;
  final String status;

  CommunityClassified({
    required this.id,
    required this.societyId,
    required this.title,
    this.description,
    required this.category,
    this.contactPhone,
    this.contactName,
    this.createdBy,
    required this.createdAt,
    this.status = 'active',
  });

  factory CommunityClassified.fromJson(Map<String, dynamic> json) {
    return CommunityClassified(
      id: json['id'] as String,
      societyId: json['society_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'other',
      contactPhone: json['contact_phone'] as String?,
      contactName: json['contact_name'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['status'] as String? ?? 'active',
    );
  }

  static const categories = ['sell', 'buy', 'rent', 'services', 'other'];
}
