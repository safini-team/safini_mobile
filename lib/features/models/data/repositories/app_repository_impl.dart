import 'package:injectable/injectable.dart';

import 'package:dartz/dartz.dart';
import '../../domain/models/app_model.dart';
import '../../domain/repositories/i_app_repository.dart';
import '../../../../core/error/failures.dart';


@Injectable(as: IAppRepository)
class AppRepositoryImpl implements IAppRepository {
  @override
  Future<Either<Failure, List<AppRuleModel>>> getAppRules(String childId) async {
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, AppRuleModel>> updateAppRule(String ruleId, {int? dailyLimitMinutes, bool? isBlocked}) async {
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, Unit>> reportUsage(String childId, List<AppUsageReportModel> reports) async {
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, Unit>> redeemTime(String ruleId, int minutes) async {
    return const Left(ServerFailure('Not implemented'));
  }
}
