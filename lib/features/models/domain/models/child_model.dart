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
}
