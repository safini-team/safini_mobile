import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../models/app_model.dart';
import '../repositories/i_app_repository.dart';
import '../../../../core/error/failures.dart';

@lazySingleton
class AppController {
  final IAppRepository _repository;

  AppController(this._repository);

  Future<Either<Failure, List<AppRuleModel>>> getAppRules(String childId) => _repository.getAppRules(childId);
  Future<Either<Failure, AppRuleModel>> updateAppRule(String ruleId, {int? dailyLimitMinutes, bool? isBlocked}) => 
      _repository.updateAppRule(ruleId, dailyLimitMinutes: dailyLimitMinutes, isBlocked: isBlocked);
  Future<Either<Failure, Unit>> reportUsage(String childId, List<AppUsageReportModel> reports) => _repository.reportUsage(childId, reports);
  Future<Either<Failure, Unit>> redeemTime(String ruleId, int minutes) => _repository.redeemTime(ruleId, minutes);
}
