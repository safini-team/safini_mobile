import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/fini/data/fini_repository.dart';
import 'package:safini/features/fini/domain/fini_models.dart';

/// Pending Fini cards across the family: the number on the Fini tab and the
/// dot on each child's circle. A failed refresh keeps the last count.
class FiniInboxCubit extends Cubit<FiniInbox> {
  FiniInboxCubit(this._repo) : super(const FiniInbox());

  final FiniRepository _repo;

  Future<void> refresh() async {
    try {
      final inbox = await _repo.inbox();
      if (!isClosed) emit(inbox);
    } catch (_) {}
  }
}
