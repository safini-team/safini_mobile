import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/prizes/prize_idea.dart';

/// A label, then a borderless text field, the way the task sheet lays out
/// its fields inside a [DsSheetPanel].
class PrizeTextRow extends StatelessWidget {
  const PrizeTextRow({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLength = 60,
    this.autofocus = false,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLength;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DsFieldRow(
      label: label,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        maxLength: maxLength,
        onChanged: onChanged,
        textCapitalization: TextCapitalization.sentences,
        cursorColor: AppColors.primary,
        style: AppText.rowTitleLg,
        decoration: InputDecoration(
          filled: false,
          isDense: true,
          counterText: '',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: hint,
          hintStyle: AppText.body.copyWith(
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

/// "Price  800 coins  [− +]". The step grows with the price, so a bike is a
/// few taps away and an ice cream still moves by 10.
class PrizePriceRow extends StatelessWidget {
  const PrizePriceRow({
    super.key,
    required this.coins,
    required this.onChanged,
    this.label,
  });

  final int coins;
  final ValueChanged<int> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label ?? s.prizePriceLabel, style: AppText.field),
          ),
          const SizedBox(width: 12),
          const DsCoinToken(size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$coins',
              style: AppText.rowTitleLg
                  .copyWith(fontWeight: FontWeight.w600)
                  .nums,
            ),
          ),
          DsStepper.onPanel(
            onLess: coins > 10
                ? () => onChanged(previousPrizePrice(coins))
                : null,
            onMore: () => onChanged(nextPrizePrice(coins)),
          ),
        ],
      ),
    );
  }
}

/// A row of emoji to pick the prize's picture from.
class PrizeEmojiPicker extends StatelessWidget {
  const PrizeEmojiPicker({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const options = [
    '🎁',
    '🍦',
    '📚',
    '🍕',
    '🎬',
    '🧸',
    '🎒',
    '🧱',
    '🎮',
    '🚲',
    '🐶',
    '⚽',
    '🎨',
    '🎧',
    '🏊',
    '🎡',
    '🛼',
    '📱',
  ];

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option == selected;
          return Pressable(
            onTap: () => onSelect(option),
            scale: 0.92,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surface : AppColors.fill,
                borderRadius: BorderRadius.circular(10),
                border: isSelected
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: Text(option, style: const TextStyle(fontSize: 20)),
            ),
          );
        },
      ),
    );
  }
}
