import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/domain/fini_plan.dart';
import 'package:safini/features/fini/presentation/cubit/fini_cubit.dart';
import 'package:safini/features/fini/presentation/widgets/goal_visuals.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm;

const _minuteStep = 15;
const _weekendExtra = 30;

Future<void> openFiniGoal(
  BuildContext context,
  FiniGoal goal,
  String childName,
) => Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => BlocProvider.value(
      value: context.read<FiniCubit>(),
      child: FiniGoalScreen(goalId: goal.id, childName: childName),
    ),
  ),
);

/// One goal: its value with −/+, the pace and the weekly steps it draws, and
/// the weekend switch. Every change saves at once; none touches a limit on
/// the phone by itself.
class FiniGoalScreen extends StatelessWidget {
  const FiniGoalScreen({
    super.key,
    required this.goalId,
    required this.childName,
  });

  final String goalId;
  final String childName;

  Future<void> _save(
    BuildContext context,
    FiniGoal goal,
    Map<String, dynamic> changes,
  ) async {
    final s = S.of(context);
    final error = await context.read<FiniCubit>().updateGoal(goal, changes);
    if (!context.mounted || error == null) return;
    AppSnackBar.error(context, error.isEmpty ? s.networkError : error);
  }

  Future<void> _remove(BuildContext context, FiniGoal goal) async {
    final s = S.of(context);
    final navigator = Navigator.of(context);
    final error = await context.read<FiniCubit>().deleteGoal(goal);
    if (!context.mounted) return;
    if (error != null) {
      AppSnackBar.error(context, error.isEmpty ? s.networkError : error);
      return;
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final goal = context
        .watch<FiniCubit>()
        .state
        .goals
        .where((g) => g.id == goalId)
        .firstOrNull;
    return Scaffold(
      backgroundColor: AppColors.bgParent,
      body: Column(
        children: [
          DsNavBar(
            title: goal == null ? '' : goalTitle(s, goal.intent),
            backLabel: s.tabFini,
            onBack: () => context.router.maybePop(),
          ),
          if (goal != null)
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  12,
                  AppSpacing.gutter,
                  40 + MediaQuery.viewPaddingOf(context).bottom,
                ),
                children: [
                  Row(
                    children: [
                      GoalIcon(intent: goal.intent, size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          goalTitle(s, goal.intent),
                          style: AppText.title1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (goal.isBudget) ...[
                    _MinutesCard(
                      goal: goal,
                      onChange: (minutes) => _save(context, goal, {
                        if (goal.weekdayMinutes != null)
                          'weekday_minutes': minutes
                        else
                          'minutes_per_day': minutes,
                        if (goal.hasWeekendExtra)
                          'weekend_minutes': minutes + _weekendExtra,
                      }),
                    ),
                    DsOverline(s.goalThePlan, top: 22),
                    _PlanCard(
                      goal: goal,
                      childName: childName,
                      onPace: (pace) =>
                          _save(context, goal, {'pace': pace.name}),
                    ),
                    const SizedBox(height: 14),
                    DsGroup(
                      children: [
                        DsRow(
                          title: s.goalWeekendExtra,
                          subtitle: s.goalWeekendExtraSub,
                          trailing: DsSwitch(
                            key: const ValueKey('goal-weekend'),
                            value: goal.hasWeekendExtra,
                            onChanged: (on) => _save(context, goal, {
                              'weekend_minutes': on
                                  ? (goal.targetMinutes ?? 0) + _weekendExtra
                                  : null,
                            }),
                          ),
                        ),
                      ],
                    ),
                    DsFootnote(s.goalPoolNote),
                  ] else if (goal.isWindow)
                    _WindowCard(
                      goal: goal,
                      onChange: (start, end) => _save(context, goal, {
                        'window_start': start.toJson(),
                        'window_end': end.toJson(),
                      }),
                    )
                  else
                    DsCard(
                      child: Text(
                        goal.intent == GoalIntent.learning
                            ? s.goalLearningDetail
                            : s.goalHomeworkDetail,
                        style: AppText.body,
                      ),
                    ),
                  const SizedBox(height: 24),
                  DsDestructiveButton(
                    key: const ValueKey('goal-remove'),
                    label: s.goalRemove,
                    onTap: () => _remove(context, goal),
                  ),
                  DsFootnote(s.goalRemoveNote),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MinutesCard extends StatelessWidget {
  const _MinutesCard({required this.goal, required this.onChange});

  final FiniGoal goal;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final minutes = goal.targetMinutes ?? 0;
    return DsCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.goalNoMoreThan, style: AppText.meta),
                Text(
                  formatHm(s, minutes),
                  key: const ValueKey('goal-minutes'),
                  style: AppText.display,
                ),
                Text(s.goalADayTogether, style: AppText.meta),
              ],
            ),
          ),
          DsStepper(
            onLess: minutes <= _minuteStep
                ? null
                : () => onChange(minutes - _minuteStep),
            onMore: minutes >= 300
                ? null
                : () => onChange(minutes + _minuteStep),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.goal,
    required this.childName,
    required this.onPace,
  });

  final FiniGoal goal;
  final String childName;
  final ValueChanged<FiniPace> onPace;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final target = goal.targetMinutes ?? 0;
    final start = goal.startMinutes;
    final steps = start == null
        ? null
        : formatPlanSteps(start, target, goal.pace);
    final String text;
    if (steps == null) {
      text = s.goalPlanWatching;
    } else if (goal.pace == FiniPace.now) {
      text = s.goalPlanNow(formatHm(s, target));
    } else {
      text = s.goalPlanText(
        formatHm(s, start!),
        formatHm(s, target),
        steps.length - 1,
      );
    }
    return DsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DsSegmentedControl(
            labels: [s.paceGentle, s.paceSteady, s.paceNow],
            selectedIndex: FiniPace.values.indexOf(goal.pace),
            onChanged: (index) => onPace(FiniPace.values[index]),
          ),
          if (steps != null && steps.length > 1) ...[
            const SizedBox(height: 16),
            _StepBars(steps: steps),
          ],
          const SizedBox(height: 14),
          Text(
            text,
            key: const ValueKey('goal-plan-text'),
            style: AppText.meta,
          ),
        ],
      ),
    );
  }
}

