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
