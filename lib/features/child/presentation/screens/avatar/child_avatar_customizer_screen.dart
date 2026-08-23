import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/profile_cubit.dart';
import 'package:safini/features/child/presentation/cubit/profile_model.dart';
import 'package:safini/features/child/presentation/cubit/profile_state.dart';
import 'package:safini/features/common/auth/presentation/cubit/child_claim_cubit.dart';
import 'package:safini/features/child/presentation/widgets/utils/avatar_face_stickers.dart';

/// The Avatar artboard: the stage on top, the face grid, then the extras that
/// cost coins.
///
/// The artboard's "Background" swatch row is left out - the avatar's backdrop
/// is derived from the child's own colour and there is no field to persist a
/// separate choice.
class ChildAvatarCustomizerScreen extends StatelessWidget {
  const ChildAvatarCustomizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale?>(
      builder: (context, locale) => Localizations.override(
        context: context,
        locale: locale,
        child: BlocProvider(
          create: (_) => getIt<AvatarCubit>(),
          child: const _AvatarScreen(),
        ),
      ),
    );
  }
}

class _AvatarScreen extends StatelessWidget {
  const _AvatarScreen();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocBuilder<AvatarCubit, AvatarState>(
      builder: (context, state) {
        final cubit = context.read<AvatarCubit>();
        final coins = context.watch<CoinsCubit>().state;
        final extras = state.avatarItems
            .where((item) => item.category != AvatarCategory.face)
            .toList();

        return Scaffold(
          backgroundColor: AppColors.bgChild,
          body: Column(
            children: [
              DsNavBar.child(
                title: s.yourAvatar,
                backLabel: s.tabMe,
                actionLabel: s.save,
                onAction: () => context.router.maybePop(true),
              ),
              Expanded(
                child: DsScreenEntrance(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      bottom: 40 + MediaQuery.viewPaddingOf(context).bottom,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.gutter,
                          14,
                          AppSpacing.gutter,
                          0,
                        ),
                        child: _Stage(state: state),
                      ),
                      DsOverline(s.faceSection, top: 26),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.gutter,
                        ),
                        child: _FaceGrid(
                          selected: state.selectedFaceEmoji,
                          onSelect: cubit.selectFace,
                        ),
                      ),
                      if (extras.isNotEmpty) ...[
                        DsOverline(
                          s.extrasSection,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const DsCoinToken(size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '$coins',
                                style: AppText.metaSm.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ).nums,
                              ),
                            ],
                          ),
                          top: 26,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.gutter,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DsGroup(
                                shadow: AppShadows.flat,
                                children: [
                                  for (final item in extras)
                                    _ExtraRow(
                                      item: item,
                                      coins: coins,
                                      onTap: () => cubit.equipItem(item.id),
                                    ),
                                ],
                              ),
                              DsFootnote(s.extrasFootnote),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({required this.state});

  final AvatarState state;

  @override
  Widget build(BuildContext context) {
    // This route is pushed on the root router, so ProfileCubit is not in
    // scope; the claimed child carries the name and level.
    final child = context.watch<ChildClaimCubit>().state.child;
    final worn = state.avatarItems
        .where((item) => item.isEquipped && item.category != AvatarCategory.face)
        .firstOrNull;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: AppColors.avatarPalette[1],
        borderRadius: BorderRadius.circular(AppRadius.hero),
        boxShadow: AppShadows.deep,
      ),
      child: Column(
        children: [
          SizedBox(
            width: 132,
            height: 132,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0x29FFFFFF),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      state.selectedFaceEmoji,
                      style: const TextStyle(fontSize: 66, height: 1.15),
                    ),
                  ),
                ),
                if (worn != null)
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x80000000),
                            offset: Offset(0, 6),
                            blurRadius: 16,
                            spreadRadius: -8,
                          ),
                        ],
                      ),
                      child: Text(
                        worn.emoji,
                        style: const TextStyle(fontSize: 24, height: 1.15),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            child?.nickname ?? '',
            style: AppText.section.copyWith(color: AppColors.textOnPrimary),
          ),
          const SizedBox(height: 3),
          Text(
            S.of(context).levelValue(child?.level ?? state.level),
            style: AppText.meta.copyWith(color: const Color(0xA8FFFFFF)),
          ),
        ],
      ),
    );
  }
}

class _FaceGrid extends StatelessWidget {
  const _FaceGrid({required this.selected, required this.onSelect});

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return DsCard(
      padding: const EdgeInsets.all(16),
      shadow: AppShadows.flat,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: 62,
        ),
        itemCount: avatarFaceStickers.length,
        itemBuilder: (context, index) {
          final emoji = avatarFaceStickers[index];
          final isSelected = emoji == selected;

          return Pressable(
            onTap: () => onSelect(emoji),
            scale: 0.93,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryTint : AppColors.fillAlt,
                borderRadius: BorderRadius.circular(AppRadius.control),
                border: isSelected
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 30, height: 1.15),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// `AvatarCategoryX.label` is upper-case for the old tab strip; the row wants
/// sentence case.
String _titleFor(S s, AvatarCategory category) => switch (category) {
  AvatarCategory.outfits => s.extraOutfit,
  AvatarCategory.hair => s.extraHair,
  AvatarCategory.back => s.extraBackpack,
  AvatarCategory.face => s.faceSection,
};

class _ExtraRow extends StatelessWidget {
  const _ExtraRow({
    required this.item,
    required this.coins,
    required this.onTap,
  });

  final AvatarGridItem item;
  final int coins;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final cost = item.cost;
    final owned = cost == null;
    final affordable = owned || coins >= cost;

    return DsRow(
      onTap: affordable && !item.isLocked ? onTap : null,
      title: _titleFor(s, item.category),
      titleColor: affordable ? AppColors.ink : AppColors.textMuted,
      subtitle: item.isEquipped
          ? s.wornLabel
          : owned
          ? s.yoursLabel
          : affordable
          ? s.unlockOnceKeepForever
          : s.coinsToGoShort(cost - coins),
      subtitleStyle: AppText.caption,
      leading: DsEmojiTile(
        emoji: item.emoji,
        size: 40,
        radius: AppRadius.md,
        background: AppColors.fillAlt,
        fontSize: 20,
        opacity: affordable ? 1 : 0.4,
      ),
      trailing: item.isEquipped
          ? DsPill.paid(label: s.wornLabel, height: 24, fontSize: 13)
          : owned
          ? DsPill.tint(label: s.wearLabel, height: 24)
          : affordable
          ? DsPill.tint(label: '$cost', height: 24)
          : DsPill.muted(label: s.lockedLabel, height: 24, fontSize: 13),
    );
  }
}
