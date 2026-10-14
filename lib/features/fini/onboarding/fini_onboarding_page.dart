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
              const SizedBox(height: 8),
              Row(
                children: [
                  DsBackButton(
                    onTap: data.previous == null ? onLeave : cubit.back,
                  ),
                ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FiniSays(pose: FiniPose.wave, text: s.obHiWho),
        const SizedBox(height: 18),
        DsGroup(
          radius: AppRadius.card,
          shadow: AppShadows.cardSoft,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
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
                    filled: false,
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: s.obChildName,
                    hintStyle: AppText.button.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        DsOverline(s.ageFieldLabel, top: 22),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final age in onboardingAges)
              DsCategoryChip(
                key: ValueKey('ob-age-$age'),
                label: age == onboardingOldest ? s.obAge16Plus : '$age',
                selected: data.age == age,
                restBackground: AppColors.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                onTap: () => cubit.setAge(age),
              ),
          ],
        ),
        DsOverline(s.obTheirPhone, top: 22),
        Row(
          children: [
            for (final (phone, label, icon) in [
              (ChildPhone.android, s.obAndroid, Icons.android_rounded),
              (ChildPhone.iphone, s.obIphone, Icons.apple_rounded),
            ]) ...[
              if (phone == ChildPhone.iphone) const SizedBox(width: 10),
              Expanded(
                child: _PhoneOption(
                  key: ValueKey('ob-phone-${phone.name}'),
                  semanticsId: phone == ChildPhone.android
                      ? QaIds.obPhoneAndroid
                      : null,
                  label: label,
                  icon: icon,
                  selected: data.phone == phone,
                  onTap: () => cubit.setPhone(phone),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(child: DsOverlineText(s.genderOptional)),
            if (data.gender != null)
              DsInlineButton.quiet(
                key: const ValueKey('ob-gender-skip'),
                label: s.obSkip,
                onTap: () => cubit.setGender(null),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (value, label) in [
              ('girl', s.genderGirl),
              ('boy', s.genderBoy),
            ])
              DsCategoryChip(
                key: ValueKey('ob-gender-$value'),
                label: label,
                selected: data.gender == value,
                restBackground: AppColors.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 9,
                ),
                onTap: () =>
                    cubit.setGender(data.gender == value ? null : value),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(s.obGenderWhy, style: AppText.meta),
      ],
    );
  }
}

class _PhoneOption extends StatelessWidget {
  const _PhoneOption({
    super.key,
    this.semanticsId,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String? semanticsId;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: semanticsId,
      container: true,
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.97,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryTint : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: selected ? AppColors.primary : AppColors.ink,
              ),
              const SizedBox(height: 6),
              Text(label, style: AppText.rowTitleStrong),
            ],
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(s.obTuneTitle, style: AppText.title1),
        const SizedBox(height: 6),
        Text(s.obTuneSub(data.name), style: AppText.subtitle),
        for (final intent in data.tuned) ...[
          const SizedBox(height: 14),
          DsCard(
            key: ValueKey('ob-tune-${intent.name}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GoalIcon(intent: intent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        goalTitle(s, intent),
                        style: AppText.rowTitleStrong,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                switch (tuneKindFor(intent)) {
                  TuneKind.minutes => Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatHm(s, data.minutesFor(intent)),
                              key: ValueKey('ob-minutes-${intent.name}'),
                              style: AppText.title1,
                            ),
                            Text(s.obADayAtMost, style: AppText.meta),
                          ],
                        ),
                      ),
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
                  TuneKind.window => Builder(
                    builder: (context) {
                      final (start, end) = data.windowFor(intent);
                      return Column(
                        children: [
                          _TimeRow(
                            label: s.goalFrom,
                            value: start,
                            onTap: () async {
                              final t = await _pick(context, start);
                              if (t != null) cubit.setWindow(intent, t, end);
                            },
                          ),
                          _TimeRow(
                            label: s.goalUntil,
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
                  TuneKind.homework => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.obHomeworkGate, style: AppText.meta),
                      const SizedBox(height: 2),
                      Text(s.obAnyStudyTask, style: AppText.body),
                    ],
                  ),
                  TuneKind.none => const SizedBox.shrink(),
                },
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        Text(s.obSuggested('${data.age}'), style: AppText.meta),
      ],
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final FiniTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppText.body)),
            Text(value.label, style: AppText.rowTitleStrong),
          ],
        ),
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
