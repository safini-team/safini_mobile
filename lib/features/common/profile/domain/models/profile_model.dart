class ProfileModel {
  final String userId;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final String? timezone;
  final String? accountType;
  final String? familyId;
  final String? childId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileModel({
    required this.userId,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    this.timezone,
    this.accountType,
    this.familyId,
    this.childId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      timezone: json['timezone'] as String?,
      accountType: json['account_type'] as String?,
      familyId: json['family_id'] as String?,
      childId: json['child_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'timezone': timezone,
      'account_type': accountType,
      'family_id': familyId,
      'child_id': childId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}