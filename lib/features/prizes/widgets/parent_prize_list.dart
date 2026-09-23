import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/prizes/parent_prizes_cubit.dart';
import 'package:safini/features/prizes/prize.dart';
import 'package:safini/features/prizes/prize_idea.dart';

/// Limits → Prizes: the child's prizes cheapest first, "Add a prize", and
/// while the store is empty, a few ideas to start from.
List<Widget> parentPrizeSlivers(
  BuildContext context, {
  required ParentPrizesState state,
  required String childName,
  required VoidCallback onAdd,
  required ValueChanged<Prize> onOpen,
  required ValueChanged<PrizeIdea> onIdea,
  required VoidCallback onRetry,
}) {
  final s = S.of(context);
  if (state.isLoading) {
    return const [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 48),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
    ];
  }
  if (state.hasError && state.prizes.isEmpty) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
          child: Column(
            children: [
              Text(s.networkError, style: AppText.meta),
              const SizedBox(height: 12),
              DsPrimaryButton.secondary(label: s.retry, onTap: onRetry),
            ],
          ),
        ),
      ),
    ];
  }

  final ideas = state.prizes.isEmpty
      ? PrizeIdea.values.take(4).toList()
      : const <PrizeIdea>[];

  return [
    SliverToBoxAdapter(child: DsOverline(s.prizesFor(childName), top: 24)),
    SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DsGroup(
              children: [
                for (final prize in state.prizes)
                  DsRow(
                    onTap: () => onOpen(prize),
                    leading: DsEmojiTile(
                      emoji: prize.displayEmoji,
                      size: 36,
                      fontSize: 20,
                      background: AppColors.coinPillBg,
                    ),
                    title: prize.title,
                    subtitle: prize.isWaiting
                        ? s.prizeWaitingForYou(childName)
                        : prize.note,
                    trailing: DsPill.coins(
                      label: '${prize.coinCost}',
                      leading: const DsCoinToken(size: 14),
                      height: 24,
                      fontSize: 13,
                    ),
                  ),
                DsRow(
                  onTap: onAdd,
                  leading: DsEmojiTile(
                    emoji: '＋',
                    size: 36,
                    background: AppColors.primaryTint,
                  ),
                  title: s.addAPrize,
                  titleColor: AppColors.primary,
                ),
              ],
            ),
            if (ideas.isNotEmpty) ...[
              const SizedBox(height: 22),
              DsOverlineText(s.prizeIdeasTitle),
              const SizedBox(height: 10),
              DsGroup(
                children: [
                  for (final idea in ideas)
                    DsRow(
                      onTap: () => onIdea(idea),
                      leading: DsEmojiTile(emoji: idea.emoji, size: 36),
                      title: idea.title(s),
                      subtitle: s.coinCountShort(idea.coins),
                      trailing: AppIcons.chevronRight(),
                    ),
                ],
              ),
            ],
            DsFootnote(s.prizeHoldExplainer(childName)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  ];
}
