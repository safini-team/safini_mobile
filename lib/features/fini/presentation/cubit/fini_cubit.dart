import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/fini/data/fini_repository.dart';
import 'package:safini/features/fini/domain/fini_goal_specs.dart';
import 'package:safini/features/fini/domain/fini_models.dart';

enum FiniStatus { idle, loading, loaded, error }

class FiniState {
  const FiniState({
    this.childId,
    this.status = FiniStatus.idle,
    this.settings = const FiniSettings(),
    this.goals = const [],
    this.pending = const [],
    this.activity = const [],
    this.trial = const FiniTrial(),
  });

  final String? childId;
  final FiniStatus status;
  final FiniSettings settings;
  final List<FiniGoal> goals;
  final List<FiniProposal> pending;
  final List<FiniProposal> activity;

  /// The family's trial; the same for every child.
  final FiniTrial trial;

  bool get hasGoals => goals.isNotEmpty;

  /// Intents already set, dimmed on the Add-a-goal grid.
  Set<GoalIntent> get addedIntents => {for (final goal in goals) goal.intent};

  /// Things Fini did today, for the Activity tile.
  int activityToday(DateTime now) => activity
      .where(
        (item) =>
            item.createdAt.year == now.year &&
            item.createdAt.month == now.month &&
            item.createdAt.day == now.day,
      )
      .length;

  FiniState copyWith({
    FiniStatus? status,
    FiniSettings? settings,
    List<FiniGoal>? goals,
    List<FiniProposal>? pending,
    List<FiniProposal>? activity,
    FiniTrial? trial,
  }) => FiniState(
    childId: childId,
    status: status ?? this.status,
    settings: settings ?? this.settings,
    goals: goals ?? this.goals,
    pending: pending ?? this.pending,
    activity: activity ?? this.activity,
    trial: trial ?? this.trial,
  );
}

/// One child's Fini: settings, goals, the cards waiting and what it did.
///
/// Writes return an error to show, or null. They never change a limit on
/// the phone themselves: goals and switches only tell Fini what to aim for.
class FiniCubit extends Cubit<FiniState> {
  FiniCubit(this._repo, {this.onInboxChanged}) : super(const FiniState());

  final FiniRepository _repo;

  /// Accept, dismiss and undo change the tab badge.
  final void Function()? onInboxChanged;

  int _generation = 0;

  /// How long a child's Fini counts as current. Switching back within it
  /// shows what is cached and calls nothing.
  static const fresh = Duration(seconds: 30);

  final _byChild = <String, FiniState>{};
  final _loadedAt = <String, DateTime>{};

  @override
  void onChange(Change<FiniState> change) {
    super.onChange(change);
    final next = change.nextState;
    // Writes land here too, so a cached child is never behind the screen.
    if (next.status == FiniStatus.loaded && next.childId != null) {
      _byChild[next.childId!] = next;
    }
  }

  /// Shows [childId] at once when it was seen before, and refetches in the
  /// background only when that copy is older than [fresh] or [force] is set.
  Future<void> load(String childId, {bool force = false}) async {
    final generation = ++_generation;
    final cached = _byChild[childId];
    if (cached != null && state.childId != childId) {
      emit(cached.copyWith(trial: state.trial));
    }
    final at = _loadedAt[childId];
    if (!force &&
        cached != null &&
        at != null &&
        DateTime.now().difference(at) < fresh) {
      return;
    }
    final same = state.childId == childId && state.status == FiniStatus.loaded;
    if (!same) emit(FiniState(childId: childId, status: FiniStatus.loading));
    try {
      final loaded = await _fetch(childId);
      if (isClosed || generation != _generation) return;
      _loadedAt[childId] = DateTime.now();
      emit(loaded);
    } catch (_) {
      if (isClosed || generation != _generation) return;
      emit(
        same ? state : FiniState(childId: childId, status: FiniStatus.error),
      );
    }
  }

