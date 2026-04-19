import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/common/profile/presentation/cubit/profile_cubit.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => getIt<ProfileCubit>()..load(),
      child: const _AuthContent(),
    );
  }
}

class _AuthContent extends StatelessWidget {
  const _AuthContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return Localizations.override(
          context: context,
          locale: locale,
          child: Builder(
            builder: (context) {
              final s = S.of(context);
              return Scaffold(
                body: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.colorScheme.primary.withValues(alpha: 0.8),
                        context.colorScheme.primary,
                        context.colorScheme.primary.withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: IconButton(
                              icon: Icon(
                                Icons.language,
                                color: context.colorScheme.onPrimary,
                              ),
                              onPressed: () => _showLanguageDialog(context),
                            ),
                          ),
                        ),
                        const Spacer(flex: 1),
                        // Mascot logo
                        ClipOval(
                          child: Image.asset(
                            'assets/logo/app_logo.png',
                            width: 120,
                            height: 120,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Title
                        Text(
                          s.appName,
                          style: context.textTheme.displayMedium?.copyWith(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: context.colorScheme.onPrimary,
                            letterSpacing: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Tagline
                        Text(
                          s.tagline,
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: context.colorScheme.onPrimary.withValues(
                              alpha: 0.85,
                            ),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(flex: 3),
                        // Role cards
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            children: [
                              _RoleCard(
                                icon: Icons.sports_esports_rounded,
                                title: s.imAKid,
                                subtitle: s.kidSubtitle,
                                gradientColors: const [
                                  Color(0xFFF5A623),
                                  Color(0xFFE8961A),
                                ],
                                onTap: () {
                                  context.router.push(
                                    const NamedRoute('childHome'),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              _RoleCard(
                                icon: Icons.people_rounded,
                                title: s.imAParent,
                                subtitle: s.parentSubtitle,
                                gradientColors: const [
                                  Color(0xFF2ECC9B),
                                  Color(0xFF27B08A),
                                ],
                                onTap: () {
                                  context.router.push(
                                    const NamedRoute('parentHome'),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const Spacer(flex: 2),
                        // Footer
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            s.footerText,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onPrimary.withValues(
                                alpha: 0.7,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(s.english),
              onTap: () {
                context.read<LocaleCubit>().setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(s.russian),
              onTap: () {
                context.read<LocaleCubit>().setLocale(const Locale('ru'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(s.kazakh),
              onTap: () {
                context.read<LocaleCubit>().setLocale(const Locale('kk'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

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
            // Arrow
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
