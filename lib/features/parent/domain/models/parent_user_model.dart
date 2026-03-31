class ParentUserModel {
  final String userId;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final String? timezone;
  final DateTime createdAt;
  final DateTime updatedAt;

  ParentUserModel({
    required this.userId,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.timezone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ParentUserModel.fromJson(Map<String, dynamic> json) {
    return ParentUserModel(
      userId: json['user_id'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      timezone: json['timezone'] as String?,
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get name => displayName ?? 'Safinio Parent';
}
