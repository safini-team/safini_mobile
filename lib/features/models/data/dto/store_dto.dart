import 'package:json_annotation/json_annotation.dart';
import '../../domain/models/store_model.dart';

part 'store_dto.g.dart';

@JsonSerializable()
class WalletHistoryDto {
  final String id;
  @JsonKey(name: 'child_id')
  final String childId;
  final int amount;
  @JsonKey(name: 'transaction_type')
  final String transactionType;
  final String description;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  WalletHistoryDto({
    required this.id,
    required this.childId,
    required this.amount,
    required this.transactionType,
    required this.description,
    required this.createdAt,
  });

  factory WalletHistoryDto.fromJson(Map<String, dynamic> json) => _$WalletHistoryDtoFromJson(json);
  Map<String, dynamic> toJson() => _$WalletHistoryDtoToJson(this);

  WalletHistoryModel toDomain() {
    return WalletHistoryModel(
      id: id,
      childId: childId,
      amount: amount,
      transactionType: transactionType,
      description: description,
      createdAt: createdAt,
    );
  }
}

@JsonSerializable()
class StoreOfferDto {
  final String id;
  final String title;
  final String description;
  final String category;
  @JsonKey(name: 'coins_price')
  final int coinsPrice;
  @JsonKey(name: 'is_available')
  final bool isAvailable;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  StoreOfferDto({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.coinsPrice,
    required this.isAvailable,
    required this.createdAt,
  });

  factory StoreOfferDto.fromJson(Map<String, dynamic> json) => _$StoreOfferDtoFromJson(json);
  Map<String, dynamic> toJson() => _$StoreOfferDtoToJson(this);

  StoreOfferModel toDomain() {
    return StoreOfferModel(
      id: id,
      title: title,
      description: description,
      category: category,
      coinsPrice: coinsPrice,
      isAvailable: isAvailable,
      createdAt: createdAt,
    );
  }
}

@JsonSerializable()
class RedemptionResultDto {
  final String id;
  @JsonKey(name: 'child_id')
  final String childId;
  @JsonKey(name: 'offer_id')
  final String offerId;
  @JsonKey(name: 'new_balance')
  final int newBalance;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  RedemptionResultDto({
    required this.id,
    required this.childId,
    required this.offerId,
    required this.newBalance,
    required this.createdAt,
  });

  factory RedemptionResultDto.fromJson(Map<String, dynamic> json) => _$RedemptionResultDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RedemptionResultDtoToJson(this);

  RedemptionResultModel toDomain() {
    return RedemptionResultModel(
      id: id,
      childId: childId,
      offerId: offerId,
      newBalance: newBalance,
      createdAt: createdAt,
    );
  }
}
