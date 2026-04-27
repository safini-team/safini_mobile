import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/core/translation/generated/l10n.dart';

/// Placeholder screen for the parent-onboarding "family decision" step.
///
/// This is the first screen after a new parent selects "Parent" on the
/// [RoleSelectionPage].
class FamilyDecisionPage extends StatelessWidget {
  const FamilyDecisionPage({super.key});

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
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 48),
                        // Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.family_restroom_rounded,
                            size: 40,
                            color: context.colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            S.of(context).setupYourFamily,
                            style: context.textTheme.headlineMedium?.copyWith(
                              color: context.colorScheme.onPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: Text(
                            S.of(context).familyDecisionSubtitle,
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: context.colorScheme.onPrimary
                                  .withValues(alpha: 0.85),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Spacer(),
                        // Placeholder illustration
                        Icon(
                          Icons.construction_rounded,
                          size: 64,
                          color: context.colorScheme.onPrimary
                              .withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          S.of(context).comingSoon,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: context.colorScheme.onPrimary
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        const Spacer(),
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
}
