import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_motion.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';

/// The pairing-code input from the Join family artboard: a row of 44x56 white
/// boxes, the next one ringed in purple.
///
/// A single hidden field owns the text; the boxes are just a readout, so paste,
/// autofill and the caret all behave normally.
class DsCodeField extends StatefulWidget {
  const DsCodeField({
    super.key,
    required this.controller,
    this.length = 4,
    this.onCompleted,
    this.autofocus = true,
    this.enabled = true,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onCompleted;
  final bool autofocus;
  final bool enabled;

  @override
  State<DsCodeField> createState() => _DsCodeFieldState();
}

class _DsCodeFieldState extends State<DsCodeField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _focus.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
    final text = widget.controller.text;
    if (text.length == widget.length) widget.onCompleted?.call(text);
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;
    final active = _focus.hasFocus;

    return Stack(
      alignment: Alignment.center,
      children: [
        // The real field, kept off-screen but still focusable and pasteable.
        SizedBox(
          width: 1,
          height: 1,
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.characters,
              keyboardType: TextInputType.visiblePassword,
              maxLength: widget.length,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp('[A-HJ-NP-Za-hj-np-z2-9]'),
                ),
                TextInputFormatter.withFunction(
                  (_, next) => next.copyWith(text: next.text.toUpperCase()),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _focus.requestFocus(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.length; i++) ...[
                if (i > 0) const SizedBox(width: 9),
                _Box(
                  char: i < text.length ? text[i] : '',
                  focused: active && i == text.length,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.char, required this.focused});

  final String char;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.press,
      curve: AppMotion.spring,
      width: 44,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.tile),
        border: focused ? Border.all(color: AppColors.primary, width: 2) : null,
        boxShadow: AppShadows.hairline,
      ),
      child: Text(
        char,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          height: 1.1,
          color: AppColors.ink,
        ),
      ),
    );
  }
}
