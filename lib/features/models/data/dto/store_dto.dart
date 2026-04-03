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
import '../../domain/models/store_model.dart';

class WalletHistoryDto {
  final String id;
  final String childId;
  final int amount;
  final String transactionType;
  final String description;
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

  factory WalletHistoryDto.fromJson(Map<String, dynamic> json) {
    return WalletHistoryDto(
      id: json['id'] as String? ?? '',
      childId: json['child_id'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      transactionType: json['transaction_type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'amount': amount,
      'transaction_type': transactionType,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

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

  final int coinsPrice;
  final bool isAvailable;
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

  factory StoreOfferDto.fromJson(Map<String, dynamic> json) {
    return StoreOfferDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      coinsPrice: json['coins_price'] as int? ?? 0,
      isAvailable: json['is_available'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'coins_price': coinsPrice,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
    };
  }

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

class RedemptionResultDto {
  final String id;
  final String childId;
  final String offerId;
  final int newBalance;
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
  factory RedemptionResultDto.fromJson(Map<String, dynamic> json) {
    return RedemptionResultDto(
      id: json['id'] as String? ?? '',
      childId: json['child_id'] as String? ?? '',
      offerId: json['offer_id'] as String? ?? '',
      newBalance: json['new_balance'] as int? ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'offer_id': offerId,
      'new_balance': newBalance,
      'created_at': createdAt.toIso8601String(),
    };
  }

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
