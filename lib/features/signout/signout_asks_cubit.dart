import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/signout/signout_request.dart';

/// Children asking to sign out, for "Needs your review" on Today (SAF-191).
class SignoutAsksCubit extends Cubit<List<SignoutRequest>> {
  SignoutAsksCubit(this._api) : super(const []);

  final SignoutApi _api;

  /// Ids with an answer in flight, so a double tap sends one answer.
  final Set<String> _answering = {};

  Future<void> load() async {
    try {
      final asks = await _api.pending();
      if (!isClosed) emit(asks);
    } catch (_) {
      // Today still shows the rest; the asks come back on the next refresh.
    }
  }

  /// Returns an error message to show, empty for a generic one, or null when
  /// it worked. An ask someone already answered (409) just leaves the list.
  Future<String?> answer(
    SignoutRequest request, {
    required bool approve,
  }) async {
    if (!_answering.add(request.id)) return null;
    try {
      await _api.answer(request, approve: approve);
      if (!isClosed) emit(state.where((r) => r.id != request.id).toList());
      return null;
    } on DioException catch (error) {
      await load();
      if (error.response?.statusCode == 409) return null;
      final detail = error.response?.data is Map
          ? (error.response!.data as Map)['detail']
          : null;
      return detail is String ? detail : '';
    } catch (_) {
      await load();
      return '';
    } finally {
      _answering.remove(request.id);
    }
  }
}
