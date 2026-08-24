import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_state.dart';

/// Two doors for a parent with no family yet, in the Welcome artboard's shape.
class FamilyDecisionPage extends StatefulWidget {
  const FamilyDecisionPage({super.key});

  @override
  State<FamilyDecisionPage> createState() => _FamilyDecisionPageState();
}

class _FamilyDecisionPageState extends State<FamilyDecisionPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale?>(
      builder: (context, locale) => Localizations.override(
        context: context,
        locale: locale,
        child: Builder(builder: _build),
      ),
    );
  }

  Widget _build(BuildContext context) {
    final s = S.of(context);

    return BlocListener<ParentFamilyCubit, ParentFamilyState>(
      listenWhen: (prev, curr) => curr.hasFamily && !prev.hasFamily,
      listener: (context, _) =>
          context.router.replace(const NamedRoute('parentHome')),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: DsScreenEntrance(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const DsBackButton(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.setupYourFamily, style: AppText.title1),
                        const SizedBox(height: 10),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: Text(
                            s.familyDecisionSubtitle,
                            style: AppText.bodyRegular,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DsChoiceCard(
                        filled: true,
                        title: s.createFamilyAction,
                        subtitle: s.createFamilySubtitle,
                        onTap: () => context.router.push(
                          const NamedRoute('createFamily'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DsChoiceCard(
                        title: s.joinFamilyAction,
                        subtitle: s.joinFamilySubtitle,
                        onTap: () =>
                            context.router.push(const NamedRoute('joinFamily')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
