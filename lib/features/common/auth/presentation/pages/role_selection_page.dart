import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/config/platform_support.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/common/auth/presentation/pages/child_coming_soon_page.dart';

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
                      // Fini alone - 'Safini' is set in the Text just below.
                      Image.asset(
                        'assets/logo/safini-mascot.png',
                        width: 96,
                        height: 96,
                        fit: BoxFit.contain,
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
                  key: const ValueKey('role-kid'),
                  title: s.imAKid,
                  subtitle: isChildModeAvailable
                      ? s.kidSubtitle
                      : s.kidComingSoonIos,
                  onTap: isChildModeAvailable
                      ? () => context.router.push(
                          const NamedRoute('enterInviteCode'),
                        )
                      : () => _showKidComingSoon(context, s),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// iOS cannot block apps yet, so the kid door explains instead of starting
  /// a claim that would end on a home screen enforcing nothing.
  Future<void> _showKidComingSoon(BuildContext context, S s) {
    return showDsSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ChildComingSoonMessage(s: s, compact: true),
          const SizedBox(height: 22),
          DsPrimaryButton(
            label: s.ok,
            onTap: () => Navigator.of(sheetContext).pop(),
          ),
        ],
      ),
    );
  }
}
