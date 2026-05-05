import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../models/child_invite_code_model.dart';
import '../models/family_model.dart';
import '../models/parent_invite_code_model.dart';
import '../repositories/i_family_repository.dart';
import '../../../../core/utils/error/failures.dart';

@lazySingleton
class FamilyController {
  final IFamilyRepository _repository;

  FamilyController(this._repository);

  Future<Either<Failure, FamilyModel>> createFamily(
    String name,
    String timezone,
  ) => _repository.createFamily(name, timezone);
  Future<Either<Failure, FamilyModel>> joinFamily(String inviteCode) =>
      _repository.joinFamily(inviteCode);
  Future<Either<Failure, FamilyModel>> getCurrentFamily() =>
      _repository.getCurrentFamily();
  Future<Either<Failure, ParentInviteCodeModel>> createParentInviteCode() =>
      _repository.createParentInviteCode();
  Future<Either<Failure, ChildInviteCodeModel>> createChildInviteCode(
    String childId,
  ) => _repository.createChildInviteCode(childId);
}
