import 'package:json_annotation/json_annotation.dart';
import '../../domain/models/family_model.dart';

part 'family_dto.g.dart';

@JsonSerializable()
class FamilyDto {
  final String id;
  @JsonKey(name: 'owner_user_id')
import '../../domain/models/family_model.dart';

class FamilyDto {
  final String id;
  final String ownerUserId;
  final String name;
  final String timezone;
  final List<ChildSummaryDto> children;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime createdAt;
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
  factory FamilyDto.fromJson(Map<String, dynamic> json) {
    return FamilyDto(
      id: json['id'] as String? ?? '',
      ownerUserId: json['owner_user_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      timezone: json['timezone'] as String? ?? '',
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => ChildSummaryDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_user_id': ownerUserId,
      'name': name,
      'timezone': timezone,
      'children': children.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

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

  factory ChildSummaryDto.fromJson(Map<String, dynamic> json) {
    return ChildSummaryDto(
      id: json['id'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      coinsBalance: json['coins_balance'] as int? ?? 0,
      level: json['level'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'age': age,
      'coins_balance': coinsBalance,
      'level': level,
    };
  }


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

@JsonSerializable()
class FamilyCreateDto {
  final String name;
  final String timezone;

  FamilyCreateDto({
    required this.name,
    required this.timezone,
  });

  factory FamilyCreateDto.fromJson(Map<String, dynamic> json) => _$FamilyCreateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FamilyCreateDtoToJson(this);

  factory FamilyCreateDto.fromJson(Map<String, dynamic> json) {
    return FamilyCreateDto(
      name: json['name'] as String? ?? '',
      timezone: json['timezone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'timezone': timezone,
    };
  }
}
