import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/fini/data/fini_repository.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/onboarding/fini_onboarding.dart';

/// Creates the child on board A. Returns the new child's id, or throws a
/// message to show.
typedef CreateChild =
    Future<String> Function({
      required String name,
      required int age,
      String? gender,
    });

/// Thrown by [CreateChild] when something else already told the parent why
/// (the Safini Pro sheet for a free-plan limit): no message under the button.
class QuietFailure {
  const QuietFailure();
}

class FiniOnboardingState {
  const FiniOnboardingState({
    this.data = const FiniOnboarding(),
    this.busy = false,
    this.error,
  });

  final FiniOnboarding data;
  final bool busy;

  /// A message to show under the button; empty means the generic one.
  final String? error;

  FiniOnboardingState copyWith({
    FiniOnboarding? data,
    bool? busy,
    String? Function()? error,
  }) => FiniOnboardingState(
    data: data ?? this.data,
    busy: busy ?? this.busy,
    error: error == null ? this.error : error(),
  );
}

/// Board A to E. A creates the child, D saves the goals, E ends the flow.
///
/// Starting with an existing child (from the Fini tab) opens at B and skips
/// A, so a parent who left after A picks up where they stopped.
class FiniOnboardingCubit extends Cubit<FiniOnboardingState> {
  FiniOnboardingCubit({
    required FiniRepository repo,
    required CreateChild createChild,
    FiniOnboarding? resume,
  }) : _repo = repo,
       _createChild = createChild,
       super(FiniOnboardingState(data: resume ?? const FiniOnboarding()));

  final FiniRepository _repo;
  final CreateChild _createChild;

  FiniOnboarding get _data => state.data;

  void _set(FiniOnboarding data) =>
      emit(state.copyWith(data: data, error: () => null));

  void setName(String name) => _set(_data.copyWith(name: name));
  void setAge(int age) => _set(
    _data.copyWith(age: age.clamp(onboardingAges.first, onboardingOldest)),
  );
  void setPhone(ChildPhone phone) => _set(_data.copyWith(phone: phone));
  void setGender(String? gender) => _set(_data.copyWith(gender: () => gender));

  /// Picks or unpicks a goal, keeping the grid's order.
  void toggleGoal(GoalIntent intent, List<GoalIntent> gridOrder) {
    final picked = {..._data.picked};
    picked.contains(intent) ? picked.remove(intent) : picked.add(intent);
    _set(
      _data.copyWith(
        picked: [
          for (final i in gridOrder)
            if (picked.contains(i)) i,
        ],
      ),
    );
  }

  void setMinutes(GoalIntent intent, int minutes) => _set(
    _data.copyWith(minutes: {..._data.minutes, intent: minutes.clamp(15, 300)}),
  );

  void setWindow(GoalIntent intent, FiniTime start, FiniTime end) =>
      _set(_data.copyWith(windows: {..._data.windows, intent: (start, end)}));

  void back() {
    final previous = _data.previous;
    if (previous != null) _set(_data.copyWith(step: previous));
  }

  /// "Change the limits" on board D.
  void changeLimits() => _set(
    _data.copyWith(
      step: _data.tuned.isEmpty ? OnboardingStep.goals : OnboardingStep.tune,
    ),
  );

  /// Continue on A, B and C. A creates the child first; D saves the goals.
  /// Returns true when the flow is finished (after E).
  Future<bool> next() async {
    if (state.busy) return false;
    switch (_data.step) {
      case OnboardingStep.child:
        if (!_data.childReady) return false;
        if (_data.childId == null && !await _run(_create)) return false;
      case OnboardingStep.goals:
        if (_data.picked.isEmpty) return false;
      case OnboardingStep.plan:
        if (!await _run(_saveGoals)) return false;
      case OnboardingStep.trial:
        if (!await _run(_repo.startTrial)) return false;
      case OnboardingStep.tune:
        break;
    }
    final next = _data.next;
    if (next == null) return true;
    _set(_data.copyWith(step: next));
    return false;
  }

  Future<void> _create() async {
    final id = await _createChild(
      name: _data.name.trim(),
      age: _data.age,
      gender: _data.gender,
    );
    _set(_data.copyWith(childId: id));
  }

  /// Skips goals the child already has, so a resumed flow never doubles one.
  Future<void> _saveGoals() async {
    final childId = _data.childId!;
    final existing = {
      for (final goal in await _repo.goals(childId)) goal.intent,
    };
    for (final body in _data.goalBodies()) {
      final intent = GoalIntent.values.byName(
        (body['target'] as Map)['intent'] as String,
      );
      if (existing.contains(intent)) continue;
      await _repo.createGoal(childId, body);
    }
  }

  Future<bool> _run(Future<void> Function() work) async {
    emit(state.copyWith(busy: true, error: () => null));
    try {
      await work();
      emit(state.copyWith(busy: false));
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          busy: false,
          error: () => switch (error) {
            QuietFailure() => null,
            String() => error,
            _ => '',
          },
        ),
      );
      return false;
    }
  }
}
