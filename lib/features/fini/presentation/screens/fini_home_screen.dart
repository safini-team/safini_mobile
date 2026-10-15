import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/qa_ids.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/fini/data/fini_repository.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/onboarding/fini_onboarding_page.dart';
import 'package:safini/features/fini/presentation/cubit/fini_cubit.dart';
import 'package:safini/features/fini/presentation/cubit/fini_inbox_cubit.dart';
import 'package:safini/features/fini/presentation/fini_copy.dart';
import 'package:safini/features/fini/presentation/screens/fini_activity_screen.dart';
import 'package:safini/features/fini/presentation/screens/fini_add_goal_sheet.dart';
import 'package:safini/features/fini/presentation/screens/fini_goal_screen.dart';
import 'package:safini/features/fini/presentation/screens/fini_rules_screen.dart';
import 'package:safini/features/fini/presentation/widgets/goal_visuals.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/parent/presentation/cubit/family_usage_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm;
import 'package:safini/features/parent/presentation/widgets/family/oldest_first.dart';
import 'package:safini/features/parent/presentation/widgets/family/open_add_child.dart';

/// Where a child stands for Fini, from the family row and today's usage.
enum FiniChildReach { notConnected, iphone, android }

/// An iPhone reports no usage (Screen Time keeps it on the device), so plans
/// that step down from usage are Android only for now.
FiniChildReach finiReach(ChildSummaryModel child, {bool? usageAvailable}) {
  if (child.claimedByUserId == null) return FiniChildReach.notConnected;
  if (usageAvailable == false) return FiniChildReach.iphone;
  return FiniChildReach.android;
}

/// The Fini tab (SAF-271): one child at a time, its status, the one card
/// that needs the parent, its goals, and the two ways in to the rules and
/// the activity log.
class FiniHomeScreen extends StatefulWidget {
  const FiniHomeScreen({super.key});

  @override
  State<FiniHomeScreen> createState() => _FiniHomeScreenState();
}

class _FiniHomeScreenState extends State<FiniHomeScreen> {
  String? _loadedFor;

  List<ChildSummaryModel> _kids(BuildContext context) => oldestFirst(
    context.watch<ParentFamilyCubit>().state.family?.children.where(
          (kid) => kid.id.isNotEmpty,
        ) ??
        const [],
  );

  ChildSummaryModel? _selected(
    BuildContext context,
    List<ChildSummaryModel> kids,
  ) {
    final picked = context.watch<ParentHomeCubit>().state.selectedChildId;
    return kids.where((kid) => kid.id == picked).firstOrNull ??
        kids.firstOrNull;
  }

  /// Runs after the frame, outside build: everything it needs from a watched
  /// cubit comes in as [kids], since watching here throws.
  void _ensureLoaded(
    BuildContext context,
    ChildSummaryModel child,
    List<ChildSummaryModel> kids,
  ) {
    if (_loadedFor == child.id) return;
    final first = _loadedFor == null;
    _loadedFor = child.id;
    final fini = context.read<FiniCubit>();
    // A switch between children only swaps the cached child; the badge and
    // the family usage are the same for every child.
    if (!first) {
      fini.load(child.id);
      return;
    }
    fini.load(child.id).then((_) {
      fini.prefetch([
        for (final kid in kids)
          if (kid.id != child.id) kid.id,
      ]);
    });
    context.read<FiniInboxCubit>().refresh();
    context.read<FamilyUsageCubit>().load([for (final kid in kids) kid.id]);
  }

