import 'dart:async';

import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/parent/data/app_data.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/domain/models/catalog_app_model.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm;



/// Add an app to a child's rules. Built from the artboard's "New task" sheet
/// pattern: emoji tiles to pick, a grey panel of stepper rows, one primary
/// button.
Future<void> showAddAppSheet(
  BuildContext context, {
  required ParentAppsCubit cubit,
}) {
  return showDsSheet<void>(
    context: context,
    builder: (context) => _AddAppSheet(cubit: cubit, added: cubit.addedSlugs),
  );
}

class _AddAppSheet extends StatefulWidget {
  const _AddAppSheet({required this.cubit, required this.added});

  final ParentAppsCubit cubit;
  final Set<String> added;

  @override
  State<_AddAppSheet> createState() => _AddAppSheetState();
}

class _AddAppSheetState extends State<_AddAppSheet> {
  List<CatalogAppModel> _available = const [];
  bool _loading = true;
  String? _loadError;

  String? _slug;
  int _limit = 60;
  int _cost = 100;
  int _reward = 30;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadCatalog());
  }

  /// The list comes from `GET /v1/apps` now. It used to be a hard-coded copy
  /// of four slugs, which went stale the moment the catalog grew.
  Future<void> _loadCatalog() async {
    final result = await widget.cubit.loadCatalog();
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _loading = false;
        _loadError = failure.message;
      }),
      (apps) => setState(() {
        _loading = false;
        _available = apps
            .where((app) => !widget.added.contains(app.appSlug))
            .toList();
        final first = _available.firstOrNull;
        if (first != null) {
          _slug = first.appSlug;
          _limit = first.defaultDailyLimitMinutes;
          _cost = first.defaultRedeemCoinCost;
          _reward = first.defaultRedeemRewardMinutes;
        }
      }),
    );
  }

  Future<void> _save() async {
    final slug = _slug;
    if (slug == null) return;
    final app = _available.firstWhere((a) => a.appSlug == slug);

    setState(() => _saving = true);
    final error = await widget.cubit.addApp(
      slug: app.appSlug,
      name: app.displayName,
      dailyLimitMinutes: _limit,
      redeemCoinCost: _cost,
      redeemRewardMinutes: _reward,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      AppSnackBar.error(context, error);
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_loadError!, style: AppText.bodyRegular),
          const SizedBox(height: 22),
          DsPrimaryButton.secondary(
            label: s.tryAgain,
            onTap: () {
              setState(() {
                _loading = true;
                _loadError = null;
              });
              unawaited(_loadCatalog());
            },
          ),
        ],
      );
    }

    if (_available.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(s.everyAppSetUp, style: AppText.title3),
          const SizedBox(height: 8),
          Text(s.openOneFromList, style: AppText.bodyRegular),
          const SizedBox(height: 22),
          DsPrimaryButton.secondary(
            label: s.close,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(s.addAnApp, style: AppText.title3),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final app in _available)
              DsCategoryChip(
                label: app.displayName,
                emoji: AppData.getEmojiForApp(app.displayName),
                selected: app.appSlug == _slug,
                restBackground: AppColors.fill,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                onTap: () => setState(() {
                  _slug = app.appSlug;
                  // Start from the catalog's own defaults rather than
                  // whatever the previously selected app happened to use.
                  _limit = app.defaultDailyLimitMinutes;
                  _cost = app.defaultRedeemCoinCost;
                  _reward = app.defaultRedeemRewardMinutes;
                }),
              ),
          ],
        ),
        const SizedBox(height: 20),
        DsSheetPanel(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              _StepperRow(
                label: s.dailyLimit,
                value: formatHm(s, _limit),
                onLess: () => setState(() => _limit = (_limit - 15).clamp(15, 480)),
                onMore: () => setState(() => _limit = (_limit + 15).clamp(15, 480)),
              ),
              const DsDivider(),
              _StepperRow(
                label: s.costsLabel,
                value: s.coinCountShort(_cost),
                onLess: () => setState(() => _cost = (_cost - 10).clamp(10, 1000)),
                onMore: () => setState(() => _cost = (_cost + 10).clamp(10, 1000)),
              ),
              const DsDivider(),
              _StepperRow(
                label: s.buysLabel,
                value: formatHm(s, _reward),
                onLess: () =>
                    setState(() => _reward = (_reward - 5).clamp(5, 240)),
                onMore: () =>
                    setState(() => _reward = (_reward + 5).clamp(5, 240)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          s.redeemExplainer(_cost, formatHm(s, _reward)),
          style: AppText.footnote,
        ),
        const SizedBox(height: 22),
        DsPrimaryButton(label: s.addAppAction, busy: _saving, onTap: _save),
      ],
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.onLess,
    required this.onMore,
  });

  final String label;
  final String value;
  final VoidCallback onLess;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: AppText.field)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: AppText.rowTitleLg.copyWith(
                fontWeight: FontWeight.w600,
              ).nums,
            ),
          ),
          DsStepper.onPanel(onLess: onLess, onMore: onMore),
        ],
      ),
    );
  }
}
