import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/presentation/cubit/fini_cubit.dart';

Future<void> openFiniRules(BuildContext context, String childName) =>
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<FiniCubit>(),
          child: FiniRulesScreen(childName: childName),
        ),
      ),
    );

/// "What Fini can do": the master switch, five things it may do alone, the
/// fixed list it always asks about, and Pause. Pausing changes no rule.
class FiniRulesScreen extends StatelessWidget {
  const FiniRulesScreen({super.key, required this.childName});

  final String childName;

  Future<void> _save(BuildContext context, FiniSettings settings) async {
    final s = S.of(context);
    final error = await context.read<FiniCubit>().saveSettings(settings);
    if (!context.mounted || error == null) return;
    AppSnackBar.error(context, error.isEmpty ? s.networkError : error);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final settings = context.watch<FiniCubit>().state.settings;
    final alone = settings.level == FiniLevel.auto;

    Widget toggle(
      String key,
      String title,
      String subtitle,
      bool value,
      FiniSettings Function(bool) apply, {
      bool enabled = true,
    }) => DsRow(
      title: title,
      subtitle: subtitle,
      trailing: DsSwitch(
        key: ValueKey('fini-rule-$key'),
        value: value,
        onChanged: enabled ? (on) => _save(context, apply(on)) : null,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.bgParent,
      body: Column(
        children: [
          DsNavBar(
            title: s.finiWhatItCanDo,
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
                const SizedBox(height: 8),
                _group([
                  toggle(
                    'alone',
                    s.finiActAlone,
                    s.finiActAloneSub,
                    alone,
                    (on) => settings.copyWith(
                      level: on ? FiniLevel.auto : FiniLevel.suggest,
                    ),
                  ),
                ]),
                DsOverline(s.finiOnItsOwn, top: 22),
                // Switches stay readable while the master is off: they say
                // what would run, and the cards still follow them.
                _group([
                  toggle(
                    'lower',
                    s.finiRuleLower,
                    s.finiRuleLowerSub,
                    settings.mayLowerLimits,
                    (on) => settings.copyWith(mayLowerLimits: on),
                  ),
                  toggle(
                    'sort',
                    s.finiRuleSort,
                    s.finiRuleSortSub,
                    settings.maySortNewApps,
                    (on) => settings.copyWith(maySortNewApps: on),
                  ),
                  toggle(
                    'usage',
                    s.finiRuleUsage,
                    s.finiRuleUsageSub,
                    settings.autoApproveUsage,
                    (on) => settings.copyWith(autoApproveUsage: on),
                  ),
                  toggle(
                    'photo',
                    s.finiRulePhoto,
                    s.finiRulePhotoSub,
                    settings.autoApprovePhoto,
                    (on) => settings.copyWith(autoApprovePhoto: on),
                  ),
                  toggle(
                    'time',
                    s.finiRuleTime,
                    s.finiRuleTimeSub(settings.extraTimeEnvelopeMinutes),
                    settings.mayGrantTime,
                    (on) => settings.copyWith(mayGrantTime: on),
                  ),
                ]),
                DsOverline(s.finiAlwaysAsks, top: 22),
                _group([
                  for (final line in [
                    s.finiAskRaise,
                    s.finiAskUnblock,
                    s.finiAskReject,
                    s.finiAskCoins,
                  ])
                    DsRow(
                      title: line,
                      verticalPadding: 11,
                      leading: const Icon(
                        Icons.lock_outline_rounded,
                        size: 18,
                        color: AppColors.locked,
                      ),
                    ),
                ]),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.gutter,
                  ),
                  child: DsDestructiveButton(
                    key: const ValueKey('fini-pause'),
                    label: settings.paused
                        ? s.finiResumeFor(childName)
                        : s.finiPauseFor(childName),
                    filled: false,
                    onTap: () => _save(
                      context,
                      settings.copyWith(paused: !settings.paused),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter,
                    8,
                    AppSpacing.gutter,
                    0,
                  ),
                  child: Text(
                    s.finiPauseNote,
                    textAlign: TextAlign.center,
                    style: AppText.meta,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _group(List<Widget> rows) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
    child: DsGroup(children: rows),
  );
}