/// The plan as bars: now, then each Monday. Long plans show the first week
/// and the last five, like the board.
class _StepBars extends StatelessWidget {
  const _StepBars({required this.steps});

  final List<int> steps;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final indexes = steps.length > 6
        ? [0, for (var i = steps.length - 5; i < steps.length; i++) i]
        : [for (var i = 0; i < steps.length; i++) i];
    final top = steps.first;
    return Semantics(
      label: steps.map((m) => formatHm(s, m)).join(', '),
      excludeSemantics: true,
      child: SizedBox(
        height: 112,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final i in indexes)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${steps[i]}',
                        style: AppText.metaSm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkSoft,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: (steps[i] / top * 64).clamp(8, 64).toDouble(),
                        decoration: BoxDecoration(
                          color: i == 0
                              ? AppColors.fillDeeper
                              : (i == 1
                                    ? AppColors.primary
                                    : AppColors.primaryPale),
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        i == 0 ? s.goalWeekNow : s.goalWeekN(i),
                        maxLines: 1,
                        style: AppText.metaSm,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WindowCard extends StatelessWidget {
  const _WindowCard({required this.goal, required this.onChange});

  final FiniGoal goal;
  final void Function(FiniTime start, FiniTime end) onChange;

  Future<FiniTime?> _pick(BuildContext context, FiniTime current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    return picked == null ? null : FiniTime(picked.hour, picked.minute);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final start = goal.windowStart ?? const FiniTime(21, 30);
    final end = goal.windowEnd ?? const FiniTime(7, 0);
    return DsGroup(
      children: [
        DsRow(
          title: s.goalFrom,
          trailing: Text(start.label, style: AppText.rowTitleStrong),
          onTap: () async {
            final picked = await _pick(context, start);
            if (picked != null) onChange(picked, end);
          },
        ),
        DsRow(
          title: s.goalUntil,
          trailing: Text(end.label, style: AppText.rowTitleStrong),
          onTap: () async {
            final picked = await _pick(context, end);
            if (picked != null) onChange(start, picked);
          },
        ),
      ],
    );
  }
}
