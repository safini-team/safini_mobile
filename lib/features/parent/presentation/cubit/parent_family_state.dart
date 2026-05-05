import 'package:safini/features/models/domain/models/family_model.dart';

enum ParentFamilyStage { decision, create, join, dashboard }

class ParentFamilyState {
  final ParentFamilyStage stage;
  final bool isLoading;
  final bool isParentInviteCodeLoading;
  final String? issuingChildInviteCodeForId;
  final FamilyModel? family;
  final String? errorMessage;
  final String? joinCodeError;
  final bool canRetry;
  final bool isUnauthorized;

  const ParentFamilyState({
    required this.stage,
    required this.isLoading,
    this.isParentInviteCodeLoading = false,
    this.issuingChildInviteCodeForId,
    this.family,
    this.errorMessage,
    this.joinCodeError,
    this.canRetry = false,
    this.isUnauthorized = false,
  });

  factory ParentFamilyState.initial({
    FamilyModel? family,
    ParentFamilyStage? stage,
  }) {
    return ParentFamilyState(
      stage: family != null
          ? ParentFamilyStage.dashboard
          : stage ?? ParentFamilyStage.decision,
      isLoading: false,
      isParentInviteCodeLoading: false,
      issuingChildInviteCodeForId: null,
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
    bool? isParentInviteCodeLoading,
    String? issuingChildInviteCodeForId,
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
      isParentInviteCodeLoading:
          isParentInviteCodeLoading ?? this.isParentInviteCodeLoading,
      issuingChildInviteCodeForId:
          issuingChildInviteCodeForId ?? this.issuingChildInviteCodeForId,
      family: clearFamily
          ? null
          : (keepFamily ? this.family : family ?? this.family),
      errorMessage: errorMessage,
      joinCodeError: joinCodeError,
      canRetry: canRetry ?? this.canRetry,
      isUnauthorized: isUnauthorized ?? this.isUnauthorized,
    );
  }
}
