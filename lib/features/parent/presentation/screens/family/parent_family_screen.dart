import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_state.dart';
import 'package:safini/features/parent/presentation/widgets/cards/parent_child_card.dart';
import 'package:safini/core/translation/generated/l10n.dart';

class ParentFamilyScreen extends StatelessWidget {
  const ParentFamilyScreen({super.key});

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

              return BlocProvider(
                create: (context) =>
                    getIt<ParentFamilyCubit>()..loadFamilyData(),
                child: Scaffold(
                  backgroundColor: context.colorScheme.surface,

                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: Text(
                      s.family,
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.language, color: Colors.white),
                        onPressed: () => _showLanguageDialog(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                    flexibleSpace: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.colorScheme.primary.withValues(alpha: 0.8),
                            context.colorScheme.primary,
                          ],
                        ),
                      ),
                    ),
                  ),

                  body: BlocBuilder<ParentFamilyCubit, ParentFamilyState>(
                    builder: (context, state) {
                      if (state is ParentFamilyLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (state is ParentFamilyLoaded) {
                        return ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            // ── Children ─────────────────────
                            Text(
                              s.yourChildren,
                              style: context.textTheme.labelMedium?.copyWith(
                                color: Colors.grey[600],
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            ...state.children.map(
                              (child) => ParentChildCard(
                                name: child.name,
                                age: 10,
                                gender: "Boy",
                                coins: 150,
                                quests: 1,
                                streak: 5,
                                onViewAsKid: () {},
                                onEdit: () {},
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── Language ─────────────────────
                            _buildLanguageTile(context, s),

                            const SizedBox(height: 16),

                            // ── Add Child ─────────────────────
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: context.colorScheme.surface,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: context.infoColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: context.infoColor,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.addAnotherChild,
                                          style: context.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          s.setUpANewProfile,
                                          style: context.textTheme.bodySmall
                                              ?.copyWith(
                                            color: context.colorScheme.onSurface
                                                .withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: context.colorScheme.onSurface
                                        .withValues(alpha: 0.4),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // ── Parent Account ─────────────────────
                            Text(
                              s.parentAccount,
                              style: context.textTheme.labelMedium?.copyWith(
                                color: Colors.grey[600],
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: context.colorScheme.surface,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 24,
                                    child: Icon(Icons.person),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          state.parent.name,
                                          style: context.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          s.familyAdmin,
                                          style: context.textTheme.bodySmall
                                              ?.copyWith(
                                            color: context.colorScheme.onSurface
                                                .withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      s.admin,
                                      style: TextStyle(
                                        color: context.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // ── Tips ─────────────────────
                            _buildTipsSection(context, s),

                            const SizedBox(height: 24),

                            const _LogoutButton(),

                            const SizedBox(height: 100),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLanguageTile(BuildContext context, S s) {
    return InkWell(
      onTap: () => _showLanguageDialog(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.infoColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.language, color: context.infoColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.changeLanguage,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getLanguageName(
                      Localizations.localeOf(context).languageCode,
                      s,
                    ),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: context.colorScheme.onSurface
                  .withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
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

  String _getLanguageName(String code, S s) {
    switch (code) {
      case 'kk':
        return s.kazakh;
      case 'ru':
        return s.russian;
      default:
        return s.english;
    }
  }

  Widget _buildTipsSection(BuildContext context, S s) {
    final tips = [s.tip1, s.tip2, s.tip3, s.tip4];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("🌟", style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                s.tipsForParents,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6),
                  const SizedBox(width: 12),
                  Expanded(child: Text(tip)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout, color: Colors.red),
          const SizedBox(width: 12),
          Text(
            s.switchToKidMode,
            style: context.textTheme.titleMedium?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}