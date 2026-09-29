import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/child/friends/child_friends_view.dart';
import 'package:safini/features/child/friends/friend.dart';
import 'package:safini/features/child/friends/friends_cubit.dart';

class ChildFriendsScreen extends StatelessWidget {
  const ChildFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale?>(
      builder: (context, locale) => Localizations.override(
        context: context,
        locale: locale,
        child: BlocProvider(
          create: (_) => getIt<FriendsCubit>()..load(),
          child: const _FriendsScreen(),
        ),
      ),
    );
  }
}

class _FriendsScreen extends StatelessWidget {
  const _FriendsScreen();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgChild,
      body: Column(
        children: [
          DsNavBar.child(title: s.friends, backLabel: s.tabMe),
          Expanded(
            child: BlocBuilder<FriendsCubit, FriendsState>(
              builder: (context, state) {
                if (state.loading && state.friends.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final cubit = context.read<FriendsCubit>();
                return ChildFriendsView(
                  publicId: state.publicId,
                  friends: [
                    for (final friend in state.visible)
                      FriendCardData.fromSummary(friend),
                  ],
                  sortByLevel: state.sortByLevel,
                  error: state.loadFailed ? s.friendsError : null,
                  onRefresh: cubit.load,
                  onToggleSort: cubit.toggleSort,
                  onCopyId: () => _copy(context, state.publicId, s),
                  onAdd: () => _add(context, s),
                  onRemove: (friend) => _remove(context, friend, s),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context, String? publicId, S s) async {
    final id = publicId?.trim();
    if (id == null || id.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: id));
    if (!context.mounted) return;
    AppSnackBar.success(context, s.friendsCopied);
  }

  Future<void> _add(BuildContext context, S s) async {
    final cubit = context.read<FriendsCubit>();
    final controller = TextEditingController();
    final code = await showDsSheet<String>(
      context: context,
      builder: (sheetContext) => _AddFriendSheet(controller: controller, s: s),
    );
    controller.dispose();
    if (code == null || !context.mounted) return;
    final error = await cubit.add(code);
    if (!context.mounted || error == null) return;
    AppSnackBar.error(context, _message(s, error));
  }

  Future<void> _remove(BuildContext context, FriendCardData friend, S s) async {
    final cubit = context.read<FriendsCubit>();
    final confirmed = await showDsSheet<bool>(
      context: context,
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(s.friendsRemoveTitle(friend.nickname), style: AppText.title3),
          const SizedBox(height: 8),
          Text(s.friendsRemoveBody, style: AppText.bodyRegular),
          const SizedBox(height: 22),
          DsPrimaryButton(
            label: s.friendsRemove,
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
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final error = await cubit.remove(friend.childId);
    if (!context.mounted || error == null) return;
    AppSnackBar.error(context, _message(s, error));
  }

  String _message(S s, FriendsError error) {
    return switch (error) {
      FriendsError.notFound => s.friendsNotFound,
      FriendsError.alreadyFriends => s.friendsAlready,
      FriendsError.ownId => s.friendsYourself,
      FriendsError.invalid => s.friendsInvalid,
      FriendsError.unavailable => s.friendsError,
    };
  }
}

class _AddFriendSheet extends StatefulWidget {
  const _AddFriendSheet({required this.controller, required this.s});

  final TextEditingController controller;
  final S s;

  @override
  State<_AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends State<_AddFriendSheet> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final ready = widget.controller.text.length == 6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.s.friendsAddTitle, style: AppText.title3),
        const SizedBox(height: 8),
        Text(widget.s.friendsAddHint, style: AppText.bodyRegular),
        const SizedBox(height: 18),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: DsCodeField(
            controller: widget.controller,
            length: 6,
            digits: true,
          ),
        ),
        const SizedBox(height: AppSpacing.gutter),
        DsPrimaryButton(
          label: widget.s.friendsAdd,
          onTap: ready
              ? () => Navigator.of(context).pop(widget.controller.text)
              : null,
        ),
      ],
    );
  }
}
