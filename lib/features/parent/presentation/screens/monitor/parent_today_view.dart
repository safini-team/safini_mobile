import 'package:safini/features/parent/presentation/widgets/apps/overall_budget_card.dart';
import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/models/presentation/widgets/app_time_list.dart';

/// One kid in the scope strip.
class TodayKid {
  const TodayKid({
    required this.id,
    required this.name,
    required this.color,
    this.pendingReviewCount = 0,
  });

  final String id;
  final String name;
  final Color color;

  /// Items waiting on the parent for this child (tasks plus prize asks).
  final int pendingReviewCount;
}

/// What a review is for: a task to pay for, a prize the child asked for
/// (coins already held), or a wish to add to the store (SAF-190).
enum TodayReviewKind { task, prize, wish }

/// A submission waiting on the parent.
class TodayReview {
  const TodayReview({
    required this.id,
    required this.title,
    required this.meta,
    required this.kidName,
    required this.color,
    required this.coins,
    this.kind = TodayReviewKind.task,
  });

  final String id;
  final String title;
  final String meta;
  final String kidName;
  final Color color;
  final int coins;
  final TodayReviewKind kind;
}

/// One app row in "Where the time went": every app the child used today.
class TodayApp {
  const TodayApp({
    required this.name,
    required this.emoji,
    required this.usedMinutes,
    required this.limitMinutes,
    this.iconUrl,
  });

  final String name;
  final String emoji;

  /// The child's own icon for this app; [emoji] stands in until it loads.
  final String? iconUrl;
  final int usedMinutes;
  final int limitMinutes;

  bool get isOver => limitMinutes > 0 && usedMinutes > limitMinutes;
}

class ParentTodayData {
  final bool usageAvailable;
  final bool configurationAvailable;
  const ParentTodayData({
    this.usageAvailable = true,
    this.configurationAvailable = true,
    required this.kids,
    required this.selectedIndex,
    required this.kidName,
    required this.usedMinutes,
    required this.limitMinutes,
    required this.topApp,
    required this.tasksDone,
    required this.tasksTotal,
    required this.coins,
    required this.reviews,
    required this.apps,
    this.streakDays,
    this.remainingMinutes,
    this.nextResetAt,
  });

  final List<TodayKid> kids;
  final int selectedIndex;
  final String kidName;
  final int usedMinutes;
  final int? limitMinutes;
  final int? remainingMinutes;
  final DateTime? nextResetAt;
  final String topApp;
  final int tasksDone;
  final int tasksTotal;
  final int coins;
  final List<TodayReview> reviews;
  final List<TodayApp> apps;

  /// `current_streak_days` from the child row, which every child-bearing
  /// endpoint returns. Null only while the dashboard has not loaded yet;
  /// the cell reads "-" in that window.
  final int? streakDays;
}

/// `hm()` from the artboard script, with localised units: `2 h 10 m` in
/// English, `2 ч 10 м` in Russian, `2 s 10 d` in Uzbek.
String formatHm(S s, int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '$m ${s.unitMinute}';
  return m == 0 ? '$h ${s.unitHour}' : '$h ${s.unitHour} $m ${s.unitMinute}';
}

/// `hmTight()`: the compact form inside the ring - `2h10`, `2ч10`, `45m`.
String formatHmTight(S s, int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '$m${s.unitMinute}';
  return m == 0 ? '$h${s.unitHour}' : '$h${s.unitHour}${m < 10 ? '0' : ''}$m';
}

/// Parent · Today, laid out exactly as the artboard: date eyebrow and large
/// title, kid scope chips, the screen-time card, then the review and app
/// sections.
class ParentTodayView extends StatelessWidget {
  const ParentTodayView({
    super.key,
    required this.data,
    required this.onSelectKid,
    required this.onOpenSettings,
    required this.onOpenReview,
    required this.onApproveReview,
    required this.onOpenLimits,
    this.onDeclineReview,
    this.onRefresh,
  });

  final ParentTodayData data;
  final ValueChanged<int> onSelectKid;
  final VoidCallback onOpenSettings;
  final ValueChanged<TodayReview> onOpenReview;
  final ValueChanged<TodayReview> onApproveReview;

