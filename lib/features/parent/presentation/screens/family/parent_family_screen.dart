import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/models/domain/models/child_invite_code_model.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/models/domain/models/parent_invite_code_model.dart';
import 'package:safini/features/parent/presentation/screens/family/edit_child_page.dart';
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

              return BlocBuilder<ParentFamilyCubit, ParentFamilyState>(
                builder: (context, state) {
                  return Scaffold(
                    backgroundColor: context.colorScheme.surface,
                    appBar: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: Text(
                        state.family?.name ?? s.family,
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
                          onPressed: () =>
                              context.read<AuthSessionCubit>().signOut(),
                        ),
                      ],
                      flexibleSpace: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              context.colorScheme.primary.withValues(
                                alpha: 0.8,
                              ),
                              context.colorScheme.primary,
                            ],
                          ),
                        ),
                      ),
                    ),
                    body: _buildBody(context, state, s),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ParentFamilyState state, S s) {
    if (state.isLoading && state.family == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.family == null) {
      return _ErrorState(
        message: state.errorMessage!,
        canRetry: state.canRetry,
        onRetry: () =>
            context.read<ParentFamilyCubit>().loadCurrentFamily(refresh: true),
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
      onRefresh: () =>
          context.read<ParentFamilyCubit>().loadCurrentFamily(refresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _ParentManagementCard(
            family: family,
            isLoading: state.isParentInviteCodeLoading,
            onCreateParentInviteCode: state.isParentInviteCodeLoading
                ? null
                : _createParentInviteCode,
          ),
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
            _EmptyChildrenState(onAddChild: _openAddChildPage)
          else
            ...family.children.map(
              (child) => _ChildSummaryCard(
                child: child,
                onCreateInviteCode: () => _createChildInviteCode(child.id),
                onEditChild: () => _openEditChildPage(child),
              ),
            ),
          if (family.children.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _openAddChildPage,
                child: const Text('Add Child'),
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (state.errorMessage != null)
            _InlineErrorBanner(
              message: state.errorMessage!,
              onRetry: state.canRetry
                  ? () => context.read<ParentFamilyCubit>().loadCurrentFamily(
                      refresh: true,
                    )
                  : null,
            ),
          const SizedBox(height: 24),
          _buildEditProfileTile(context),
          const SizedBox(height: 16),
          _buildLanguageTile(context, s),
          const SizedBox(height: 24),
          const _LogoutButton(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Future<void> _createParentInviteCode() async {
    final cubit = context.read<ParentFamilyCubit>();
    final inviteCode = await cubit.createParentInviteCode();
    if (!mounted) return;
    if (inviteCode == null) {
      final message = cubit.state.errorMessage;
      if (message != null && message.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => _ParentInviteCodeDialog(inviteCode: inviteCode),
    );
  }

  Future<void> _createChildInviteCode(String childId) async {
    final cubit = context.read<ParentFamilyCubit>();
    final inviteCode = await cubit.createChildInviteCode(childId);
    if (!mounted) return;
    if (inviteCode == null) {
      final message = cubit.state.errorMessage;
      if (message != null && message.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => _ChildInviteCodeDialog(inviteCode: inviteCode),
    );
  }

  Future<void> _openAddChildPage() async {
    final result = await context.router.push<bool>(
      const NamedRoute('addChild'),
    );
    if (!mounted) return;
    if (result == true) {
      await context.read<ParentFamilyCubit>().loadCurrentFamily(refresh: true);
    }
  }

  Future<void> _openEditChildPage(ChildSummaryModel child) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EditChildPage(child: child)),
    );
    if (!mounted) return;
    if (updated == true) {
      await context.read<ParentFamilyCubit>().loadCurrentFamily(refresh: true);
    }
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
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: context.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditProfileTile(BuildContext context) {
    return InkWell(
      onTap: () => context.router.push(const NamedRoute('editProfile')),
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
                color: context.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.edit_rounded,
                color: context.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Edit Profile',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: context.colorScheme.onSurface.withValues(alpha: 0.4),
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

class _ParentManagementCard extends StatelessWidget {
  final FamilyModel family;
  final bool isLoading;
  final VoidCallback? onCreateParentInviteCode;

  const _ParentManagementCard({
    required this.family,
    required this.isLoading,
    required this.onCreateParentInviteCode,
  });

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
            'Parents',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          if (family.parents.isEmpty)
            const _ParentListTile(displayName: 'Parent', role: 'admin')
          else
            ...family.parents.map(
              (parent) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ParentListTile(
                  displayName: parent.displayName,
                  role: parent.role,
                ),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCreateParentInviteCode,
              child: isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Parent Invite Code'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentInviteCodeDialog extends StatelessWidget {
  final ParentInviteCodeModel inviteCode;

  const _ParentInviteCodeDialog({required this.inviteCode});

  @override
  Widget build(BuildContext context) {
    final expiryLocal = inviteCode.inviteCodeExpiresAt.toLocal();
    final date = MaterialLocalizations.of(context).formatFullDate(expiryLocal);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(expiryLocal));

    return AlertDialog(
      title: const Text('Parent Invite Code'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SelectableText(
              inviteCode.inviteCode,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Expires: $date, $time'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: inviteCode.inviteCode));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invite code copied')),
              );
            }
          },
          child: const Text('Copy'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _ParentListTile extends StatelessWidget {
  final String displayName;
  final String role;

  const _ParentListTile({required this.displayName, required this.role});

  @override
  Widget build(BuildContext context) {
    final initials = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'P';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 18, child: Text(initials)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(role, style: context.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildSummaryCard extends StatelessWidget {
  final ChildSummaryModel child;
  final VoidCallback onCreateInviteCode;
  final VoidCallback onEditChild;

  const _ChildSummaryCard({
    required this.child,
    required this.onCreateInviteCode,
    required this.onEditChild,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(
                  child.nickname.isNotEmpty
                      ? child.nickname[0].toUpperCase()
                      : 'C',
                ),
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
                    Text(
                      'Age: ${child.age}',
                      style: context.textTheme.bodySmall,
                    ),
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: child.claimedByUserId == null
                  ? onCreateInviteCode
                  : onEditChild,
              child: Text(
                child.claimedByUserId == null
                    ? 'Create Child Invite Code'
                    : 'Edit Child',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildInviteCodeDialog extends StatelessWidget {
  final ChildInviteCodeModel inviteCode;

  const _ChildInviteCodeDialog({required this.inviteCode});

  @override
  Widget build(BuildContext context) {
    final expiryLocal = inviteCode.inviteCodeExpiresAt.toLocal();
    final date = MaterialLocalizations.of(context).formatFullDate(expiryLocal);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(expiryLocal));

    return AlertDialog(
      title: const Text('Child Invite Code'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SelectableText(
              inviteCode.inviteCode,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Expires: $date, $time'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: inviteCode.inviteCode));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invite code copied')),
              );
            }
          },
          child: const Text('Copy'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
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
            Icon(
              Icons.family_restroom_rounded,
              size: 72,
              color: context.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('No family set up yet', style: context.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Create a family or join one with an invite code.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChildrenState extends StatelessWidget {
  final VoidCallback onAddChild;

  const _EmptyChildrenState({required this.onAddChild});

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
          Text(
            'Invite a child or refresh after linking a family member.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onAddChild, child: const Text('Add Child')),
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
