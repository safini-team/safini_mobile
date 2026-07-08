import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/child/presentation/widgets/cards/level_badge.dart';

/// Large preview of the child's current avatar face plus a level badge.
///
/// Composes two single-purpose widgets: the [_AvatarFace] circle and a
/// reusable [LevelBadge]. Presentation-only — it just renders what it is given.
class AvatarPreviewCard extends StatelessWidget {
  /// The emoji currently equipped as the child's face.
  final String faceEmoji;

  /// The child's level; a value of 0 renders a label without a number.
  final int level;

  const AvatarPreviewCard({
    super.key,
    required this.faceEmoji,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AvatarFace(faceEmoji: faceEmoji),
        const SizedBox(height: AppSpacing.md),
        LevelBadge(level: level),
      ],
    );
  }
}

/// The rounded avatar circle with the equipped face emoji.
class _AvatarFace extends StatelessWidget {
  /// Shared [Hero] tag so the avatar animates between screens.
  static const String heroTag = 'child-avatar-hero';

  final String faceEmoji;

  const _AvatarFace({required this.faceEmoji});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Center(
          // Sized from the global text theme rather than a hardcoded value.
          child: Text(faceEmoji, style: context.textTheme.displayLarge),
        ),
      ),
    );
  }
}
