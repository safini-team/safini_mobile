import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/kid/kid_fini.dart';
import 'package:safini/features/fini/presentation/widgets/goal_visuals.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm;

/// "Want more game time?" on the kid's Today, when a Fini budget is spent
/// (SAF-275). The reason is the family's plan, in templated words: a child
/// never reads that an AI decided. One ask a day; the answer replaces the
/// button.
class KidAskCard extends StatelessWidget {
  const KidAskCard({
    super.key,
    required this.fini,
    required this.onAsk,
    this.asking = false,
  });

  final KidFini fini;
  final ValueChanged<KidPool> onAsk;
  final bool asking;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final pool = fini.focus;
    if (pool == null) return const SizedBox.shrink();
    final plan = formatHm(s, pool.planMinutes ?? pool.limitMinutes);
    final ask = fini.ask;
    return DsCard(
      key: const ValueKey('kid-ask-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GoalIcon(intent: pool.intent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(_title(s, pool.intent), style: AppText.rowTitleLg),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_plan(s, pool.intent, plan), style: AppText.meta),
          if (pool.timeUp && pool.apps.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.lock_rounded,
                  size: 15,
                  color: AppColors.locked,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    s.kidAskAppsUp(pool.apps.join(', ')),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.metaSm.copyWith(color: AppColors.locked),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          if (ask == null && fini.canAsk) ...[
            DsPrimaryButton(
              key: const ValueKey('kid-ask'),
              label: s.kidAskButton(formatHm(s, fini.askMinutes)),
              busy: asking,
              onTap: asking ? null : () => onAsk(pool),
            ),
            const SizedBox(height: 6),
            Text(
              s.kidAskOnceADay,
              textAlign: TextAlign.center,
              style: AppText.metaSm,
            ),
          ] else if (ask != null)
            _Answer(ask: ask),
        ],
      ),
    );
  }

  static String _title(S s, GoalIntent intent) => switch (intent) {
    GoalIntent.games => s.kidAskTitleGames,
    GoalIntent.scrolling => s.kidAskTitleScrolling,
    _ => s.kidAskTitleOther,
  };

  static String _plan(S s, GoalIntent intent, String limit) => switch (intent) {
    GoalIntent.games => s.kidAskPlanGames(limit),
    GoalIntent.scrolling => s.kidAskPlanScrolling(limit),
    _ => s.kidAskPlanOther(limit),
  };
}

class _Answer extends StatelessWidget {
  const _Answer({required this.ask});

  final KidAsk ask;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final minutes = formatHm(s, ask.minutes);
    final (String text, Color fg, Color bg) = switch (ask.state) {
      KidAskState.pending => (
        s.kidAskPending,
        AppColors.textSecondary,
        AppColors.fill,
      ),
      KidAskState.granted => (
        ask.parentName == null || ask.parentName!.isEmpty
            ? s.kidAskGrantedFini(minutes)
            : s.kidAskGrantedBy(ask.parentName!, minutes),
        AppColors.successDeep,
        AppColors.successBg,
      ),
      KidAskState.declined => (
        s.kidAskDeclined,
        AppColors.locked,
        AppColors.fill,
      ),
    };
    return Container(
      key: ValueKey('kid-ask-${ask.state.name}'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppText.rowTitleStrong.copyWith(color: fg),
      ),
    );
  }
}
