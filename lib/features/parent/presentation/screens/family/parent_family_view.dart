import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';

class FamilyParentRow {
  const FamilyParentRow({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.color,
    this.avatarUrl,
    this.isYou = false,
    this.isPending = false,
  });

  final String id;
  final String name;
  final String subtitle;
  final Color color;
  final String? avatarUrl;
  final bool isYou;
  final bool isPending;
}

class FamilyChildCard {
  const FamilyChildCard({
    required this.id,
    required this.name,
    required this.age,
    required this.color,
    required this.level,
    required this.coins,
    required this.paired,
  });

  final String id;
  final String name;
  final int age;
  final Color color;
  final int level;
  final int coins;
  final bool paired;

  String get displayName => age > 0 ? '$name, $age' : name;

  String status(S s) => paired ? s.paired : s.notPairedYet;
}

class ParentFamilyData {
  const ParentFamilyData({
    required this.parents,
    required this.children,
    this.inviteBusy = false,
  });

  final List<FamilyParentRow> parents;
  final List<FamilyChildCard> children;
  final bool inviteBusy;
}

/// Parent · My family: the parents card, the children cards, then the account
/// card. Same order and spacing as the artboard.
class ParentFamilyView extends StatelessWidget {
  const ParentFamilyView({
    super.key,
    required this.data,
    required this.onOpenParent,
    required this.onInviteParent,
    required this.onOpenChild,
    required this.onAddChild,
    required this.onOpenSettings,
    this.onRefresh,
    this.banner,
  });

  final ParentFamilyData data;
  final ValueChanged<FamilyParentRow> onOpenParent;
  final VoidCallback onInviteParent;
  final ValueChanged<FamilyChildCard> onOpenChild;
  final VoidCallback onAddChild;
  final VoidCallback onOpenSettings;
  final Future<void> Function()? onRefresh;

  /// Inline error banner, shown under the children when a refresh failed.
  final Widget? banner;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return DsScreen(
      onRefresh: onRefresh,
      slivers: [
        SliverToBoxAdapter(child: DsLargeTitle(title: s.myFamily)),
        SliverToBoxAdapter(child: DsOverline(s.parents, top: 22)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DsGroup(
                  children: [
                    for (final parent in data.parents)
                      DsRow(
                        onTap: () => onOpenParent(parent),
                        title: parent.isYou
                            ? s.youSuffix(parent.name)
                            : parent.name,
                        subtitle: parent.subtitle,
                        subtitleStyle: AppText.metaSm,
                        leading: DsInitialAvatar(
                          name: parent.name,
                          color: parent.color,
                          imageUrl: parent.avatarUrl,
                          size: 38,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (parent.isPending) ...[
                              // The chevron keeps its width; the pill is what
                              // gives if the label runs long.
                              Flexible(child: DsPill.pending(label: s.invited)),
                              const SizedBox(width: 4),
                            ],
                            AppIcons.chevronRight(),
                          ],
                        ),
                      ),
                    _InviteParentRow(
                      onTap: onInviteParent,
                      busy: data.inviteBusy,
                    ),
                  ],
                ),
                DsFootnote(s.bothParentsSee, top: 12),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: DsOverline(
            s.yourChildren,
            trailing: _AddPill(onTap: onAddChild),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: data.children.isEmpty
                ? _NoChildren(onTap: onAddChild)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final child in data.children) ...[
                        _ChildCard(
                          child: child,
                          onTap: () => onOpenChild(child),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
          ),
        ),
        if (banner != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                12,
                AppSpacing.gutter,
                0,
              ),
              child: banner!,
            ),
          ),
        SliverToBoxAdapter(child: DsOverline(s.yourAccount, top: 30)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: DsGroup(
              shadow: AppShadows.flat,
              children: [
                DsRow(
                  onTap: onOpenSettings,
                  title: s.settings,
                  leading: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.fill,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: AppIcons.gear(size: 18),
                  ),
                  trailing: AppIcons.chevronRight(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InviteParentRow extends StatelessWidget {
  const _InviteParentRow({required this.onTap, required this.busy});

  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Pressable.row(
      onTap: busy ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primaryTint,
                shape: BoxShape.circle,
              ),
              child: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : AppIcons.plus(size: 16),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                S.of(context).inviteAParent,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.rowTitleStrong.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPill extends StatelessWidget {
  const _AddPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.95,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryTint,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcons.plus(size: 12),
            const SizedBox(width: 5),
            Text(
              S.of(context).addShort,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.125,
                height: 1.2,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.child, required this.onTap});

  final FamilyChildCard child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DsCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              DsInitialAvatar(name: child.name, color: child.color, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(child.displayName, style: AppText.cardTitle),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        DsStatusDot(online: child.paired),
                        const SizedBox(width: 6),
                        Text(child.status(S.of(context)), style: AppText.meta),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AppIcons.chevronRight(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatTile(
                value: '${child.level}',
                label: S.of(context).levelShort,
              ),
              const SizedBox(width: 8),
              _StatTile(
                value: '${child.coins}',
                label: S.of(context).statCoins,
                valueColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    this.valueColor = AppColors.ink,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.fillAlt,
          borderRadius: BorderRadius.circular(AppRadius.tile),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.192,
                height: 1.2,
                color: valueColor,
                fontFeatures: AppText.tabular,
              ),
            ),
            const SizedBox(height: 1),
            Text(label, style: AppText.caption.copyWith(fontSize: 11.5)),
          ],
        ),
      ),
    );
  }
}

class _NoChildren extends StatelessWidget {
  const _NoChildren({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DsCard(
      shadow: AppShadows.flat,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      child: Column(
        children: [
          Text(S.of(context).noChildrenYet, style: AppText.rowTitleStrong),
          const SizedBox(height: 4),
          Text(
            S.of(context).noChildrenYetBody,
            style: AppText.meta,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: DsPrimaryButton(
              label: S.of(context).addAChild,
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}
