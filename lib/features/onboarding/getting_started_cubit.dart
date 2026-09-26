import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/onboarding/onboarding_store.dart';
import 'package:safini/features/prizes/prize.dart';

/// The parent's first-week checklist, in the order it is shown.
enum SetupStep { child, phone, task, limit, prize }

class GettingStarted {
  const GettingStarted({
    this.familyId,
    this.done = const {},
    this.hidden = true,
  });

  final String? familyId;
  final Set<SetupStep> done;

  /// Dismissed, finished before this card existed, or not loaded yet.
  final bool hidden;

  int get doneCount => done.length;
  int get total => SetupStep.values.length;
  bool get complete => doneCount == total;

  /// The first step still open, which Fini talks about.
  SetupStep? get next =>
      SetupStep.values.where((step) => !done.contains(step)).firstOrNull;

  GettingStarted copyWith({Set<SetupStep>? done, bool? hidden}) =>
      GettingStarted(
        familyId: familyId,
        done: done ?? this.done,
        hidden: hidden ?? this.hidden,
      );
}

/// Ticks steps off from data Today already has, and remembers them, so a
/// step never un-ticks. Prizes are the one thing Today does not load, so they
/// are fetched here until the first one turns up.
class GettingStartedCubit extends Cubit<GettingStarted> {
  GettingStartedCubit(
    this._store,
    this._prizes, {
    DateTime Function()? now,
    this.prizeRecheck = const Duration(seconds: 15),
  }) : _now = now ?? DateTime.now,
       super(const GettingStarted());

  final OnboardingStore _store;
  final PrizeApi _prizes;
  final DateTime Function() _now;
  final Duration prizeRecheck;

  bool _checkingPrizes = false;
  DateTime? _prizesCheckedAt;

  Future<void> observe({
    required String familyId,
    required List<String> childIds,
    required bool phoneConnected,
    required bool hasTask,
    required bool hasLimit,
  }) async {
    final firstLook = state.familyId != familyId;
    final stored = firstLook
        ? _store.done(familyId).map(_stepOf).nonNulls.toSet()
        : state.done;
    final done = {
      ...stored,
      if (childIds.isNotEmpty) SetupStep.child,
      if (phoneConnected) SetupStep.phone,
      if (hasTask) SetupStep.task,
      if (hasLimit) SetupStep.limit,
    };

    var hidden = firstLook ? _store.isHidden(familyId) : state.hidden;
    // A family that did everything before this card shipped never sees it.
    // The prize check has not run yet, so "everything else" is the test.
    if (firstLook && !hidden && _store.done(familyId).isEmpty) {
      final rest = {...SetupStep.values}..remove(SetupStep.prize);
      if (done.containsAll(rest) && await _anyPrize(childIds)) {
        hidden = true;
        await _store.hide(familyId);
      }
    }

    if (isClosed) return;
    _emit(
      firstLook
          ? GettingStarted(familyId: familyId, done: done, hidden: hidden)
          : state.copyWith(done: done, hidden: hidden),
    );

    if (!state.hidden && !done.contains(SetupStep.prize)) {
      await _checkPrizes(childIds);
    }
  }

  /// "Hide" on the card, and "Done" once every step is ticked.
  Future<void> hide() async {
    final familyId = state.familyId;
    if (familyId == null) return;
    emit(state.copyWith(hidden: true));
    await _store.hide(familyId);
  }

  Future<void> _checkPrizes(List<String> childIds) async {
    final last = _prizesCheckedAt;
    if (_checkingPrizes ||
        (last != null && _now().difference(last) < prizeRecheck)) {
      return;
    }
    _checkingPrizes = true;
    try {
      final found = await _anyPrize(childIds);
      if (found && !isClosed) {
        _emit(state.copyWith(done: {...state.done, SetupStep.prize}));
      }
    } finally {
      _checkingPrizes = false;
    }
  }

  Future<bool> _anyPrize(List<String> childIds) async {
    _prizesCheckedAt = _now();
    for (final id in childIds) {
      try {
        if ((await _prizes.list(id)).prizes.isNotEmpty) return true;
      } catch (_) {
        // Offline or a removed child: try again on the next look.
      }
    }
    return false;
  }

  void _emit(GettingStarted next) {
    final familyId = next.familyId;
    if (familyId != null &&
        (familyId != state.familyId || !setEquals(next.done, state.done))) {
      _store.saveDone(familyId, next.done.map((step) => step.name).toSet());
    }
    emit(next);
  }

  static SetupStep? _stepOf(String name) =>
      SetupStep.values.where((step) => step.name == name).firstOrNull;
}
