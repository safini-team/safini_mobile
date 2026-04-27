import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_state.dart';
import 'package:safini/core/translation/generated/l10n.dart';

class ParentFamilyScreen extends StatefulWidget {
  const ParentFamilyScreen({super.key});

  @override
  State<ParentFamilyScreen> createState() => _ParentFamilyScreenState();
}

class _ParentFamilyScreenState extends State<ParentFamilyScreen> {
  bool _refreshed = false;

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

              if (!_refreshed) {
                _refreshed = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    final cubit = context.read<ParentFamilyCubit>();
                    if (cubit.state.hasFamily) {
                      cubit.loadCurrentFamily(refresh: true);
                    }
                  }
                });
              }

              return Scaffold(
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
                      onPressed: () => context.read<AuthSessionCubit>().signOut(),
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
                    if (state.isLoading && state.family == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.errorMessage != null && state.family == null) {
                      return _ErrorState(
                        message: state.errorMessage!,
                        canRetry: state.canRetry,
                        onRetry: () => context
                            .read<ParentFamilyCubit>()
                            .loadCurrentFamily(refresh: true),
                        onCreate: () => context.read<ParentFamilyCubit>().markCreateFlow(),
                        onJoin: () => context.read<ParentFamilyCubit>().markJoinFlow(),
                      );
                    }

                    final family = state.family;
                    if (family == null) {
                      return _EmptyState(
                        onCreate: () => context.read<ParentFamilyCubit>().markCreateFlow(),
                        onJoin: () => context.read<ParentFamilyCubit>().markJoinFlow(),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => context
                          .read<ParentFamilyCubit>()
                          .loadCurrentFamily(refresh: true),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        children: [
                          _FamilySummaryCard(family: family),
                          const SizedBox(height: 24),
                          Text(
                            s.yourChildren,
                            style: context.textTheme.labelMedium?.copyWith(
                              color: Colors.grey[600],
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (family.children.isEmpty)
                            _EmptyChildrenState(onJoin: () => context.read<ParentFamilyCubit>().markJoinFlow())
                          else
                            ...family.children.map(
                              (child) => _ChildSummaryCard(child: child),
                            ),
                          const SizedBox(height: 24),
                          if (state.errorMessage != null)
                            _InlineErrorBanner(
                              message: state.errorMessage!,
                              onRetry: state.canRetry
                                  ? () => context
                                      .read<ParentFamilyCubit>()
                                      .loadCurrentFamily(refresh: true)
                                  : null,
                            ),
                          const SizedBox(height: 24),
                          _buildLanguageTile(context, s),
                          const SizedBox(height: 16),
                          _ActionRow(
                            onCreate: () => context.read<ParentFamilyCubit>().markCreateFlow(),
                            onJoin: () => context.read<ParentFamilyCubit>().markJoinFlow(),
                          ),
                          const SizedBox(height: 24),
                          const _LogoutButton(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
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

}

class _FamilySummaryCard extends StatelessWidget {
  final FamilyModel family;

  const _FamilySummaryCard({required this.family});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            family.name,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Timezone: ${family.timezone}',
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Children: ${family.children.length}',
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ChildSummaryCard extends StatelessWidget {
  final ChildSummaryModel child;

  const _ChildSummaryCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            child: Text(child.nickname.isNotEmpty ? child.nickname[0].toUpperCase() : 'C'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.nickname,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Age: ${child.age}', style: context.textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Coins', style: context.textTheme.bodySmall),
              Text(
                child.coinsBalance.toString(),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  const _EmptyState({required this.onCreate, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          children: [
            Icon(Icons.family_restroom_rounded, size: 72, color: context.colorScheme.primary),
            const SizedBox(height: 16),
            Text('No family set up yet', style: context.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Create a family or join one with an invite code.', textAlign: TextAlign.center, style: context.textTheme.bodyMedium),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(onPressed: onCreate, child: const Text('Create family')),
                OutlinedButton(onPressed: onJoin, child: const Text('Join family')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChildrenState extends StatelessWidget {
  final VoidCallback onJoin;

  const _EmptyChildrenState({required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(Icons.child_care_rounded, size: 40),
          const SizedBox(height: 12),
          Text('No children found yet', style: context.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('Invite a child or refresh after linking a family member.', textAlign: TextAlign.center, style: context.textTheme.bodySmall),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onJoin, child: const Text('Join a family')),
        ],
      ),
    );
  }
}

class _InlineErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _InlineErrorBanner({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(color: Colors.red)),
          if (onRetry != null) ...[
            const SizedBox(height: 10),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  const _ActionRow({required this.onCreate, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onCreate,
            child: const Text('Create family'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: onJoin,
            child: const Text('Join family'),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final bool canRetry;
  final VoidCallback onRetry;
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  const _ErrorState({
    required this.message,
    required this.canRetry,
    required this.onRetry,
    required this.onCreate,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_rounded, size: 56, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (canRetry)
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(onPressed: onCreate, child: const Text('Create family')),
                OutlinedButton(onPressed: onJoin, child: const Text('Join family')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.read<AuthSessionCubit>().signOut(),
        borderRadius: BorderRadius.circular(20),
        child: Container(
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
        ),
      ),
    );
  }
}