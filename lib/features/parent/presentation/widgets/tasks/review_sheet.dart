import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';

/// The artboard's review sheet: what was submitted, who sent it and what it is
/// worth, their note, then approve or ask to redo.
Future<void> showReviewSheet(
  BuildContext context, {
  required ParentTasksCubit cubit,
  required ParentTaskInstanceModel task,
  String? childName,
}) {
  return showDsSheet<void>(
    context: context,
    builder: (context) => BlocProvider.value(
      value: cubit,
      child: _ReviewSheet(task: task, childName: childName),
    ),
  );
}

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet({required this.task, this.childName});

  final ParentTaskInstanceModel task;
  final String? childName;

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  bool? _deciding;

  Future<void> _decide(bool approve) async {
    if (_deciding != null) return;
    setState(() => _deciding = approve);
    final navigator = Navigator.of(context);
    await context.read<ParentTasksCubit>().reviewTask(
      widget.task.id,
      approve: approve,
    );
    if (mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final task = widget.task;
    final kid = widget.childName ?? '';
    final coins = task.rewardCoins ?? 0;
    final note = (task.submissionNote ?? '').trim();
    // proof_mode is `text_image` when a photo was asked for. The old check
    // looked for 'photo', which never matches, so this panel never rendered.
    final wantsPhoto = (task.proofMode ?? '').toLowerCase().contains('image');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        DsOverlineText(s.reviewTaskSheetTitle),
        const SizedBox(height: 8),
        Text(task.displayTitle, style: AppText.title3),
        if (kid.isNotEmpty) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              DsInitialAvatar(
                name: kid,
                color: AppColors.kidColor(task.childId ?? kid),
                size: 30,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  s.worthCoins(kid, s.coinCountShort(coins)),
                  style: AppText.chip.copyWith(
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (wantsPhoto) ...[
          const SizedBox(height: 18),
          Container(
            height: 170,
            decoration: BoxDecoration(
              color: AppColors.fill,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: const Color(0x2417151C),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcons.camera(),
                const SizedBox(height: 8),
                Text(
                  s.photoProofAsked,
                  style: AppText.metaSm.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
        if (note.isNotEmpty) ...[
          const SizedBox(height: 16),
          DsSheetPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DsOverlineText(s.theirNote),
                const SizedBox(height: 7),
                Text(
                  note,
                  style: AppText.body.copyWith(
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
        if ((task.description ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            task.description!.trim(),
            style: AppText.bodyRegular.copyWith(color: AppColors.inkSoft),
          ),
        ],
        const SizedBox(height: 20),
        DsPrimaryButton(
          label: s.approvePayCoins(s.coinCountShort(coins)),
          busy: _deciding == true,
          onTap: () => _decide(true),
        ),
        const SizedBox(height: 9),
        DsPrimaryButton.secondary(
          label: s.askToRedo,
          busy: _deciding == false,
          onTap: () => _decide(false),
        ),
      ],
    );
  }
}
