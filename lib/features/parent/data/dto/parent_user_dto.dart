import 'package:safini/features/parent/domain/models/parent_user_model.dart';

class ParentUserDto {
  final String userId;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final String? timezone;
  final String createdAt;
  final String updatedAt;

  const ParentUserDto({
    required this.userId,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.timezone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ParentUserDto.fromJson(Map<String, dynamic> json) {
    return ParentUserDto(
      userId: json['user_id'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      timezone: json['timezone'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  ParentUserModel toDomain() {
    return ParentUserModel(
      userId: userId,
      email: email,
      displayName: displayName,
      avatarUrl: avatarUrl,
      bio: bio,
      timezone: timezone,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
