import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/parent/presentation/cubit/parent_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_state.dart';
import 'package:safini/features/parent/presentation/screens/family/edit_child_page.dart';
import 'package:safini/features/parent/presentation/screens/family/parent_family_view.dart';
import 'package:safini/features/parent/presentation/widgets/family/family_sheets.dart';
import 'package:safini/features/parent/presentation/widgets/family/family_states.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ParentFamilyScreen extends StatefulWidget {
  const ParentFamilyScreen({super.key});

  @override
  State<ParentFamilyScreen> createState() => _ParentFamilyScreenState();
}

class _ParentFamilyScreenState extends State<ParentFamilyScreen> {
  bool _refreshed = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale?>(
      builder: (context, locale) => Localizations.override(
        context: context,
        locale: locale,
        child: Builder(builder: _buildScreen),
      ),
    );
  }

  Widget _buildScreen(BuildContext context) {
    if (!_refreshed) {
      _refreshed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final cubit = context.read<ParentFamilyCubit>();
        if (cubit.state.hasFamily) cubit.loadCurrentFamily(refresh: true);
      });
    }

    return BlocBuilder<ParentFamilyCubit, ParentFamilyState>(
      builder: (context, state) {
        final cubit = context.read<ParentFamilyCubit>();

        final s = S.of(context);

        if (state.isLoading && state.family == null) {
          return const _FamilySkeleton();
        }

        if (state.errorMessage != null && state.family == null) {
          return DsScreen(
            slivers: [
              SliverToBoxAdapter(child: DsLargeTitle(title: s.myFamily)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter,
                    24,
                    AppSpacing.gutter,
                    0,
                  ),
                  child: FamilyErrorState(
                    message: state.errorMessage!,
                    canRetry: state.canRetry,
                    onRetry: () => cubit.loadCurrentFamily(refresh: true),
                    onCreate: cubit.markCreateFlow,
                    onJoin: cubit.markJoinFlow,
                  ),
                ),
              ),
            ],
          );
        }

        final family = state.family;
        if (family == null) {
          return DsScreen(
            slivers: [
              SliverToBoxAdapter(child: DsLargeTitle(title: s.myFamily)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter,
                    24,
                    AppSpacing.gutter,
                    0,
                  ),
                  child: FamilyEmptyState(
                    onCreate: cubit.markCreateFlow,
                    onJoin: cubit.markJoinFlow,
                  ),
                ),
              ),
            ],
          );
        }

        final currentUserId =
            Supabase.instance.client.auth.currentSession?.user.id;

        return ParentFamilyView(
          data: ParentFamilyData(
            inviteBusy: state.isParentInviteCodeLoading,
            parents: [
              for (final parent in family.parents)
                FamilyParentRow(
                  id: parent.userId,
                  name: parent.displayName,
                  subtitle: _parentSubtitle(s, parent),
                  color: AppColors.kidColor(parent.userId),
                  isYou: parent.userId == currentUserId,
                ),
            ],
            children: [
              for (final child in family.children)
                FamilyChildCard(
                  id: child.id,
                  name: child.nickname,
                  age: child.age,
                  color: AppColors.kidColor(child.id),
                  level: child.level,
                  coins: child.coinsBalance,
                  paired: (child.claimedByUserId ?? '').isNotEmpty,
                ),
            ],
          ),
          banner: state.errorMessage == null
              ? null
              : InlineErrorBanner(
                  message: state.errorMessage!,
                  onRetry: state.canRetry
                      ? () => cubit.loadCurrentFamily(refresh: true)
                      : null,
                ),
          onRefresh: () => cubit.loadCurrentFamily(refresh: true),
          onOpenParent: (row) => _openParent(family, row),
          onInviteParent: () => _inviteParent(),
          onOpenChild: (card) => _openChild(card),
          onAddChild: () => _addChild(),
          onOpenSettings: () => _openSettings(),
        );
      },
    );
  }

  String _parentSubtitle(S s, ParentSummaryModel parent) {
    final email = parent.email;
    if (email != null && email.trim().isNotEmpty) {
      return '${_roleLabel(s, parent.role)} · ${email.trim()}';
    }
    return _roleLabel(s, parent.role);
  }

  String _roleLabel(S s, String role) =>
      role.toLowerCase() == 'admin' ? s.roleOwner : s.roleParent;

  Future<void> _openParent(FamilyModel family, FamilyParentRow row) async {
    final s = S.of(context);
    final parent = family.parents
        .where((p) => p.userId == row.id)
        .firstOrNull;
    final cubit = context.read<ParentFamilyCubit>();
    final router = context.router;
    final parentCubit = context.read<ParentCubit>();

    final action = await showParentSheet(
      context,
      parent: row,
      role: _roleLabel(s, parent?.role ?? 'parent'),
      since: parent?.joinedAt == null
          ? s.notRecorded
          : DateFormat.yMMM(
              Localizations.localeOf(context).toLanguageTag(),
            ).format(parent!.joinedAt!),
      canRemove: !row.isYou,
      onCreateCode: () async {
        final invite = await cubit.createParentInviteCode();
        if (invite == null && mounted) {
          final message = cubit.state.errorMessage;
          if (message != null && message.isNotEmpty) {
            AppSnackBar.error(context, message);
          }
        }
        return invite?.inviteCode;
      },
    );

    if (action == FamilySheetAction.removeParent) {
      await _removeParent(cubit, row);
      return;
    }

    if (action != FamilySheetAction.editProfile) return;
    final updated = await router.push<bool>(const NamedRoute('editProfile'));
    if (updated == true && mounted) {
      parentCubit.loadProfile();
      cubit.loadCurrentFamily(refresh: true);
    }
  }

  Future<void> _removeParent(
    ParentFamilyCubit cubit,
    FamilyParentRow row,
  ) async {
    final confirmed = await showDsSheet<bool>(
      context: context,
      builder: (context) {
        final s = S.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.removeParentConfirmTitle, style: AppText.title3),
            const SizedBox(height: 8),
            Text(s.removeParentConfirmBody, style: AppText.bodyRegular),
            const SizedBox(height: 22),
            DsPrimaryButton(
              label: s.removeParent,
              background: AppColors.danger,
              shadow: const [],
              onTap: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 9),
            DsPrimaryButton.secondary(
              label: s.cancel,
              onTap: () => Navigator.of(context).pop(false),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    final failure = await cubit.removeParent(row.id);
    if (!mounted) return;
    if (failure != null) {
      AppSnackBar.error(context, failure.message);
      return;
    }
    cubit.loadCurrentFamily(refresh: true);
  }

  Future<void> _inviteParent() async {
    final cubit = context.read<ParentFamilyCubit>();
    final invite = await cubit.createParentInviteCode();
    if (!mounted) return;
    if (invite == null) {
      final message = cubit.state.errorMessage;
      if (message != null && message.isNotEmpty) {
        AppSnackBar.error(context, message);
      }
      return;
    }
    await showDsSheet<void>(
      context: context,
      builder: (context) {
        final s = S.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.inviteAParent, style: AppText.title3),
            const SizedBox(height: 8),
            Text(s.inviteAParentBody, style: AppText.bodyRegular),
            const SizedBox(height: 18),
            DsCodePanel(
              caption: s.inviteCodeValid,
              code: invite.inviteCode,
            ),
            const SizedBox(height: 18),
            DsPrimaryButton(
              label: s.doneAction,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openChild(FamilyChildCard card) async {
    final cubit = context.read<ParentFamilyCubit>();
    final navigator = Navigator.of(context);

    final action = await showChildSheet(
      context,
      child: card,
      onCreateCode: () async {
        final invite = await cubit.createChildInviteCode(card.id);
        if (invite == null && mounted) {
          final message = cubit.state.errorMessage;
          if (message != null && message.isNotEmpty) {
            AppSnackBar.error(context, message);
          }
        }
        return invite?.inviteCode;
      },
    );

    if (action != FamilySheetAction.editChild) return;
    final child = cubit.state.family?.children
        .where((c) => c.id == card.id)
        .firstOrNull;
    if (child == null) return;
    final updated = await navigator.push<bool>(
      MaterialPageRoute(builder: (_) => EditChildPage(child: child)),
    );
    if (updated == true && mounted) {
      cubit.loadCurrentFamily(refresh: true);
    }
  }

  Future<void> _addChild() async {
    final cubit = context.read<ParentFamilyCubit>();
    final added = await context.router.push<bool>(const NamedRoute('addChild'));
    if (added == true && mounted) {
      await cubit.loadCurrentFamily(refresh: true);
    }
  }

  Future<void> _openSettings() async {
    final cubit = context.read<ParentFamilyCubit>();
    final parentCubit = context.read<ParentCubit>();
    final changed = await context.router.push<bool>(
      const NamedRoute('parentSettings'),
    );
    if (changed == true && mounted) {
      parentCubit.loadProfile();
      cubit.loadCurrentFamily(refresh: true);
    }
  }
}

class _FamilySkeleton extends StatelessWidget {
  const _FamilySkeleton();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return DsScreen(
      animateEntrance: false,
      slivers: [
        SliverToBoxAdapter(child: DsLargeTitle(title: s.myFamily)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              28,
              AppSpacing.gutter,
              0,
            ),
            child: Column(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  Container(
                    height: i == 0 ? 180 : 128,
                    decoration: BoxDecoration(
                      color: AppColors.fillPressed,
                      borderRadius: BorderRadius.circular(AppRadius.group),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
