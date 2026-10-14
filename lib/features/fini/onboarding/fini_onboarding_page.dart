import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/qa_ids.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/fini/data/fini_repository.dart';
import 'package:safini/features/fini/domain/fini_goal_specs.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/onboarding/fini_onboarding.dart';
import 'package:safini/features/fini/onboarding/fini_onboarding_cubit.dart';
import 'package:safini/features/fini/presentation/widgets/goal_tile_grid.dart';
import 'package:safini/features/fini/presentation/widgets/goal_visuals.dart';
import 'package:safini/features/onboarding/fini.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm;

/// Boards A to E, one question per screen, Fini speaking on each. Needs a
/// [FiniOnboardingCubit] above it. [onDone] runs after E; [onLeave] when
/// Back is pressed on the first board shown.
class FiniOnboardingFlow extends StatelessWidget {
  const FiniOnboardingFlow({
    super.key,
    required this.onDone,
    required this.onLeave,
  });

  final VoidCallback onDone;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<FiniOnboardingCubit>();
    final state = cubit.state;
    final data = state.data;
    final s = S.of(context);

    Future<void> next() async {
      FocusScope.of(context).unfocus();
      if (await cubit.next()) onDone();
    }

    final (Widget body, Widget footer) = switch (data.step) {
      OnboardingStep.child => (
        _ChildBoard(data: data),
        _Continue(
          key: const ValueKey('ob-continue'),
          label: s.continueAction,
          enabled: data.childReady,
          busy: state.busy,
          onTap: next,
        ),
      ),
      OnboardingStep.goals => (
        _GoalsBoard(data: data),
        _Continue(
          key: const ValueKey('ob-continue'),
          label: s.tourNext,
          enabled: data.picked.isNotEmpty,
          onTap: next,
        ),
      ),
      OnboardingStep.tune => (
        _TuneBoard(data: data),
        _Continue(
          key: const ValueKey('ob-continue'),
          label: s.tourNext,
          onTap: next,
        ),
      ),
      OnboardingStep.plan => (
        _PlanBoard(data: data),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Continue(
              key: const ValueKey('ob-continue'),
              label: s.obSoundsGood,
              busy: state.busy,
              onTap: next,
            ),
            const SizedBox(height: 10),
            DsPrimaryButton.secondary(
              key: const ValueKey('ob-change'),
              label: s.obChangeLimits,
              onTap: cubit.changeLimits,
            ),
          ],
        ),
      ),
      OnboardingStep.trial => (
        const _TrialBoard(),
        _Continue(
          key: const ValueKey('ob-continue'),
          label: s.obStartTrial,
          onTap: next,
        ),
      ),
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        data.previous == null ? onLeave() : cubit.back();
      },
      child: Scaffold(
        backgroundColor: AppColors.bgParent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                step: data.step,
                onBack: data.previous == null ? onLeave : cubit.back,
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: SingleChildScrollView(
                    key: ValueKey(data.step),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      4,
                      AppSpacing.gutter,
                      24,
                    ),
                    child: body,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  8,
                  AppSpacing.gutter,
                  12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          state.error!.isEmpty ? s.networkError : state.error!,
                          textAlign: TextAlign.center,
                          style: AppText.metaSm.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.dangerDeep,
                          ),
                        ),
                      ),
                    footer,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── A · who is your child ──

class _ChildBoard extends StatefulWidget {
  const _ChildBoard({required this.data});

  final FiniOnboarding data;

  @override
  State<_ChildBoard> createState() => _ChildBoardState();
}

class _ChildBoardState extends State<_ChildBoard> {
  late final _name = TextEditingController(text: widget.data.name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final cubit = context.read<FiniOnboardingCubit>();
    final data = widget.data;
    const genders = ['girl', 'boy', null];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FiniSays(pose: FiniPose.wave, size: 88, text: s.obHiWho),
        const SizedBox(height: 14),
        _Field(
          label: s.obChildName,
          child: Semantics(
            identifier: QaIds.obName,
            container: true,
            child: TextField(
              key: const ValueKey('ob-name'),
              controller: _name,
              onChanged: cubit.setName,
              textCapitalization: TextCapitalization.words,
              cursorColor: AppColors.primary,
              style: AppText.button.copyWith(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                hintText: s.nameHintExample,
                hintStyle: AppText.button.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.textTertiary,
                ),
                border: _outline(Colors.transparent),
                enabledBorder: _outline(
                  data.name.trim().isEmpty
                      ? Colors.transparent
                      : AppColors.primary,
                ),
                focusedBorder: _outline(AppColors.primary),
              ),
            ),
          ),
        ),
        _Field(
          label: s.ageFieldLabel,
          child: _Grid(
            columns: 6,
            spacing: 8,
            children: [
              for (final age in onboardingAges)
                _Choice(
                  key: ValueKey('ob-age-$age'),
                  height: 44,
                  selected: data.age == age,
                  filled: true,
                  onTap: () => cubit.setAge(age),
                  child: Text(
                    age == onboardingOldest ? s.obAge16Plus : '$age',
                    style: AppText.rowTitleStrong.copyWith(
                      color: data.age == age
                          ? AppColors.textOnPrimary
                          : AppColors.ink,
                    ),
                  ),
                ),
            ],
          ),
        ),
        _Field(
          label: s.obTheirPhone,
          child: _Grid(
            columns: 2,
            spacing: 10,
            children: [
              for (final (phone, label, icon) in [
                (ChildPhone.android, s.obAndroid, Icons.android_rounded),
                (ChildPhone.iphone, s.obIphone, Icons.apple_rounded),
              ])
                Semantics(
                  identifier: phone == ChildPhone.android
                      ? QaIds.obPhoneAndroid
                      : null,
                  container: true,
                  child: _Choice(
                    key: ValueKey('ob-phone-${phone.name}'),
                    height: 56,
                    selected: data.phone == phone,
                    onTap: () => cubit.setPhone(phone),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 24, color: AppColors.ink),
                        const SizedBox(width: 10),
                        Text(label, style: AppText.rowTitleStrong),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        _Field(
          label: s.genderOptional,
          child: DsSegmentedControl(
            key: const ValueKey('ob-gender'),
            labels: [s.genderGirl, s.genderBoy, s.obSkip],
            selectedIndex: genders.indexOf(data.gender),
            onChanged: (index) => cubit.setGender(genders[index]),
          ),
        ),
      ],
    );
  }

  static OutlineInputBorder _outline(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: color, width: 1.5),
  );
}

