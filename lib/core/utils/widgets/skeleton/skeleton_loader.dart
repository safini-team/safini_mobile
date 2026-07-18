import 'package:flutter/material.dart';

/// Wraps a subtree of [SkeletonBox]es and animates a shimmer band across all
/// of them at once. Build a static grey layout of the screen and wrap it in a
/// single [Skeleton] so every placeholder shimmers in sync.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, required this.child});

  final Widget child;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final highlight = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.black.withValues(alpha: 0.02);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [base, highlight, base],
              stops: const [0.35, 0.5, 0.65],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              transform: _SlidingGradientTransform(slide: _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slide});

  final double slide;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // Sweep the gradient from left off-screen to right off-screen.
    return Matrix4.translationValues(bounds.width * (slide * 2 - 1), 0.0, 0.0);
  }
}

/// A single grey placeholder block. Solid color is supplied by the parent
/// [Skeleton]'s shimmer via [BlendMode.srcATop], so the color here just needs
/// to be opaque.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius = 8,
    this.shape = BoxShape.rectangle,
  });

  const SkeletonBox.circle({super.key, required double size})
      : width = size,
        height = size,
        radius = 0,
        shape = BoxShape.circle;

  final double? width;
  final double height;
  final double radius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey,
        shape: shape,
        borderRadius:
            shape == BoxShape.circle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}
