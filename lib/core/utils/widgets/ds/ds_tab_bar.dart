import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_motion.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/utils/widgets/ds/ds_blur.dart';

class DsTabItem {
  const DsTabItem({
    required this.builder,
    required this.label,
    this.badge,
  });

  /// Receives the resolved colour so the icon can use `currentColor`.
  final Widget Function(Color color) builder;
  final String label;
  final int? badge;
}

/// The floating translucent tab bar:
/// `rgba(250,249,252,.76)` + `blur(24px) saturate(180%)`, a 1px white top edge
/// and a hairline shadow underneath it. Colour crossfades over 180ms.
///
/// Label size follows the artboard's copy-pressure rule: 10.5px for English,
/// 10px for Russian and 9.5px for Uzbek, because `Vazifalar` and `Cheklovlar`
/// need the smaller size to stay on one line. The bar shrinks rather than
/// truncating - a tab label that ellipses is worse than a slightly smaller one.
class DsTabBar extends StatelessWidget {
  const DsTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.background = const Color(0xC2FAF9FC),
  });

  /// Child side sits on `#FBF8FF`, so its bar is tinted `rgba(252,250,255,.76)`.
  const DsTabBar.child({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  }) : background = const Color(0xC2FCFAFF);

  final List<DsTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color background;

  /// The design pads 26 under the labels; on a device that is the home
  /// indicator's own inset, so mirror it rather than stacking both.
  static double bottomPadding(BuildContext context) {
    final inset = MediaQuery.viewPaddingOf(context).bottom;
    return inset > 0 ? math.max(inset - 8, 12) : 12;
  }

  /// Per the artboard's copy-pressure rule.
  static ({double label, double letterSpacing, double icon}) metricsFor(
    String languageCode,
  ) => switch (languageCode) {
    'uz' => (label: 9.5, letterSpacing: 0, icon: 23),
    'ru' => (label: 10, letterSpacing: 0, icon: 23),
    _ => (label: 10.5, letterSpacing: 0.105, icon: 25),
  };

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(color: Color(0x0F17151C), offset: Offset(0, -1)),
        ],
      ),
      child: ClipRect(
        child: DsBackdrop(
          child: Container(
            decoration: BoxDecoration(
              color: background,
              border: const Border(
                top: BorderSide(color: Color(0x99FFFFFF)),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              10,
              9,
              10,
              bottomPadding(context),
            ),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _Tab(
                      item: items[i],
                      selected: i == currentIndex,
                      onTap: () => onTap(i),
                      metrics: metricsFor(
                        Localizations.localeOf(context).languageCode,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.metrics,
  });

  final DsTabItem item;
  final bool selected;
  final VoidCallback onTap;
  final ({double label, double letterSpacing, double icon}) metrics;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(
          end: selected ? AppColors.primary : AppColors.tabInactive,
        ),
        duration: const Duration(milliseconds: 180),
        curve: AppMotion.ease,
        builder: (context, color, _) {
          final resolved = color ?? AppColors.tabInactive;
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: metrics.icon,
                    child: FittedBox(child: item.builder(resolved)),
                  ),
                  const SizedBox(height: 4),
                  // The artboard's rule is shrink, never truncate: it already
                  // picks a smaller size per language, and on a phone narrower
                  // than the 402pt artboard we scale down the rest of the way
                  // rather than ellipsing a tab label.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item.label,
                      maxLines: 1,
                      softWrap: false,
                      style: AppText.tabLabel.copyWith(
                        fontSize: metrics.label,
                        letterSpacing: metrics.letterSpacing,
                        color: resolved,
                      ),
                    ),
                  ),
                ],
              ),
              // `top:-1;left:50%;margin-left:7px` - the badge's left edge sits
              // 7px right of the tab's centre, whatever the count's width.
              if (item.badge != null && item.badge! > 0)
                Transform.translate(
                  offset: const Offset(7, -1),
                  child: FractionalTranslation(
                    translation: const Offset(0.5, 0),
                    // Unconstrained so the badge shrink-wraps the count instead
                    // of stretching to the tab's width.
                    child: UnconstrainedBox(
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 17),
                        height: 17,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          '${item.badge}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textOnPrimary,
                            height: 1,
                            fontFeatures: AppText.tabular,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
