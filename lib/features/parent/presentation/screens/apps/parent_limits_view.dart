import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/core/utils/screen_time_cap.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm;

class LimitsKid {
  const LimitsKid({required this.id, required this.name, required this.color});

  final String id;
  final String name;
  final Color color;
}

class LimitsApp {
  const LimitsApp({
    required this.slug,
    required this.name,
    required this.emoji,
    required this.usedMinutes,
    required this.limitMinutes,
    required this.isLimited,
    required this.canRedeem,
    this.redeemCoinCost = 100,
    this.redeemRewardMinutes = 30,
  });

  final String slug;
  final String name;
  final String emoji;
  final int usedMinutes;
  final int limitMinutes;

  /// Does the daily cap apply at all. This is the real "no limit".
  final bool isLimited;

  /// May the child buy extra minutes. Independent of [isLimited]: a parent may
  /// want a capped app the child cannot buy past, or an uncapped one.
  final bool canRedeem;

  final int redeemCoinCost;
  final int redeemRewardMinutes;

  bool get isOver => isLimited && limitMinutes > 0 && usedMinutes > limitMinutes;

  /// "1 h of 45 m · over", "21 m · no limit", "21 m · no free time".
  ///
  /// A limit of zero used to render as "no limit", which is the opposite of
  /// what the server does with it: with a cap of 0 every minute is overage
  /// and the child has no free time at all.
  String subtitle(S s) {
    final used = formatHm(s, usedMinutes);
    if (!isLimited) return s.usedNoLimit(used);
    if (limitMinutes <= 0) return '$used · ${s.noFreeTime}';
    final limit = formatHm(s, limitMinutes);
    return isOver ? s.usedOfLimitOver(used, limit) : s.usedOfLimit(used, limit);
  }
}

class ParentLimitsData {
  const ParentLimitsData({
    required this.kids,
    required this.selectedKidId,
    required this.kidName,
    required this.apps,
    this.capMinutes,
  });

  final List<LimitsKid> kids;
  final String? selectedKidId;
  final String kidName;
  final List<LimitsApp> apps;

  /// `daily_screen_time_minutes`: the whole-device budget, or null when the
  /// parent has not set one. Zero is a cap of zero, not the absence of one.
  final int? capMinutes;

  bool get hasCap => capMinutes != null;

  int get usedMinutes => apps.fold(0, (sum, app) => sum + app.usedMinutes);

  /// The sum of the per-app limits. Shown only when there is no cap, and
  /// labelled as the sum it is - nothing spends from this figure.
  int get combinedLimitMinutes =>
      apps.fold(0, (sum, app) => sum + app.limitMinutes);

  /// What the panel counts down: the real cap when set, else the sum.
  int get allowanceMinutes => capMinutes ?? combinedLimitMinutes;

  int get leftMinutes => allowanceMinutes <= 0
      ? 0
      : (allowanceMinutes - usedMinutes).clamp(0, allowanceMinutes);

  double get progress => allowanceMinutes <= 0
      ? 0
      : (usedMinutes / allowanceMinutes).clamp(0.0, 1.0);
}

/// Parent · Limits: kid chips, the deep-purple allowance panel, then the app
/// list.
///
/// The panel's −/+ stepper from the artboard is wired now that the child row
/// carries `daily_screen_time_minutes`. Its bottom rung is "no cap", so the
/// same control that sets the budget is the one that removes it.
class ParentLimitsView extends StatelessWidget {
  const ParentLimitsView({
    super.key,
    required this.data,
    required this.onSelectKid,
    required this.onOpenApp,
    required this.onAddApp,
    this.onSetCap,
    this.onRefresh,
    this.onSeeAllApps,
  });

  final ParentLimitsData data;
  final ValueChanged<String> onSelectKid;
  final ValueChanged<LimitsApp> onOpenApp;
  final VoidCallback onAddApp;

  /// Null minutes removes the cap. Absent entirely in the design preview,
  /// where the panel renders read-only.
  final ValueChanged<int?>? onSetCap;
  final Future<void> Function()? onRefresh;

