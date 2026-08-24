import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_motion.dart';

/// The design's press feedback: `transition:transform 140ms cubic-bezier(.23,1,.32,1)`
/// with `style-active="transform:scale(...)"`, or `opacity:.5` on list rows.
///
/// Scale values straight off the artboards:
///  * `.985` full-width card
///  * `.975` primary button
///  * `.96`  chip, inline button, pill
///  * `.94`  round icon button
///  * `.92`  small tile in a grid
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.975,
    this.pressedOpacity,
    this.duration = AppMotion.press,
    this.behavior = HitTestBehavior.opaque,
  });

  /// Row-style feedback: no scale, `opacity:.5`, 120ms.
  const Pressable.row({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.behavior = HitTestBehavior.opaque,
  }) : scale = 1,
       pressedOpacity = 0.5,
       duration = const Duration(milliseconds: 120);

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final double? pressedOpacity;
  final Duration duration;
  final HitTestBehavior behavior;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool value) {
    if (_down == value || widget.onTap == null && widget.onLongPress == null) {
      return;
    }
    setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    if (widget.pressedOpacity != null) {
      child = AnimatedOpacity(
        opacity: _down ? widget.pressedOpacity! : 1,
        duration: widget.duration,
        curve: AppMotion.ease,
        child: child,
      );
    }

    if (widget.scale != 1) {
      child = AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: widget.duration,
        curve: AppMotion.spring,
        child: child,
      );
    }

    return GestureDetector(
      behavior: widget.behavior,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      child: child,
    );
  }
}
