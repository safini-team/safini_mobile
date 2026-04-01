import 'package:json_annotation/json_annotation.dart';
import '../../domain/models/family_model.dart';

part 'family_dto.g.dart';

@JsonSerializable()
class FamilyDto {
  final String id;
  @JsonKey(name: 'owner_user_id')
  final String ownerUserId;
  final String name;
  final String timezone;
  final List<ChildSummaryDto> children;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  FamilyDto({
    required this.id,
    required this.ownerUserId,
    required this.name,
    required this.timezone,
    required this.children,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FamilyDto.fromJson(Map<String, dynamic> json) => _$FamilyDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FamilyDtoToJson(this);

  FamilyModel toDomain() {
    return FamilyModel(
      id: id,
      ownerUserId: ownerUserId,
      name: name,
      timezone: timezone,
      children: children.map((e) => e.toDomain()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

@JsonSerializable()
class ChildSummaryDto {
  final String id;
  final String nickname;
  final int age;
  @JsonKey(name: 'coins_balance')
  final int coinsBalance;
  final int level;

  ChildSummaryDto({
    required this.id,
    required this.nickname,
    required this.age,
    required this.coinsBalance,
    required this.level,
  });

  factory ChildSummaryDto.fromJson(Map<String, dynamic> json) => _$ChildSummaryDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ChildSummaryDtoToJson(this);

  ChildSummaryModel toDomain() {
    return ChildSummaryModel(
      id: id,
      nickname: nickname,
      age: age,
      coinsBalance: coinsBalance,
      level: level,
    );
  }
}
