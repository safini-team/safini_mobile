import 'package:flutter/material.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/onboarding/coach_tour.dart';
import 'package:safini/features/onboarding/onboarding_store.dart';

/// The four things on the parent's shell worth pointing at once a child's
/// phone is connected and there is something real on Today.
abstract final class ParentTour {
  static final screenTime = GlobalKey(debugLabel: 'tour-screen-time');
  static final review = GlobalKey(debugLabel: 'tour-review');
  static final tasksTab = GlobalKey(debugLabel: 'tour-tasks-tab');
  static final limitsTab = GlobalKey(debugLabel: 'tour-limits-tab');

  static List<CoachStep> steps(S s) => [
    CoachStep(target: screenTime, text: s.tourScreenTime),
    CoachStep(target: review, text: s.tourReview),
    CoachStep(target: tasksTab, text: s.tourTasks),
    CoachStep(target: limitsTab, text: s.tourLimits),
  ];
}

/// Starts the tour once per family on this phone, the first time Today is
/// on screen with a connected child. Draws nothing itself.
class ParentTourHost extends StatefulWidget {
  const ParentTourHost({
    super.key,
    required this.familyId,
    required this.ready,
    required this.store,
    this.delay = const Duration(milliseconds: 700),
  });

  final String? familyId;

  /// Today is the visible tab and some child's phone is connected.
  final bool ready;
  final OnboardingStore store;

  /// Lets Today's entrance animation settle, so the holes land on the
  /// widgets' final positions.
  final Duration delay;

  @override
  State<ParentTourHost> createState() => _ParentTourHostState();
}

class _ParentTourHostState extends State<ParentTourHost> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _maybeStart();
  }

  @override
  void didUpdateWidget(ParentTourHost old) {
    super.didUpdateWidget(old);
    _maybeStart();
  }

  void _maybeStart() {
    final familyId = widget.familyId;
    if (_started ||
        !widget.ready ||
        familyId == null ||
        widget.store.tourSeen(familyId)) {
      return;
    }
    _started = true;
    Future<void>.delayed(widget.delay, () async {
      // Not over a sheet or a pushed page the parent opened meanwhile.
      if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? true)) {
        _started = false;
        return;
      }
      // Nothing laid out to point at yet: try again on the next rebuild
      // rather than burn the one showing.
      final steps = visibleSteps(ParentTour.steps(S.of(context)));
      if (steps.isEmpty) {
        _started = false;
        return;
      }
      await widget.store.markTourSeen(familyId);
      if (!mounted) return;
      await showCoachTour(context, steps);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
