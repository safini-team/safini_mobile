// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FamilyDto _$FamilyDtoFromJson(Map<String, dynamic> json) => FamilyDto(
  id: json['id'] as String,
  ownerUserId: json['owner_user_id'] as String,
  name: json['name'] as String,
  timezone: json['timezone'] as String,
  children: (json['children'] as List<dynamic>)
      .map((e) => ChildSummaryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$FamilyDtoToJson(FamilyDto instance) => <String, dynamic>{
  'id': instance.id,
  'owner_user_id': instance.ownerUserId,
  'name': instance.name,
  'timezone': instance.timezone,
  'children': instance.children,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

ChildSummaryDto _$ChildSummaryDtoFromJson(Map<String, dynamic> json) =>
    ChildSummaryDto(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      age: (json['age'] as num).toInt(),
      coinsBalance: (json['coins_balance'] as num).toInt(),
      level: (json['level'] as num).toInt(),
    );

Map<String, dynamic> _$ChildSummaryDtoToJson(ChildSummaryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nickname': instance.nickname,
      'age': instance.age,
      'coins_balance': instance.coinsBalance,
      'level': instance.level,
    };

FamilyCreateDto _$FamilyCreateDtoFromJson(Map<String, dynamic> json) =>
    FamilyCreateDto(
      name: json['name'] as String,
      timezone: json['timezone'] as String,
    );

Map<String, dynamic> _$FamilyCreateDtoToJson(FamilyCreateDto instance) =>
    <String, dynamic>{'name': instance.name, 'timezone': instance.timezone};
