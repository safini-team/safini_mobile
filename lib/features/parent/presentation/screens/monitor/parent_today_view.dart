import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';

/// One kid in the scope strip.
class TodayKid {
  const TodayKid({required this.id, required this.name, required this.color});

  final String id;
  final String name;
  final Color color;
}

/// A submission waiting on the parent.
class TodayReview {
  const TodayReview({
    required this.id,
    required this.title,
    required this.meta,
    required this.kidName,
    required this.color,
    required this.coins,
  });

  final String id;
  final String title;
  final String meta;
  final String kidName;
  final Color color;
  final int coins;
}

/// One app row in "Where the time went".
class TodayApp {
  const TodayApp({
    required this.name,
    required this.emoji,
    required this.usedMinutes,
    required this.limitMinutes,
  });

  final String name;
  final String emoji;
  final int usedMinutes;
  final int limitMinutes;

  bool get isOver => limitMinutes > 0 && usedMinutes > limitMinutes;
}

class ParentTodayData {
  const ParentTodayData({
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
  });

  final List<TodayKid> kids;
  final int selectedIndex;
  final String kidName;
  final int usedMinutes;
  final int limitMinutes;
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

  int get leftMinutes =>
      limitMinutes <= 0 ? 0 : (limitMinutes - usedMinutes).clamp(0, limitMinutes);

  double get ringProgress =>
      limitMinutes <= 0 ? 0 : (usedMinutes / limitMinutes).clamp(0.0, 1.0);
}

/// `hm()` from the artboard script, with localised units: `2 h 10 m` in
/// English, `2 ч 10 мин` in Russian, `2 s 10 d` in Uzbek.
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
  return m == 0
      ? '$h${s.unitHour}'
      : '$h${s.unitHour}${m < 10 ? '0' : ''}$m';
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
    this.onRefresh,
  });

  final ParentTodayData data;
  final ValueChanged<int> onSelectKid;
  final VoidCallback onOpenSettings;
  final ValueChanged<TodayReview> onOpenReview;
  final ValueChanged<TodayReview> onApproveReview;
  final VoidCallback onOpenLimits;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return DsScreen(
      onRefresh: onRefresh,
      slivers: [
        SliverToBoxAdapter(child: _Header(data: data, onTap: onOpenSettings)),
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
                  selectedKey: data.kids[data.selectedIndex.clamp(
                    0,
                    data.kids.length - 1,
                  )].id,
                  options: [
                    for (final kid in data.kids)
                      DsPickerOption(
                        key: kid.id,
                        label: kid.name,
                        color: kid.color,
                      ),
                  ],
                  onSelect: (id) => onSelectKid(
                    data.kids.indexWhere((kid) => kid.id == id),
                  ),
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
              child: DsGroup(
                verticalPadding: 4,
                children: [for (final app in data.apps) _AppRow(app: app)],
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
          Row(
            children: [
              DsProgressRing(
                progress: data.ringProgress,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatHmTight(s, data.usedMinutes),
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.504,
                        height: 1.1,
                        color: AppColors.ink,
                        fontFeatures: AppText.tabular,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      data.limitMinutes > 0
                          ? s.ofTotal(formatHmTight(s, data.limitMinutes))
                          : s.tabToday,
                      style: AppText.micro,
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
                    Text(s.screenTime.toUpperCase(), style: AppText.overline),
                    const SizedBox(height: 6),
                    Text(
                      data.limitMinutes > 0
                          ? s.kidHasLeftToday(
                              data.kidName,
                              formatHm(s, data.leftMinutes),
                            )
                          : s.kidUsedToday(
                              data.kidName,
                              formatHm(s, data.usedMinutes),
                            ),
                      style: AppText.headline.copyWith(
                        fontSize: 17,
                        letterSpacing: -0.204,
                        height: 1.35,
                      ),
                    ),
                    if (data.topApp.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        s.mostOfItIn(data.topApp),
                        style: AppText.meta.copyWith(height: 1.4),
                      ),
                    ],
                  ],
                ),
              ),
            ],
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
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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
  });

  final TodayReview review;
  final VoidCallback onOpen;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
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
                DsPill.tint(label: '+${review.coins}'),
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
                    label: S.of(context).approve,
                    onTap: onApprove,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DsInlineButton.quiet(
                    label: S.of(context).lookCloser,
                    onTap: onOpen,
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

class _AppRow extends StatelessWidget {
  const _AppRow({required this.app});

  final TodayApp app;

  /// The artboard scales every bar against a fixed 90-minute reference so the
  /// rows stay comparable, rather than each app filling its own limit.
  static const int _scaleMinutes = 90;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          DsEmojiTile(emoji: app.emoji, fontSize: 17),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(child: Text(app.name, style: AppText.body)),
                    Text(
                      formatHm(S.of(context), app.usedMinutes),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        color: app.isOver
                            ? AppColors.dangerDeep
                            : AppColors.textSecondary,
                        fontFeatures: AppText.tabular,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                DsProgressBar(
                  progress: app.usedMinutes / _scaleMinutes,
                  color: app.isOver ? AppColors.danger : AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
