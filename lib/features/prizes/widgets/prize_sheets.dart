import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/prizes/parent_prizes_cubit.dart';
import 'package:safini/features/prizes/prize.dart';
import 'package:safini/features/prizes/prize_idea.dart';
import 'package:safini/features/prizes/widgets/prize_fields.dart';

enum _NewPrizeChoice { custom }

/// Ideas first, then "your own". Nothing is added until the editor is saved.
Future<void> showNewPrizeChooser(
  BuildContext context, {
  required ParentPrizesCubit cubit,
  required String childName,
}) async {
  final ideas = PrizeIdea.notIn(cubit.state.prizes.map((p) => p.templateKey));
  final choice = await showDsSheet<Object>(
    context: context,
    builder: (sheetContext) {
      final s = S.of(sheetContext);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(s.addAPrize, style: AppText.title3),
          const SizedBox(height: 6),
          Text(s.prizesBody(childName), style: AppText.bodyRegular),
          const SizedBox(height: 18),
          DsPrimaryButton.secondary(
            label: s.yourOwnPrize,
            icon: const Icon(Icons.edit_rounded, size: 19),
            onTap: () => Navigator.of(sheetContext).pop(_NewPrizeChoice.custom),
          ),
          if (ideas.isNotEmpty) ...[
            const SizedBox(height: 22),
            DsOverlineText(s.prizeIdeasTitle),
            const SizedBox(height: 10),
            DsGroup(
              children: [
                for (final idea in ideas)
                  DsRow(
                    onTap: () => Navigator.of(sheetContext).pop(idea),
                    title: idea.title(s),
                    subtitle: s.coinCountShort(idea.coins),
                    leading: DsEmojiTile(emoji: idea.emoji, size: 36),
                    trailing: AppIcons.chevronRight(),
                  ),
              ],
            ),
          ],
        ],
      );
    },
  );
  if (!context.mounted || choice == null) return;
  await showPrizeEditor(
    context,
    cubit: cubit,
    childName: childName,
    idea: choice is PrizeIdea ? choice : null,
  );
}

/// Add ([prize] null) or edit a prize. [idea] prefills an add.
Future<void> showPrizeEditor(
  BuildContext context, {
  required ParentPrizesCubit cubit,
  required String childName,
  Prize? prize,
  PrizeIdea? idea,
}) {
  return showDsSheet<void>(
    context: context,
    builder: (_) => _PrizeEditor(
      cubit: cubit,
      childName: childName,
      prize: prize,
      idea: idea,
    ),
  );
}

class _PrizeEditor extends StatefulWidget {
  const _PrizeEditor({
    required this.cubit,
    required this.childName,
    this.prize,
    this.idea,
  });

  final ParentPrizesCubit cubit;
  final String childName;
  final Prize? prize;
  final PrizeIdea? idea;

  @override
  State<_PrizeEditor> createState() => _PrizeEditorState();
}

class _PrizeEditorState extends State<_PrizeEditor> {
  late final TextEditingController _title = TextEditingController(
    text: widget.prize?.title ?? '',
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.prize?.note ?? '',
  );
  late String _emoji = widget.prize?.displayEmoji ?? widget.idea?.emoji ?? '🎁';
  late int _coins = widget.prize?.coinCost ?? widget.idea?.coins ?? 100;
  bool _busy = false;
  bool _prefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The idea's name is only known once there is a locale to read it in.
    if (!_prefilled && widget.idea != null) {
      _title.text = widget.idea!.title(S.of(context));
    }
    _prefilled = true;
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  bool get _canSave => _title.text.trim().isNotEmpty && !_busy;

