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
    this.detail,
    String? fullName,
    this.badge,
    this.owned = false,
    this.pending = false,
  }) : fullName = fullName ?? name;

  final String id;
  final String emoji;

  /// What it is - "Brawl Stars", "Cosmic Cape". One line on the tile.
  final String name;

  /// The second line under the name, e.g. "30 min" for app time.
  final String? detail;

  /// Name and detail together, for the reward sheet: "Brawl Stars · 30 min".
  final String fullName;

  final int cost;
  final bool affordable;

  /// Overrides the price pill, e.g. "12 m left" on an active unlock.
  final String? badge;
  final bool owned;

  /// A purchase for this card is in flight: not tappable, and it says so.
  final bool pending;
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

/// Kid · Store: a two-column grid of reward tiles, each with its name and its
/// price in coins. A tile the child cannot afford yet is dimmed.
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
                onTap: data.cards[index].pending
                    ? null
                    : () => onOpenCard(data.cards[index]),
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
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final nameStyle = AppText.rowTitleStrong.copyWith(
      fontSize: 15.5,
      letterSpacing: -0.186,
    );
    const coin = DsCoinToken(size: 15);
    final price = '${card.cost}';

    return DsCard(
      onTap: onTap,
      pressScale: 0.975,
      shadow: AppShadows.tile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: card.pending
                ? 0.5
                : card.affordable || card.owned
                ? 1
                : 0.4,
            child: Text(card.emoji, style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 10),
          // The tile is a fixed 168pt. The name wraps at the tile's width as
          // usual, and only when its lines are taller than the room left does
          // the whole block shrink - never "...", never a half-cut second line
          // the way `maxLines: 2` inside this box used to render.
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) => FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: box.maxWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(card.name, style: nameStyle),
                      if (card.detail != null) ...[
                        const SizedBox(height: 2),
                        Text(card.detail!, style: AppText.caption),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (card.pending)
            const SizedBox(
              height: 26,
              width: 26,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (card.owned)
            DsPill.paid(
              label: S.of(context).yoursLabel,
              height: 26,
              fontSize: 13.5,
            )
          // "12 m left" on an active unlock, a lock reason: a state, not a
          // price, so no coin in front of it.
          else if (card.badge != null)
            card.affordable
                ? DsPill.coins(label: card.badge!, height: 26, fontSize: 13.5)
                : DsPill.muted(label: card.badge!, height: 26, fontSize: 13.5)
          // Name and price, nothing else: a tile the child cannot afford yet is
          // dimmed, not annotated with how far off it is.
          else if (card.affordable)
            DsPill.coins(
              label: price,
              leading: coin,
              height: 26,
              fontSize: 13.5,
            )
          else
            DsPill.muted(
              label: price,
              leading: const Opacity(opacity: 0.55, child: coin),
              height: 26,
              fontSize: 13.5,
            ),
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
