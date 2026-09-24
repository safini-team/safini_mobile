import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/prizes/prize.dart';

/// Every open ask and wish in the family, for "Needs your review" on Today.
class PrizeAsksCubit extends Cubit<List<PrizeRequest>> {
  PrizeAsksCubit(this._api) : super(const []);

  final PrizeApi _api;

  /// Ids with an answer in flight, so a double tap sends one answer.
  final Set<String> _answering = {};

  Future<void> load() async {
    try {
      final asks = await _api.familyRequests();
      if (!isClosed) emit(asks);
    } catch (_) {
      // Today still shows tasks; the asks come back on the next refresh.
    }
  }

  /// Returns an error message to show, or null when it worked.
  Future<String?> answer(
    PrizeRequest request, {
    required bool approve,
    int? coinCost,
  }) async {
    if (!_answering.add(request.id)) return null;
    try {
      if (approve) {
        await _api.approve(
          request.id,
          coinCost: request.isWish ? coinCost : null,
        );
      } else {
        await _api.decline(request.id);
      }
      if (!isClosed) emit(state.where((r) => r.id != request.id).toList());
      return null;
    } catch (error) {
      await load();
      return prizeErrorDetail(error) ?? '';
    } finally {
      _answering.remove(request.id);
    }
  }
}