  /// Opens the read-only list of every app installed on the child's device.
  /// Null hides the entry point (feature-flagged / no child selected).
  final VoidCallback? onSeeAllApps;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return DsScreen(
      onRefresh: onRefresh,
      slivers: [
        // The picker sits above the title now: you pick whose phone first, and
        // the title reads as the answer.
        if (data.kids.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.textGutter,
                2,
                AppSpacing.textGutter,
                0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: DsKidPicker(
                  selectedKey: data.selectedKidId ?? data.kids.first.id,
                  options: [
                    for (final kid in data.kids)
                      DsPickerOption(
                        key: kid.id,
                        label: kid.name,
                        color: kid.color,
                      ),
                  ],
                  onSelect: onSelectKid,
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.textGutter,
              14,
              AppSpacing.textGutter,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.tabLimits, style: AppText.largeTitle),
                const SizedBox(height: 4),
                Text(s.limitsSubtitle(data.kidName), style: AppText.subtitle),
              ],
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
            child: _AllowancePanel(data: data, onSetCap: onSetCap),
          ),
        ),
        if (onSetCap != null)
          SliverToBoxAdapter(child: DsFootnote(s.screenTimeCapHint, top: 10)),
        SliverToBoxAdapter(
          child: DsOverline(s.kidsApps(data.kidName), top: 28),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DsGroup(
                  children: [
                    for (final app in data.apps)
                      _AppRow(app: app, onTap: () => onOpenApp(app)),
                    _AddAppRow(onTap: onAddApp),
                  ],
                ),
                DsFootnote(s.limitsFootnote),
                if (!AppConstants.enforcementShipped)
                  DsFootnote(s.limitsNotYetEnforced),
              ],
            ),
          ),
        ),
        if (onSeeAllApps != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                14,
                AppSpacing.gutter,
                0,
              ),
              child: DsGroup(
                children: [
                  DsRow(
                    onTap: onSeeAllApps,
                    title: s.seeAllApps,
                    leading: const DsEmojiTile(
                      emoji: '📱',
                      size: 36,
                      radius: AppRadius.sm,
                      fontSize: 18,
                    ),
                    trailing: AppIcons.chevronRight(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _AllowancePanel extends StatelessWidget {
  const _AllowancePanel({required this.data, this.onSetCap});

  final ParentLimitsData data;
  final ValueChanged<int?>? onSetCap;

  /// With a cap: the cap. Without: the old sum, and the label says so.
  String _headline(S s) {
    if (data.hasCap) return formatHm(s, data.capMinutes!);
    return data.combinedLimitMinutes <= 0
        ? s.noLimitsSet
        : formatHm(s, data.combinedLimitMinutes);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final overline = data.hasCap
        ? s.screenTimeCap
        : s.dailyAllowanceFor(data.kidName);

    return DsCard.deep(
      radius: AppRadius.feature,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  overline.toUpperCase(),
                  style: AppText.overline.copyWith(
                    color: const Color(0x80FFFFFF),
                  ),
                ),
              ),
              if (onSetCap != null) ...[
                const SizedBox(width: 12),
                DsStepper.onDeep(
                  onLess: () => onSetCap!(screenTimeCapDown(data.capMinutes)),
                  onMore: () => onSetCap!(
                    screenTimeCapUp(
                      data.capMinutes,
                      combinedMinutes: data.combinedLimitMinutes,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _headline(s),
            style: AppText.title2.copyWith(
              letterSpacing: -0.64,
              color: AppColors.textOnPrimary,
              fontSize: 32,
            ).nums,
          ),
          const SizedBox(height: 18),
          DsProgressBar(
            progress: data.progress,
            height: 8,
            trackColor: const Color(0x29FFFFFF),
            color: AppColors.primaryBar,
          ),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  s.timeUsed(formatHm(s, data.usedMinutes)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.metaSm.copyWith(
                    color: const Color(0xB3FFFFFF),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  data.allowanceMinutes <= 0
                      ? ''
                      : s.timeLeft(formatHm(s, data.leftMinutes)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: AppText.metaSm.copyWith(
                    color: const Color(0xB3FFFFFF),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppRow extends StatelessWidget {
  const _AppRow({required this.app, required this.onTap});

  final LimitsApp app;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DsRow(
      onTap: onTap,
      title: app.name,
      subtitle: app.subtitle(S.of(context)),
      subtitleStyle: AppText.metaSm.copyWith(
        color: app.isOver ? AppColors.dangerDeep : AppColors.textSecondary,
      ),
      leading: DsEmojiTile(
        emoji: app.emoji,
        size: 36,
        radius: AppRadius.sm,
        fontSize: 18,
      ),
      trailing: AppIcons.chevronRight(),
    );
  }
}

class _AddAppRow extends StatelessWidget {
  const _AddAppRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable.row(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primaryTint,
                shape: BoxShape.circle,
              ),
              child: AppIcons.plus(size: 16),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                S.of(context).addAnApp,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.rowTitleStrong.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty and loading states, kept next to the view they belong to.
class ParentLimitsSkeleton extends StatelessWidget {
  const ParentLimitsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScreen(
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
                  width: 130,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.fillPressed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 26),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.fillPressed,
                    borderRadius: BorderRadius.circular(AppRadius.feature),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.fillPressed,
                    borderRadius: BorderRadius.circular(AppRadius.group),
                    boxShadow: AppShadows.flat,
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
