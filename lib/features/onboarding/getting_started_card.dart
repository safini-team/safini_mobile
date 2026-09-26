import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_motion.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/onboarding/fini.dart';
import 'package:safini/features/onboarding/getting_started_cubit.dart';

/// "Getting started · 2 of 5" on the parent's Today. Fini says the next step,
/// each open row goes to where that step is done, and the card cheers and
/// leaves once all five are ticked.
class GettingStartedCard extends StatelessWidget {
  const GettingStartedCard({
    super.key,
    required this.state,
    required this.kidName,
    required this.onOpen,
    required this.onHide,
  });

  final GettingStarted state;

  /// The child Fini talks about: the first one whose phone is not connected,
  /// else the one selected on Today.
  final String kidName;
  final ValueChanged<SetupStep> onOpen;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final next = state.next;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        DsCard(
          shadow: AppShadows.cardSoft,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FiniSays(
                      size: 58,
                      cheer: state.complete,
                      bubbleColor: AppColors.fillAlt,
                      text: _line(s, next),
                    ),
                  ),
                  if (!state.complete)
                    Semantics(
                      button: true,
                      label: s.gettingStartedHide,
                      child: Pressable(
                        onTap: onHide,
                        scale: 0.9,
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
                          child: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      s.gettingStartedTitle,
                      style: AppText.rowTitleStrong,
                    ),
                  ),
                  Text(
                    s.gettingStartedCount(state.doneCount, state.total),
                    style: AppText.meta,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DsProgressBar(
                progress: state.doneCount / state.total,
                height: 6,
                color: state.complete ? AppColors.success : AppColors.primary,
              ),
              const SizedBox(height: 6),
              if (state.complete)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
                  child: DsPrimaryButton(label: s.doneAction, onTap: onHide),
                )
              else
                for (final step in SetupStep.values)
                  _StepRow(
                    label: _label(s, step),
                    done: state.done.contains(step),
                    isNext: step == next,
                    onTap: () => onOpen(step),
                  ),
            ],
          ),
        ),
        if (state.complete) const Positioned.fill(child: FiniConfetti()),
      ],
    );
  }

  String _line(S s, SetupStep? next) => switch (next) {
    null => s.finiAllSet,
    SetupStep.child => s.finiNextChild,
    SetupStep.phone => s.finiNextPhone(kidName),
    SetupStep.task => s.finiNextTask,
    SetupStep.limit => s.finiNextLimit,
    SetupStep.prize => s.finiNextPrize,
  };

  static String _label(S s, SetupStep step) => switch (step) {
    SetupStep.child => s.setupStepChild,
    SetupStep.phone => s.setupStepPhone,
    SetupStep.task => s.setupStepTask,
    SetupStep.limit => s.setupStepLimit,
    SetupStep.prize => s.setupStepPrize,
  };
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.label,
    required this.done,
    required this.isNext,
    required this.onTap,
  });

  final String label;
  final bool done;
  final bool isNext;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: AppMotion.spring,
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? AppColors.success : Colors.transparent,
              border: done
                  ? null
                  : Border.all(
                      color: isNext ? AppColors.primary : AppColors.strokeQuiet,
                      width: 2,
                    ),
            ),
            child: done ? AppIcons.check(size: 12) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: done
                  ? AppText.body.copyWith(
                      color: AppColors.textTertiary,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppColors.textTertiary,
                    )
                  : isNext
                  ? AppText.rowTitleStrong
                  : AppText.body,
            ),
          ),
          if (!done)
            AppIcons.chevronRight(
              color: isNext ? AppColors.primary : AppColors.chevron,
            ),
        ],
      ),
    );
    if (done) return Semantics(checked: true, child: row);
    return Semantics(
      button: true,
      checked: false,
      child: Pressable.row(onTap: onTap, child: row),
    );
  }
}
