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
class FamilyModel {
  final String id;
  final String ownerUserId;
  final String name;
  final String timezone;
  final List<ChildSummaryModel> children;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FamilyModel({
    required this.id,
    required this.ownerUserId,
    required this.name,
    required this.timezone,
    required this.children,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    return FamilyModel(
      id: json['id'] as String,
      ownerUserId: json['ownerUserId'] as String,
      name: json['name'] as String,
      timezone: json['timezone'] as String,
      children: (json['children'] as List<dynamic>)
          .map((e) => ChildSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerUserId': ownerUserId,
      'name': name,
      'timezone': timezone,
      'children': children.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ChildSummaryModel {
  final String id;
  final String nickname;
  final int age;
  final int coinsBalance;
  final int level;

  const ChildSummaryModel({
    required this.id,
    required this.nickname,
    required this.age,
    required this.coinsBalance,
    required this.level,
  });

  factory ChildSummaryModel.fromJson(Map<String, dynamic> json) {
    return ChildSummaryModel(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      age: json['age'] as int,
      coinsBalance: json['coinsBalance'] as int,
      level: json['level'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'age': age,
      'coinsBalance': coinsBalance,
      'level': level,
    };
  }
}
