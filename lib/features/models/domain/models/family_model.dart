import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_model.freezed.dart';

@freezed
class FamilyModel with _$FamilyModel {
  const factory FamilyModel({
    required String id,
    required String ownerUserId,
    required String name,
    required String timezone,
    required List<ChildSummaryModel> children,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FamilyModel;
}

@freezed
class ChildSummaryModel with _$ChildSummaryModel {
  const factory ChildSummaryModel({
    required String id,
    required String nickname,
    required int age,
    required int coinsBalance,
    required int level,
  }) = _ChildSummaryModel;
}
