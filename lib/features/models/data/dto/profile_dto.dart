import '../../domain/models/profile_model.dart';

class ProfileDto {
  final String userId;
  final String email;
  final String displayName;
  final String avatarUrl;
  final String bio;
  final String timezone;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileDto({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    required this.bio,
    required this.timezone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      userId: json['user_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      timezone: json['timezone'] as String? ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
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

  ProfileModel toDomain() {
    return ProfileModel(
      userId: userId,
      email: email,
      displayName: displayName,
      avatarUrl: avatarUrl,
      bio: bio,
      timezone: timezone,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ProfileDto.fromDomain(ProfileModel domain) {
    return ProfileDto(
      userId: domain.userId,
      email: domain.email,
      displayName: domain.displayName,
      avatarUrl: domain.avatarUrl,
      bio: domain.bio,
      timezone: domain.timezone,
      createdAt: domain.createdAt,
      updatedAt: domain.updatedAt,
    );
  }
}

class ProfileUpdateDto {
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final String? timezone;

  ProfileUpdateDto({
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.timezone,
  });

  factory ProfileUpdateDto.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateDto(
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'timezone': timezone,
    };
  }
}
