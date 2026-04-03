// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileDto _$ProfileDtoFromJson(Map<String, dynamic> json) => ProfileDto(
  userId: json['user_id'] as String,
  email: json['email'] as String,
  displayName: json['display_name'] as String,
  avatarUrl: json['avatar_url'] as String,
  bio: json['bio'] as String,
  timezone: json['timezone'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ProfileDtoToJson(ProfileDto instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'email': instance.email,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'bio': instance.bio,
      'timezone': instance.timezone,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

ProfileUpdateDto _$ProfileUpdateDtoFromJson(Map<String, dynamic> json) =>
    ProfileUpdateDto(
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      timezone: json['timezone'] as String?,
    );

Map<String, dynamic> _$ProfileUpdateDtoToJson(ProfileUpdateDto instance) =>
    <String, dynamic>{
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'bio': instance.bio,
      'timezone': instance.timezone,
    };
