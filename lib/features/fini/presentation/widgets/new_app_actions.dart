import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/presentation/cubit/fini_cubit.dart';
import 'package:safini/features/fini/presentation/fini_copy.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm;

/// New apps Fini put under a capped goal in the last day that the parent
/// has not answered yet: each gets "Allow 15 min a day" and "Not a game".
List<FiniProposal> openAppSorts(List<FiniProposal> activity, DateTime now) {
  final answered = {
    for (final p in activity)
      if (p.isAppSort && p.decidedBy == 'parent') p.appPackage,
  };
  return [
    for (final p in activity)
      if (p.isAppSort &&
          p.ranAlone &&
          !answered.contains(p.appPackage) &&
          now.difference(p.createdAt) < const Duration(hours: 24))
        p,
  ];
}

Future<void> _place(
  BuildContext context,
  FiniProposal proposal, {
  String? category,
  int? minutes,
}) async {
  final s = S.of(context);
  final error = await context.read<FiniCubit>().placeApp(
    proposal,
    category: category,
    minutes: minutes,
  );
  if (!context.mounted || error == null) return;
  AppSnackBar.error(context, error.isEmpty ? s.networkError : error);
}

/// "Allow 15 min a day" and "Not a game" under a new app Fini sorted.
class NewAppActions extends StatelessWidget {
  const NewAppActions({super.key, required this.proposal});

  final FiniProposal proposal;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Row(
      children: [
        Expanded(
          child: DsInlineButton.quiet(
            key: ValueKey('fini-app-not-${proposal.appPackage}'),
            label: finiNotThisLabel(s, proposal.appCategory),
            onTap: () => _place(context, proposal, category: 'other'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DsInlineButton(
            key: ValueKey('fini-app-allow-${proposal.appPackage}'),
            label: s.finiAllowApp(formatHm(s, finiNewAppMinutes)),
            onTap: () => _place(context, proposal, minutes: finiNewAppMinutes),
          ),
        ),
      ],
    );
  }
}

/// The "new app, sort it?" card's answers: one chip per category.
class SortAppChips extends StatelessWidget {
  const SortAppChips({super.key, required this.proposal});

  final FiniProposal proposal;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final category in finiAppCategories)
          DsCategoryChip(
            key: ValueKey('fini-sort-$category'),
            label: finiAppCategoryName(s, category),
            selected: false,
            onTap: () => _place(context, proposal, category: category),
          ),
      ],
    );
  }
}

/// A queued sort (Suggest mode): "Not a game" or yes.
class ConfirmSortActions extends StatelessWidget {
  const ConfirmSortActions({super.key, required this.proposal});

  final FiniProposal proposal;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Row(
      children: [
        Expanded(
          child: DsInlineButton.quiet(
            label: finiNotThisLabel(s, proposal.appCategory),
            onTap: () => _place(context, proposal, category: 'other'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DsInlineButton(
            label: s.finiApprove,
            onTap: () =>
                _place(context, proposal, category: proposal.appCategory),
          ),
        ),
      ],
    );
  }
}
