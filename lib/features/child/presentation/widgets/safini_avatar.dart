import 'package:flutter/material.dart';
import 'package:safini/features/child/presentation/widgets/utils/avatar_character_catalog.dart';

/// Layer ordering (bottom → top):
///   1. base character image
///   2. vehicle (behind character, e.g. car, board)
///   3. accessory (in front, e.g. watch, glasses)
///   4. head cosmetic (hat, crown, etc.)
///
/// Each layer renders `assets/avatar/cosmetics/<slot>/<itemId>.png`.
/// When an asset file is not yet present, the layer is skipped silently.
class SafiniAvatar extends StatelessWidget {
  const SafiniAvatar({
    super.key,
    required this.characterId,
    this.headItemId,
    this.accessoryItemId,
    this.vehicleItemId,
    this.size = 88,
    this.showPlaceholderRing = false,
  });

  final String characterId;
  final String? headItemId;
  final String? accessoryItemId;
  final String? vehicleItemId;
  final double size;

  /// Draws an orange selection ring (used in the character grid).
  final bool showPlaceholderRing;

  @override
  Widget build(BuildContext context) {
    final character = resolvedCharacter(characterId);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Placeholder ring (selection indicator in the character grid)
          if (showPlaceholderRing)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF07830),
                    width: 2.5,
                  ),
                ),
              ),
            ),

          // Vehicle layer (behind character)
          if (vehicleItemId != null)
            Positioned.fill(
              child: _CosmeticLayer(
                slot: 'vehicles',
                itemId: vehicleItemId!,
                size: size,
                alignment: Alignment.bottomCenter,
              ),
            ),

          // Base character
          Positioned.fill(
            child: _CharacterImage(character: character, size: size),
          ),

          // Accessory layer (e.g. glasses, watch — overlaid on character body)
          if (accessoryItemId != null)
            Positioned.fill(
              child: _CosmeticLayer(
                slot: 'accessories',
                itemId: accessoryItemId!,
                size: size,
                alignment: Alignment.center,
              ),
            ),

          // Head layer (hat, crown, etc. — rendered last, on top)
          if (headItemId != null)
            Positioned.fill(
              child: _CosmeticLayer(
                slot: 'head',
                itemId: headItemId!,
                size: size,
                alignment: Alignment.topCenter,
              ),
            ),
        ],
      ),
    );
  }
}

/// Renders a single character image. Falls back to a named placeholder disc
/// when the PNG asset has not yet been added to the bundle.
class _CharacterImage extends StatelessWidget {
  const _CharacterImage({required this.character, required this.size});

  final SafiniCharacter character;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      character.assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stack) => _CharacterPlaceholder(
        character: character,
        size: size,
      ),
    );
  }
}

/// Placeholder shown before individual character illustrations are shipped.
/// Renders the character's color as a tinted disc with a small label.
class _CharacterPlaceholder extends StatelessWidget {
  const _CharacterPlaceholder({
    required this.character,
    required this.size,
  });

  final SafiniCharacter character;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: character.placeholderColor,
        shape: BoxShape.circle,
      ),
      child: Text(
        character.name.characters.first.toUpperCase(),
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

/// One cosmetic layer (head / accessory / vehicle).
/// The image is positioned to fill the avatar square; each slot asset should
/// be pre-cropped to fit that bounding box.
class _CosmeticLayer extends StatelessWidget {
  const _CosmeticLayer({
    required this.slot,
    required this.itemId,
    required this.size,
    required this.alignment,
  });

  final String slot;
  final String itemId;
  final double size;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final path = 'assets/avatar/cosmetics/$slot/$itemId.png';
    return Align(
      alignment: alignment,
      child: Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stack) => const SizedBox.shrink(),
      ),
    );
  }
}

/// Small variant of [SafiniAvatar] used in lists and pickers (32–48 px).
/// No cosmetic layers at very small sizes — just the base character.
class SafiniAvatarCompact extends StatelessWidget {
  const SafiniAvatarCompact({
    super.key,
    required this.characterId,
    this.headItemId,
    this.size = 38,
  });

  final String characterId;
  final String? headItemId;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SafiniAvatar(
      characterId: characterId,
      headItemId: size >= 32 ? headItemId : null,
      size: size,
    );
  }
}
