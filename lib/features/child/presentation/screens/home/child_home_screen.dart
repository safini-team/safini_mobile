import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/child/presentation/cubit/home/home_cubit.dart';
import 'package:safini/features/child/presentation/cubit/quest_cubit.dart';
import 'package:safini/features/child/presentation/cubit/quest_state.dart';
import 'package:safini/features/child/presentation/widgets/cards/reward_store_card.dart';
import 'package:safini/features/child/presentation/widgets/dialogs/task_detail_dialog.dart';
import 'package:safini/features/child/presentation/widgets/tiles/quest_tile.dart';
import 'package:safini/core/translation/generated/l10n.dart';

/// Localized greeting based on the current time of day.
String _timeBasedGreeting(S s) {
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
      child: const _ChildHomeView(),
    );
  }
}

// ─── Root View ────────────────────────────────────────────────────────────────

class _ChildHomeView extends StatelessWidget {
  const _ChildHomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Column(
        children: [
          _HomeHeader(),
          Expanded(child: _QuestListBody()),
        ],
      ),
    );
  }
}

// ─── Purple Header ─────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuestCubit, QuestState>(
      buildWhen: (prev, curr) => prev.childNickname != curr.childNickname,
      builder: (context, state) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colorScheme.primary.withValues(alpha: 0.9),
                context.colorScheme.primary,
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.md,
                bottom: AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.childNickname != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Text(
                        '${_timeBasedGreeting(S.of(context))}, ${state.childNickname}!',
                        style: context.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  RewardStoreCard(
                    onTap: () =>
                        context.read<ChildHomeCubit>().selectTab(2),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Quest List ───────────────────────────────────────────────────────────────

class _QuestListBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<QuestCubit, QuestState>(
      builder: (context, state) {
        if (state.quests.isEmpty) {
          return Center(
            child: Text(
              s.noQuestsInCategory,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      s.todaysQuests,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    _QuestCountBadge(
                      completed: state.completedCount,
                      total: state.totalCount,
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final quest = state.quests[index];
                final cubit = context.read<QuestCubit>();
                return QuestTile(
                  quest: quest,
                  isHighlighted: index == 0,
                  onTap: () => TaskDetailDialog.show(
                    context,
                    quest,
                    onSubmit: quest.isCompleted || quest.isSubmitted
                        ? null
                        : (note) => cubit.submitQuest(quest.id, note: note),
                  ),
                );
              }, childCount: state.quests.length),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        );
      },
    );
  }
}

// ─── Count Badge ──────────────────────────────────────────────────────────────

class _QuestCountBadge extends StatelessWidget {
  final int completed;
  final int total;

  const _QuestCountBadge({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.xl),
      ),
      child: Text(
        '$completed/$total',
        style: context.textTheme.labelLarge?.copyWith(
          color: context.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
