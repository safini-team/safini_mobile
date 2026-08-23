import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';

class StoreCardData {
  const StoreCardData({
    required this.id,
    required this.emoji,
    required this.name,
    required this.cost,
    required this.affordable,
    this.toGo,
    this.badge,
    this.owned = false,
  });

  final String id;
  final String emoji;
  final String name;
  final int cost;
  final bool affordable;

  /// Coins still missing, shown on a locked tile instead of the price.
  final int? toGo;

  /// Overrides the price pill, e.g. "12 m left" on an active unlock.
  final String? badge;
  final bool owned;
}

class ChildStoreData {
  const ChildStoreData({
    required this.coins,
    required this.tabs,
    required this.selectedTab,
    required this.cards,
    required this.subtitle,
    required this.footnote,
  });

  final int coins;
  final List<String> tabs;
  final int selectedTab;
  final List<StoreCardData> cards;
  final String subtitle;
  final String footnote;
}

/// Kid · Store: a two-column grid of reward tiles. A locked tile shows how far
/// off it is rather than just greying out - that is the whole point of the
/// artboard's copy note.
class ChildStoreView extends StatelessWidget {
  const ChildStoreView({
    super.key,
    required this.data,
    required this.onSelectTab,
    required this.onOpenCard,
    this.onRefresh,
  });

  final ChildStoreData data;
  final ValueChanged<int> onSelectTab;
  final ValueChanged<StoreCardData> onOpenCard;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return DsScreen(
      background: AppColors.bgChild,
      onRefresh: onRefresh,
      slivers: [
        SliverToBoxAdapter(
          child: DsLargeTitle(
            title: S.of(context).tabStore,
            subtitle: data.subtitle,
            crossAxisAlignment: CrossAxisAlignment.start,
            trailing: DsCoinBalance(
              coins: data.coins,
              shadow: AppShadows.hairline,
            ),
          ),
        ),
        if (data.tabs.length > 1)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                18,
                AppSpacing.gutter,
                0,
              ),
              child: DsSegmentedControl(
                labels: data.tabs,
                selectedIndex: data.selectedTab,
                onChanged: onSelectTab,
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            20,
            AppSpacing.gutter,
            0,
          ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 168,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _StoreTile(
                card: data.cards[index],
                onTap: () => onOpenCard(data.cards[index]),
              ),
              childCount: data.cards.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
            child: Text(data.footnote, style: AppText.footnote),
          ),
        ),
      ],
    );
  }
}

class _StoreTile extends StatelessWidget {
  const _StoreTile({required this.card, required this.onTap});

  final StoreCardData card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label =
        card.badge ??
        (card.affordable
            ? '${card.cost}'
            : S.of(context).toGo(card.toGo ?? card.cost));

    return DsCard(
      onTap: onTap,
      pressScale: 0.975,
      shadow: AppShadows.tile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: card.affordable || card.owned ? 1 : 0.4,
            child: Text(card.emoji, style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              card.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppText.rowTitleStrong.copyWith(
                fontSize: 15.5,
                letterSpacing: -0.186,
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (card.owned)
            DsPill.paid(
              label: S.of(context).yoursLabel,
              height: 26,
              fontSize: 13.5,
            )
          else if (card.affordable)
            DsPill.coins(label: label, height: 26, fontSize: 13.5)
          else
            DsPill.muted(label: label, height: 26, fontSize: 13.5),
        ],
      ),
    );
  }
}

/// Loading silhouette for the store grid.
class ChildStoreSkeleton extends StatelessWidget {
  const ChildStoreSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScreen(
      background: AppColors.bgChild,
      animateEntrance: false,
      slivers: [
        SliverToBoxAdapter(
          child: DsLargeTitle(title: S.of(context).tabStore),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            24,
            AppSpacing.gutter,
            0,
          ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 168,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => Container(
                decoration: BoxDecoration(
                  color: AppColors.fillPressed,
                  borderRadius: BorderRadius.circular(AppRadius.group),
                ),
              ),
              childCount: 4,
            ),
          ),
        ),
      ],
    );
  }
}
