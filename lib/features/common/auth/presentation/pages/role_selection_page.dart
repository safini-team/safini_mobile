import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';

/// The Welcome artboard: two doors, no account wall on the kid side.
///
/// Shown when `account_type` is null or unrecognised after login.
class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

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

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: DsScreenEntrance(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 22, 28, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            boxShadow: AppShadows.logo,
                          ),
                          child: Image.asset(
                            'assets/logo/app_logo.png',
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text('Safini', style: AppText.display),
                      const SizedBox(height: 18),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 290),
                        child: Text(s.tagline, style: AppText.lede),
                      ),
                    ],
                  ),
                ),
                DsChoiceCard(
                  filled: true,
                  title: s.imAParent,
                  subtitle: s.parentSubtitle,
                  onTap: () =>
                      context.router.push(const NamedRoute('familyDecision')),
                ),
                const SizedBox(height: 10),
                DsChoiceCard(
                  title: s.imAKid,
                  subtitle: s.kidSubtitle,
                  onTap: () =>
                      context.router.push(const NamedRoute('enterInviteCode')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
