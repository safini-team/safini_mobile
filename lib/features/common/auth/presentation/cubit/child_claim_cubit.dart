import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/child_claim_state.dart';
import 'package:safini/features/models/domain/controllers/child_controller.dart';

class ChildClaimCubit extends Cubit<ChildClaimState> {
  final ChildController _childController;
  final AuthSessionCubit _authSessionCubit;

  ChildClaimCubit(this._childController, this._authSessionCubit)
    : super(const ChildClaimState.initial());

  Future<Failure?> claimChild(String inviteCode) async {
    emit(
      state.copyWith(
        status: ChildClaimStatus.loading,
        errorMessage: null,
        clearChild: true,
      ),
    );

    final result = await _childController.claimChild(inviteCode);

    Failure? capturedFailure;
    await result.fold(
      (failure) async {
        if (failure is UnauthorizedFailure) {
          await _authSessionCubit.forceSignOut(
            failure.message.isEmpty
                ? 'Invalid or expired session token.'
                : failure.message,
          );
        }
        capturedFailure = failure;
        emit(
          state.copyWith(
            status: ChildClaimStatus.error,
            errorMessage: _toUiMessage(failure),
            clearChild: true,
          ),
        );
      },
      (child) async {
        capturedFailure = null;
        emit(
          state.copyWith(
            status: ChildClaimStatus.success,
            child: child,
            errorMessage: null,
          ),
        );
      },
    );

    return capturedFailure;
  }

  void clearError() {
    emit(state.copyWith(status: ChildClaimStatus.initial, errorMessage: null));
  }

  String _toUiMessage(Failure failure) {
    if (failure is UnauthorizedFailure) {
      return 'Invalid or expired token. Please sign in again.';
    }
    if (failure is ValidationFailure) {
      return failure.message;
    }
    if (failure is ServerFailure) {
      return failure.message;
    }
    if (failure is NetworkFailure) {
      return 'Network error. Please check your connection and try again.';
    }
    return 'Unable to continue right now. Please try again.';
  }
}
