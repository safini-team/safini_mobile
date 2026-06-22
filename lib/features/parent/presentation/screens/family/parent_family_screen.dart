import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/models/domain/models/child_invite_code_model.dart';
import 'package:shared_preferences/shared_preferences.dart' as safini_prefs;
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/models/domain/models/parent_invite_code_model.dart';
import 'package:safini/features/parent/presentation/screens/family/edit_child_page.dart';
import 'package:safini/features/parent/presentation/screens/family/parent_profile_page.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_cubit.dart';
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
                    backgroundColor: context.colorScheme.primary,
                    appBar: AppBar(
                      toolbarHeight: 100,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(
                          s.myFamily,
                          style: context.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () async {
                            final result = await context.router.push<bool>(
                              const NamedRoute('parentSettings'),
                            );
                            if (result == true && context.mounted) {
                              context.read<ParentCubit>().loadProfile();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Log Out'),
                                content: const Text(
                                  'Are you sure you want to log out?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text(
                                      'Log Out',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              try {
                                await getIt<
                                  safini_auth.AuthGoogleSignInService
                                >().signOut();
                              } catch (_) {}
                              await getIt<safini_prefs.SharedPreferences>()
                                  .remove('access_token');
                              if (context.mounted) {
                                context.router.replaceAll([
                                  const NamedRoute('login'),
                                ]);
                              }
                            }
                          },
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
                    body: Container(
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: context.colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                      ),
                      child: _buildBody(context, state, s),
                    ),
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
            onParentTap: _onParentTap,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  s.yourChildren,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: Colors.grey[600],
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (family.children.isNotEmpty)
                GestureDetector(
                  onTap: _openAddChildPage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 16,
                          color: context.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          s.addChild,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
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
          const SizedBox(height: 24),
          if (state.errorMessage != null) ...[
            _InlineErrorBanner(
              message: state.errorMessage!,
              onRetry: state.canRetry
                  ? () => context.read<ParentFamilyCubit>().loadCurrentFamily(
                      refresh: true,
                    )
                  : null,
            ),
            const SizedBox(height: 24),
          ],
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

  Future<void> _onParentTap(ParentSummaryModel parent) async {
    final currentUserId = Supabase.instance.client.auth.currentSession?.user.id;
    if (parent.userId == currentUserId) {
      final result = await context.router.push<bool>(const NamedRoute('editProfile'));
      if (result == true && mounted) {
        context.read<ParentCubit>().loadProfile();
        context.read<ParentFamilyCubit>().loadCurrentFamily(refresh: true);
      }
    } else {
      final updated = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => ParentProfilePage(parentModel: parent)),
      );
      if (updated == true && mounted) {
        context.read<ParentFamilyCubit>().loadCurrentFamily(refresh: true);
      }
    }
  }

}

class _ParentManagementCard extends StatelessWidget {
  final FamilyModel family;
  final bool isLoading;
  final VoidCallback? onCreateParentInviteCode;
  final void Function(ParentSummaryModel) onParentTap;

  const _ParentManagementCard({
    required this.family,
    required this.isLoading,
    required this.onCreateParentInviteCode,
    required this.onParentTap,
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
            S.of(context).parents,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          if (family.parents.isEmpty)
             _ParentListTile(displayName: S.of(context).parentAccount, role: S.of(context).admin, onTap: () {})
          else
            ...family.parents.map(
              (parent) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ParentListTile(
                  displayName: parent.displayName,
                  role: parent.role,
                  onTap: () => onParentTap(parent),
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
                  : Text(S.of(context).createParentInviteCode),
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

    return _InviteCodeDialog(
      title: S.of(context).parentInviteCodeTitle,
      code: inviteCode.inviteCode,
      expiresLabel: S.of(context).expiresLabel(date, time),
      icon: Icons.supervisor_account_rounded,
    );
  }
}

class _ParentListTile extends StatelessWidget {
  final String displayName;
  final String role;
  final VoidCallback onTap;

  const _ParentListTile({required this.displayName, required this.role, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final initials = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'P';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
    ));
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
                      S.of(context).ageLabel(child.age),
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
                    ? S.of(context).createChildInviteCode
                    : S.of(context).editChild,
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

    return _InviteCodeDialog(
      title: S.of(context).childInviteCodeTitle,
      code: inviteCode.inviteCode,
      expiresLabel: S.of(context).expiresLabel(date, time),
      icon: Icons.child_care_rounded,
    );
  }
}

class _InviteCodeDialog extends StatelessWidget {
  final String title;
  final String code;
  final String expiresLabel;
  final IconData icon;

  const _InviteCodeDialog({
    required this.title,
    required this.code,
    required this.expiresLabel,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: SelectableText(
                    code,
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                      color: primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  expiresLabel,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: code));
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(S.of(context).inviteCodeCopied),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: Text(S.of(context).copy),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(S.of(context).close),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
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
            Icon(
              Icons.family_restroom_rounded,
              size: 72,
              color: context.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(S.of(context).noFamilySetupYet, style: context.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              S.of(context).createOrJoinFamily,
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
          Text(S.of(context).noChildrenFoundYet, style: context.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            S.of(context).inviteChildOrRefresh,
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onAddChild, child: Text(S.of(context).addChild)),
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
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Log Out'),
              content: const Text('Are you sure you want to log out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
          if (confirm == true) {
            try {
              await getIt<safini_auth.AuthGoogleSignInService>().signOut();
            } catch (_) {}
            await getIt<safini_prefs.SharedPreferences>()
                .remove('access_token');
            if (context.mounted) {
              context.router.replaceAll([const NamedRoute('login')]);
            }
          }
        },
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
