enum UserRole { admin, resident, guard, staff, supervisor }

class UserProfile {
  final String id;
  final String societyId;
  final String? unitId;
  final UserRole role;
  final String fullName;
  final String? phoneNumber;
  final String? email;
  final String? deviceToken;
  final String? dailyHelpCode;
  final bool isSosEnabled;
  final bool dataProcessingConsent;
  final DateTime? consentTimestamp;
  final DateTime? createdAt;

  UserProfile({
    required this.id,
    required this.societyId,
    this.unitId,
    required this.role,
    required this.fullName,
    this.phoneNumber,
    this.email,
    this.deviceToken,
    this.dailyHelpCode,
    this.isSosEnabled = true,
    this.dataProcessingConsent = false,
    this.consentTimestamp,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      societyId: json['society_id'] ?? '',
      unitId: json['unit_id'],
      role: UserRole.values.firstWhere(
        (e) => e.name == (json['role'] ?? 'resident'),
        orElse: () => UserRole.resident,
      ),
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'],
      email: json['email'],
      deviceToken: json['device_token'],
      dailyHelpCode: json['daily_help_code'],
      isSosEnabled: json['is_sos_enabled'] ?? true,
      dataProcessingConsent: json['data_processing_consent'] ?? false,
      consentTimestamp: json['consent_timestamp'] != null
          ? DateTime.parse(json['consent_timestamp'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'society_id': societyId,
        'unit_id': unitId,
        'role': role.name,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'email': email,
        'device_token': deviceToken,
        'daily_help_code': dailyHelpCode,
        'is_sos_enabled': isSosEnabled,
        'data_processing_consent': dataProcessingConsent,
        'consent_timestamp': consentTimestamp?.toIso8601String(),
      };

  UserProfile copyWith({
    String? id,
    String? societyId,
    String? unitId,
    UserRole? role,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? deviceToken,
    String? dailyHelpCode,
    bool? isSosEnabled,
    bool? dataProcessingConsent,
    DateTime? consentTimestamp,
    DateTime? createdAt,
  }) =>
      UserProfile(
        id: id ?? this.id,
        societyId: societyId ?? this.societyId,
        unitId: unitId ?? this.unitId,
        role: role ?? this.role,
        fullName: fullName ?? this.fullName,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        email: email ?? this.email,
        deviceToken: deviceToken ?? this.deviceToken,
        dailyHelpCode: dailyHelpCode ?? this.dailyHelpCode,
        isSosEnabled: isSosEnabled ?? this.isSosEnabled,
        dataProcessingConsent:
            dataProcessingConsent ?? this.dataProcessingConsent,
        consentTimestamp: consentTimestamp ?? this.consentTimestamp,
        createdAt: createdAt ?? this.createdAt,
      );
}
