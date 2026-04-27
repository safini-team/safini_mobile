import 'package:safini/features/models/domain/models/family_model.dart';

enum ParentFamilyStage {
  decision,
  create,
  join,
  dashboard,
}

class ParentFamilyState {
  final ParentFamilyStage stage;
  final bool isLoading;
  final FamilyModel? family;
  final String? errorMessage;
  final String? joinCodeError;
  final bool canRetry;
  final bool isUnauthorized;

  const ParentFamilyState({
    required this.stage,
    required this.isLoading,
    this.family,
    this.errorMessage,
    this.joinCodeError,
    this.canRetry = false,
    this.isUnauthorized = false,
  });

  factory ParentFamilyState.initial({FamilyModel? family, ParentFamilyStage? stage}) {
    return ParentFamilyState(
      stage: family != null ? ParentFamilyStage.dashboard : stage ?? ParentFamilyStage.decision,
      isLoading: false,
      family: family,
    );
  }

  bool get hasFamily => family != null;
  bool get isDashboard => stage == ParentFamilyStage.dashboard;
  bool get isDecision => stage == ParentFamilyStage.decision;
  bool get isCreate => stage == ParentFamilyStage.create;
  bool get isJoin => stage == ParentFamilyStage.join;

  ParentFamilyState copyWith({
    ParentFamilyStage? stage,
    bool? isLoading,
    FamilyModel? family,
    String? errorMessage,
    String? joinCodeError,
    bool? canRetry,
    bool? isUnauthorized,
    bool keepFamily = false,
    bool clearFamily = false,
  }) {
    return ParentFamilyState(
      stage: stage ?? this.stage,
      isLoading: isLoading ?? this.isLoading,
      family: clearFamily ? null : (keepFamily ? this.family : family ?? this.family),
      errorMessage: errorMessage,
      joinCodeError: joinCodeError,
      canRetry: canRetry ?? this.canRetry,
      isUnauthorized: isUnauthorized ?? this.isUnauthorized,
    );
  }
}
