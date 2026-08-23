import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_motion.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/utils/widgets/ds/ds_avatar.dart';
import 'package:safini/core/utils/widgets/ds/pressable.dart';

class DsPickerOption {
  const DsPickerOption({
    required this.key,
    required this.label,
    required this.color,
    this.initial,
  });

  final String key;
  final String label;
  final Color color;

  /// Overrides the derived initial; the "Everyone" row uses a middot.
  final String? initial;
}

/// The kid scope picker that replaced the chip strips on Parent Today, Tasks
/// and Limits: a white pill showing who you are looking at, which opens a menu.
///
/// Trigger: `padding:5px 11px 5px 5px;border-radius:100px;background:#fff` with
/// a 24px avatar and a chevron that flips on 200ms.
/// Menu: `min-width:194px;border-radius:18px;padding:6px`, entering on
/// `menuIn 170ms` from `translateY(-4px) scale(.97)`, over a full-screen scrim.
class DsKidPicker extends StatefulWidget {
  const DsKidPicker({
    super.key,
    required this.options,
    required this.selectedKey,
    required this.onSelect,
  });

  final List<DsPickerOption> options;
  final String selectedKey;
  final ValueChanged<String> onSelect;

  @override
  State<DsKidPicker> createState() => _DsKidPickerState();
}

class _DsKidPickerState extends State<DsKidPicker>
    with SingleTickerProviderStateMixin {
  final _link = LayerLink();
  final _controller = OverlayPortalController();

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 170),
    reverseDuration: const Duration(milliseconds: 120),
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _anim,
    curve: AppMotion.spring,
  );

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  DsPickerOption get _selected => widget.options.firstWhere(
    (option) => option.key == widget.selectedKey,
    orElse: () => widget.options.first,
  );

  void _open() {
    _controller.show();
    _anim.forward();
  }

  Future<void> _close() async {
    await _anim.reverse();
    if (mounted) _controller.hide();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.options.isEmpty) return const SizedBox.shrink();

    final selected = _selected;

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _controller,
        overlayChildBuilder: (context) => _Menu(
          link: _link,
          animation: _t,
          options: widget.options,
          selectedKey: widget.selectedKey,
          onDismiss: _close,
          onSelect: (key) {
            widget.onSelect(key);
            _close();
          },
        ),
        child: Pressable(
          onTap: () => _anim.isDismissed ? _open() : _close(),
          scale: 0.97,
          child: Container(
            padding: const EdgeInsets.fromLTRB(5, 5, 11, 5),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D17151C),
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
                BoxShadow(
                  color: Color(0x5217151C),
                  offset: Offset(0, 10),
                  blurRadius: 22,
                  spreadRadius: -16,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DsInitialAvatar(
                  name: selected.label,
                  label: selected.initial,
                  color: selected.color,
                  size: 24,
                  fontSize: 11,
                ),
                const SizedBox(width: 7),
                Text(
                  selected.label,
                  style: AppText.chip.copyWith(letterSpacing: -0.145),
                ),
                const SizedBox(width: 7),
                AnimatedBuilder(
                  animation: _t,
                  builder: (context, child) =>
                      Transform.rotate(angle: 3.14159 * _t.value, child: child),
                  child: const _Chevron(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `M1.3 1.4L6 6l4.7-4.6` at 11×7, `#6C6A75` stroke 2.
class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 11,
      height: 7,
      child: CustomPaint(painter: _ChevronPainter()),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 12;
    final paint = Paint()
      ..color = AppColors.textSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(1.3 * k, 1.4 * k)
      ..lineTo(6 * k, 6 * k)
      ..lineTo(10.7 * k, 1.4 * k);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => false;
}

class _Menu extends StatelessWidget {
  const _Menu({
    required this.link,
    required this.animation,
    required this.options,
    required this.selectedKey,
    required this.onSelect,
    required this.onDismiss,
  });

  final LayerLink link;
  final Animation<double> animation;
  final List<DsPickerOption> options;
  final String selectedKey;
  final ValueChanged<String> onSelect;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // `position:fixed;inset:0` - a tap anywhere outside closes the menu.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDismiss,
          ),
        ),
        CompositedTransformFollower(
          link: link,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 7),
          child: Align(
            alignment: Alignment.topLeft,
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) => Opacity(
                opacity: animation.value,
                child: Transform.translate(
                  offset: Offset(0, -4 * (1 - animation.value)),
                  child: Transform.scale(
                    scale: 0.97 + 0.03 * animation.value,
                    alignment: Alignment.topLeft,
                    child: child,
                  ),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                // The follower hands down the full screen width, so size to the
                // widest row instead - `min-width:194px` in the artboard.
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 194,
                    maxWidth: 300,
                  ),
                  child: IntrinsicWidth(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.panel),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1217151C),
                            offset: Offset(0, 2),
                            blurRadius: 6,
                          ),
                          BoxShadow(
                            color: Color(0x6B17151C),
                            offset: Offset(0, 22),
                            blurRadius: 44,
                            spreadRadius: -20,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final option in options)
                            _Row(
                              option: option,
                              selected: option.key == selectedKey,
                              onTap: () => onSelect(option.key),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final DsPickerOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF8F5FC) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.action),
        ),
        child: Row(
          children: [
            DsInitialAvatar(
              name: option.label,
              label: option.initial,
              color: option.color,
              size: 24,
              fontSize: 11,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                option.label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.12,
                  height: 1.2,
                  color: AppColors.ink,
                ),
              ),
            ),
            if (selected) ...[const SizedBox(width: 10), const _Check()],
          ],
        ),
      ),
    );
  }
}

/// `M1.6 5.4l3.6 3.6L12.4 1.8` at 14×11, purple stroke 2.2.
class _Check extends StatelessWidget {
  const _Check();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 14,
      height: 11,
      child: CustomPaint(painter: _CheckPainter()),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 14;
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(1.6 * k, 5.4 * k)
      ..lineTo(5.2 * k, 9 * k)
      ..lineTo(12.4 * k, 1.8 * k);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => false;
}
