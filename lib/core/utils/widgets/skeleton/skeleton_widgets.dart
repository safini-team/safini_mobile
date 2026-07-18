import 'package:flutter/material.dart';
import 'package:safini/core/utils/widgets/skeleton/skeleton_loader.dart';

/// A placeholder standing in for a card/list row: leading square, two text
/// lines and a trailing chip. Matches the app-limit / task tile footprint.
class SkeletonTile extends StatelessWidget {
  const SkeletonTile({super.key, this.height = 72});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const SkeletonBox(width: 44, height: 44, radius: 12),
          const SizedBox(width: 14),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SkeletonBox(width: 120, height: 14),
              SizedBox(height: 8),
              SkeletonBox(width: 80, height: 12),
            ],
          ),
          const Spacer(),
          const SkeletonBox(width: 48, height: 26, radius: 13),
        ],
      ),
    );
  }
}

/// A vertical stack of [SkeletonTile]s wrapped in a single shimmer.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.count = 3,
    this.tileHeight = 72,
    this.padding = EdgeInsets.zero,
  });

  final int count;
  final double tileHeight;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Padding(
        padding: padding,
        child: Column(
          children: List.generate(
            count,
            (_) => SkeletonTile(height: tileHeight),
          ),
        ),
      ),
    );
  }
}

/// Section header placeholder: a wide title bar and a short action bar.
class SkeletonSectionHeader extends StatelessWidget {
  const SkeletonSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        SkeletonBox(width: 140, height: 20),
        SkeletonBox(width: 70, height: 16),
      ],
    );
  }
}

/// Full-body skeleton for the parent monitor screen: two stat cards, a
/// section header and a few app-limit tiles.
class MonitorSkeleton extends StatelessWidget {
  const MonitorSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Expanded(child: SkeletonBox(height: 96, radius: 20)),
              SizedBox(width: 16),
              Expanded(child: SkeletonBox(height: 96, radius: 20)),
            ],
          ),
          const SizedBox(height: 32),
          const SkeletonSectionHeader(),
          const SizedBox(height: 16),
          SkeletonTile(),
          SkeletonTile(),
          SkeletonTile(),
        ],
      ),
    );
  }
}
