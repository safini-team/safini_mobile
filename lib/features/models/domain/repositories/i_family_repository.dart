import 'package:dartz/dartz.dart';
import '../models/child_invite_code_model.dart';
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
}
