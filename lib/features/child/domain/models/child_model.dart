class ChildModel {
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

  const ChildModel({
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
}
