import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/prizes/prize.dart';

class ParentPrizesState {
  const ParentPrizesState({
    this.childId,
    this.list = const PrizeList.empty(),
    this.isLoading = false,
    this.hasError = false,
  });

  final String? childId;
  final PrizeList list;
  final bool isLoading;
  final bool hasError;

  List<Prize> get prizes => list.prizes;
}

/// One child's prizes, for the parent's Limits → Prizes list.
class ParentPrizesCubit extends Cubit<ParentPrizesState> {
  ParentPrizesCubit(this._api) : super(const ParentPrizesState());

  final PrizeApi _api;

  // Every child seen, so a switch shows their prizes at once while the
  // fresh list loads behind them.
  final _byChild = <String, PrizeList>{};

  @override
  void onChange(Change<ParentPrizesState> change) {
    super.onChange(change);
    final next = change.nextState;
    final id = next.childId;
    if (id != null && !next.isLoading && !next.hasError) {
      _byChild[id] = next.list;
    }
  }

  Future<void> load([String? childId]) async {
    final id = childId ?? state.childId;
    if (id == null || id.isEmpty) return;
    final switched = id != state.childId;
    final cached = switched ? _byChild[id] : state.list;
    emit(
      ParentPrizesState(
        childId: id,
        list: cached ?? const PrizeList.empty(),
        isLoading: cached == null || cached.prizes.isEmpty,
      ),
    );
    try {
      final list = await _api.list(id);
      if (isClosed || state.childId != id) return;
      emit(ParentPrizesState(childId: id, list: list));
    } catch (_) {
      if (isClosed || state.childId != id) return;
      emit(ParentPrizesState(childId: id, list: state.list, hasError: true));
    }
  }

  /// Returns an error message to show, or null when it worked.
  Future<String?> add({
    required String title,
    required int coinCost,
    String? emoji,
    String? note,
    String? templateKey,
  }) => _run(
    () => _api.create(
      state.childId!,
      title: title,
      coinCost: coinCost,
      emoji: emoji,
      note: note,
      templateKey: templateKey,
    ),
  );

  Future<String?> save(
    Prize prize, {
    required String title,
    required int coinCost,
    String? emoji,
    String? note,
  }) => _run(
    () => _api.update(
      prize.id,
      title: title,
      coinCost: coinCost,
      emoji: emoji,
      note: note,
    ),
  );

  Future<String?> remove(Prize prize) => _run(() => _api.delete(prize.id));

  Future<String?> _run(Future<Object?> Function() call) async {
    if (state.childId == null) return '';
    try {
      await call();
      await load();
      return null;
    } catch (error) {
      return prizeErrorDetail(error) ?? '';
    }
  }
}
