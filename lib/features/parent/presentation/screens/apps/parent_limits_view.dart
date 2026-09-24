import 'package:flutter/material.dart';
import 'package:safini/core/app_icons/app_icon_tile.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/parent/presentation/widgets/apps/overall_budget_card.dart';
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
  final bool usageAvailable;
  const LimitsApp({
    this.usageAvailable = true,
    required this.slug,
    required this.name,
    required this.emoji,
    required this.usedMinutes,
    required this.limitMinutes,
    this.isBlocked = false,
    required this.isLimited,
    required this.canRedeem,
    this.redeemCoinCost = 100,
    this.redeemRewardMinutes = 30,
    this.iconUrl,
  });

  final String slug;
  final String name;
  final String emoji;

  /// The child's own icon for this app, drawn in place of [emoji] once it
  /// loads. A path on the API; `null` until the child's phone uploads it.
  final String? iconUrl;
  final int usedMinutes;
  final int limitMinutes;

  /// Paused outright, purchased time included, whatever the limit says.
  final bool isBlocked;

  /// Does the daily cap apply at all. This is the real "no limit".
  final bool isLimited;

  /// May the child buy extra minutes. Independent of [isLimited]: a parent may
  /// want a capped app the child cannot buy past, or an uncapped one.
  final bool canRedeem;

  final int redeemCoinCost;
  final int redeemRewardMinutes;

  bool get isOver =>
      isLimited && limitMinutes > 0 && usedMinutes > limitMinutes;

  /// "1 h of 45 m · over", "21 m · no limit", "21 m · no free time".
  ///
  /// A limit of zero used to render as "no limit", which is the opposite of
  /// what the server does with it: with a cap of 0 every minute is overage
  /// and the child has no free time at all.
  String subtitle(S s) {
    final used = formatHm(s, usedMinutes);
    if (isBlocked) return s.blockCompletely;
    if (!isLimited) return s.usedNoLimit(used);
    if (limitMinutes <= 0) return '$used · ${s.noFreeTime}';
    final limit = formatHm(s, limitMinutes);
    return isOver ? s.usedOfLimitOver(used, limit) : s.usedOfLimit(used, limit);
  }
}

class ParentLimitsData {
  final bool usageAvailable;
  final bool configurationAvailable;
  const ParentLimitsData({
    this.usageAvailable = true,
    this.configurationAvailable = true,
    required this.kids,
    required this.selectedKidId,
    required this.kidName,
    required this.apps,
    this.capMinutes,
    this.usedMinutes = 0,
    this.remainingMinutes,
    this.nextResetAt,
  });

  final List<LimitsKid> kids;
  final String? selectedKidId;
  final String kidName;
  final List<LimitsApp> apps;

  /// `daily_screen_time_minutes`: the whole-device budget, or null when the
  /// parent has not set one. Zero is a cap of zero, not the absence of one.
  final int? capMinutes;

  bool get hasCap => capMinutes != null;

  final int usedMinutes;
  final int? remainingMinutes;
  final DateTime? nextResetAt;
}

/// Optional shared budget above independent per-app rules.
class ParentLimitsView extends StatelessWidget {
  const ParentLimitsView({
    super.key,
    required this.data,
    required this.onSelectKid,
    required this.onOpenApp,
    this.onAddApp,
    this.onSetCap,
    this.onRefresh,
    this.showingPrizes = false,
    this.onShowPrizes,
    this.prizeSlivers = const [],
  });

  final ParentLimitsData data;
  final ValueChanged<String> onSelectKid;
  final ValueChanged<LimitsApp> onOpenApp;
  final VoidCallback? onAddApp;

  /// Null minutes removes the cap. Absent entirely in the design preview,
  /// where the panel renders read-only.
  final Future<String?> Function(int?)? onSetCap;
  final Future<void> Function()? onRefresh;

  /// Apps | Prizes (SAF-190): Limits already decides what coins buy, so the
  /// child's prizes sit behind a switch here. Absent in the design preview.
  final bool showingPrizes;
  final ValueChanged<bool>? onShowPrizes;
  final List<Widget> prizeSlivers;

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
                Text(s.dateToday, style: AppText.subtitle),
              ],
            ),
          ),
        ),
        if (onShowPrizes != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                16,
                AppSpacing.gutter,
                0,
              ),
              child: DsSegmentedControl(
                labels: [s.apps, s.prizesTab],
                selectedIndex: showingPrizes ? 1 : 0,
                onChanged: (index) => onShowPrizes!(index == 1),
              ),
            ),
          ),
        if (showingPrizes)
          ...prizeSlivers
        else ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                18,
                AppSpacing.gutter,
                0,
              ),
              child: OverallBudgetCard(
                limitMinutes: data.capMinutes,
                usedMinutes: data.usedMinutes,
                remainingMinutes: data.remainingMinutes,
                usageAvailable: data.usageAvailable,
                configurationAvailable: data.configurationAvailable,
                nextResetAt: data.nextResetAt,
                onSave: onSetCap,
              ),
            ),
          ),

          SliverToBoxAdapter(child: DsOverline(s.apps, top: 28)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DsGroup(
                    children: [
                      for (final app in data.apps)
                        _AppRow(
                          usageAvailable: data.usageAvailable,
                          app: app,
                          onTap: () => onOpenApp(app),
                        ),
                      if (onAddApp != null) _AddAppRow(onTap: onAddApp!),
                    ],
                  ),
                  DsFootnote(s.limitsFootnote),
                  DsFootnote(s.limitsNotYetEnforced),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AppRow extends StatelessWidget {
  final bool usageAvailable;
  const _AppRow({
    this.usageAvailable = true,
    required this.app,
    required this.onTap,
  });

  final LimitsApp app;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DsRow(
      onTap: onTap,
      title: app.name,
      subtitle: usageAvailable ? app.subtitle(s) : _dailyAllowance(s),
      subtitleStyle: AppText.metaSm.copyWith(
        color: app.isOver ? AppColors.dangerDeep : AppColors.textSecondary,
      ),
      leading: AppIconTile(
        emoji: app.emoji,
        iconUrl: app.iconUrl,
        size: 36,
        radius: AppRadius.sm,
        fontSize: 18,
      ),
      trailing: AppIcons.chevronRight(),
    );
  }

  String _dailyAllowance(S s) {
    if (app.isBlocked) return s.blockCompletely;
    if (!app.isLimited) return s.noDailyLimit;
    return s.dailyLimitValue(formatHm(s, app.limitMinutes));
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
                S.of(context).addAnAppLimit,
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
