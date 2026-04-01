import 'package:json_annotation/json_annotation.dart';
import '../../domain/models/profile_model.dart';

part 'profile_dto.g.dart';

@JsonSerializable()
class ProfileDto {
  @JsonKey(name: 'user_id')
  final String userId;
  final String email;
  @JsonKey(name: 'display_name')
  final String displayName;
  @JsonKey(name: 'avatar_url')
  final String avatarUrl;
  final String bio;
  final String timezone;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
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

  factory ProfileDto.fromJson(Map<String, dynamic> json) => _$ProfileDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileDtoToJson(this);

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

@JsonSerializable()
class ProfileUpdateDto {
  @JsonKey(name: 'display_name')
  final String? displayName;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  final String? bio;
  final String? timezone;

  ProfileUpdateDto({
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.timezone,
  });

  factory ProfileUpdateDto.fromJson(Map<String, dynamic> json) => _$ProfileUpdateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileUpdateDtoToJson(this);
}
