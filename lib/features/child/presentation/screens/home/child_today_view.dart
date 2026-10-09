import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/child/presentation/widgets/child_avatar.dart';
import 'package:safini/features/child/presentation/widgets/safini_avatar.dart';
import 'package:safini/features/child/presentation/widgets/kid_usage_section.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm;

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

/// Something in the Store the child can spend coins on, previewed on Today:
/// a gift a parent added, or an avatar item not owned yet.
class TodayGift {
  const TodayGift({
    required this.id,
    required this.name,
    required this.emoji,
    required this.cost,
    required this.coins,
    this.isAvatarItem = false,
    this.isWaiting = false,
  });

  final String id;
  final String name;
  final String emoji;
  final int cost;
  final int coins;

  /// Which Store tab it lives on: Avatar, or Gifts.
  final bool isAvatarItem;

  /// Asked for and waiting on a parent, with its price held.
  final bool isWaiting;

  bool get affordable => coins >= cost;

  double get progress => cost <= 0 ? 1 : (coins / cost).clamp(0.0, 1.0);
}

/// Why the child has nothing to start right now.
enum TodayRest { withParent, allDone, empty, offline }

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
    this.gifts = const [],
    this.streakDays,
    this.faceEmoji,
    this.accessoryEmoji,
    this.avatarColor,
    this.level,
    this.characterId,
    this.usageApps = const [],
    this.usageMinutes = 0,
    this.budget,
    this.usageAvailable = true,
    this.loadFailed = false,
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

  /// "Rewards for you": a few things from the Store, so the child sees what
  /// coins are for without opening it. Empty hides the section.
  final List<TodayGift> gifts;

  /// Null until the backend exposes streaks; the pill is hidden when it is.
  final int? streakDays;

  /// The avatar beside the greeting; hidden while the profile has not loaded.
  final String? faceEmoji;
  final String? accessoryEmoji;
  final Color? avatarColor;
  final int? level;

  /// v2: illustrated character ID. When set, [SafiniAvatar] is shown instead
  /// of the legacy emoji disc.
  final String? characterId;

  /// "My usage today": every app used today and every app the parent capped
  /// or blocked, limits first. Empty with no [budget] hides the section.
  final List<KidAppUsage> usageApps;

  /// Minutes across every app today, beside the section title.
  final int usageMinutes;

  /// The parent's daily budget, null when there is none.
  final KidBudget? budget;

  /// False on an iPhone: limits are known, minutes are not.
  final bool usageAvailable;

  /// Today's tasks could not be fetched, so an empty list proves nothing.
  final bool loadFailed;

  bool get hasUsage => budget != null || usageApps.isNotEmpty;

  double get ringProgress =>
      questsTotal <= 0 ? 0 : (questsDone / questsTotal).clamp(0.0, 1.0);

  int get questsLeft => (questsTotal - questsDone).clamp(0, questsTotal);

  /// What the day looks like once there is nothing left to start.
  TodayRest get rest => questsAwaitingReview > 0
      ? TodayRest.withParent
      : questsTotal > 0
      ? TodayRest.allDone
      : loadFailed
      ? TodayRest.offline
      : TodayRest.empty;

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
      TodayRest.offline => s.todayOffline,
    };
  }
}

/// Kid · Today. The child's avatar and greeting, the deep hero, then the next
/// task with the press-and-hold send and up to two more after it, a strip of
/// rewards from the Store, the day's apps against what the parent allows, then
/// more time to buy.
class ChildTodayView extends StatelessWidget {
  const ChildTodayView({
    super.key,
    required this.data,
    required this.onOpenStore,
    required this.onOpenTasks,
    required this.onOpenQuest,
    required this.onSendQuest,
    this.onOpenProfile,
    this.onOpenGift,
    this.onOpenGifts,
    this.onRefresh,
  });

  final ChildTodayData data;
  final VoidCallback onOpenStore;

  /// Opens that reward in the Store. Falls back to [onOpenStore] when null.
  final ValueChanged<TodayGift>? onOpenGift;

