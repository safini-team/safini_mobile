import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart' as safini_prefs;
import 'package:safini/features/common/auth/data/auth_google_sign_in_service.dart'
    as safini_auth;
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/parent/presentation/screens/family/edit_child_page.dart';
import 'package:safini/features/parent/presentation/screens/family/parent_profile_page.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_cubit.dart';
import 'package:safini/features/parent/presentation/widgets/family/child_summary_card.dart';
import 'package:safini/features/parent/presentation/widgets/family/family_invite_dialogs.dart';
import 'package:safini/features/parent/presentation/widgets/family/family_management_widgets.dart';
import 'package:safini/features/parent/presentation/widgets/family/family_states.dart';
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
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              final result = await context.router.push<bool>(
                                const NamedRoute('parentSettings'),
                              );
                              if (result == true && context.mounted) {
                                context.read<ParentCubit>().loadProfile();
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: IconButton(
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
      return FamilyErrorState(
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
      return FamilyEmptyState(
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
          ParentManagementCard(
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
            EmptyChildrenState(onAddChild: _openAddChildPage)
          else
            ...family.children.map(
              (child) => ChildSummaryCard(
                child: child,
                onCreateInviteCode: () => _createChildInviteCode(child.id),
                onEditChild: () => _openEditChildPage(child),
              ),
            ),
          const SizedBox(height: 24),
          if (state.errorMessage != null) ...[
            InlineErrorBanner(
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
        AppSnackBar.error(context, message);
      }
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => ParentInviteCodeDialog(inviteCode: inviteCode),
    );
  }

  Future<void> _createChildInviteCode(String childId) async {
    final cubit = context.read<ParentFamilyCubit>();
    final inviteCode = await cubit.createChildInviteCode(childId);
    if (!mounted) return;
    if (inviteCode == null) {
      final message = cubit.state.errorMessage;
      if (message != null && message.isNotEmpty) {
        AppSnackBar.error(context, message);
      }
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => ChildInviteCodeDialog(inviteCode: inviteCode),
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

