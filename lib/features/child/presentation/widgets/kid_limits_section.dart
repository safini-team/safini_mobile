import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safini/core/app_icons/app_icon_tile.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/parent/data/app_data.dart';
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

enum KidAppLimitState { blocked, timesUp, limited, open }

/// One app the parent has a rule on, as the kid reads it.
class KidAppLimit {
  const KidAppLimit({
    required this.name,
    required this.usedMinutes,
    required this.limitMinutes,
    required this.remainingMinutes,
    this.iconUrl,
    this.bonusMinutes = 0,
    this.isBlocked = false,
    this.isLimited = true,
    this.canRedeem = false,
  });

  final String name;
  final String? iconUrl;
  final int usedMinutes;

  /// The parent's daily allowance, before minutes bought with coins.
  final int limitMinutes;

  /// Bought with coins and not spent yet.
  final int bonusMinutes;

  /// What the server says is still spendable, already capped by the daily
  /// budget. Null for an app with no limit under no budget.
  final int? remainingMinutes;
  final bool isBlocked;
  final bool isLimited;

  /// Extra minutes for this app are sold in the Store.
  final bool canRedeem;

  KidAppLimitState get state {
    if (isBlocked) return KidAppLimitState.blocked;
    if (remainingMinutes == 0) return KidAppLimitState.timesUp;
    return isLimited ? KidAppLimitState.limited : KidAppLimitState.open;
  }

  /// Most urgent first: out of time, then the least left, then apps with no
  /// limit, then the ones the parent switched off.
  static int compare(KidAppLimit a, KidAppLimit b) {
    int rank(KidAppLimit app) => switch (app.state) {
      KidAppLimitState.timesUp => 0,
      KidAppLimitState.limited => 1,
      KidAppLimitState.open => 2,
      KidAppLimitState.blocked => 3,
    };
    final byRank = rank(a).compareTo(rank(b));
    if (byRank != 0) return byRank;
    if (a.state == KidAppLimitState.limited) {
      final byLeft = (a.remainingMinutes ?? 0).compareTo(
        b.remainingMinutes ?? 0,
      );
      if (byLeft != 0) return byLeft;
    }
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}

/// Kid · Today "My limits": how much of the day's budget is left and, per
/// app, what the parent allows and what is left of it, so the child can plan
/// a game before the block screen ends it.
class KidLimitsSection extends StatelessWidget {
  const KidLimitsSection({
    super.key,
    required this.apps,
    this.budget,
    this.usageAvailable = true,
    this.onOpenStore,
  });

  final KidBudget? budget;
  final List<KidAppLimit> apps;
  final bool usageAvailable;
  final VoidCallback? onOpenStore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (budget != null) _BudgetCard(budget: budget!),
        if (budget != null && apps.isNotEmpty) const SizedBox(height: 10),
        if (apps.isNotEmpty)
          DsGroup(
            verticalPadding: 4,
            shadow: AppShadows.flat,
            children: [
              for (final app in apps)
                _AppLimitRow(
                  app: app,
                  usageAvailable: usageAvailable,
                  onTap: app.canRedeem && !app.isBlocked ? onOpenStore : null,
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

class _AppLimitRow extends StatelessWidget {
  const _AppLimitRow({
    required this.app,
    required this.usageAvailable,
    this.onTap,
  });

  final KidAppLimit app;
  final bool usageAvailable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final state = app.state;
    final allowance = app.limitMinutes + app.bonusMinutes;
    final remaining = app.remainingMinutes ?? 0;
    final low =
        state == KidAppLimitState.limited && remaining <= kidLowTimeMinutes;
    final showBar =
        usageAvailable &&
        (state == KidAppLimitState.limited ||
            (state == KidAppLimitState.timesUp && app.isLimited));

    final Widget? pill = switch (state) {
      KidAppLimitState.blocked => DsPill.muted(label: s.kidAppBlocked),
      KidAppLimitState.timesUp => DsPill(
        label: s.kidAppTimesUp,
        background: AppColors.fill,
        foreground: AppColors.dangerDeep,
      ),
      KidAppLimitState.limited when !usageAvailable => null,
      KidAppLimitState.limited when low => DsPill.pending(
        label: s.timeLeft(formatHm(s, remaining)),
      ),
      KidAppLimitState.limited => DsPill.tint(
        label: s.timeLeft(formatHm(s, remaining)),
      ),
      KidAppLimitState.open => DsPill.paid(label: s.kidAppNoLimit),
    };

    final String detail;
    if (state == KidAppLimitState.blocked) {
      detail = s.kidAppBlockedBody;
    } else if (!usageAvailable) {
      detail = app.isLimited
          ? s.dailyLimitValue(formatHm(s, app.limitMinutes))
          : s.noDailyLimit;
    } else if (state == KidAppLimitState.timesUp && app.canRedeem) {
      detail = s.kidGetMoreInStore;
    } else if (app.isLimited) {
      final used = s.usedOfLimit(
        formatHm(s, app.usedMinutes),
        formatHm(s, allowance),
      );
      detail = app.bonusMinutes > 0
          ? '$used · ${s.kidBonusFromCoins(formatHm(s, app.bonusMinutes))}'
          : used;
    } else {
      detail = s.kidAppUsedToday(formatHm(s, app.usedMinutes));
    }

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
            opacity: state == KidAppLimitState.blocked ? 0.5 : 1,
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
                      child: Text(
                        app.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.rowTitleStrong,
                      ),
                    ),
                    if (pill != null) ...[const SizedBox(width: 8), pill],
                  ],
                ),
                if (showBar) ...[
                  const SizedBox(height: 8),
                  DsProgressBar(
                    progress: allowance <= 0 ? 1 : app.usedMinutes / allowance,
                    color: state == KidAppLimitState.timesUp
                        ? AppColors.danger
                        : low
                        ? AppColors.coin
                        : AppColors.primary,
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  detail,
                  style: AppText.metaSm.copyWith(
                    color: state == KidAppLimitState.timesUp && app.canRedeem
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight:
                        state == KidAppLimitState.timesUp && app.canRedeem
                        ? FontWeight.w600
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return onTap == null ? row : Pressable.row(onTap: onTap!, child: row);
  }
}
