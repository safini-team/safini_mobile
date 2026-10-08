import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/subscription/family_plan.dart';
import 'package:safini/features/subscription/pro_store.dart';

/// One-shot messages for the paywall; [ProState.noticeSeq] makes a repeat
/// of the same one show again.
enum ProNotice {
  none,
  welcome,
  restored,
  nothingToRestore,
  pending,
  failed,
  otherFamily,
}

class ProState {
  const ProState({
    this.plan,
    this.offers = const [],
    this.loadingOffers = false,
    this.offersFailed = false,
    this.busy = false,
    this.notice = ProNotice.none,
    this.noticeSeq = 0,
  });

  /// Null until the server answered.
  final FamilyPlan? plan;
  final List<ProOffer> offers;
  final bool loadingOffers;
  final bool offersFailed;

  /// A purchase or restore is in flight.
  final bool busy;
  final ProNotice notice;
  final int noticeSeq;

  bool get isPro => plan?.isPro ?? false;

  ProOffer? offer(ProPeriod period) {
    for (final offer in offers) {
      if (offer.period == period) return offer;
    }
    return null;
  }

  /// How much the year saves against twelve months, in whole percent.
  int? get yearlySavingPercent {
    final month = offer(ProPeriod.month);
    final year = offer(ProPeriod.year);
    if (month == null || year == null || month.rawPrice <= 0) return null;
    final saving = 1 - year.rawPrice / (month.rawPrice * 12);
    return saving > 0 ? (saving * 100).round() : null;
  }

  ProState copyWith({
    FamilyPlan? plan,
    List<ProOffer>? offers,
    bool? loadingOffers,
    bool? offersFailed,
    bool? busy,
  }) => ProState(
    plan: plan ?? this.plan,
    offers: offers ?? this.offers,
    loadingOffers: loadingOffers ?? this.loadingOffers,
    offersFailed: offersFailed ?? this.offersFailed,
    busy: busy ?? this.busy,
    notice: notice,
    noticeSeq: noticeSeq,
  );

  ProState withNotice(ProNotice notice, {FamilyPlan? plan}) => ProState(
    plan: plan ?? this.plan,
    offers: offers,
    loadingOffers: loadingOffers,
    offersFailed: offersFailed,
    notice: notice,
    noticeSeq: noticeSeq + 1,
  );
}

/// Safini Pro for the signed-in parent's family (SAF-213).
///
/// StoreKit says what Apple charged; the server decides whether the family is
/// Pro. Every transaction goes to the server and is finished only once the
/// server took it, so a dropped connection never loses a purchase: StoreKit
/// hands the unfinished one back on the next launch.
class ProCubit extends Cubit<ProState> {
  ProCubit({required PlanApi api, ProStore? store})
    : _api = api,
      _store = store,
      super(const ProState());

  final PlanApi _api;

  /// Null where the app sells nothing (Android).
  final ProStore? _store;
  StreamSubscription<List<StoreUpdate>>? _updates;
  String? _familyId;
  bool _restoring = false;

  bool get canSell => _store != null;

  /// Called when a parent's home opens: listens for renewals and purchases
  /// from other devices, delivers leftovers, and reads the plan.
  Future<void> start() async {
    final store = _store;
    if (store != null && _updates == null) {
      _updates = store.updates.listen(_onUpdates);
    }
    _familyId = null;
    await refresh();
    await _deliverUnfinished();
  }

  Future<void> refresh() async {
    try {
      final plan = await _api.current();
      if (!isClosed) emit(state.copyWith(plan: plan));
    } catch (_) {
      // The plan stays as it was; the next open tries again.
    }
  }

  Future<void> loadOffers() async {
    final store = _store;
    if (store == null || state.loadingOffers) return;
    emit(state.copyWith(loadingOffers: true, offersFailed: false));
    try {
      final offers = await store.offers();
      if (isClosed) return;
      emit(
        state.copyWith(
          offers: offers,
          loadingOffers: false,
          offersFailed: offers.isEmpty,
        ),
      );
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(loadingOffers: false, offersFailed: true));
      }
    }
  }

  Future<void> buy(ProPeriod period) async {
    final store = _store;
    final offer = state.offer(period);
    if (store == null || offer == null || state.busy) return;
    emit(state.copyWith(busy: true));
    try {
      await _deliverUnfinished();
      _familyId ??= await _api.familyId();
      await store.buy(offer, accountToken: _familyId!);
    } catch (_) {
      if (!isClosed) emit(state.withNotice(ProNotice.failed));
    }
  }

  Future<void> restore() async {
    final store = _store;
    if (store == null || state.busy) return;
    emit(state.copyWith(busy: true));
    _restoring = true;
    try {
      await store.restore();
    } catch (_) {
      _restoring = false;
      if (!isClosed) emit(state.withNotice(ProNotice.failed));
    }
  }

  Future<void> _onUpdates(List<StoreUpdate> updates) async {
    if (_restoring && updates.isEmpty) {
      _restoring = false;
      emit(state.withNotice(ProNotice.nothingToRestore));
      return;
    }
    for (final update in updates) {
      if (!ProProducts.all.contains(update.productId)) continue;
      switch (update.kind) {
        case StoreUpdateKind.purchased:
        case StoreUpdateKind.restored:
          // A renewal or a purchase on another device updates the plan
          // without a message; only what the parent just tapped gets one.
          await _deliver(update, quiet: !state.busy && !_restoring);
        case StoreUpdateKind.pending:
          emit(state.withNotice(ProNotice.pending));
        case StoreUpdateKind.canceled:
          emit(state.copyWith(busy: false));
        case StoreUpdateKind.failed:
          emit(state.withNotice(ProNotice.failed));
      }
    }
    _restoring = false;
  }

  Future<void> _deliverUnfinished() async {
    final store = _store;
    if (store == null) return;
    try {
      for (final update in await store.unfinished()) {
        await _deliver(update, quiet: true);
      }
    } catch (_) {
      // Transaction.updates hands them over at the next launch anyway.
    }
  }

  Future<void> _deliver(StoreUpdate update, {bool quiet = false}) async {
    final store = _store!;
    final restoring = _restoring || update.kind == StoreUpdateKind.restored;
    try {
      final plan = await _api.recordAppleTransaction(update.signedTransaction);
      await store.finish(update);
      if (isClosed) return;
      if (quiet) {
        emit(state.copyWith(plan: plan));
      } else {
        emit(
          state.withNotice(
            restoring ? ProNotice.restored : ProNotice.welcome,
            plan: plan,
          ),
        );
      }
    } on DioException catch (error) {
      if (error.response?.statusCode == 409) {
        // Bought for another Safini family. Retrying can never succeed, so
        // the transaction is finished instead of resent forever.
        await store.finish(update);
        if (!isClosed) emit(state.withNotice(ProNotice.otherFamily));
        return;
      }
      if (!isClosed && !quiet) emit(state.withNotice(ProNotice.failed));
    } catch (_) {
      if (!isClosed && !quiet) emit(state.withNotice(ProNotice.failed));
    }
  }

  @override
  Future<void> close() async {
    await _updates?.cancel();
    return super.close();
  }
}
