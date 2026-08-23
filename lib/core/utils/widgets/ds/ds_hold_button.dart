import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_motion.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';

/// Press-and-hold to send a task.
///
/// A `rgba(255,255,255,.26)` wipe fills the purple pill left-to-right over
/// 1150ms linear; letting go rewinds in 220ms on the house curve. The label
/// swaps to "Keep holding…" while the finger is down - that swap is the whole
/// point of the control, it is what tells a kid the press is doing something.
class DsHoldButton extends StatefulWidget {
  const DsHoldButton({
    super.key,
    required this.label,
    required this.holdingLabel,
    required this.onComplete,
    this.requireHold = true,
    this.radius = AppRadius.control,
    this.padding = const EdgeInsets.all(16),
    this.fontSize = 16.5,
    this.enabled = true,
  });

  final String label;
  final String holdingLabel;
  final VoidCallback onComplete;

  /// When false the control degrades to a plain tap, matching the design's
  /// `holdToComplete` prop being off.
  final bool requireHold;
  final double radius;
  final EdgeInsets padding;
  final double fontSize;
  final bool enabled;

  @override
  State<DsHoldButton> createState() => _DsHoldButtonState();
}

class _DsHoldButtonState extends State<DsHoldButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fill = AnimationController(
    vsync: this,
    duration: AppMotion.hold,
    reverseDuration: const Duration(milliseconds: 220),
  )..addStatusListener(_onStatus);

  bool _holding = false;

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _holding = false;
    HapticFeedback.mediumImpact();
    widget.onComplete();
    _fill.value = 0;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _fill.dispose();
    super.dispose();
  }

  void _down(_) {
    if (!widget.enabled) return;
    if (!widget.requireHold) {
      HapticFeedback.selectionClick();
      widget.onComplete();
      return;
    }
    setState(() => _holding = true);
    HapticFeedback.selectionClick();
    _fill.forward();
  }

  void _up([_]) {
    if (!_holding) return;
    setState(() => _holding = false);
    _fill.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final label = _holding ? widget.holdingLabel : widget.label;

    return Listener(
      onPointerDown: _down,
      onPointerUp: _up,
      onPointerCancel: _up,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: widget.enabled ? AppColors.primary : AppColors.fill,
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: widget.enabled ? AppShadows.primaryGlowLg : const [],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _fill,
                  builder: (context, _) => Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: _fill.value,
                      child: const ColoredBox(color: Color(0x42FFFFFF)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: widget.padding,
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.008 * widget.fontSize,
                      height: 1.2,
                      color: widget.enabled
                          ? AppColors.textOnPrimary
                          : AppColors.textTertiary,
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
