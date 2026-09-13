import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/child/presentation/widgets/child_avatar.dart';

class TodayQuest {
  const TodayQuest({
    required this.id,
    required this.title,
    required this.meta,
    required this.emoji,
    required this.coins,
    this.needsPhoto = false,
  });

  final String id;
  final String title;
  final String meta;
  final String emoji;
  final int coins;

  /// The parent asked for photo proof, so this one cannot be sent from the
  /// card: the button opens the sheet that collects the photo.
  final bool needsPhoto;
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

  double get progress => cost <= 0 ? 1 : (coins / cost).clamp(0.0, 1.0);
}

/// Why the child has nothing to start right now.
enum TodayRest { withParent, allDone, empty }

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
    this.questsAwaitingReview = 0,
    this.more = const [],
    this.teaser,
    this.streakDays,
    this.faceEmoji,
    this.accessoryEmoji,
    this.avatarColor,
    this.level,
  });

  final String greeting;
  final String name;
  final int coins;
  final int questsDone;
  final int questsTotal;

  /// Sent and waiting for the parent. Nothing left to do is not the same as
  /// everything being approved, and the card used to say the former for both.
  final int questsAwaitingReview;

  /// Coins still on the table across every open task.
  final int openCoins;

  final TodayQuest? next;

  /// Up to two more open tasks after [next], shown as compact rows so Today
  /// previews the day without becoming the Tasks tab.
  final List<TodayQuest> more;

  final bool holdToComplete;
  final TodayTeaser? teaser;

  /// Null until the backend exposes streaks; the pill is hidden when it is.
  final int? streakDays;

  /// The avatar beside the greeting; hidden while the profile has not loaded.
  final String? faceEmoji;
  final String? accessoryEmoji;
  final Color? avatarColor;
  final int? level;

  double get ringProgress =>
      questsTotal <= 0 ? 0 : (questsDone / questsTotal).clamp(0.0, 1.0);

  int get questsLeft => (questsTotal - questsDone).clamp(0, questsTotal);

  /// What the day looks like once there is nothing left to start.
  TodayRest get rest => questsAwaitingReview > 0
      ? TodayRest.withParent
      : (questsTotal > 0 ? TodayRest.allDone : TodayRest.empty);

  String headline(S s) {
    if (next != null) {
      return s.tasksLeftCoinsOnTable(
        s.taskCount(questsLeft),
        s.coinCountShort(openCoins),
      );
    }
    return switch (rest) {
      TodayRest.withParent => s.everythingIsWithParent,
      TodayRest.allDone => s.allDoneToday,
      TodayRest.empty => s.nothingForToday,
    };
  }
}

/// Kid · Today. The child's avatar and greeting, the deep hero, then the next
/// task with the press-and-hold send and up to two more after it, then what
/// the coins are heading towards.
class ChildTodayView extends StatelessWidget {
  const ChildTodayView({
    super.key,
    required this.data,
    required this.onOpenStore,
    required this.onOpenTasks,
    required this.onOpenQuest,
    required this.onSendQuest,
    this.onOpenProfile,
    this.onRefresh,
  });

  final ChildTodayData data;
  final VoidCallback onOpenStore;
  final VoidCallback onOpenTasks;
  final VoidCallback? onOpenProfile;
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
            crossAxisAlignment: CrossAxisAlignment.center,
            leading: data.faceEmoji == null
                ? null
                : Pressable(
                    onTap: onOpenProfile,
                    scale: 0.95,
                    child: Padding(
                      // Room for the level pill that hangs below the disc.
                      padding: const EdgeInsets.only(bottom: 6),
                      child: ChildAvatar(
                        faceEmoji: data.faceEmoji!,
                        color: data.avatarColor ?? AppColors.avatarPalette[1],
                        accessoryEmoji: data.accessoryEmoji,
                        level: data.level,
                        size: 54,
                      ),
                    ),
                  ),
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
                ? _Rest(rest: data.rest)
                : _NextQuestCard(
                    quest: next,
                    holdToComplete: data.holdToComplete,
                    onOpen: () => onOpenQuest(next),
                    onSend: () => onSendQuest(next),
                  ),
          ),
        ),
        if (next != null && data.more.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                10,
                AppSpacing.gutter,
                0,
              ),
              child: DsGroup(
                shadow: AppShadows.flat,
                children: [
                  for (final quest in data.more.take(2))
                    _MoreQuestRow(
                      quest: quest,
                      onTap: () => onOpenQuest(quest),
                    ),
                ],
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
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              s.nDayStreak(data.streakDays!),
                              maxLines: 1,
                              softWrap: false,
                              style: AppText.metaSm.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textOnPrimary,
                              ),
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
            label: quest.needsPhoto
                ? s.addPhoto
                : (holdToComplete ? s.holdToMarkDone : s.markItDone),
            holdingLabel: s.keepHolding,
            requireHold: holdToComplete && !quest.needsPhoto,
            // A task the parent wants a photo for goes to the sheet that
            // collects it. Sending it from here skipped the proof entirely.
            onComplete: quest.needsPhoto ? onOpen : onSend,
          ),
        ],
      ),
    );
  }
}

/// A task after the first: tap opens its sheet, where it can be sent.
class _MoreQuestRow extends StatelessWidget {
  const _MoreQuestRow({required this.quest, required this.onTap});

  final TodayQuest quest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable.row(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            DsEmojiTile(
              emoji: quest.emoji,
              size: 36,
              radius: AppRadius.xs,
              background: AppColors.primaryTint,
              fontSize: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(quest.title, style: AppText.rowTitleStrong),
            ),
            const SizedBox(width: 10),
            DsPill.coins(label: '+${quest.coins}', height: 24, fontSize: 13),
            const SizedBox(width: 8),
            AppIcons.chevronRight(),
          ],
        ),
      ),
    );
  }
}

class _Rest extends StatelessWidget {
  const _Rest({required this.rest});

  final TodayRest rest;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final (emoji, title, body) = switch (rest) {
      TodayRest.withParent => ('🎈', s.everythingSent, s.parentReviewsNext),
      TodayRest.allDone => ('🎉', s.allDoneToday, s.allDoneTodayBody),
      TodayRest.empty => ('🌤️', s.nothingForToday, s.nothingForTodayBody),
    };

    return DsCard(
      radius: AppRadius.feature,
      shadow: AppShadows.flat,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 10),
          Text(title, style: AppText.cardTitle.copyWith(fontSize: 18)),
          const SizedBox(height: 5),
          Text(
            body,
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
                Row(
                  children: [
                    const DsCoinToken(size: 14),
                    const SizedBox(width: 5),
                    Text('${teaser.cost}', style: AppText.caption.nums),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
