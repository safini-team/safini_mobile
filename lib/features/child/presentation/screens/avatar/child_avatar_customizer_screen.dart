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
import 'package:safini/features/child/presentation/widgets/safini_avatar.dart';
import 'package:safini/features/child/presentation/widgets/utils/avatar_character_catalog.dart';
import 'package:safini/features/common/auth/presentation/cubit/child_claim_cubit.dart';

/// The Avatar artboard: large preview on top, then a tab row
/// (Characters / Head / Accessories / Vehicles), then the item grid.
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

        final visibleTabs = [
          AvatarCategory.character,
          AvatarCategory.head,
          AvatarCategory.accessory,
          AvatarCategory.vehicle,
        ];

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
                      // Preview stage
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.gutter,
                          14,
                          AppSpacing.gutter,
                          0,
                        ),
                        child: _Stage(state: state),
                      ),

                      // Tab row
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.gutter,
                        ),
                        child: _TabRow(
                          tabs: visibleTabs,
                          selected: state.selectedCategory,
                          onSelect: cubit.selectCategory,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Content for selected tab
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.gutter,
                        ),
                        child: state.selectedCategory == AvatarCategory.character
                            ? _CharacterGrid(
                                selectedId: state.characterId,
                                ownedCharacterIds: state.ownedCharacterIds,
                                coins: coins,
                                onSelect: cubit.selectCharacter,
                                onPurchase: cubit.purchaseCharacter,
                              )
                            : const _ComingSoonSection(),
                      ),
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

// ─── Preview Stage ────────────────────────────────────────────────────────────

class _Stage extends StatelessWidget {
  const _Stage({required this.state});

  final AvatarState state;

  @override
  Widget build(BuildContext context) {
    final child = context.watch<ChildClaimCubit>().state.child;
    final charId = state.characterId ?? defaultCharacterId;

    final headItem = state.avatarItems
        .where((i) => i.category == AvatarCategory.head && i.isEquipped)
        .firstOrNull;
    final accessoryItem = state.avatarItems
        .where((i) => i.category == AvatarCategory.accessory && i.isEquipped)
        .firstOrNull;
    final vehicleItem = state.avatarItems
        .where((i) => i.category == AvatarCategory.vehicle && i.isEquipped)
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
          SafiniAvatar(
            characterId: charId,
            headItemId: headItem?.assetKey ?? headItem?.id,
            accessoryItemId: accessoryItem?.assetKey ?? accessoryItem?.id,
            vehicleItemId: vehicleItem?.assetKey ?? vehicleItem?.id,
            size: 132,
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

// ─── Tab Row ─────────────────────────────────────────────────────────────────

class _TabRow extends StatelessWidget {
  const _TabRow({
    required this.tabs,
    required this.selected,
    required this.onSelect,
  });

  final List<AvatarCategory> tabs;
  final AvatarCategory selected;
  final ValueChanged<AvatarCategory> onSelect;

  String _label(S s, AvatarCategory cat) => switch (cat) {
    AvatarCategory.character => s.avatarTabCharacters,
    AvatarCategory.head => s.avatarTabHead,
    AvatarCategory.accessory => s.avatarTabAccessories,
    AvatarCategory.vehicle => s.avatarTabVehicles,
    _ => cat.label,
  };

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final tab in tabs) ...[
            _TabChip(
              label: _label(s, tab),
              selected: selected == tab,
              onTap: () => onSelect(tab),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.94,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.fill,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppText.chip.copyWith(
            color: selected ? AppColors.textOnPrimary : AppColors.ink,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── Character Grid ───────────────────────────────────────────────────────────

class _CharacterGrid extends StatelessWidget {
  const _CharacterGrid({
    required this.selectedId,
    required this.ownedCharacterIds,
    required this.coins,
    required this.onSelect,
    required this.onPurchase,
  });

  final String? selectedId;
  final Set<String> ownedCharacterIds;
  final int coins;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onPurchase;

  @override
  Widget build(BuildContext context) {
    final effectiveId = selectedId ?? defaultCharacterId;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 108,
      ),
      itemCount: safiniiCharacters.length,
      itemBuilder: (context, index) {
        final character = safiniiCharacters[index];
        final isSelected = character.id == effectiveId;
        final cost = characterPrices[character.id];
        final owned = cost == null || ownedCharacterIds.contains(character.id);
        final effectiveCost = cost ?? 0;
        final affordable = owned || coins >= effectiveCost;

        return Pressable(
          onTap: owned
              ? () => onSelect(character.id)
              : affordable
              ? () => onPurchase(character.id)
              : null,
          scale: 0.93,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryTint
                      : owned
                      ? AppColors.fillAlt
                      : AppColors.fillAlt.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppRadius.control),
                  border: isSelected
                      ? Border.all(color: AppColors.primary, width: 2.5)
                      : null,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.control - 2),
                      child: Opacity(
                        opacity: owned ? 1.0 : 0.45,
                        child: SafiniAvatar(
                          characterId: character.id,
                          size: 80,
                          showPlaceholderRing: false,
                        ),
                      ),
                    ),
                    if (!owned)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppRadius.control - 2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.lock_rounded,
                              color: Colors.white,
                              size: 22,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (cost != null && !owned) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const DsCoinToken(size: 10),
                    const SizedBox(width: 2),
                    Text(
                      '$cost',
                      style: AppText.micro.copyWith(
                        fontWeight: FontWeight.w700,
                        color: affordable ? AppColors.ink : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ─── Coming Soon ──────────────────────────────────────────────────────────────

class _ComingSoonSection extends StatelessWidget {
  const _ComingSoonSection();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(AppRadius.feature),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🚧', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            s.comingSoon,
            style: AppText.section.copyWith(color: AppColors.ink),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            s.comingSoonSubtitle,
            style: AppText.meta.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

