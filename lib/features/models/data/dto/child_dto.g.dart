// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChildDto _$ChildDtoFromJson(Map<String, dynamic> json) => ChildDto(
  id: json['id'] as String,
  familyId: json['family_id'] as String,
  nickname: json['nickname'] as String,
  age: (json['age'] as num).toInt(),
  gender: json['gender'] as String,
  avatarState: AvatarStateDto.fromJson(
    json['avatar_state'] as Map<String, dynamic>,
  ),
  level: (json['level'] as num).toInt(),
  xp: (json['xp'] as num).toInt(),
  currentStreakDays: (json['current_streak_days'] as num).toInt(),
  longestStreakDays: (json['longest_streak_days'] as num).toInt(),
  tasksCompletedCount: (json['tasks_completed_count'] as num).toInt(),
  coinsBalance: (json['coins_balance'] as num).toInt(),
  achievementsCount: (json['achievements_count'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ChildDtoToJson(ChildDto instance) => <String, dynamic>{
  'id': instance.id,
  'family_id': instance.familyId,
  'nickname': instance.nickname,
  'age': instance.age,
  'gender': instance.gender,
  'avatar_state': instance.avatarState,
  'level': instance.level,
  'xp': instance.xp,
  'current_streak_days': instance.currentStreakDays,
  'longest_streak_days': instance.longestStreakDays,
  'tasks_completed_count': instance.tasksCompletedCount,
  'coins_balance': instance.coinsBalance,
  'achievements_count': instance.achievementsCount,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

AvatarStateDto _$AvatarStateDtoFromJson(Map<String, dynamic> json) =>
    AvatarStateDto(equipped: Map<String, String>.from(json['equipped'] as Map));

Map<String, dynamic> _$AvatarStateDtoToJson(AvatarStateDto instance) =>
    <String, dynamic>{'equipped': instance.equipped};

ChildCreateDto _$ChildCreateDtoFromJson(Map<String, dynamic> json) =>
    ChildCreateDto(
      nickname: json['nickname'] as String,
      age: (json['age'] as num).toInt(),
      gender: json['gender'] as String,
    );

Map<String, dynamic> _$ChildCreateDtoToJson(ChildCreateDto instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'age': instance.age,
      'gender': instance.gender,
    };

ChildUpdateDto _$ChildUpdateDtoFromJson(Map<String, dynamic> json) =>
    ChildUpdateDto(
      nickname: json['nickname'] as String?,
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      avatarState: json['avatar_state'] == null
          ? null
          : AvatarStateDto.fromJson(
              json['avatar_state'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ChildUpdateDtoToJson(ChildUpdateDto instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'age': instance.age,
      'gender': instance.gender,
      'avatar_state': instance.avatarState,
    };
