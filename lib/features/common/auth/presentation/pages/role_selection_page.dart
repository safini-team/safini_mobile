import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/core/translation/generated/l10n.dart';

/// Screen shown when `account_type` is `null` or unrecognised after login.
///
/// Two role cards — **Parent** and **Child**.
class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return Localizations.override(
          context: context,
          locale: locale,
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.colorScheme.primary.withValues(alpha: 0.85),
                        context.colorScheme.primary,
                        context.colorScheme.primary.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Language switcher
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8, top: 4),
                            child: IconButton(
                              icon: Icon(
                                Icons.language,
                                color: context.colorScheme.onPrimary,
                              ),
                              onPressed: () => _showLanguageDialog(context),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person_outline_rounded,
                                  size: 36,
                                  color: context.colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                S.of(context).chooseYourRole,
                                style: context.textTheme.headlineMedium
                                    ?.copyWith(
                                      color: context.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                S.of(context).roleSelectionSubtitle,
                                style: context.textTheme.bodyLarge?.copyWith(
                                  color: context.colorScheme.onPrimary
                                      .withValues(alpha: 0.85),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Role cards
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            children: [
                              // ── Parent card ──────────────────────────
                              _RoleCard(
                                icon: Icons.people_rounded,
                                title: S.of(context).imAParent,
                                subtitle: S.of(context).parentSubtitle,
                                gradientColors: const [
                                  Color(0xFF2ECC9B),
                                  Color(0xFF27B08A),
                                ],
                                onTap: () {
                                  context.router.push(
                                    const NamedRoute('familyDecision'),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              // ── Child card (coming soon) ─────────────
                              _RoleCard(
                                icon: Icons.sports_esports_rounded,
                                title: S.of(context).imAKid,
                                subtitle: S.of(context).kidInviteSubtitle,
                                gradientColors: const [
                                  Color(0xFF5A7DFF),
                                  Color(0xFF3F63E0),
                                ],
                                onTap: () {
                                  context.router.push(
                                    const NamedRoute('enterInviteCode'),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Footer
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Text(
                            S.of(context).footerText,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onPrimary.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final s = S.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(s.english),
              onTap: () {
                context.read<LocaleCubit>().setLocale(const Locale('en'));
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              title: Text(s.russian),
              onTap: () {
                context.read<LocaleCubit>().setLocale(const Locale('ru'));
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              title: Text(s.kazakh),
              onTap: () {
                context.read<LocaleCubit>().setLocale(const Locale('kk'));
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable role card ──────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.colorScheme.onPrimary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: context.colorScheme.onPrimary, size: 28),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: context.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onPrimary.withValues(
                        alpha: 0.85,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.colorScheme.onPrimary.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: context.colorScheme.onPrimary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
