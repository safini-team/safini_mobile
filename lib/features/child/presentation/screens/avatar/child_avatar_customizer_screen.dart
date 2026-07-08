import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/child/presentation/cubit/profile_cubit.dart';
import 'package:safini/features/child/presentation/cubit/profile_state.dart';
import 'package:safini/features/child/presentation/widgets/utils/store_coin_badge.dart';
import 'package:safini/core/translation/generated/l10n.dart';

/// Face stickers the child can pick from (free — no coins required).
const List<String> _faceStickers = [
  '😀', '😁', '😂', '🤣', '😊', '😇', '🙂', '🙃',
  '😉', '😌', '😍', '🥰', '😘', '😋', '😛', '😜',
  '🤪', '🤨', '🧐', '🤓', '😎', '🥳', '🤩', '😏',
  '😴', '🤤', '😪', '😷', '🤒', '🤕', '🤠', '😈',
  '👻', '🤖', '👽', '🎃', '😺', '😸', '🙀', '😻',
  '🦸', '🦹', '🧚', '🧙', '🧛', '🦄', '🐱', '🐶',
];

class ChildAvatarCustomizerScreen extends StatelessWidget {
  const ChildAvatarCustomizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return Localizations.override(
          context: context,
          locale: locale,
          child: BlocProvider(
            create: (ctx) => getIt<AvatarCubit>(),
            child: const _AvatarCustomizerView(),
          ),
        );
      },
    );
  }
}

// ─── Root View ────────────────────────────────────────────────────────────────

class _AvatarCustomizerView extends StatelessWidget {
  const _AvatarCustomizerView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.primary,
      body: Column(
        children: [
          _AvatarHeader(),
          Expanded(child: _AvatarBody()),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _AvatarHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<AvatarCubit, AvatarState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colorScheme.primary.withValues(alpha: 0.9),
                context.colorScheme.primary,
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.router.maybePop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            s.myAvatar,
                            style: context.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const StoreCoinBadge(),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Avatar preview card
                _AvatarPreview(
                  faceEmoji: state.selectedFaceEmoji,
                  level: state.level,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  final String faceEmoji;
  final int level;

  const _AvatarPreview({
    required this.faceEmoji,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Hero(
          tag: 'child-avatar-hero',
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Center(
              child: Text(
                faceEmoji,
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFF5A623),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            level > 0 ? 'Level $level' : 'Level',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── White Body ───────────────────────────────────────────────────────────────

class _AvatarBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: BlocBuilder<AvatarCubit, AvatarState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Text(
                      'FACE',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: context.colorScheme.primary,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Face sticker grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _faceStickers.length,
                  itemBuilder: (context, index) {
                    final emoji = _faceStickers[index];
                    return _FaceStickerCard(
                      emoji: emoji,
                      selected: state.selectedFaceEmoji == emoji,
                      onTap: () =>
                          context.read<AvatarCubit>().selectFace(emoji),
                    );
                  },
                ),
              ),
              // Save button
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.router.maybePop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      s.saveMyLook,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Face Sticker Card ────────────────────────────────────────────────────────

class _FaceStickerCard extends StatelessWidget {
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _FaceStickerCard({
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected
              ? context.colorScheme.primary.withValues(alpha: 0.15)
              : const Color(0xFFF6F3FB),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected
                ? context.colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 28)),
        ),
      ),
    );
  }
}
