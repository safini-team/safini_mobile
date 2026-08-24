import 'package:dartz/dartz.dart';
import '../models/child_invite_code_model.dart';
import '../models/child_model.dart';
import '../models/parent_invite_code_model.dart';
import '../models/family_model.dart';
import '../../../../core/utils/error/failures.dart';

abstract class IFamilyRepository {
  Future<Either<Failure, FamilyModel>> createFamily(
    String name,
    String timezone,
  );
  Future<Either<Failure, FamilyModel>> joinFamily(String inviteCode);
  Future<Either<Failure, FamilyModel>> getCurrentFamily();
  Future<Either<Failure, ParentInviteCodeModel>> createParentInviteCode();
  Future<Either<Failure, ChildInviteCodeModel>> createChildInviteCode(
    String childId,
  );
  Future<Either<Failure, ChildModel>> createChild({
    required String nickname,
    required int age,
    String? gender,
  });
  /// PATCH /v1/children/{child_id}. [clearDailyScreenTime] is the only way to
  /// send `daily_screen_time_minutes: null`, which is what removes a cap - a
  /// plain null argument is indistinguishable from "leave it alone".
  Future<Either<Failure, ChildModel>> updateChild(
    String childId, {
    String? nickname,
    int? age,
    String? gender,
    int? dailyScreenTimeMinutes,
    bool clearDailyScreenTime = false,
  });
  Future<Either<Failure, void>> removeParent(String parentUserId);
}
