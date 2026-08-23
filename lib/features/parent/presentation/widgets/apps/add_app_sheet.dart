import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/parent/data/app_data.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm;

/// Controlled apps the backend accepts. There is no catalog endpoint, so this
/// list is maintained client-side; add new entries here as the backend seeds
/// more controlled apps.
const List<({String slug, String name})> knownApps = [
  (slug: 'youtube-kids', name: 'YouTube Kids'),
  (slug: 'roblox', name: 'Roblox'),
  (slug: 'brawl-stars', name: 'Brawl Stars'),
  (slug: 'minecraft', name: 'Minecraft'),
];

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
  late final List<({String slug, String name})> _available = knownApps
      .where((app) => !widget.added.contains(app.slug))
      .toList();

  String? _slug;
  int _limit = 60;
  int _cost = 100;
  int _reward = 30;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _slug = _available.firstOrNull?.slug;
  }

  Future<void> _save() async {
    final slug = _slug;
    if (slug == null) return;
    final app = _available.firstWhere((a) => a.slug == slug);

    setState(() => _saving = true);
    final error = await widget.cubit.addApp(
      slug: app.slug,
      name: app.name,
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
                label: app.name,
                emoji: AppData.getEmojiForApp(app.name),
                selected: app.slug == _slug,
                restBackground: AppColors.fill,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                onTap: () => setState(() => _slug = app.slug),
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