  /// "See all" beside the rewards. Falls back to [onOpenStore] when null.
  final VoidCallback? onOpenGifts;
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
            leading: (data.faceEmoji == null && data.characterId == null)
                ? null
                : Pressable(
                    onTap: onOpenProfile,
                    scale: 0.95,
                    child: Padding(
                      // Room for the level pill that hangs below the disc.
                      padding: const EdgeInsets.only(bottom: 6),
                      child: data.characterId != null
                          ? SafiniAvatar(
                              characterId: data.characterId!,
                              size: 54,
                            )
                          : ChildAvatar(
                              faceEmoji: data.faceEmoji!,
                              color:
                                  data.avatarColor ?? AppColors.avatarPalette[1],
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
            title: next == null && data.rest != TodayRest.offline
                ? s.nothingLeft
                : s.doThisNext,
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
        if (data.gifts.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: DsSectionHeader(
              title: s.rewardsForYou,
              trailingText: s.seeAllRewards,
              onTrailingTap: onOpenGifts ?? onOpenStore,
              top: 28,
            ),
          ),
          SliverToBoxAdapter(
            child: _GiftStrip(
              gifts: data.gifts,
              onOpen: onOpenGift ?? (_) => onOpenStore(),
            ),
          ),
        ],
        if (data.hasUsage) ...[
          SliverToBoxAdapter(
            child: DsSectionHeader(
              title: s.myUsageToday,
              trailingText: data.usageAvailable && data.usageMinutes > 0
                  ? formatHm(s, data.usageMinutes)
                  : null,
              top: 28,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter,
              ),
              child: KidUsageSection(
                budget: data.budget,
                apps: data.usageApps,
                usageAvailable: data.usageAvailable,
                onOpenStore: onOpenStore,
              ),
            ),
          ),
        ],
        if (data.teaser != null) ...[
          SliverToBoxAdapter(
            child: DsSectionHeader(title: s.buyMoreTime, top: 28),
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
      TodayRest.offline => ('📡', s.todayOffline, s.todayOfflineBody),
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

/// A sideways row of Store rewards. One the child can afford shows its price
/// in coin colours; one still out of reach shows how close they are.
class _GiftStrip extends StatelessWidget {
  const _GiftStrip({required this.gifts, required this.onOpen});

  final List<TodayGift> gifts;
  final ValueChanged<TodayGift> onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Room for the card shadow under the 150pt card.
      height: 162,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          0,
          AppSpacing.gutter,
          12,
        ),
        clipBehavior: Clip.none,
        itemCount: gifts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) => _GiftCard(
          gift: gifts[index],
          onTap: () => onOpen(gifts[index]),
        ),
      ),
    );
  }
}

class _GiftCard extends StatelessWidget {
  const _GiftCard({required this.gift, required this.onTap});

  final TodayGift gift;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    const coin = DsCoinToken(size: 14);

    return SizedBox(
      width: 128,
      child: DsCard(
        onTap: onTap,
        pressScale: 0.975,
        shadow: AppShadows.tile,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(gift.emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            // Same rule as the Store tile: a long name shrinks to fit rather
            // than ending in "..." or a half-cut second line.
            Expanded(
              child: LayoutBuilder(
                builder: (context, box) => FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: box.maxWidth,
                    child: Text(
                      gift.name,
                      style: AppText.rowTitleStrong.copyWith(
                        fontSize: 14.5,
                        letterSpacing: -0.17,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            if (gift.isWaiting)
              DsPill.pending(label: s.prizeWaiting, height: 24, fontSize: 13)
            else if (gift.affordable)
              DsPill.coins(
                label: '${gift.cost}',
                leading: coin,
                height: 24,
                fontSize: 13,
              )
            else ...[
              DsProgressBar(
                progress: gift.progress,
                height: 5,
                color: AppColors.coin,
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  const Opacity(opacity: 0.55, child: coin),
                  const SizedBox(width: 5),
                  // "1240 / 3000" still fits the 100pt card.
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${gift.coins} / ${gift.cost}',
                        maxLines: 1,
                        style: AppText.caption.nums,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
