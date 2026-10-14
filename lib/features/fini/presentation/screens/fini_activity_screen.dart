import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/fini/data/fini_repository.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/presentation/cubit/fini_cubit.dart';
import 'package:safini/features/fini/presentation/fini_copy.dart';

Future<void> openFiniActivity(BuildContext context, String childName) =>
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<FiniCubit>(),
          child: FiniActivityScreen(childName: childName),
        ),
      ),
    );

/// Everything Fini did or proposed and how it ended, newest first, with
/// Undo for 24 hours on what ran. The Sunday report card joins the top of
/// this list in SAF-278.
class FiniActivityScreen extends StatelessWidget {
  const FiniActivityScreen({super.key, required this.childName});

  final String childName;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final items = context.watch<FiniCubit>().state.activity;
    final now = DateTime.now();
    bool isToday(FiniProposal p) =>
        p.createdAt.year == now.year &&
        p.createdAt.month == now.month &&
        p.createdAt.day == now.day;
    final today = items.where(isToday).toList();
    final earlier = items.where((p) => !isToday(p)).toList();

    return Scaffold(
      backgroundColor: AppColors.bgParent,
      body: Column(
        children: [
          DsNavBar(
            title: s.finiActivity,
            backLabel: s.tabFini,
            onBack: () => context.router.maybePop(),
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: 40 + MediaQuery.viewPaddingOf(context).bottom,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.textGutter,
                    4,
                    AppSpacing.textGutter,
                    0,
                  ),
                  child: Text(
                    s.finiActivitySub(childName),
                    style: AppText.subtitle,
                  ),
                ),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      20,
                      AppSpacing.gutter,
                      0,
                    ),
                    child: DsCard(
                      child: Text(s.finiActivityEmpty, style: AppText.body),
                    ),
                  ),
                for (final (title, list) in [
                  (s.finiDayToday, today),
                  (s.finiDayEarlier, earlier),
                ])
                  if (list.isNotEmpty) ...[
                    DsOverline(title, top: 22),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.gutter,
                      ),
                      child: DsGroup(
                        children: [
                          for (final item in list)
                            _Entry(item: item, childName: childName),
                        ],
                      ),
                    ),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({required this.item, required this.childName});

  final FiniProposal item;
  final String childName;

  Future<void> _undo(BuildContext context) async {
    final s = S.of(context);
    final error = await context.read<FiniCubit>().decide(
      item,
      FiniDecision.undo,
    );
    if (!context.mounted || error == null) return;
    AppSnackBar.error(context, error.isEmpty ? s.networkError : error);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final local = MaterialLocalizations.of(context);
    final time = local.formatTimeOfDay(
      TimeOfDay.fromDateTime(item.createdAt),
      alwaysUse24HourFormat: true,
    );
    final result = finiResultLine(s, item);
    final evidence = finiEvidenceLine(item);
    return Padding(
      key: ValueKey('fini-activity-${item.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(time, style: AppText.metaSm),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  finiActivityTitle(s, item, childName: childName),
                  style: AppText.rowTitleStrong,
                ),
                if (item.reason.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(item.reason, style: AppText.meta),
                ],
                if (result != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    result,
                    style: AppText.metaSm.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
                if (evidence.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.fillAlt,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DsOverlineText(s.finiWhatItLookedAt),
                        const SizedBox(height: 4),
                        Text(evidence, style: AppText.metaSm),
                        const SizedBox(height: 2),
                        Text(
                          s.finiNeverNames,
                          style: AppText.metaSm.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (item.canUndo) ...[
            const SizedBox(width: 10),
            DsInlineButton.quiet(
              key: ValueKey('fini-undo-${item.id}'),
              label: s.finiUndo,
              onTap: () => _undo(context),
            ),
          ],
        ],
      ),
    );
  }
}
