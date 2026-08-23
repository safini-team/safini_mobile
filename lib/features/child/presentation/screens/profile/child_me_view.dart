import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';

class MeBadge {
  const MeBadge({required this.emoji, required this.label, this.earned = true});

  final String emoji;
  final String label;
  final bool earned;
}

class ChildMeData {
  const ChildMeData({
    required this.name,
    required this.faceEmoji,
    required this.avatarColor,
    required this.levelLine,
    required this.xpProgress,
    required this.xpCaption,
    required this.coins,
    required this.questsDone,
    required this.streakDays,
    required this.badges,
    this.accessoryEmoji,
  });

  final String name;
  final String faceEmoji;
  final Color avatarColor;
  final String levelLine;
  final double xpProgress;
  final String xpCaption;
  final int coins;
  final int questsDone;
  final int streakDays;
  final List<MeBadge> badges;
  final String? accessoryEmoji;
}

/// Kid · Me: the avatar card with the level bar, this week's streak strip, then
/// the badge row.
class ChildMeView extends StatelessWidget {
  const ChildMeView({
    super.key,
    required this.data,
    required this.onChangeAvatar,
    this.onEditName,
    this.onRefresh,
    this.footer,
  });

  final ChildMeData data;
  final VoidCallback onChangeAvatar;
  final VoidCallback? onEditName;
  final Future<void> Function()? onRefresh;

  /// Appended under the badges. The artboard has nothing here, but the child
  /// still needs language and sign out somewhere.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return DsScreen(
      background: AppColors.bgChild,
      onRefresh: onRefresh,
      slivers: [
        SliverToBoxAdapter(child: DsLargeTitle(title: s.tabMe)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              18,
              AppSpacing.gutter,
              0,
            ),
            child: _ProfileCard(
              data: data,
              onChangeAvatar: onChangeAvatar,
              onEditName: onEditName,
            ),
          ),
        ),
        SliverToBoxAdapter(child: DsOverline(s.thisWeek)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: _WeekStrip(streakDays: data.streakDays),
          ),
        ),
        if (data.badges.isNotEmpty) ...[
          SliverToBoxAdapter(child: DsOverline(s.badges)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter,
              ),
              child: Row(
                children: [
                  for (var i = 0; i < data.badges.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: _BadgeTile(badge: data.badges[i])),
                  ],
                ],
              ),
            ),
          ),
        ],
        if (footer != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: footer!,
            ),
          ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.data,
    required this.onChangeAvatar,
    required this.onEditName,
  });

  final ChildMeData data;
  final VoidCallback onChangeAvatar;
  final VoidCallback? onEditName;

  @override
  Widget build(BuildContext context) {
    return DsCard(
      radius: AppRadius.feature,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: SizedBox(
              width: 88,
              height: 88,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: data.avatarColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        data.faceEmoji,
                        style: const TextStyle(fontSize: 42, height: 1.15),
                      ),
                    ),
                  ),
                  if (data.accessoryEmoji != null)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x4D17151C),
                              offset: Offset(0, 2),
                              blurRadius: 8,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: Text(
                          data.accessoryEmoji!,
                          style: const TextStyle(fontSize: 17, height: 1.15),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Pressable(
            onTap: onEditName,
            scale: onEditName == null ? 1 : 0.97,
            child: Text(
              data.name,
              textAlign: TextAlign.center,
              style: AppText.title5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            data.levelLine,
            textAlign: TextAlign.center,
            style: AppText.meta.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 16),
          DsProgressBar(progress: data.xpProgress, height: 7),
          const SizedBox(height: 8),
          Text(
            data.xpCaption,
            textAlign: TextAlign.center,
            style: AppText.caption,
          ),
          const SizedBox(height: 18),
          Center(
            child: Pressable(
              onTap: onChangeAvatar,
              scale: 0.96,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.fill,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  S.of(context).changeAvatar,
                  style: AppText.chip.copyWith(letterSpacing: -0.087),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Seven day circles; the streak fills them from Monday forward, today carries
/// a ring instead of a fill.
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.streakDays});

  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final todayIndex = DateTime.now().weekday - 1;
    final firstDone = (todayIndex + 1 - streakDays).clamp(0, 7);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final monday = DateTime.utc(2024, 1, 1);
    final labels = [
      for (var i = 0; i < 7; i++)
        DateFormat.E(locale).format(monday.add(Duration(days: i))),
    ];

    return DsCard(
      shadow: AppShadows.flat,
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      labels[i],
                      maxLines: 1,
                      style: AppText.micro.copyWith(letterSpacing: 0.345),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _DayDot(
                    done: i >= firstDone && i <= todayIndex && streakDays > 0,
                    isToday: i == todayIndex,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.done, required this.isToday});

  final bool done;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: done ? AppColors.primary : Colors.transparent,
        shape: BoxShape.circle,
        border: done
            ? null
            : Border.all(
                color: isToday ? AppColors.primary : AppColors.trackAlt,
                width: 2,
              ),
      ),
      child: done ? AppIcons.check(size: 13, strokeWidth: 2.4) : null,
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final MeBadge badge;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: badge.earned ? 1 : 0.45,
      child: DsCard(
        radius: AppRadius.card,
        shadow: AppShadows.flat,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            Text(badge.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 8),
            Text(
              badge.label,
              textAlign: TextAlign.center,
              style: AppText.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
