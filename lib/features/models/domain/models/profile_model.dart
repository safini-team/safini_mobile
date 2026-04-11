class ProfileModel {
  final String userId;
  final String email;
  final String displayName;
  final String avatarUrl;
  final String bio;
  final String timezone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileModel({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    required this.bio,
    required this.timezone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['userId'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String,
      bio: json['bio'] as String,
      timezone: json['timezone'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'timezone': timezone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