  Future<void> _refresh(BuildContext context, ChildSummaryModel child) =>
      Future.wait([
        context.read<FiniCubit>().load(child.id, force: true),
        context.read<FiniInboxCubit>().refresh(),
      ]);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final kids = _kids(context);
    final child = _selected(context, kids);
    final inbox = context.watch<FiniInboxCubit>().state;
    final trial = context.watch<FiniCubit>().state.trial;
    if (child != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ensureLoaded(this.context, child, kids);
      });
    }

    return DsScreen(
      onRefresh: child == null ? null : () => _refresh(context, child),
      slivers: [
        SliverToBoxAdapter(
          child: DsLargeTitle(
            title: s.tabFini,
            trailing: trial.inTrial && trial.daysLeft != null
                ? _TrialPill(daysLeft: trial.daysLeft!)
                : null,
          ),
        ),
        if (kids.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: DsKidStories(
                showEveryone: false,
                everyoneLabel: s.scopeEveryone,
                addLabel: s.addShort,
                selectedId: child?.id,
                kids: [
                  for (final kid in kids)
                    DsStoryKid(
                      id: kid.id,
                      name: kid.nickname,
                      color: AppColors.kidColor(kid.id),
                      avatar: kid.avatarLook,
                      hasNews: (inbox.byChild[kid.id] ?? 0) > 0,
                    ),
                ],
                onSelect: (id) {
                  if (id != null) {
                    context.read<ParentHomeCubit>().selectChild(id);
                  }
                },
                onAdd: () => openAddChild(context),
              ),
            ),
          ),
        if (child == null)
          SliverToBoxAdapter(
            child: _MascotCard(
              pose: 'wave',
              title: s.finiNoChild,
              action: s.addChild,
              onAction: () => openAddChild(context),
            ),
          )
        else
          ..._body(context, child),
      ],
    );
  }

  List<Widget> _body(BuildContext context, ChildSummaryModel child) {
    final s = S.of(context);
    final state = context.watch<FiniCubit>().state;
    final usage = context.watch<FamilyUsageCubit>().state?[child.id];
    final reach = finiReach(
      child,
      usageAvailable: usage?.screenTime.usageAvailable,
    );

    if (state.childId != child.id || state.status == FiniStatus.loading) {
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 80),
            child: Center(child: CircularProgressIndicator.adaptive()),
          ),
        ),
      ];
    }
    if (state.status == FiniStatus.error) {
      return [
        SliverToBoxAdapter(
          child: _MascotCard(
            pose: 'oops',
            title: s.networkError,
            action: s.retry,
            onAction: () => context.read<FiniCubit>().load(child.id),
          ),
        ),
      ];
    }

    // The trial ended without Pro: one calm card, nothing else to act on.
    if (state.trial.paused) {
      return [
        SliverToBoxAdapter(
          child: _MascotCard(
            key: const ValueKey('fini-paused'),
            pose: 'wait',
            title: s.finiPausedTitle,
            body: s.finiPausedBody,
            action: s.finiKeepWithPro,
            onAction: () => context.router.push(const NamedRoute('paywall')),
          ),
        ),
      ];
    }

    final card = state.pending.firstOrNull;
    return [
      SliverToBoxAdapter(
        child: _StatusCard(
          line: reach == FiniChildReach.notConnected
              ? s.finiNotConnected(child.nickname)
              : finiStatusLine(
                  s,
                  childName: child.nickname,
                  settings: state.settings,
                  goals: state.goals.length,
                  pending: state.pending.length,
                ),
          sub: reach == FiniChildReach.iphone ? s.finiIosNote : s.finiPromise,
          pose: state.settings.paused
              ? 'wait'
              : (state.goals.isEmpty ? 'point' : 'wave'),
        ),
      ),
      if (card != null)
        SliverToBoxAdapter(
          child: _NeedsYouCard(proposal: card, childName: child.nickname),
        ),
      SliverToBoxAdapter(child: DsOverline(s.finiGoalsHeader, top: 24)),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: DsGroup(
            children: [
              for (final (index, goal) in state.goals.indexed)
                Semantics(
                  identifier: index == 0 ? QaIds.finiFirstGoal : null,
                  container: index == 0,
                  child: DsRow(
                    key: ValueKey('fini-goal-${goal.id}'),
                    onTap: () => openFiniGoal(context, goal, child.nickname),
                    leading: GoalIcon(intent: goal.intent),
                    title: goalTitle(s, goal.intent),
                    subtitle: goalValueLine(s, goal),
                    trailing: AppIcons.chevronRight(),
                  ),
                ),
              Semantics(
                identifier: QaIds.finiAddGoal,
                container: true,
                child: DsRow(
                  key: const ValueKey('fini-add-goal'),
                  onTap: () => state.goals.isEmpty
                      ? _setUp(context, child)
                      : showAddGoalSheet(context, childName: child.nickname),
                  leading: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AppIcons.plus(size: 16, color: AppColors.primary),
                  ),
                  title: state.goals.isEmpty ? s.finiPickGoal : s.finiAddGoal,
                  titleColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            14,
            AppSpacing.gutter,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: _Tile(
                  semanticsId: QaIds.finiRules,
                  key: const ValueKey('fini-rules-tile'),
                  title: s.finiWhatItCanDo,
                  sub: s.finiSwitchesOn(state.settings.switchesOn, 5),
                  onTap: () => openFiniRules(context, child.nickname),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Tile(
                  semanticsId: QaIds.finiActivity,
                  key: const ValueKey('fini-activity-tile'),
                  title: s.finiActivity,
                  sub: s.finiThingsToday(state.activityToday(DateTime.now())),
                  onTap: () => openFiniActivity(context, child.nickname),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }
}

/// "45 min a day", "Screens off 22:00-07:00", or the tile's own line.
String goalValueLine(S s, FiniGoal goal) {
  if (goal.isWindow && goal.windowStart != null && goal.windowEnd != null) {
    return s.goalScreensOff(goal.windowStart!.label, goal.windowEnd!.label);
  }
  final minutes = goal.targetMinutes;
  if (goal.isBudget && minutes != null) {
    return s.goalMinutesADay(formatHm(s, minutes));
  }
  return switch (goal.intent) {
    GoalIntent.homework => s.goalHomeworkSub,
    GoalIntent.learning => s.goalLearningSub,
    _ => '',
  };
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.line,
    required this.sub,
    required this.pose,
  });

  final String line;
  final String sub;
  final String pose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        16,
        AppSpacing.gutter,
        0,
      ),
      child: DsCard(
        padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
        child: Row(
          children: [
            Image.asset(
              'assets/mascot/fini-$pose.png',
              width: 72,
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line,
                    key: const ValueKey('fini-status'),
                    style: AppText.rowTitleStrong.copyWith(height: 1.35),
                  ),
                  const SizedBox(height: 6),
                  Text(sub, style: AppText.meta.copyWith(height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeedsYouCard extends StatelessWidget {
  const _NeedsYouCard({required this.proposal, required this.childName});

  final FiniProposal proposal;
  final String childName;

  Future<void> _decide(BuildContext context, FiniDecision decision) async {
    final s = S.of(context);
    final error = await context.read<FiniCubit>().decide(proposal, decision);
    if (!context.mounted || error == null) return;
    AppSnackBar.error(context, error.isEmpty ? s.networkError : error);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final time = TimeOfDay.fromDateTime(proposal.createdAt).format(context);
    return Padding(
      key: const ValueKey('fini-needs-you'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        12,
        AppSpacing.gutter,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.group),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DsOverlineText(
                    s.finiNeedsYou,
                    color: AppColors.primary,
                  ),
                ),
                Text(time, style: AppText.metaSm),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              finiCardTitle(s, proposal, childName: childName),
              style: AppText.rowTitleLg,
            ),
            if (proposal.reason.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(finiReasonLine(s, proposal), style: AppText.meta),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DsInlineButton.quiet(
                    label: s.finiNotNow,
                    onTap: () => _decide(context, FiniDecision.dismiss),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DsInlineButton(
                    label: finiCardYes(s, proposal),
                    onTap: () => _decide(context, FiniDecision.accept),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    super.key,
    required this.semanticsId,
    required this.title,
    required this.sub,
    required this.onTap,
  });

  final String semanticsId;
  final String title;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: semanticsId,
      container: true,
      child: DsCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        radius: AppRadius.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppText.rowTitleStrong),
            const SizedBox(height: 4),
            Text(sub, style: AppText.meta),
          ],
        ),
      ),
    );
  }
}

class _MascotCard extends StatelessWidget {
  const _MascotCard({
    super.key,
    required this.pose,
    required this.title,
    this.body,
    required this.action,
    required this.onAction,
  });

  final String pose;
  final String title;
  final String? body;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        24,
        AppSpacing.gutter,
        0,
      ),
      child: DsCard(
        child: Column(
          children: [
            Image.asset('assets/mascot/fini-$pose.png', height: 120),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: AppText.rowTitleLg),
            if (body != null) ...[
              const SizedBox(height: 6),
              Text(body!, textAlign: TextAlign.center, style: AppText.meta),
            ],
            const SizedBox(height: 16),
            DsPrimaryButton(label: action, onTap: onAction),
          ],
        ),
      ),
    );
  }
}

/// No goals yet: the onboarding from board B, then a reload.
Future<void> _setUp(BuildContext context, ChildSummaryModel child) async {
  final cubit = context.read<FiniCubit>();
  await openFiniOnboarding(
    context,
    repo: getIt<FiniRepository>(),
    childId: child.id,
    name: child.nickname,
    age: child.age,
  );
  await cubit.load(child.id);
}

/// "Free trial · 11 days left", next to the title while the trial runs.
class _TrialPill extends StatelessWidget {
  const _TrialPill({required this.daysLeft});

  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('fini-trial-pill'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        S.of(context).finiTrialPill(daysLeft),
        style: AppText.metaSm.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
