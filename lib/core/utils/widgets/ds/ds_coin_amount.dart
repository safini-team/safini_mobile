import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/utils/widgets/ds/ds_controls.dart';
import 'package:safini/core/utils/widgets/ds/ds_pill.dart';

/// Coin amount with a typed field and the −/+ stepper. Used by parent task
/// reward and prize/wish price so both keep the same bounds and input.
class DsCoinAmount extends StatefulWidget {
  const DsCoinAmount({
    super.key,
    required this.value,
    required this.onChanged,
    this.onLess,
    this.onMore,
    this.min = 0,
    this.max = 100000,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final VoidCallback? onLess;
  final VoidCallback? onMore;
  final int min;
  final int max;

  @override
  State<DsCoinAmount> createState() => _DsCoinAmountState();
}

class _DsCoinAmountState extends State<DsCoinAmount> {
  late final TextEditingController _controller;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
    _focus = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(DsCoinAmount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _parsed != widget.value) {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  int? get _parsed => int.tryParse(_controller.text);

  int _clamp(int value) => value.clamp(widget.min, widget.max);

  void _commit() {
    final parsed = _parsed;
    final next = _clamp(parsed ?? widget.min);
    if (_controller.text != '$next') _controller.text = '$next';
    if (next != widget.value) widget.onChanged(next);
  }

  void _onFocusChange() {
    if (_focus.hasFocus) return;
    _commit();
  }

  void _onText(String raw) {
    final parsed = int.tryParse(raw);
    if (parsed == null) return;
    if (parsed > widget.max) {
      final next = widget.max;
      _controller.text = '$next';
      _controller.selection = TextSelection.collapsed(offset: '$next'.length);
      if (next != widget.value) widget.onChanged(next);
      return;
    }
    if (parsed >= widget.min && parsed != widget.value) {
      widget.onChanged(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const DsCoinToken(size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: TextField(
            key: const ValueKey('coin-amount'),
            controller: _controller,
            focusNode: _focus,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(widget.max.toString().length),
            ],
            cursorColor: AppColors.primary,
            style: AppText.rowTitleLg
                .copyWith(fontWeight: FontWeight.w600)
                .nums,
            decoration: const InputDecoration(
              filled: false,
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: _onText,
            onSubmitted: (_) => _commit(),
          ),
        ),
        DsStepper.onPanel(onLess: widget.onLess, onMore: widget.onMore),
      ],
    );
  }
}
