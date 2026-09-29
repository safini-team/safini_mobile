import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/child/friends/friend.dart';
import 'package:safini/features/child/presentation/widgets/child_avatar.dart';

/// What one row of the friends list draws. Built from [FriendSummary] at the
/// screen, and passed in directly by tests.
class FriendCardData {
  const FriendCardData({
    required this.childId,
    required this.nickname,
    required this.faceEmoji,
    required this.color,
    required this.level,
    required this.tasksDoneToday,
    required this.tasksTotalToday,
    required this.prizesClaimedCount,
    this.accessoryEmoji,
  });

  final String childId;
  final String nickname;
  final String faceEmoji;
  final Color color;
  final String? accessoryEmoji;
  final int level;
  final int tasksDoneToday;
  final int tasksTotalToday;
  final int prizesClaimedCount;

  bool get allTasksDoneToday =>
      tasksTotalToday > 0 && tasksDoneToday == tasksTotalToday;

  factory FriendCardData.fromSummary(FriendSummary friend) {
    return FriendCardData(
      childId: friend.childId,
      nickname: friend.nickname,
      faceEmoji: friend.faceEmoji,
      accessoryEmoji: friend.accessoryEmoji,
      color: AppColors.kidColor(friend.childId),
      level: friend.level,
      tasksDoneToday: friend.tasksDoneToday,
      tasksTotalToday: friend.tasksTotalToday,
      prizesClaimedCount: friend.prizesClaimedCount,
    );
  }
}

class ChildFriendsView extends StatelessWidget {
  const ChildFriendsView({
    super.key,
    required this.publicId,
    required this.friends,
    required this.sortByLevel,
    required this.onAdd,
    required this.onToggleSort,
    required this.onCopyId,
    required this.onRemove,
    this.error,
    this.onRefresh,
  });

  final String? publicId;
  final List<FriendCardData> friends;
  final bool sortByLevel;
  final VoidCallback onAdd;
  final VoidCallback onToggleSort;
  final VoidCallback onCopyId;
  final ValueChanged<FriendCardData> onRemove;
  final String? error;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          8,
          AppSpacing.gutter,
          AppSpacing.tabBarClearance + DsTabBar.extraHeight(context),
        ),
        children: [
          _IdCard(publicId: publicId, onCopy: onCopyId),
          const SizedBox(height: 16),
          DsPrimaryButton(label: s.friendsAdd, onTap: onAdd),
          if (error != null) ...[
            const SizedBox(height: 16),
            Text(error!, textAlign: TextAlign.center, style: AppText.body),
          ],
          const SizedBox(height: 22),
          if (friends.isEmpty && error == null)
            _Empty(title: s.friendsEmptyTitle, body: s.friendsEmptyBody)
          else ...[
            Row(
              children: [
                Expanded(child: Text(s.friends, style: AppText.title5)),
                Pressable(
                  onTap: onToggleSort,
                  child: Text(
                    sortByLevel ? s.friendsSortRecent : s.friendsSortLevel,
                    style: AppText.chip.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < friends.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _FriendCard(
                friend: friends[i],
                onRemove: () => onRemove(friends[i]),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _IdCard extends StatelessWidget {
  const _IdCard({required this.publicId, required this.onCopy});

  final String? publicId;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final id = (publicId == null || publicId!.isEmpty) ? '------' : publicId!;

    return DsCard(
      radius: AppRadius.feature,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
      child: Column(
        children: [
          Text(s.friendsYourId, style: AppText.meta),
          const SizedBox(height: 6),
          Text(
            id,
            style: AppText.title5
                .copyWith(fontSize: 34, letterSpacing: 4, height: 1.1)
                .nums,
          ),
          const SizedBox(height: 6),
          Text(
            s.friendsYourIdHint,
            textAlign: TextAlign.center,
            style: AppText.caption,
          ),
          const SizedBox(height: 12),
          Pressable(
            onTap: publicId == null || publicId!.isEmpty ? null : onCopy,
            child: Text(
              s.friendsCopy,
              style: AppText.chip.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      child: Column(
        children: [
          Text(title, textAlign: TextAlign.center, style: AppText.title5),
          const SizedBox(height: 6),
          Text(body, textAlign: TextAlign.center, style: AppText.body),
        ],
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  const _FriendCard({required this.friend, required this.onRemove});

  final FriendCardData friend;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return DsCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: ChildAvatar(
              faceEmoji: friend.faceEmoji,
              color: friend.color,
              accessoryEmoji: friend.accessoryEmoji,
              size: 64,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.rowTitleLg,
                ),
                const SizedBox(height: 2),
                Text(s.levelValue(friend.level), style: AppText.meta),
                const SizedBox(height: 6),
                Text(
                  s.friendsTasksToday(friend.tasksDoneToday),
                  style: AppText.caption,
                ),
                Text(
                  s.friendsPrizes(friend.prizesClaimedCount),
                  style: AppText.caption,
                ),
                if (friend.allTasksDoneToday) ...[
                  const SizedBox(height: 8),
                  DsPill.tint(label: s.allDoneToday),
                ],
              ],
            ),
          ),
          Pressable(
            onTap: onRemove,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Text(
                s.friendsRemove,
                style: AppText.caption.copyWith(color: AppColors.danger),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
