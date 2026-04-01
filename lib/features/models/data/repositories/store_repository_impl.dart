import 'package:dartz/dartz.dart';
import '../../domain/models/store_model.dart';
import '../../domain/repositories/i_store_repository.dart';
import '../../../../core/error/failures.dart';

class StoreRepositoryImpl implements IStoreRepository {
  @override
  Future<Either<Failure, List<WalletHistoryModel>>> getWalletHistory(String childId) async {
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, List<StoreOfferModel>>> getStoreOffers() async {
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, RedemptionResultModel>> redeemOffer(String childId, String offerId) async {
    return const Left(ServerFailure('Not implemented'));
  }
}
