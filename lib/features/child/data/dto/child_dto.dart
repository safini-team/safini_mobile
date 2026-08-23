import 'package:safini/features/child/domain/models/child_model.dart';

class ChildDto {
  final String id;
  final String familyId;
  final String nickname;
  final int age;
  final String? gender;
  final int level;
  final int xp;
  final int coinsBalance;
  final int currentStreakDays;
  final int longestStreakDays;
  final int tasksCompletedCount;
  final int achievementsCount;
  final Map<String, dynamic>? avatarState;
  final String createdAt;
  final String updatedAt;

  const ChildDto({
    required this.id,
    required this.familyId,
    required this.nickname,
    required this.age,
    this.gender,
    required this.level,
    required this.xp,
    required this.coinsBalance,
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.tasksCompletedCount,
    required this.achievementsCount,
    this.avatarState,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChildDto.fromJson(Map<String, dynamic> json) {
    return ChildDto(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      nickname: (json['nickname'] as String?)?.trim().isNotEmpty == true
          ? (json['nickname'] as String).trim()
          : 'NoName',
      age: json['age'] as int,
      gender: json['gender'] as String?,
      level: (json['level'] as num?)?.toInt() ?? 1,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      coinsBalance: (json['coins_balance'] as num?)?.toInt() ?? 0,
      currentStreakDays: (json['current_streak_days'] as num?)?.toInt() ?? 0,
      longestStreakDays: (json['longest_streak_days'] as num?)?.toInt() ?? 0,
      tasksCompletedCount:
          (json['tasks_completed_count'] as num?)?.toInt() ?? 0,
      achievementsCount: (json['achievements_count'] as num?)?.toInt() ?? 0,
      avatarState: json['avatar_state'] as Map<String, dynamic>?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  ChildModel toDomain() {
    return ChildModel(
      id: id,
      familyId: familyId,
      nickname: nickname,
      age: age,
      gender: gender,
      level: level,
      xp: xp,
      coinsBalance: coinsBalance,
      currentStreakDays: currentStreakDays,
      longestStreakDays: longestStreakDays,
      tasksCompletedCount: tasksCompletedCount,
      achievementsCount: achievementsCount,
      avatarState: avatarState,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
