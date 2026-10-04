import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safini/core/app_icons/app_icon_tile.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/models/domain/models/device_usage.dart';
import 'package:safini/features/parent/data/app_data.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm, formatHmTight;

/// At or under this many minutes left, the kid sees amber instead of green so
/// the end of a game does not come as a surprise.
const int kidLowTimeMinutes = 10;

/// The parent's daily budget across every app with a rule.
class KidBudget {
  const KidBudget({
    required this.limitMinutes,
    required this.usedMinutes,
    required this.remainingMinutes,
    this.usageAvailable = true,
    this.nextResetAt,
  });

  final int limitMinutes;
  final int usedMinutes;
  final int remainingMinutes;

  /// False on an iPhone, whose usage stays on the device: only the limit is
  /// known, so no "left" figure is shown.
  final bool usageAvailable;
  final DateTime? nextResetAt;
}

enum KidAppState { timesUp, limited, blocked, free }

/// One app in "My usage today": anything the child opened today, plus every
/// app the parent capped or blocked even if it has not been opened yet.
class KidAppUsage {
  const KidAppUsage({
    required this.name,
    required this.usedMinutes,
    this.iconUrl,
    this.limitMinutes,
    this.bonusMinutes = 0,
    this.remainingMinutes,
    this.isBlocked = false,
    this.canRedeem = false,
  });

  final String name;
  final String? iconUrl;
  final int usedMinutes;

  /// The parent's daily cap, before minutes bought with coins. Null when the
  /// app has none: its row is just the minutes.
  final int? limitMinutes;

  /// Bought with coins and not spent yet.
  final int bonusMinutes;

  /// What the server says is still spendable, already capped by the daily
  /// budget.
  final int? remainingMinutes;
  final bool isBlocked;

  /// Extra minutes for this app are sold in the Store.
  final bool canRedeem;

  int get allowanceMinutes => (limitMinutes ?? 0) + bonusMinutes;

  KidAppState get state {
    if (isBlocked) return KidAppState.blocked;
    if (limitMinutes == null) return KidAppState.free;
    return remainingMinutes == 0 ? KidAppState.timesUp : KidAppState.limited;
  }

  /// Limits first, most urgent on top: out of time, then the least left,
  /// then the ones the parent switched off. Uncapped apps follow, most used
  /// first, like "where the time went" on the parent's Today.
  static int compare(KidAppUsage a, KidAppUsage b) {
    final byState = a.state.index.compareTo(b.state.index);
    if (byState != 0) return byState;
    final int byMinutes = switch (a.state) {
      KidAppState.limited => (a.remainingMinutes ?? 0).compareTo(
        b.remainingMinutes ?? 0,
      ),
      KidAppState.free => b.usedMinutes.compareTo(a.usedMinutes),
      _ => 0,
    };
    if (byMinutes != 0) return byMinutes;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}

/// Joins where the time went ([usage], every app opened, real minutes) with
/// the parent's rules ([rules], from `app-usage`) on the app slug. A capped or
/// blocked app reads its minutes from the rule, so "37 m of 45 m" and
/// "8 m left" agree. A rule with no cap adds nothing the budget card does not
/// say, so it only shows if the app was used.
List<KidAppUsage> kidAppUsage({
  DeviceUsage? usage,
  List<ChildAppUsageModel> rules = const [],
}) {
  bool capped(ChildAppUsageModel rule) => rule.isLimited || rule.isBlocked;
  KidAppUsage fromRule(ChildAppUsageModel rule) => KidAppUsage(
    name: rule.displayName,
    iconUrl: rule.iconUrl,
    usedMinutes: rule.usedMinutes,
    limitMinutes: rule.isLimited ? rule.dailyLimitMinutes : null,
    bonusMinutes: rule.bonusMinutesRemaining,
    remainingMinutes: rule.remainingMinutesToday,
    isBlocked: rule.isBlocked,
    canRedeem: rule.canRedeem,
  );

  final pending = {for (final rule in rules) rule.appSlug: rule};
  final rows = <KidAppUsage>[];
  if (usage != null && usage.usageAvailable) {
    for (final app in usage.apps) {
      final rule = pending.remove(app.appSlug);
      rows.add(
        rule != null && capped(rule)
            ? fromRule(rule)
            : KidAppUsage(
                name: app.displayName,
                iconUrl: app.iconUrl ?? rule?.iconUrl,
                usedMinutes: app.usedMinutes,
              ),
      );
    }
  }
  for (final rule in pending.values) {
    if (capped(rule)) rows.add(fromRule(rule));
  }
  return rows..sort(KidAppUsage.compare);
}

/// Kid · Today "My usage today": how much of the day's budget is left, then
/// one row per app - what is left of a capped one, the minutes of the rest -
/// so the child can plan a game before the block screen ends it.
class KidUsageSection extends StatefulWidget {
  const KidUsageSection({
    super.key,
    required this.apps,
    this.budget,
    this.usageAvailable = true,
    this.onOpenStore,
    this.collapsed = 6,
  });

