import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/common/auth/domain/usecases/select_role_usecase.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_role_state.dart';

class AuthRoleCubit extends Cubit<AuthRoleState> {
  final SelectRoleUseCase _selectRoleUseCase;

  AuthRoleCubit(this._selectRoleUseCase) : super(const AuthRoleState.initial());

  Future<void> selectRole(String role) async {
    emit(state.copyWith(status: AuthRoleStatus.saving));
    try {
      await _selectRoleUseCase(role);
      emit(
        state.copyWith(
          status: AuthRoleStatus.saved,
          selectedRole: role,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthRoleStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
