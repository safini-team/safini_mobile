import 'package:dartz/dartz.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';

abstract class IParentAppUsageRepository {
  /// GET /v1/children/{child_id}/app-usage
  Future<Either<Failure, List<ChildAppUsageModel>>> fetchAppUsage(
    String childId,
  );

  /// PUT /v1/children/{child_id}/app-rules/{app_slug}
  Future<Either<Failure, Unit>> updateAppRule(
    String childId,
    ChildAppUsageModel rule,
  );

  /// GET /v1/children/{child_id}/dashboard → the child's chosen face emoji
  /// (from `avatar_state.emojis.face`), or null when not set.
  Future<String?> fetchChildFaceEmoji(String childId);
}