  /// Prize asks and wishes only; a task is sent back from its review sheet.
  final ValueChanged<TodayReview>? onDeclineReview;
  final VoidCallback onOpenLimits;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return DsScreen(
      onRefresh: onRefresh,
      slivers: [
        SliverToBoxAdapter(
          child: _Header(data: data, onTap: onOpenSettings),
        ),
        if (data.kids.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.textGutter,
                16,
                AppSpacing.textGutter,
                0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: DsKidPicker(
                  selectedKey: data
                      .kids[data.selectedIndex.clamp(0, data.kids.length - 1)]
                      .id,
                  options: [
                    for (final kid in data.kids)
                      DsPickerOption(
                        key: kid.id,
                        label: kid.name,
                        color: kid.color,
                        badge: kid.pendingReviewCount,
                      ),
                  ],
                  onSelect: (id) =>
                      onSelectKid(data.kids.indexWhere((kid) => kid.id == id)),
                ),
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
            child: _ScreenTimeCard(data: data),
          ),
        ),
        SliverToBoxAdapter(
          child: DsSectionHeader(
            title: s.needsYourReview,
            trailingText: data.reviews.isEmpty
                ? null
                : s.waitingCount(data.reviews.length),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: data.reviews.isEmpty
                ? const _AllCaughtUp()
                : DsGroup(
                    horizontalPadding: 0,
                    verticalPadding: 0,
                    children: [
                      for (final review in data.reviews)
                        _ReviewRow(
                          review: review,
                          onOpen: () => onOpenReview(review),
                          onApprove: () => onApproveReview(review),
                          onDecline: onDeclineReview == null
                              ? null
                              : () => onDeclineReview!(review),
                        ),
                    ],
                  ),
          ),
        ),
        if (data.apps.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: DsSectionHeader(
              title: s.whereTheTimeWent,
              trailingText: s.tabLimits,
              onTrailingTap: onOpenLimits,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter,
              ),
              child: AppTimeList(
                // A new child is a new list, collapsed again.
                key: ValueKey(data.kidName),
                apps: [
                  for (final app in data.apps)
                    AppTimeRow(
                      name: app.name,
                      iconUrl: app.iconUrl,
                      usedMinutes: app.usedMinutes,
                      isOver: app.isOver,
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.data, required this.onTap});

  final ParentTodayData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DsLargeTitle(
      title: S.of(context).tabToday,
      trailing: Pressable(
        onTap: onTap,
        scale: 0.94,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: AppShadows.hairline,
          ),
          child: AppIcons.gear(),
        ),
      ),
    );
  }
}

class _ScreenTimeCard extends StatelessWidget {
  const _ScreenTimeCard({required this.data});

  final ParentTodayData data;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return DsCard(
      radius: AppRadius.feature,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OverallBudgetSummary(
            limitMinutes: data.limitMinutes,
            usedMinutes: data.usedMinutes,
            remainingMinutes: data.remainingMinutes,
            usageAvailable: data.usageAvailable,
            topApp: data.topApp,
            configurationAvailable: data.configurationAvailable,
            nextResetAt: data.nextResetAt,
          ),
          const SizedBox(height: 18),
          const DsDivider(),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(
              children: [
                _Stat(
                  value: '${data.tasksDone}/${data.tasksTotal}',
                  label: s.statTasksDone,
                ),
                const _StatDivider(),
                _Stat(
                  value: data.streakDays?.toString() ?? '-',
                  label: s.statDayStreak,
                ),
                const _StatDivider(),
                _Stat(
                  value: '${data.coins}',
                  label: s.statCoins,
                  valueColor: AppColors.primary,
                  valueLeading: const DsCoinToken(size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    this.valueColor = AppColors.ink,
    this.valueLeading,
  });

  final String value;
  final String label;
  final Color valueColor;
  final Widget? valueLeading;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (valueLeading != null) ...[
                    valueLeading!,
                    const SizedBox(width: 6),
                  ],
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.285,
                      height: 1.15,
                      color: valueColor,
                      fontFeatures: AppText.tabular,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppText.caption),
        ],
      ),
    );
  }
}

/// The 1px vertical rule between stat cells, with the design's 16px lead-in on
/// the cell that follows it.
class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.only(right: 16),
      color: AppColors.divider,
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.review,
    required this.onOpen,
    required this.onApprove,
    this.onDecline,
  });

  final TodayReview review;
  final VoidCallback onOpen;
  final VoidCallback onApprove;
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isTask = review.kind == TodayReviewKind.task;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Pressable.row(
            onTap: onOpen,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DsInitialAvatar(
                  name: review.kidName,
                  color: review.color,
                  size: 36,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(review.title, style: AppText.rowTitleStrong),
                      const SizedBox(height: 3),
                      Text(review.meta, style: AppText.meta),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Earned coins are pine, spent coins are amber.
                if (isTask)
                  DsPill.tint(label: '+${review.coins}')
                else
                  DsPill.coins(
                    label: review.kind == TodayReviewKind.prize
                        ? '−${review.coins}'
                        : '${review.coins}',
                    leading: const DsCoinToken(size: 13),
                    height: 22,
                    fontSize: 13,
                    horizontalPadding: 9,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Padding(
            padding: const EdgeInsets.only(left: 49),
            child: Row(
              children: [
                Expanded(
                  child: DsInlineButton(
                    label: switch (review.kind) {
                      TodayReviewKind.task => s.approve,
                      TodayReviewKind.prize => s.markGiven,
                      TodayReviewKind.wish => s.addToStore,
                    },
                    onTap: onApprove,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DsInlineButton.quiet(
                    label: isTask ? s.lookCloser : s.notThisTime,
                    onTap: isTask ? onOpen : (onDecline ?? onOpen),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllCaughtUp extends StatelessWidget {
  const _AllCaughtUp();

  @override
  Widget build(BuildContext context) {
    return DsCard(
      shadow: AppShadows.flat,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.successBg,
              shape: BoxShape.circle,
            ),
            child: AppIcons.checkLarge(color: const Color(0xFF00A85A)),
          ),
          const SizedBox(height: 12),
          Text(S.of(context).allCaughtUp, style: AppText.rowTitleStrong),
          const SizedBox(height: 4),
          Text(
            S.of(context).newSubmissionsLandHere,
            style: AppText.meta,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