  /// Loads the other children quietly, one after another, so the first
  /// switch to them is instant too. Nothing on screen changes.
  Future<void> prefetch(Iterable<String> childIds) async {
    for (final id in childIds) {
      if (isClosed) return;
      if (_byChild.containsKey(id)) continue;
      try {
        final loaded = await _fetch(id);
        if (isClosed || _byChild.containsKey(id)) continue;
        _byChild[id] = loaded;
        _loadedAt[id] = DateTime.now();
      } catch (_) {
        // A miss here only means that child loads on the switch, as before.
      }
    }
  }

  Future<FiniState> _fetch(String childId) async {
    final results = await Future.wait([
      _repo.settings(childId),
      _repo.goals(childId),
      _repo.pending(childId),
      _repo.activity(childId),
      _trialOrLast(),
    ]);
    return FiniState(
      childId: childId,
      status: FiniStatus.loaded,
      settings: results[0] as FiniSettings,
      goals: results[1] as List<FiniGoal>,
      pending: results[2] as List<FiniProposal>,
      activity: results[3] as List<FiniProposal>,
      trial: results[4] as FiniTrial,
    );
  }

  /// A trial the server cannot say keeps the last one: the tab still works,
  /// it only loses the pill.
  Future<FiniTrial> _trialOrLast() async {
    try {
      return await _repo.trial();
    } catch (_) {
      return state.trial;
    }
  }

  Future<String?> addGoal(GoalIntentSpec spec, {int? minutes}) =>
      _write(() async {
        final goal = await _repo.createGoal(
          state.childId!,
          spec.createBody(minutes: minutes),
        );
        emit(state.copyWith(goals: [...state.goals, goal]));
      });

  Future<String?> updateGoal(FiniGoal goal, Map<String, dynamic> changes) =>
      _write(() async {
        final updated = await _repo.updateGoal(goal.id, changes);
        emit(
          state.copyWith(
            goals: [for (final g in state.goals) g.id == goal.id ? updated : g],
          ),
        );
      });

  /// Skips the rest of a budget goal's plan: the pool goes to the goal today.
  Future<String?> jumpToTarget(FiniGoal goal) => _write(() async {
    final jumped = await _repo.jumpToTarget(goal.id);
    emit(
      state.copyWith(
        goals: [for (final g in state.goals) g.id == goal.id ? jumped : g],
      ),
    );
  });

  Future<String?> deleteGoal(FiniGoal goal) => _write(() async {
    await _repo.deleteGoal(goal.id);
    emit(
      state.copyWith(goals: state.goals.where((g) => g.id != goal.id).toList()),
    );
  });

  /// Optimistic: the switch moves at once and moves back if the save fails.
  Future<String?> saveSettings(FiniSettings settings) async {
    final previous = state.settings;
    emit(state.copyWith(settings: settings));
    final error = await _write(() async {
      final saved = await _repo.saveSettings(state.childId!, settings);
      emit(state.copyWith(settings: saved));
    });
    if (error != null) emit(state.copyWith(settings: previous));
    return error;
  }

  Future<String?> decide(FiniProposal proposal, FiniDecision decision) =>
      _write(() async {
        await _repo.decide(proposal.id, decision);
        final childId = state.childId!;
        final results = await Future.wait([
          _repo.pending(childId),
          _repo.activity(childId),
        ]);
        emit(state.copyWith(pending: results[0], activity: results[1]));
        onInboxChanged?.call();
      });

  /// "Allow 15 min a day", "Not a game", or a category from the card.
  Future<String?> placeApp(
    FiniProposal proposal, {
    String? category,
    int? minutes,
  }) => _write(() async {
    final childId = state.childId!;
    await _repo.placeApp(
      childId,
      proposal.appPackage,
      category: category,
      minutes: minutes,
    );
    final results = await Future.wait([
      _repo.pending(childId),
      _repo.activity(childId),
    ]);
    emit(state.copyWith(pending: results[0], activity: results[1]));
    onInboxChanged?.call();
  });

  Future<String?> _write(Future<void> Function() run) async {
    if (state.childId == null) return '';
    try {
      await run();
      return null;
    } catch (error) {
      return _message(error);
    }
  }

  /// The server's `detail` when it sent one (a 409 says why), else empty
  /// for the generic network message.
  static String _message(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      final detail = data is Map ? data['detail'] : null;
      if (detail is String && detail.isNotEmpty) return detail;
    }
    return '';
  }
}
