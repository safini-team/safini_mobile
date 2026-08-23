import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_motion.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/utils/widgets/ds/app_icons.dart';
import 'package:safini/core/utils/widgets/ds/ds_blur.dart';
import 'package:safini/core/utils/widgets/ds/pressable.dart';

/// `@keyframes scrIn{from{opacity:0;transform:translateY(8px)}to{…}}` -
/// 320ms on the house curve. Every screen in the design enters with it.
class DsScreenEntrance extends StatefulWidget {
  const DsScreenEntrance({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  State<DsScreenEntrance> createState() => _DsScreenEntranceState();
}

class _DsScreenEntranceState extends State<DsScreenEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppMotion.screen,
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: AppMotion.spring,
  );

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _c.forward();
    } else {
      _c.value = 1;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;

    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - _t.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// A tab-root screen: flat background, no app bar, large title at the top and
/// enough bottom padding to clear the floating tab bar.
class DsScreen extends StatelessWidget {
  const DsScreen({
    super.key,
    required this.slivers,
    this.background = AppColors.bgParent,
    this.bottomPadding = AppSpacing.tabBarClearance,
    this.floatingAction,
    this.onRefresh,
    this.controller,
    this.animateEntrance = true,
  });

  final List<Widget> slivers;
  final Color background;
  final double bottomPadding;
  final Widget? floatingAction;
  final Future<void> Function()? onRefresh;
  final ScrollController? controller;
  final bool animateEntrance;

  @override
  Widget build(BuildContext context) {
    Widget scroll = CustomScrollView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 6),
          sliver: const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
        ...slivers,
        SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
      ],
    );

    if (onRefresh != null) {
      scroll = RefreshIndicator(
        onRefresh: onRefresh!,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        displacement: 60,
        child: scroll,
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
      ),
      child: Container(
        color: background,
        child: DsScreenEntrance(
          enabled: animateEntrance,
          child: floatingAction == null
              ? scroll
              : Stack(
                  children: [
                    scroll,
                    Positioned(
                      right: AppSpacing.gutter,
                      bottom: 104,
                      child: floatingAction!,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// `font-size:34px;font-weight:700;letter-spacing:-.024em` with an optional
/// eyebrow above and a subtitle below, at `padding:6px 20px 0`.
class DsLargeTitle extends StatelessWidget {
  const DsLargeTitle({
    super.key,
    required this.title,
    this.eyebrow,
    this.eyebrowColor = AppColors.primary,
    this.subtitle,
    this.trailing,
    this.crossAxisAlignment = CrossAxisAlignment.end,
  });

  final String title;
  final String? eyebrow;
  final Color eyebrowColor;
  final String? subtitle;
  final Widget? trailing;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final block = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (eyebrow != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              eyebrow!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.13,
                height: 1.2,
                color: eyebrowColor,
              ),
            ),
          ),
        Text(title, style: AppText.largeTitle),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(subtitle!, style: AppText.subtitle),
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.textGutter, 6, AppSpacing.textGutter, 0),
      child: trailing == null
          ? block
          : Row(
              crossAxisAlignment: crossAxisAlignment,
              children: [
                Expanded(child: block),
                const SizedBox(width: 12),
                trailing!,
              ],
            ),
    );
  }
}

/// The bare back affordance on an onboarding step: `padding:0 14px 8px` with a
/// purple chevron and a 17px label, no bar behind it.
class DsBackButton extends StatelessWidget {
  const DsBackButton({super.key, this.label = 'Back', this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Pressable(
          onTap: onTap ?? () => Navigator.of(context).maybePop(),
          scale: 0.96,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcons.chevronLeft(),
                const SizedBox(width: 2),
                Text(
                  label,
                  style: AppText.button.copyWith(
                    fontWeight: FontWeight.w400,
                    color: AppColors.primary,
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

/// The sticky translucent nav bar on a pushed screen: back label on the left,
/// 16/640 title in the middle, optional action on the right.
class DsNavBar extends StatelessWidget {
  const DsNavBar({
    super.key,
    required this.title,
    required this.backLabel,
    this.onBack,
    this.actionLabel,
    this.onAction,
    this.background = const Color(0xD1F5F4F8),
  });

  /// Child-side nav bar over `#FBF8FF`.
  const DsNavBar.child({
    super.key,
    required this.title,
    required this.backLabel,
    this.onBack,
    this.actionLabel,
    this.onAction,
  }) : background = const Color(0xD1FBF8FF);

  final String title;
  final String backLabel;
  final VoidCallback? onBack;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final sideWidth = actionLabel == null ? 74.0 : 66.0;

    return ClipRect(
      child: DsBackdrop(
        blur: 20,
        child: Container(
          color: background,
          padding: EdgeInsets.fromLTRB(
            14,
            MediaQuery.paddingOf(context).top + 2,
            14,
            10,
          ),
          child: Row(
            children: [
              Pressable(
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
                scale: 0.96,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcons.chevronLeft(),
                      const SizedBox(width: 2),
                      Text(
                        backLabel,
                        style: AppText.button.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.rowTitleStrong,
                ),
              ),
              SizedBox(
                width: sideWidth,
                child: actionLabel == null
                    ? const SizedBox.shrink()
                    : Pressable(
                        onTap: onAction,
                        scale: 0.96,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Text(
                            actionLabel!,
                            textAlign: TextAlign.right,
                            style: AppText.button.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
