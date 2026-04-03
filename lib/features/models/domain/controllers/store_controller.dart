import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../models/store_model.dart';
import '../repositories/i_store_repository.dart';
import '../../../../core/error/failures.dart';

@lazySingleton
class StoreController {
  final IStoreRepository _repository;

  StoreController(this._repository);

  Future<Either<Failure, List<WalletHistoryModel>>> getWalletHistory(String childId) => _repository.getWalletHistory(childId);
  Future<Either<Failure, List<StoreOfferModel>>> getStoreOffers() => _repository.getStoreOffers();
  Future<Either<Failure, RedemptionResultModel>> redeemOffer(String childId, String offerId) => _repository.redeemOffer(childId, offerId);
}
