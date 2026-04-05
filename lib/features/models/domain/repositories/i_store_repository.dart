import 'package:dartz/dartz.dart';
import '../models/store_model.dart';
import '../../../../core/error/failures.dart';

abstract class IStoreRepository {
  Future<Either<Failure, List<WalletHistoryModel>>> getWalletHistory(String childId);
  Future<Either<Failure, List<StoreOfferModel>>> getStoreOffers();
  Future<Either<Failure, RedemptionResultModel>> redeemOffer(String childId, String offerId);
}
