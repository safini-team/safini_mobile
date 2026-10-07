import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/utils/widgets/ds/pressable.dart';

/// Four dots and a phone-style keypad. Digits stay in this widget; callers
/// receive the completed PIN once and should not keep it.
class ParentPinPad extends StatefulWidget {
  const ParentPinPad({
    super.key,
    required this.title,
    required this.onCompleted,
    this.subtitle,
    this.error,
    this.enabled = true,
    this.clearToken,
    this.fillHeight = false,
  });

  /// When the pad is given a bounded height, use the spare room to push the
  /// keypad down toward the thumb zone while the title and dots stay on top.
  /// Two thirds of the free space go above the keypad, one third below it,
  /// so it sits low without hugging the bottom edge.
  final bool fillHeight;

  final String title;
  final String? subtitle;
  final String? error;
  final bool enabled;
  final ValueChanged<String> onCompleted;

  /// Change this after a failed attempt so the dots empty.
  final Object? clearToken;

  @override
  State<ParentPinPad> createState() => _ParentPinPadState();
}

class _ParentPinPadState extends State<ParentPinPad> {
  String _pin = '';

  @override
  void didUpdateWidget(covariant ParentPinPad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clearToken != widget.clearToken) {
      _pin = '';
    }
  }

  void _digit(String digit) {
    if (!widget.enabled || _pin.length >= 4) return;
    HapticFeedback.selectionClick();
    final next = _pin + digit;
    setState(() => _pin = next);
    if (next.length != 4) return;
    widget.onCompleted(next);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _pin = '');
    });
  }

  void _delete() {
    if (!widget.enabled || _pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final live = widget.enabled;

    return Column(
      children: [
        Text(widget.title, textAlign: TextAlign.center, style: AppText.title2),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.subtitle!,
            textAlign: TextAlign.center,
            style: AppText.bodyRegular.copyWith(color: AppColors.textSecondary),
          ),
        ],
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 4; i++) ...[
              if (i > 0) const SizedBox(width: 14),
              _Dot(filled: i < _pin.length, keyed: i),
            ],
          ],
        ),
        SizedBox(
          height: 44,
          child: widget.error == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    widget.error!,
                    textAlign: TextAlign.center,
                    style: AppText.metaSm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.dangerDeep,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        if (widget.fillHeight) const Spacer(flex: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: _Keypad(enabled: live, onDigit: _digit, onDelete: _delete),
        ),
        if (widget.fillHeight) const Spacer(),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.filled, required this.keyed});

  final bool filled;
  final int keyed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      key: ValueKey('app-lock-dot-$keyed'),
      duration: const Duration(milliseconds: 140),
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: filled ? AppColors.primary : AppColors.primaryBar,
          width: 2,
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.enabled,
    required this.onDigit,
    required this.onDelete,
  });

  final bool enabled;
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    const digits = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];

    return Column(
      children: [
        for (final row in digits)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                for (final digit in row)
                  Expanded(
                    child: _Key(
                      label: digit,
                      enabled: enabled,
                      onTap: () => onDigit(digit),
                    ),
                  ),
              ],
            ),
          ),
        Row(
          children: [
            const Expanded(child: SizedBox.shrink()),
            Expanded(
              child: _Key(
                label: '0',
                enabled: enabled,
                onTap: () => onDigit('0'),
              ),
            ),
            Expanded(
              child: _Key(
                icon: Icons.backspace_outlined,
                enabled: enabled,
                keyed: 'app-lock-delete',
                onTap: onDelete,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.onTap,
    required this.enabled,
    this.label,
    this.icon,
    this.keyed,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool enabled;
  final String? keyed;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.ink : AppColors.textTertiary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Pressable(
        onTap: enabled ? onTap : null,
        scale: 0.96,
        child: Container(
          key: ValueKey(keyed ?? 'app-lock-digit-$label'),
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.tile),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A0C231C),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: icon != null
              ? Icon(icon, size: 22, color: color)
              : Text(
                  label ?? '',
                  style: AppText.title3.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
        ),
      ),
    );
  }
}
