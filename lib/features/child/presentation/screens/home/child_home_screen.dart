import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/on_app_resume.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/home/home_cubit.dart';
import 'package:safini/features/child/presentation/cubit/home/home_state.dart';
import 'package:safini/features/child/presentation/cubit/profile_cubit.dart';
import 'package:safini/features/child/presentation/cubit/quest_cubit.dart';
import 'package:safini/features/child/presentation/cubit/quest_model.dart';
import 'package:safini/features/child/presentation/cubit/quest_state.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_cubit.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_state.dart';
import 'package:safini/features/child/presentation/screens/home/child_today_view.dart';
import 'package:safini/features/child/presentation/widgets/dialogs/task_detail_dialog.dart';

/// Localized greeting based on the current time of day.
String childGreeting(S s) {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) return s.goodMorning;
  if (hour >= 12 && hour < 17) return s.goodAfternoon;
  if (hour >= 17 && hour < 21) return s.goodEvening;
  return s.goodNight;
}

class ChildHomeScreen extends StatelessWidget {
  const ChildHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<QuestCubit>(),
      // Reload when the Today tab becomes active so submissions made on the
      // Tasks tab (a separate cubit) show up here, and again whenever the app
      // comes back: the parent approves and the block screen spends coins
      // while this app is in the background.
      child: Builder(
        builder: (context) => BlocListener<ChildHomeCubit, ChildHomeState>(
          listenWhen: (prev, curr) =>
              prev.selectedIndex != curr.selectedIndex &&
              curr.selectedIndex == 0,
          listener: (ctx, _) => _refresh(ctx),
          child: OnAppResume(
            onResume: () => _refresh(context),
            child: const _ChildTodayScreen(),
          ),
        ),
      ),
    );
  }

  /// Tasks, wallet and store together: the coin balance shown on Today, Store
  /// and Me is one shared cubit, and reloading only the tasks left it stale.
  static void _refresh(BuildContext context) {
    context.read<QuestCubit>().loadQuests();
    context.read<ProfileCubit>().loadProfile();
    context.read<RewardStoreCubit>().loadStore();
  }
}

class _ChildTodayScreen extends StatelessWidget {
  const _ChildTodayScreen();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocBuilder<QuestCubit, QuestState>(
      builder: (context, quests) {
        if (quests.isLoading && quests.quests.isEmpty) {
          return const _TodaySkeleton();
        }

        final coins = context.watch<CoinsCubit>().state;
        final profile = context.watch<ProfileCubit>().state;
        final store = context.watch<RewardStoreCubit>().state;

        final open = quests.quests
            .where((q) => !q.isCompleted && !q.isSubmitted)
            .toList();
        final next = open.firstOrNull;

        return ChildTodayView(
          data: ChildTodayData(
            greeting: childGreeting(s),
            name: quests.childNickname ?? profile.name,
            coins: coins,
            questsDone: quests.completedCount,
            questsTotal: quests.totalCount,
            questsAwaitingReview: quests.quests.where((q) => q.isSubmitted).length,
            openCoins: open.fold(0, (sum, q) => sum + q.coins),
            streakDays: profile.dayStreak > 0 ? profile.dayStreak : null,
            holdToComplete: true,
            next: next == null ? null : _toTodayQuest(next, s),
            teaser: _teaser(store, coins, s),
          ),
          onOpenStore: () => context.read<ChildHomeCubit>().selectTab(2),
          onOpenTasks: () => context.read<ChildHomeCubit>().selectTab(1),
          onOpenQuest: (quest) => _openQuest(context, quests, quest.id),
          onSendQuest: (quest) => _send(context, quests, quest.id, s),
          onRefresh: () async {
            final cubit = context.read<QuestCubit>();
            final profile = context.read<ProfileCubit>();
            final store = context.read<RewardStoreCubit>();
            await Future.wait([
              cubit.loadQuests(),
              profile.loadProfile(),
              store.loadStore(),
            ]);
          },
        );
      },
    );
  }

  TodayQuest _toTodayQuest(QuestModel quest, S s) => TodayQuest(
    id: quest.id,
    title: quest.title,
    meta: quest.localizedSubtitle(s),
    emoji: quest.emoji ?? '⭐',
    coins: quest.coins,
    needsPhoto: quest.needsPhoto,
  );

  /// The cheapest thing the child cannot afford yet - the artboard's
  /// "Almost yours" hook. Nothing to show once everything is within reach.
  TodayTeaser? _teaser(RewardStoreState store, int coins, S s) {
    final candidates = <({String name, String emoji, int cost})>[
      for (final item in store.appTimeItems)
        (name: item.title, emoji: '⏱️', cost: item.cost),
      for (final item in store.avatarItems)
        if (item.cost != null)
          (name: s.avatarItem, emoji: item.emoji, cost: item.cost!),
    ]..sort((a, b) => a.cost.compareTo(b.cost));

    final target = candidates.where((c) => c.cost > coins).firstOrNull;
    if (target == null) return null;
    return TodayTeaser(
      name: target.name,
      emoji: target.emoji,
      cost: target.cost,
      coins: coins,
    );
  }

  void _openQuest(BuildContext context, QuestState state, String questId) {
    final quest = state.quests.where((q) => q.id == questId).firstOrNull;
    if (quest == null) return;
    final cubit = context.read<QuestCubit>();
    TaskDetailDialog.show(
      context,
      quest,
      onSubmit: quest.isCompleted || quest.isSubmitted
          ? null
          : (note, imageObjectKey) => cubit.submitQuest(
              quest.id,
              note: note,
              imageObjectKey: imageObjectKey,
            ),
      onUploadPhoto: (path) => cubit.uploadPhoto(quest.id, path),
    );
  }

  /// The card sends a task straight off Today. A task the parent asked photo
  /// proof for cannot be sent that way - it opens the sheet that collects the
  /// photo, which is the same rule the sheet itself enforces.
  Future<void> _send(
    BuildContext context,
    QuestState state,
    String questId,
    S s,
  ) async {
    final quest = state.quests.where((q) => q.id == questId).firstOrNull;
    if (quest == null) return;
    if (quest.needsPhoto) {
      _openQuest(context, state, questId);
      return;
    }
    final cubit = context.read<QuestCubit>();
    final error = await cubit.submitQuest(questId);
    if (!context.mounted) return;
    if (error != null) {
      AppSnackBar.error(context, error);
      return;
    }
    AppSnackBar.success(context, s.taskSubmittedForReview);
  }
}

class _TodaySkeleton extends StatelessWidget {
  const _TodaySkeleton();

  @override
  Widget build(BuildContext context) {
    return DsScreen(
      background: AppColors.bgChild,
      animateEntrance: false,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.textGutter,
              6,
              AppSpacing.textGutter,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.fillPressed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 26),
                Container(
                  height: 152,
                  decoration: BoxDecoration(
                    color: AppColors.fillPressed,
                    borderRadius: BorderRadius.circular(AppRadius.hero),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  height: 190,
                  decoration: BoxDecoration(
                    color: AppColors.fillPressed,
                    borderRadius: BorderRadius.circular(AppRadius.feature),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
