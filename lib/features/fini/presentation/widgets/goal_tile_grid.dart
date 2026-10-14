import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/fini/domain/fini_goal_specs.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/presentation/widgets/goal_visuals.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm;

/// The goal tiles, two to a row: the Fini tab's Add-a-goal sheet (one tap
/// adds) and onboarding step B (several picked, then Next).
///
/// [added] tiles are dimmed with "Added" and cannot be tapped. A coming-soon
/// tile is shown but cannot be picked either.
class GoalTileGrid extends StatelessWidget {
  const GoalTileGrid({
    super.key,
    required this.onTap,
    this.specs = goalIntentSpecs,
    this.added = const {},
    this.selected = const {},
    this.multiSelect = false,
    this.tileColor = AppColors.surface,
  });

  /// White on the page; a warm fill on a white sheet.
  final Color tileColor;

  final List<GoalIntentSpec> specs;
  final Set<GoalIntent> added;

  /// Multi-select only: the tiles currently picked.
  final Set<GoalIntent> selected;
  final bool multiSelect;
  final ValueChanged<GoalIntentSpec> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final width = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final spec in specs)
              SizedBox(
                width: width,
                child: _GoalTile(
                  spec: spec,
                  added: added.contains(spec.intent),
                  selected: selected.contains(spec.intent),
                  multiSelect: multiSelect,
                  color: tileColor,
                  onTap: () => onTap(spec),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// The line under a tile's title: an example of what it covers.
String goalTileSubtitle(S s, GoalIntentSpec spec) => switch (spec.intent) {
  GoalIntent.games => s.goalGamesSub,
  GoalIntent.scrolling => s.goalScrollingSub,
  GoalIntent.video => s.goalVideoSub,
  GoalIntent.homework => s.goalHomeworkSub,
  GoalIntent.learning => s.goalLearningSub,
  GoalIntent.bedtime ||
  GoalIntent.school ||
  GoalIntent.dinner => s.goalWindow(
    spec.windowStart!.label,
    spec.windowEnd!.label,
  ),
  GoalIntent.custom => '',
};

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.spec,
    required this.added,
    required this.selected,
    required this.multiSelect,
    required this.color,
    required this.onTap,
  });

  final Color color;
  final GoalIntentSpec spec;
  final bool added;
  final bool selected;
  final bool multiSelect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final enabled = !added && !spec.comingSoon;
    final subtitle = added ? s.goalAdded : goalTileSubtitle(s, spec);
    final minutes = spec.minutesPerDay;
    return Semantics(
      button: enabled,
      selected: multiSelect ? selected : null,
      enabled: enabled,
      child: Opacity(
        opacity: added ? 0.55 : 1,
        child: Pressable(
          key: ValueKey('goal-tile-${spec.intent.name}'),
          onTap: enabled ? onTap : null,
          scale: 0.97,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GoalIcon(intent: spec.intent),
                    const Spacer(),
                    if (multiSelect && enabled) _Check(on: selected),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  goalTitle(s, spec.intent),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: added ? FontWeight.w600 : FontWeight.w400,
                    color: added
                        ? AppColors.successDeep
                        : AppColors.textSecondary,
                  ),
                ),
                if (multiSelect && minutes != null && !added)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      s.goalMinutesADay(formatHm(s, minutes)),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: on ? AppColors.primary : Colors.transparent,
        border: on ? null : Border.all(color: AppColors.strokeQuiet, width: 2),
      ),
      child: on
          ? AppIcons.check(size: 12, color: AppColors.textOnPrimary)
          : null,
    );
  }
}
