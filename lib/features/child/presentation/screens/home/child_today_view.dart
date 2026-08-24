import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';

class TodayQuest {
  const TodayQuest({
    required this.id,
    required this.title,
    required this.meta,
    required this.emoji,
    required this.coins,
  });

  final String id;
  final String title;
  final String meta;
  final String emoji;
  final int coins;
}

class TodayTeaser {
  const TodayTeaser({
    required this.name,
    required this.emoji,
    required this.cost,
    required this.coins,
  });

  final String name;
  final String emoji;
  final int cost;
  final int coins;

  int get toGo => (cost - coins).clamp(0, cost);

  double get progress => cost <= 0 ? 1 : (coins / cost).clamp(0.0, 1.0);
}

class ChildTodayData {
  const ChildTodayData({
    required this.greeting,
    required this.name,
    required this.coins,
    required this.questsDone,
    required this.questsTotal,
    required this.openCoins,
    required this.next,
    required this.holdToComplete,
    this.teaser,
    this.streakDays,
  });

  final String greeting;
  final String name;
  final int coins;
  final int questsDone;
  final int questsTotal;

  /// Coins still on the table across every open task.
  final int openCoins;

  final TodayQuest? next;
  final bool holdToComplete;
  final TodayTeaser? teaser;

  /// Null until the backend exposes streaks; the pill is hidden when it is.
  final int? streakDays;

  double get ringProgress =>
      questsTotal <= 0 ? 0 : (questsDone / questsTotal).clamp(0.0, 1.0);

  int get questsLeft => (questsTotal - questsDone).clamp(0, questsTotal);

  String headline(S s) => next == null
      ? s.everythingIsWithParent
      : s.tasksLeftCoinsOnTable(
          s.taskCount(questsLeft),
          s.coinCountShort(openCoins),
        );
}

/// Kid · Today. Deep-purple hero, then the one task to do next with the
/// press-and-hold send, then what the coins are heading towards.
class ChildTodayView extends StatelessWidget {
  const ChildTodayView({
    super.key,
    required this.data,
    required this.onOpenStore,
    required this.onOpenTasks,
    required this.onOpenQuest,
    required this.onSendQuest,
    this.onRefresh,
  });

  final ChildTodayData data;
  final VoidCallback onOpenStore;
  final VoidCallback onOpenTasks;
  final ValueChanged<TodayQuest> onOpenQuest;
  final ValueChanged<TodayQuest> onSendQuest;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final next = data.next;

    return DsScreen(
      background: AppColors.bgChild,
      onRefresh: onRefresh,
      slivers: [
        SliverToBoxAdapter(
          child: DsLargeTitle(
            title: data.name,
            eyebrow: data.greeting,
            crossAxisAlignment: CrossAxisAlignment.start,
            trailing: DsCoinBalance(
              coins: data.coins,
              onTap: onOpenStore,
              shadow: AppShadows.pill,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              18,
              AppSpacing.gutter,
              0,
            ),
            child: _Hero(data: data),
          ),
        ),
        SliverToBoxAdapter(
          child: DsSectionHeader(
            title: next == null ? s.nothingLeft : s.doThisNext,
            trailingText: s.allTasks,
            onTrailingTap: onOpenTasks,
            top: 28,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: next == null
                ? const _AllSent()
                : _NextQuestCard(
                    quest: next,
                    holdToComplete: data.holdToComplete,
                    onOpen: () => onOpenQuest(next),
                    onSend: () => onSendQuest(next),
                  ),
          ),
        ),
        if (data.teaser != null) ...[
          SliverToBoxAdapter(
            child: DsSectionHeader(title: s.almostYours, top: 28),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter,
              ),
              child: _TeaserCard(teaser: data.teaser!, onTap: onOpenStore),
            ),
          ),
        ],
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.data});

  final ChildTodayData data;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return DsCard.deep(
      radius: AppRadius.hero,
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          DsProgressRing.onDeep(
            progress: data.ringProgress,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${data.questsDone}',
                  style: AppText.title4.copyWith(
                    fontSize: 24,
                    letterSpacing: -0.48,
                    color: AppColors.textOnPrimary,
                  ).nums,
                ),
                const SizedBox(height: 1),
                Text(
                  s.ofTotal('${data.questsTotal}'),
                  style: AppText.micro.copyWith(
                    fontSize: 11,
                    color: const Color(0x99FFFFFF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.headline(s),
                  style: AppText.headline.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
                if (data.streakDays != null) ...[
                  const SizedBox(height: 11),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x24FFFFFF),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcons.flame(),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            s.nDayStreak(data.streakDays!),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.metaSm.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                        ),
                      ],
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

class _NextQuestCard extends StatelessWidget {
  const _NextQuestCard({
    required this.quest,
    required this.holdToComplete,
    required this.onOpen,
    required this.onSend,
  });

  final TodayQuest quest;
  final bool holdToComplete;
  final VoidCallback onOpen;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return DsCard(
      radius: AppRadius.feature,
      padding: const EdgeInsets.all(20),
      shadow: AppShadows.cardLifted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Pressable.row(
            onTap: onOpen,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DsEmojiTile(
                  emoji: quest.emoji,
                  size: 44,
                  radius: AppRadius.action,
                  background: AppColors.primaryTint,
                  fontSize: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(quest.title, style: AppText.headline),
                      if (quest.meta.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          quest.meta,
                          style: AppText.meta.copyWith(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                DsPill.coins(label: '+${quest.coins}'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          DsHoldButton(
            label: holdToComplete ? s.holdToMarkDone : s.markItDone,
            holdingLabel: s.keepHolding,
            requireHold: holdToComplete,
            onComplete: onSend,
          ),
        ],
      ),
    );
  }
}

class _AllSent extends StatelessWidget {
  const _AllSent();

  @override
  Widget build(BuildContext context) {
    return DsCard(
      radius: AppRadius.feature,
      shadow: AppShadows.flat,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      child: Column(
        children: [
          const Text('🎈', style: TextStyle(fontSize: 30)),
          const SizedBox(height: 10),
          Text(
            S.of(context).everythingSent,
            style: AppText.cardTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 5),
          Text(
            S.of(context).parentReviewsNext,
            textAlign: TextAlign.center,
            style: AppText.meta.copyWith(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _TeaserCard extends StatelessWidget {
  const _TeaserCard({required this.teaser, required this.onTap});

  final TodayTeaser teaser;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DsCard(
      onTap: onTap,
      shadow: AppShadows.flat,
      child: Row(
        children: [
          DsEmojiTile(
            emoji: teaser.emoji,
            size: 46,
            radius: AppRadius.action,
            fontSize: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  teaser.name,
                  style: AppText.rowTitleStrong.copyWith(
                    fontSize: 16.5,
                    letterSpacing: -0.198,
                  ),
                ),
                const SizedBox(height: 9),
                DsProgressBar(
                  progress: teaser.progress,
                  height: 6,
                  color: AppColors.coin,
                ),
                const SizedBox(height: 7),
                Text(
                  S.of(context).coinsToGo(teaser.toGo),
                  style: AppText.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
