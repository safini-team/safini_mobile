import 'package:safini/core/utils/display_name.dart';
class ChildModel {
  final String id;
  final String familyId;
  final String nickname;
  final int age;
  final String gender;
  final AvatarStateModel avatarState;
  final int level;
  final int xp;
  final int currentStreakDays;
  final int longestStreakDays;
  final int tasksCompletedCount;
  final int coinsBalance;
  final int achievementsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChildModel({
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

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    final avatarStateRaw = json['avatarState'] ?? json['avatar_state'];
    final avatarStateJson = avatarStateRaw is Map<String, dynamic>
        ? avatarStateRaw
        : <String, dynamic>{};

    return ChildModel(
      id: json['id'] as String,
      familyId: (json['familyId'] ?? json['family_id']) as String,
      nickname: resolveDisplayName(json['nickname']),
      age: json['age'] as int,
      gender: (json['gender'] as String?) ?? '',
      avatarState: AvatarStateModel.fromJson(avatarStateJson),
      level: json['level'] as int,
      xp: json['xp'] as int,
      currentStreakDays:
          (json['currentStreakDays'] ?? json['current_streak_days']) as int,
      longestStreakDays:
          (json['longestStreakDays'] ?? json['longest_streak_days']) as int,
      tasksCompletedCount:
          (json['tasksCompletedCount'] ?? json['tasks_completed_count']) as int,
      coinsBalance: (json['coinsBalance'] ?? json['coins_balance']) as int,
      achievementsCount:
          (json['achievementsCount'] ?? json['achievements_count']) as int,
      createdAt: DateTime.parse(
        (json['createdAt'] ?? json['created_at']) as String,
      ),
      updatedAt: DateTime.parse(
        (json['updatedAt'] ?? json['updated_at']) as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'familyId': familyId,
      'nickname': nickname,
      'age': age,
      'gender': gender,
      'avatarState': avatarState.toJson(),
      'level': level,
      'xp': xp,
      'currentStreakDays': currentStreakDays,
      'longestStreakDays': longestStreakDays,
      'tasksCompletedCount': tasksCompletedCount,
      'coinsBalance': coinsBalance,
      'achievementsCount': achievementsCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class AvatarStateModel {
  final Map<String, String> equipped;

  const AvatarStateModel({required this.equipped});

  /// A child row with no avatar yet (`avatar_state` null) arrives as `{}`.
  /// The hard cast used to throw there, and Save on Edit child spun forever.
  factory AvatarStateModel.fromJson(Map<String, dynamic> json) {
    final equipped = json['equipped'];
    return AvatarStateModel(
      equipped: equipped is Map
          ? Map<String, String>.from(equipped)
          : const <String, String>{},
    );
  }

  Map<String, dynamic> toJson() {
    return {'equipped': equipped};
  }
}
