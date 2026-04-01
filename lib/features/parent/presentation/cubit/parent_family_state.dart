import 'package:safini/features/child/domain/models/child_model.dart';
import 'package:safini/features/parent/domain/models/parent_user_model.dart';

abstract class ParentFamilyState {
  const ParentFamilyState();
}

class ParentFamilyInitial extends ParentFamilyState {
  const ParentFamilyInitial();
}

class ParentFamilyLoading extends ParentFamilyState {
  const ParentFamilyLoading();
}

class ParentFamilyLoaded extends ParentFamilyState {
  final List<ChildModel> children;
  final ParentUserModel parent;

  const ParentFamilyLoaded({
    required this.children,
    required this.parent,
  });
}

class ParentFamilyError extends ParentFamilyState {
  final String message;
  const ParentFamilyError(this.message);
}
