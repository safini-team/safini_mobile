import 'package:dartz/dartz.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/parent/domain/models/catalog_app_model.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';

abstract class IParentAppUsageRepository {
  /// GET /v1/apps - every app a parent can control, with its defaults.
  Future<Either<Failure, List<CatalogAppModel>>> fetchCatalog();

  /// GET /v1/children/{child_id}/app-usage - the per-app rows and the child's
  /// whole-device budget for the day.
  Future<Either<Failure, ChildAppUsageSnapshot>> fetchAppUsage(String childId);

  /// PUT /v1/children/{child_id}/app-rules/{app_slug}
  Future<Either<Failure, Unit>> updateAppRule(
    String childId,
    ChildAppUsageModel rule,
  );

  /// GET /v1/children/{child_id}/dashboard → the child's chosen face emoji
  /// (from `avatar_state.emojis.face`), or null when not set.
  Future<String?> fetchChildFaceEmoji(String childId);
}
