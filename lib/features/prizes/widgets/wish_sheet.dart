import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/prizes/widgets/prize_fields.dart';

typedef SendWish =
    Future<bool> Function({
      required String title,
      required int coinCost,
      String? emoji,
    });

/// The child wishes for something that is not in the store yet, and says what
/// they think it is worth. A parent can add it at that price or change it.
Future<void> showWishSheet(BuildContext context, {required SendWish onSend}) {
  return showDsSheet<void>(
    context: context,
    builder: (_) => _WishSheet(onSend: onSend),
  );
}

class _WishSheet extends StatefulWidget {
  const _WishSheet({required this.onSend});

  final SendWish onSend;

  @override
  State<_WishSheet> createState() => _WishSheetState();
}

class _WishSheetState extends State<_WishSheet> {
  final TextEditingController _title = TextEditingController();
  String _emoji = '🎁';
  int _coins = 100;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _busy = true);
    final sent = await widget.onSend(
      title: _title.text.trim(),
      coinCost: _coins,
      emoji: _emoji,
    );
    if (!mounted) return;
    if (sent) {
      Navigator.of(context).pop();
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: DsEmojiTile(
            emoji: _emoji,
            size: 64,
            background: AppColors.coinPillBg,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          s.wishSheetTitle,
          textAlign: TextAlign.center,
          style: AppText.title3,
        ),
        const SizedBox(height: 6),
        Text(
          s.wishSheetBody,
          textAlign: TextAlign.center,
          style: AppText.bodyRegular,
        ),
        const SizedBox(height: 16),
        PrizeEmojiPicker(
          selected: _emoji,
          onSelect: (emoji) => setState(() => _emoji = emoji),
        ),
        const SizedBox(height: 14),
        DsSheetPanel(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              PrizeTextRow(
                label: s.prizeNameLabel,
                controller: _title,
                hint: s.wishNameHint,
                autofocus: true,
                onChanged: (_) => setState(() {}),
              ),
              const DsDivider(),
              PrizePriceRow(
                label: s.wishPriceLabel,
                coins: _coins,
                onChanged: (coins) => setState(() => _coins = coins),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        DsPrimaryButton(
          label: s.sendWish,
          enabled: _title.text.trim().isNotEmpty && !_busy,
          busy: _busy,
          onTap: _send,
        ),
      ],
    );
  }
}