/// A label over its control, every label on the same left edge.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label,
              style: AppText.meta.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.inkSoft,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Equal-width cells, [columns] to a row.
class _Grid extends StatelessWidget {
  const _Grid({
    required this.columns,
    required this.spacing,
    required this.children,
  });

  final int columns;
  final double spacing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

/// One option of a single choice: a white tile, pine when picked ([filled])
/// or ringed in pine.
class _Choice extends StatelessWidget {
  const _Choice({
    super.key,
    required this.height,
    required this.selected,
    required this.onTap,
    required this.child,
    this.filled = false,
  });

  final double height;
  final bool selected;
  final bool filled;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.96,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected && filled ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(height >= 50 ? 16 : 14),
            border: Border.all(
              color: selected && !filled
                  ? AppColors.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── B · main goal ──

class _GoalsBoard extends StatelessWidget {
  const _GoalsBoard({required this.data});

  final FiniOnboarding data;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final cubit = context.read<FiniOnboardingCubit>();
    final order = [for (final spec in goalIntentSpecs) spec.intent];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(s.obGoalsTitle(data.name), style: AppText.title1),
        const SizedBox(height: 6),
        Text(s.obGoalsSub, style: AppText.subtitle),
        const SizedBox(height: 18),
        GoalTileGrid(
          multiSelect: true,
          selected: data.picked.toSet(),
          onTap: (spec) => cubit.toggleGoal(spec.intent, order),
        ),
      ],
    );
  }
}

// ── C · the numbers ──

class _TuneBoard extends StatelessWidget {
  const _TuneBoard({required this.data});

  final FiniOnboarding data;

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
    final cubit = context.read<FiniOnboardingCubit>();

    Widget row(GoalIntent intent) {
      final (String sub, Widget? control) = switch (tuneKindFor(intent)) {
        TuneKind.minutes => (
          s.obADayAtMost,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatHm(s, data.minutesFor(intent)),
                key: ValueKey('ob-minutes-${intent.name}'),
                style: AppText.rowTitleLg,
              ),
              const SizedBox(width: 10),
              DsStepper(
                onLess: data.minutesFor(intent) <= 15
                    ? null
                    : () => cubit.setMinutes(
                        intent,
                        data.minutesFor(intent) - 15,
                      ),
                onMore: data.minutesFor(intent) >= 300
                    ? null
                    : () => cubit.setMinutes(
                        intent,
                        data.minutesFor(intent) + 15,
                      ),
              ),
            ],
          ),
        ),
        TuneKind.window => (
          s.obScreensOff,
          Builder(
            builder: (context) {
              final (start, end) = data.windowFor(intent);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TimePill(
                    value: start,
                    onTap: () async {
                      final t = await _pick(context, start);
                      if (t != null) cubit.setWindow(intent, t, end);
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text('-', style: AppText.meta),
                  ),
                  _TimePill(
                    value: end,
                    onTap: () async {
                      final t = await _pick(context, end);
                      if (t != null) cubit.setWindow(intent, start, t);
                    },
                  ),
                ],
              );
            },
          ),
        ),
        TuneKind.homework => (s.obAnyStudyTask, null),
        TuneKind.none => ('', null),
      };
      return Padding(
        key: ValueKey('ob-tune-${intent.name}'),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            GoalIcon(intent: intent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(goalTitle(s, intent), style: AppText.rowTitleStrong),
                  if (sub.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(sub, style: AppText.meta),
                  ],
                ],
              ),
            ),
            if (control != null) ...[const SizedBox(width: 8), control],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(s.obTuneTitle, style: AppText.title1),
        const SizedBox(height: 6),
        Text(s.obTuneSub(data.name), style: AppText.subtitle),
        const SizedBox(height: 16),
        DsGroup(
          radius: AppRadius.card,
          shadow: AppShadows.cardSoft,
          children: [for (final intent in data.tuned) row(intent)],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(s.obSuggested('${data.age}'), style: AppText.meta),
        ),
      ],
    );
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({required this.value, required this.onTap});

  final FiniTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.fill,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(value.label, style: AppText.rowTitleStrong),
      ),
    );
  }
}

