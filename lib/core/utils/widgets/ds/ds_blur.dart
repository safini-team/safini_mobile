import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// `backdrop-filter: blur(Npx) saturate(180%)`.
///
/// CSS blur radius is roughly 2× the Gaussian sigma, so `blur(24px)` is
/// `sigma 12`. The saturate half matters more than it looks - without it the
/// tab bar and the sticky nav bar read as flat grey instead of picking up the
/// purple underneath.
class DsBackdrop extends StatelessWidget {
  const DsBackdrop({
    super.key,
    required this.child,
    this.blur = 24,
    this.saturation = 1.8,
  });

  final Widget child;
  final double blur;
  final double saturation;

  static ui.ColorFilter saturate(double s) {
    const lr = 0.213, lg = 0.715, lb = 0.072;
    return ui.ColorFilter.matrix(<double>[
      lr + (1 - lr) * s, lg - lg * s, lb - lb * s, 0, 0,
      lr - lr * s, lg + (1 - lg) * s, lb - lb * s, 0, 0,
      lr - lr * s, lg - lg * s, lb + (1 - lb) * s, 0, 0,
      0, 0, 0, 1, 0,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ui.ImageFilter.compose(
        outer: saturate(saturation),
        inner: ui.ImageFilter.blur(sigmaX: blur / 2, sigmaY: blur / 2),
      ),
      child: child,
    );
  }
}
