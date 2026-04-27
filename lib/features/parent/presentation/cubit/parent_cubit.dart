import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/parent/domain/controllers/parent_controller.dart';
import 'package:safini/features/parent/presentation/cubit/parent_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ParentCubit extends Cubit<ParentState> {
  final ParentController _controller;
  final SupabaseClient _supabase;

  ParentCubit(this._controller, this._supabase) : super(const ParentState.initial());

  Future<void> loadProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    emit(state.copyWith(isLoading: true));
    
    final result = await _controller.getParentProfile(userId);
    
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false)),
      (user) => emit(state.copyWith(isLoading: false, user: user)),
    );
  }
}
