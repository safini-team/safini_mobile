import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_model.freezed.dart';

@freezed
class ChildModel with _$ChildModel {
  const factory ChildModel({
    required String id,
    required String familyId,
    required String nickname,
    required int age,
    required String gender,
    required AvatarStateModel avatarState,
    required int level,
    required int xp,
    required int currentStreakDays,
    required int longestStreakDays,
    required int tasksCompletedCount,
    required int coinsBalance,
    required int achievementsCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ChildModel;
}

@freezed
class AvatarStateModel with _$AvatarStateModel {
  const factory AvatarStateModel({
    required Map<String, String> equipped,
  }) = _AvatarStateModel;
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
    return ChildModel(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      nickname: json['nickname'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      avatarState: AvatarStateModel.fromJson(json['avatarState'] as Map<String, dynamic>),
      level: json['level'] as int,
      xp: json['xp'] as int,
      currentStreakDays: json['currentStreakDays'] as int,
      longestStreakDays: json['longestStreakDays'] as int,
      tasksCompletedCount: json['tasksCompletedCount'] as int,
      coinsBalance: json['coinsBalance'] as int,
      achievementsCount: json['achievementsCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
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

  const AvatarStateModel({
    required this.equipped,
  });

  factory AvatarStateModel.fromJson(Map<String, dynamic> json) {
    return AvatarStateModel(
      equipped: Map<String, String>.from(json['equipped'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipped': equipped,
    };
  }
}
