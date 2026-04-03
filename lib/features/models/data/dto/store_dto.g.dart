// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletHistoryDto _$WalletHistoryDtoFromJson(Map<String, dynamic> json) =>
    WalletHistoryDto(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      amount: (json['amount'] as num).toInt(),
      transactionType: json['transaction_type'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$WalletHistoryDtoToJson(WalletHistoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'child_id': instance.childId,
      'amount': instance.amount,
      'transaction_type': instance.transactionType,
      'description': instance.description,
      'created_at': instance.createdAt.toIso8601String(),
    };

StoreOfferDto _$StoreOfferDtoFromJson(Map<String, dynamic> json) =>
    StoreOfferDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      coinsPrice: (json['coins_price'] as num).toInt(),
      isAvailable: json['is_available'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$StoreOfferDtoToJson(StoreOfferDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'coins_price': instance.coinsPrice,
      'is_available': instance.isAvailable,
      'created_at': instance.createdAt.toIso8601String(),
    };

RedemptionResultDto _$RedemptionResultDtoFromJson(Map<String, dynamic> json) =>
    RedemptionResultDto(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      offerId: json['offer_id'] as String,
      newBalance: (json['new_balance'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$RedemptionResultDtoToJson(
  RedemptionResultDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'child_id': instance.childId,
  'offer_id': instance.offerId,
  'new_balance': instance.newBalance,
  'created_at': instance.createdAt.toIso8601String(),
};
