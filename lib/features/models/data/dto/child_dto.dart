import 'package:json_annotation/json_annotation.dart';
import '../../domain/models/child_model.dart';

part 'child_dto.g.dart';

@JsonSerializable()
class ChildDto {
  final String id;
  @JsonKey(name: 'family_id')
  final String familyId;
  final String nickname;
  final int age;
  final String gender;
  @JsonKey(name: 'avatar_state')
  final AvatarStateDto avatarState;
  final int level;
  final int xp;
  @JsonKey(name: 'current_streak_days')
  final int currentStreakDays;
  @JsonKey(name: 'longest_streak_days')
  final int longestStreakDays;
  @JsonKey(name: 'tasks_completed_count')
  final int tasksCompletedCount;
  @JsonKey(name: 'coins_balance')
  final int coinsBalance;
  @JsonKey(name: 'achievements_count')
  final int achievementsCount;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  ChildDto({
    required this.id,
    required this.familyId,
    required this.nickname,
    required this.age,
    required this.gender,
    required this.avatarState,
    required this.level,
    required this.xp,
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.tasksCompletedCount,
    required this.coinsBalance,
    required this.achievementsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChildDto.fromJson(Map<String, dynamic> json) => _$ChildDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ChildDtoToJson(this);

  ChildModel toDomain() {
    return ChildModel(
      id: id,
      familyId: familyId,
      nickname: nickname,
      age: age,
      gender: gender,
      avatarState: avatarState.toDomain(),
      level: level,
      xp: xp,
      currentStreakDays: currentStreakDays,
      longestStreakDays: longestStreakDays,
      tasksCompletedCount: tasksCompletedCount,
      coinsBalance: coinsBalance,
      achievements_count: achievementsCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

@JsonSerializable()
class AvatarStateDto {
  final Map<String, String> equipped;

  AvatarStateDto({required this.equipped});

  factory AvatarStateDto.fromJson(Map<String, dynamic> json) => _$AvatarStateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AvatarStateDtoToJson(this);

  AvatarStateModel toDomain() => AvatarStateModel(equipped: equipped);
}

@JsonSerializable()
class ChildCreateDto {
  final String nickname;
  final int age;
  final String gender;

  ChildCreateDto({
    required this.nickname,
    required this.age,
    required this.gender,
  });

  factory ChildCreateDto.fromJson(Map<String, dynamic> json) => _$ChildCreateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ChildCreateDtoToJson(this);
}

@JsonSerializable()
class ChildUpdateDto {
  final String? nickname;
  final int? age;
  final String? gender;
  @JsonKey(name: 'avatar_state')
  final AvatarStateDto? avatarState;

  ChildUpdateDto({
    this.nickname,
    this.age,
    this.gender,
    this.avatarState,
  });

  factory ChildUpdateDto.fromJson(Map<String, dynamic> json) => _$ChildUpdateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ChildUpdateDtoToJson(this);
}