  Future<void> _save() async {
    final s = S.of(context);
    setState(() => _busy = true);
    final note = _note.text.trim();
    final error = widget.prize == null
        ? await widget.cubit.add(
            title: _title.text.trim(),
            coinCost: _coins,
            emoji: _emoji,
            note: note.isEmpty ? null : note,
            templateKey: widget.idea?.key,
          )
        : await widget.cubit.save(
            widget.prize!,
            title: _title.text.trim(),
            coinCost: _coins,
            emoji: _emoji,
            note: note.isEmpty ? null : note,
          );
    if (!mounted) return;
    setState(() => _busy = false);
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      AppSnackBar.error(context, error.isEmpty ? s.networkError : error);
    }
  }

  Future<void> _remove() async {
    final s = S.of(context);
    setState(() => _busy = true);
    final error = await widget.cubit.remove(widget.prize!);
    if (!mounted) return;
    setState(() => _busy = false);
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      AppSnackBar.error(context, error.isEmpty ? s.networkError : error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final editing = widget.prize != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(editing ? s.editPrize : s.addAPrize, style: AppText.title3),
        const SizedBox(height: 16),
        Center(
          child: DsEmojiTile(
            emoji: _emoji,
            size: 64,
            background: AppColors.coinPillBg,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 12),
        PrizeEmojiPicker(
          selected: _emoji,
          onSelect: (emoji) => setState(() => _emoji = emoji),
        ),
        const SizedBox(height: 16),
        DsSheetPanel(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              PrizeTextRow(
                label: s.prizeNameLabel,
                controller: _title,
                hint: s.prizeNameHint,
                autofocus: !editing && widget.idea == null,
                onChanged: (_) => setState(() {}),
              ),
              const DsDivider(),
              PrizePriceRow(
                coins: _coins,
                onChanged: (coins) => setState(() => _coins = coins),
              ),
              const DsDivider(),
              PrizeTextRow(
                label: s.prizeNoteLabel,
                controller: _note,
                hint: s.prizeNoteHint,
                maxLength: 120,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        DsFootnote(s.prizeHoldExplainer(widget.childName)),
        const SizedBox(height: 16),
        DsPrimaryButton(
          label: editing ? s.saveChanges : s.addPrizeFor(widget.childName),
          enabled: _canSave,
          busy: _busy,
          onTap: _save,
        ),
        if (editing) ...[
          const SizedBox(height: 4),
          DsDestructiveButton(
            label: s.removePrize,
            filled: false,
            onTap: _busy ? null : _remove,
          ),
        ],
      ],
    );
  }
}

/// A parent's answer to one ask. For a wish the price can be changed first.
/// Returns true for approve, false for decline, null when dismissed.
Future<({bool approve, int coins})?> showPrizeAnswerSheet(
  BuildContext context, {
  required PrizeRequest request,
}) {
  return showDsSheet<({bool approve, int coins})>(
    context: context,
    builder: (_) => _PrizeAnswer(request: request),
  );
}

class _PrizeAnswer extends StatefulWidget {
  const _PrizeAnswer({required this.request});

  final PrizeRequest request;

  @override
  State<_PrizeAnswer> createState() => _PrizeAnswerState();
}

class _PrizeAnswerState extends State<_PrizeAnswer> {
  late int _coins = widget.request.coinCost;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final request = widget.request;
    final name = request.childNickname ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: DsEmojiTile(
            emoji: request.displayEmoji,
            size: 64,
            background: AppColors.coinPillBg,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          request.isWish
              ? s.wishReviewTitle(name, request.title)
              : s.prizeAskReviewTitle(name, request.title),
          textAlign: TextAlign.center,
          style: AppText.title3,
        ),
        const SizedBox(height: 8),
        Text(
          request.isWish
              ? s.wishReviewBody(name)
              : s.prizeAskReviewBody(s.coinCountShort(request.coinCost)),
          textAlign: TextAlign.center,
          style: AppText.bodyRegular,
        ),
        if (request.isWish) ...[
          const SizedBox(height: 16),
          DsSheetPanel(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: PrizePriceRow(
              coins: _coins,
              onChanged: (coins) => setState(() => _coins = coins),
            ),
          ),
        ],
        const SizedBox(height: 22),
        DsPrimaryButton(
          label: request.isWish ? s.addToStore : s.markGiven,
          onTap: () =>
              Navigator.of(context).pop((approve: true, coins: _coins)),
        ),
        const SizedBox(height: 9),
        DsPrimaryButton.secondary(
          label: s.notThisTime,
          onTap: () =>
              Navigator.of(context).pop((approve: false, coins: _coins)),
        ),
      ],
    );
  }
}
