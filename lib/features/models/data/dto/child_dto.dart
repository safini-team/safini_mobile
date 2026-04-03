
import 'package:json_annotation/json_annotation.dart';
import '../../domain/models/child_model.dart';

part 'child_dto.g.dart';

@JsonSerializable()
class ChildDto {
  final String id;
  @JsonKey(name: 'family_id')

import '../../domain/models/child_model.dart';

class ChildDto {
  final String id;

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

  final AvatarStateDto avatarState;
  final int level;
  final int xp;
  final int currentStreakDays;
  final int longestStreakDays;
  final int tasksCompletedCount;
  final int coinsBalance;
  final int achievementsCount;
  final DateTime createdAt;
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

  factory ChildDto.fromJson(Map<String, dynamic> json) {
    return ChildDto(
      id: json['id'] as String? ?? '',
      familyId: json['family_id'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      gender: json['gender'] as String? ?? '',
      avatarState: json['avatar_state'] != null 
          ? AvatarStateDto.fromJson(json['avatar_state'] as Map<String, dynamic>) 
          : AvatarStateDto(equipped: {}),
      level: json['level'] as int? ?? 0,
      xp: json['xp'] as int? ?? 0,
      currentStreakDays: json['current_streak_days'] as int? ?? 0,
      longestStreakDays: json['longest_streak_days'] as int? ?? 0,
      tasksCompletedCount: json['tasks_completed_count'] as int? ?? 0,
      coinsBalance: json['coins_balance'] as int? ?? 0,
      achievementsCount: json['achievements_count'] as int? ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'nickname': nickname,
      'age': age,
      'gender': gender,
      'avatar_state': avatarState.toJson(),
      'level': level,
      'xp': xp,
      'current_streak_days': currentStreakDays,
      'longest_streak_days': longestStreakDays,
      'tasks_completed_count': tasksCompletedCount,
      'coins_balance': coinsBalance,
      'achievements_count': achievementsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

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

      achievementsCount: achievementsCount,
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

  factory AvatarStateDto.fromJson(Map<String, dynamic> json) {
    return AvatarStateDto(
      equipped: (json['equipped'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipped': equipped,
    };
  }
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

  factory ChildCreateDto.fromJson(Map<String, dynamic> json) {
    return ChildCreateDto(
      nickname: json['nickname'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      gender: json['gender'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'age': age,
      'gender': gender,
    };
  }
}

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

  factory ChildUpdateDto.fromJson(Map<String, dynamic> json) {
    return ChildUpdateDto(
      nickname: json['nickname'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      avatarState: json['avatar_state'] != null
          ? AvatarStateDto.fromJson(json['avatar_state'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'age': age,
      'gender': gender,
      'avatar_state': avatarState?.toJson(),
    };
  }
}