  final KidBudget? budget;
  final List<KidAppUsage> apps;
  final bool usageAvailable;
  final VoidCallback? onOpenStore;

  /// Rows shown before "Show all N apps". Limits sort first, so only the
  /// least used uncapped apps fold away.
  final int collapsed;

  @override
  State<KidUsageSection> createState() => _KidUsageSectionState();
}

class _KidUsageSectionState extends State<KidUsageSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final budget = widget.budget;
    final apps = widget.apps;
    final hidden = apps.length - widget.collapsed;
    final shown = _expanded || hidden <= 0
        ? apps
        : apps.take(widget.collapsed).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (budget != null) _BudgetCard(budget: budget),
        if (budget != null && apps.isNotEmpty) const SizedBox(height: 10),
        if (apps.isNotEmpty)
          DsGroup(
            verticalPadding: 4,
            shadow: AppShadows.flat,
            children: [
              for (final app in shown)
                _AppRow(
                  app: app,
                  usageAvailable: widget.usageAvailable,
                  onTap: app.canRedeem && app.state != KidAppState.blocked
                      ? widget.onOpenStore
                      : null,
                ),
              if (hidden > 0)
                Pressable.row(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _expanded
                                ? s.showFewerApps
                                : s.showAllAppsCount(apps.length),
                            style: AppText.rowTitleStrong.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: _expanded ? -0.25 : 0.25,
                          duration: const Duration(milliseconds: 200),
                          child: AppIcons.chevronRight(),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.budget});

  final KidBudget budget;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final limit = budget.limitMinutes;
    final remaining = budget.remainingMinutes;
    final reset = budget.nextResetAt;
    final resetLabel = reset == null
        ? null
        : DateFormat.Hm(
            Localizations.localeOf(context).toLanguageTag(),
          ).format(reset.toLocal());
    final color = remaining == 0
        ? AppColors.danger
        : remaining <= kidLowTimeMinutes
        ? AppColors.coin
        : AppColors.primary;

    final String headline;
    final String? meta;
    if (!budget.usageAvailable) {
      headline = s.kidScreenTimeDaily(formatHm(s, limit));
      meta = s.kidBudgetShared;
    } else if (remaining == 0) {
      headline = s.kidScreenTimeUp;
      meta = resetLabel == null ? null : s.kidScreenTimeBackAt(resetLabel);
    } else {
      headline = s.kidScreenTimeLeft(formatHm(s, remaining));
      meta = s.kidBudgetShared;
    }

    return DsCard(
      radius: AppRadius.feature,
      padding: const EdgeInsets.all(18),
      shadow: AppShadows.flat,
      child: Row(
        children: [
          DsProgressRing(
            progress: !budget.usageAvailable
                ? 0
                : limit == 0
                ? 1
                : budget.usedMinutes / limit,
            size: 88,
            radius: 37,
            strokeWidth: 10,
            color: color,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  budget.usageAvailable
                      ? formatHmTight(s, budget.usedMinutes)
                      : formatHmTight(s, limit),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: AppColors.ink,
                    fontFeatures: AppText.tabular,
                  ),
                ),
                if (budget.usageAvailable) ...[
                  const SizedBox(height: 1),
                  Text(
                    s.ofTotal(formatHmTight(s, limit)),
                    style: AppText.micro,
                  ),
                ],
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
                  headline,
                  style: AppText.headline.copyWith(
                    fontSize: 17,
                    height: 1.28,
                    color: remaining == 0 && budget.usageAvailable
                        ? AppColors.dangerDeep
                        : AppColors.ink,
                  ),
                ),
                if (meta != null) ...[
                  const SizedBox(height: 4),
                  Text(meta, style: AppText.meta),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppRow extends StatelessWidget {
  const _AppRow({required this.app, required this.usageAvailable, this.onTap});

  final KidAppUsage app;
  final bool usageAvailable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final state = app.state;
    final allowance = app.allowanceMinutes;
    final remaining = app.remainingMinutes ?? 0;
    final low = state == KidAppState.limited && remaining <= kidLowTimeMinutes;
    final showBar =
        usageAvailable &&
        (state == KidAppState.limited || state == KidAppState.timesUp);

    final Widget? trailing = switch (state) {
      KidAppState.blocked => DsPill.muted(label: s.kidAppBlocked),
      KidAppState.timesUp => DsPill(
        label: s.kidAppTimesUp,
        background: AppColors.fill,
        foreground: AppColors.dangerDeep,
      ),
      KidAppState.limited when !usageAvailable => null,
      KidAppState.limited when low => DsPill.pending(
        label: s.timeLeft(formatHm(s, remaining)),
      ),
      KidAppState.limited => DsPill.tint(
        label: s.timeLeft(formatHm(s, remaining)),
      ),
      KidAppState.free => Text(
        formatHm(s, app.usedMinutes),
        style: AppText.metaSm.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          fontFeatures: AppText.tabular,
        ),
      ),
    };

    final String? detail;
    if (state == KidAppState.free) {
      detail = null;
    } else if (state == KidAppState.blocked) {
      detail = s.kidAppBlockedBody;
    } else if (!usageAvailable) {
      detail = s.dailyLimitValue(formatHm(s, app.limitMinutes ?? 0));
    } else if (state == KidAppState.timesUp && app.canRedeem) {
      detail = s.kidGetMoreInStore;
    } else {
      final used = s.usedOfLimit(
        formatHm(s, app.usedMinutes),
        formatHm(s, allowance),
      );
      detail = app.bonusMinutes > 0
          ? '$used · ${s.kidBonusFromCoins(formatHm(s, app.bonusMinutes))}'
          : used;
    }
    final emphasize = state == KidAppState.timesUp && app.canRedeem;

    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          AppIconTile(
            emoji: AppData.getEmojiForApp(app.name),
            iconUrl: app.iconUrl,
            size: 36,
            radius: AppRadius.sm,
            fontSize: 18,
            opacity: state == KidAppState.blocked ? 0.5 : 1,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      // Two lines: a long name beside "27 m left" in Russian
                      // would otherwise lose most of itself on a small phone.
                      child: Text(
                        app.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.rowTitleStrong,
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      trailing,
                    ],
                  ],
                ),
                if (showBar) ...[
                  const SizedBox(height: 8),
                  DsProgressBar(
                    progress: allowance <= 0 ? 1 : app.usedMinutes / allowance,
                    color: state == KidAppState.timesUp
                        ? AppColors.danger
                        : low
                        ? AppColors.coin
                        : AppColors.primary,
                  ),
                ],
                if (detail != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    detail,
                    style: AppText.metaSm.copyWith(
                      color: emphasize
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: emphasize ? FontWeight.w600 : null,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return onTap == null ? row : Pressable.row(onTap: onTap!, child: row);
  }
}
