import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_model.freezed.dart';

@freezed
class WalletHistoryModel with _$WalletHistoryModel {
  const factory WalletHistoryModel({
    required String id,
    required String childId,
    required int amount,
    required String transactionType,
    required String description,
    required DateTime createdAt,
  }) = _WalletHistoryModel;
}

@freezed
class StoreOfferModel with _$StoreOfferModel {
  const factory StoreOfferModel({
    required String id,
    required String title,
    required String description,
    required String category,
    required int coinsPrice,
    required bool isAvailable,
    required DateTime createdAt,
  }) = _StoreOfferModel;
}

@freezed
class RedemptionResultModel with _$RedemptionResultModel {
  const factory RedemptionResultModel({
    required String id,
    required String childId,
    required String offerId,
    required int newBalance,
    required DateTime createdAt,
  }) = _RedemptionResultModel;
}
