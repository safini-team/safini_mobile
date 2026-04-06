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
class WalletHistoryModel {
  final String id;
  final String childId;
  final int amount;
  final String transactionType;
  final String description;
  final DateTime createdAt;

  const WalletHistoryModel({
    required this.id,
    required this.childId,
    required this.amount,
    required this.transactionType,
    required this.description,
    required this.createdAt,
  });

  factory WalletHistoryModel.fromJson(Map<String, dynamic> json) {
    return WalletHistoryModel(
      id: json['id'] as String,
      childId: json['childId'] as String,
      amount: json['amount'] as int,
      transactionType: json['transactionType'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'amount': amount,
      'transactionType': transactionType,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class StoreOfferModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final int coinsPrice;
  final bool isAvailable;
  final DateTime createdAt;

  const StoreOfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.coinsPrice,
    required this.isAvailable,
    required this.createdAt,
  });

  factory StoreOfferModel.fromJson(Map<String, dynamic> json) {
    return StoreOfferModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      coinsPrice: json['coinsPrice'] as int,
      isAvailable: json['isAvailable'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'coinsPrice': coinsPrice,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class RedemptionResultModel {
  final String id;
  final String childId;
  final String offerId;
  final int newBalance;
  final DateTime createdAt;

  const RedemptionResultModel({
    required this.id,
    required this.childId,
    required this.offerId,
    required this.newBalance,
    required this.createdAt,
  });

  factory RedemptionResultModel.fromJson(Map<String, dynamic> json) {
    return RedemptionResultModel(
      id: json['id'] as String,
      childId: json['childId'] as String,
      offerId: json['offerId'] as String,
      newBalance: json['newBalance'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'offerId': offerId,
      'newBalance': newBalance,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
