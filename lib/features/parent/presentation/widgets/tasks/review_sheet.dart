import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';
import 'package:safini/features/parent/presentation/widgets/buttons/gradient_button.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/task_section_label.dart';

Future<void> showReviewSheet(
  BuildContext context, {
  required ParentTasksCubit cubit,
  required ParentTaskInstanceModel task,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: ReviewSheet(task: task),
    ),
  );
}

class ReviewSheet extends StatefulWidget {
  final ParentTaskInstanceModel task;

  const ReviewSheet({super.key, required this.task});

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  final _noteController = TextEditingController();
  bool? _approving;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit(bool approve) async {
    setState(() => _approving = approve);
    await context.read<ParentTasksCubit>().reviewTask(
      widget.task.id,
      approve: approve,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocListener<ParentTasksCubit, ParentTasksState>(
      listener: (context, state) {
        if (state is ParentTaskReviewed) {
          Navigator.of(context).pop();
        } else if (state is ParentTaskActionError &&
            !state.isConflict &&
            !state.isUnauthorized) {
          setState(() => _approving = null);
          AppSnackBar.error(context, state.message);
        }
      },
      child: BlocBuilder<ParentTasksCubit, ParentTasksState>(
        builder: (context, state) {
          final isBusy = state is ParentTaskReviewing;
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Header
                      Row(
                        children: [
                          Text(
                            s.reviewTaskSheetTitle,
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              fontSize: 22,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: isBusy
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F5),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // Task summary card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: context.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.task_alt_rounded,
                                color: context.colorScheme.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.task.displayTitle,
                                    style:
                                        context.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (widget.task.rewardCoins != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '🪙 ${widget.task.rewardCoins} coins',
                                      style:
                                          context.textTheme.bodySmall?.copyWith(
                                        color: context.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // Note field
                      TaskSectionLabel(s.reviewNoteHint),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _noteController,
                        maxLines: 3,
                        maxLength: 2000,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: s.reviewNoteHint,
                          hintStyle: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(AppSpacing.lg),
                          counterStyle: context.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // Approve button
                      GradientButton(
                        label: s.approve,
                        isLoading: isBusy && _approving == true,
                        isEnabled: !isBusy,
                        onTap: isBusy ? null : () => _submit(true),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Reject button
                      _RejectButton(
                        label: s.reject,
                        isLoading: isBusy && _approving == false,
                        isEnabled: !isBusy,
                        onTap: isBusy ? null : () => _submit(false),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RejectButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _RejectButton({
    required this.label,
    required this.isLoading,
    required this.isEnabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.55,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.error, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.error,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