/// Back, and the five boards as a progress bar.
class _Header extends StatelessWidget {
  const _Header({required this.step, required this.onBack});

  final OnboardingStep step;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, AppSpacing.gutter, 10),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: MaterialLocalizations.of(context).backButtonTooltip,
            child: Pressable(
              onTap: onBack,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(child: AppIcons.chevronLeft()),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Row(
              children: [
                for (final board in OnboardingStep.values) ...[
                  if (board.index > 0) const SizedBox(width: 6),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      height: 4,
                      decoration: BoxDecoration(
                        color: board.index <= step.index
                            ? AppColors.primary
                            : AppColors.fillDeeper,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── D · Fini's plan ──

class _PlanBoard extends StatelessWidget {
  const _PlanBoard({required this.data});

  final FiniOnboarding data;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final budgets = data.picked.any(
      (intent) => tuneKindFor(intent) == TuneKind.minutes,
    );
    final night = data.picked.contains(GoalIntent.bedtime)
        ? data.windowFor(GoalIntent.bedtime)
        : null;
    final steps = [
      (s.obPlanWatchTitle, s.obPlanWatchBody(data.name)),
      if (budgets) (s.obPlanMondayTitle, s.obPlanMondayBody),
      if (data.picked.contains(GoalIntent.homework))
        (s.obPlanHomeworkTitle, s.obPlanHomeworkBody),
      if (night != null)
        (s.obPlanNightTitle, s.obPlanNightBody(night.$1.label, night.$2.label)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FiniSays(pose: FiniPose.point, text: s.obPlanTitle),
        const SizedBox(height: 18),
        DsGroup(
          radius: AppRadius.card,
          shadow: AppShadows.cardSoft,
          dividerIndent: 40,
          children: [
            for (final (index, (title, body)) in steps.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryTint,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: AppText.rowTitleStrong),
                          const SizedBox(height: 3),
                          Text(body, style: AppText.meta),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        DsCard(
          color: AppColors.primaryTint,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(s.obInCharge, style: AppText.body)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── E · trial ──

class _TrialBoard extends StatelessWidget {
  const _TrialBoard();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final rows = [
      (s.finiDayToday, s.obTrialTodayBody),
      (s.obTrialDay('12'), s.obTrialDay12Body),
      (s.obTrialDay('14'), s.obTrialDay14Body),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const Center(child: Fini(size: 112, cheer: true, pose: FiniPose.cheer)),
        const SizedBox(height: 16),
        Text(
          s.obTrialLead,
          textAlign: TextAlign.center,
          style: AppText.subtitle,
        ),
        Text(
          s.obTrialTitle,
          textAlign: TextAlign.center,
          style: AppText.title1,
        ),
        const SizedBox(height: 8),
        Text(s.obTrialSub, textAlign: TextAlign.center, style: AppText.meta),
        const SizedBox(height: 22),
        DsGroup(
          radius: AppRadius.card,
          shadow: AppShadows.cardSoft,
          children: [
            for (final (index, (day, what)) in rows.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 5, right: 14),
                      decoration: BoxDecoration(
                        color: index == 0
                            ? AppColors.primary
                            : AppColors.fillDeeper,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(day, style: AppText.rowTitleStrong),
                          const SizedBox(height: 2),
                          Text(what, style: AppText.meta),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Reopens the onboarding from the Fini tab at board B for a child that has
/// no goals yet, e.g. a parent who left after board A.
Future<void> openFiniOnboarding(
  BuildContext context, {
  required FiniRepository repo,
  required String childId,
  required String name,
  required int age,
}) => Navigator.of(context).push(
  MaterialPageRoute(
    fullscreenDialog: true,
    builder: (route) => BlocProvider(
      create: (_) => FiniOnboardingCubit(
        repo: repo,
        createChild: ({required name, required age, gender}) =>
            throw StateError('the child already exists'),
        resume: FiniOnboarding(
          step: OnboardingStep.goals,
          childId: childId,
          name: name,
          age: age.clamp(onboardingAges.first, onboardingOldest),
        ),
      ),
      child: FiniOnboardingFlow(
        onDone: () => Navigator.of(route).pop(),
        onLeave: () => Navigator.of(route).pop(),
      ),
    ),
  ),
);

/// The board's main button, with the id the screenshot walk taps.
class _Continue extends StatelessWidget {
  const _Continue({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.busy = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool busy;

  @override
  Widget build(BuildContext context) => Semantics(
    identifier: QaIds.obContinue,
    container: true,
    child: DsPrimaryButton(
      label: label,
      enabled: enabled,
      busy: busy,
      onTap: onTap,
    ),
  );
}
