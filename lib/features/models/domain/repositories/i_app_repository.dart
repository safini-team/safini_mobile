import 'package:dartz/dartz.dart';
import '../models/app_model.dart';
import '../../../../core/error/failures.dart';

abstract class IAppRepository {
  Future<Either<Failure, List<AppRuleModel>>> getAppRules(String childId);
  Future<Either<Failure, AppRuleModel>> updateAppRule(String ruleId, {int? dailyLimitMinutes, bool? isBlocked});
  Future<Either<Failure, Unit>> reportUsage(String childId, List<AppUsageReportModel> reports);
  Future<Either<Failure, Unit>> redeemTime(String ruleId, int minutes);
}
