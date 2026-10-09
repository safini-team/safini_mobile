import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/utils/child_avatar_look.dart';
import 'package:safini/features/child/presentation/widgets/safini_avatar.dart';

/// Round initial badge - the design's stand-in for a photo everywhere a person
/// appears. White bold initial on the child's own colour.
class DsInitialAvatar extends StatelessWidget {
  const DsInitialAvatar({
    super.key,
    required this.name,
    this.color,
    this.imageUrl,
    this.size = 38,
    this.fontSize,
    this.label,
  });

  final String name;
  final Color? color;
  final String? imageUrl;
  final double size;
  final double? fontSize;

  /// Rendered verbatim instead of the derived initial - the "Everyone" entry
  /// in the kid picker uses a middot.
  final String? label;

  static String initialOf(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color ?? AppColors.kidColor(name),
        shape: BoxShape.circle,
      ),
      child: Text(
        label ?? initialOf(name),
        style: TextStyle(
          fontSize: fontSize ?? size * 0.395,
          fontWeight: FontWeight.w700,
          color: AppColors.textOnPrimary,
          height: 1,
        ),
      ),
    );

    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) return fallback;

    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
            wasSynchronouslyLoaded || frame != null ? child : fallback,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }
}

/// The child's avatar. Renders an illustrated [SafiniAvatar] when a
/// [characterId] is set; falls back to the legacy emoji disc otherwise.
class DsChildAvatar extends StatelessWidget {
  const DsChildAvatar({
    super.key,
    required this.color,
    this.faceEmoji,
    this.accessoryEmoji,
    this.characterId,
    this.headItemId,
    this.accessoryItemId,
    this.vehicleItemId,
    this.size = 38,
    this.showAccessory,
    this.accessoryOnTop = false,
  });

  factory DsChildAvatar.fromLook({
    Key? key,
    required ChildAvatarLook look,
    required Color color,
    double size = 38,
    bool? showAccessory,
    bool accessoryOnTop = false,
  }) {
    return DsChildAvatar(
      key: key,
      color: color,
      faceEmoji: look.faceEmoji,
      accessoryEmoji: look.accessoryEmoji,
      characterId: look.characterId,
      headItemId: look.headItemId,
      accessoryItemId: look.accessoryItemId,
      vehicleItemId: look.vehicleItemId,
      size: size,
      showAccessory: showAccessory,
      accessoryOnTop: accessoryOnTop,
    );
  }

  final Color color;
  final String? faceEmoji;
  final String? accessoryEmoji;

  // v2 illustrated avatar fields
  final String? characterId;
  final String? headItemId;
  final String? accessoryItemId;
  final String? vehicleItemId;

  final double size;

  /// Defaults to on at 24px and above, so the kid picker still shows extras.
  final bool? showAccessory;

  /// Child Me/Today put a level pill under the chin, so the extra moves up.
  final bool accessoryOnTop;

  @override
  Widget build(BuildContext context) {
    // Use the illustrated renderer when a character has been selected.
    if (characterId != null && characterId!.isNotEmpty) {
      return SafiniAvatar(
        characterId: characterId!,
        headItemId: headItemId,
        accessoryItemId: accessoryItemId,
        vehicleItemId: vehicleItemId,
        size: size,
      );
    }
    final k = size / 88;
    final face = (faceEmoji ?? '').trim().isEmpty
        ? ChildAvatarLook.defaultFaceEmoji
        : faceEmoji!.trim();
    final extra = accessoryEmoji?.trim();
    final drawExtra =
        extra != null &&
        extra.isNotEmpty &&
        (showAccessory ?? size >= 24);
    final bubble = 32 * k;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Text(
                face,
                style: TextStyle(fontSize: 42 * k, height: 1.15),
              ),
            ),
          ),
          if (drawExtra)
            Positioned(
              right: -2 * k,
              top: accessoryOnTop ? -2 * k : null,
              bottom: accessoryOnTop ? null : -2 * k,
              child: Container(
                width: bubble,
                height: bubble,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x4D0C231C),
                      offset: Offset(0, 2),
                      blurRadius: 8,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Text(
                  extra,
                  style: TextStyle(fontSize: 17 * k, height: 1.15),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Initials for "Everyone"; otherwise the child's in-app face. Never a photo.
class DsKidFace extends StatelessWidget {
  const DsKidFace({
    super.key,
    required this.color,
    required this.name,
    this.initial,
    this.avatar,
    this.size = 24,
    this.fontSize,
  });

  final Color color;
  final String name;
  final String? initial;
  final ChildAvatarLook? avatar;
  final double size;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    if (initial != null) {
      return DsInitialAvatar(
        name: name,
        label: initial,
        color: color,
        size: size,
        fontSize: fontSize,
      );
    }
    return DsChildAvatar.fromLook(
      look: avatar ?? const ChildAvatarLook(),
      color: color,
      size: size,
    );
  }
}

/// The rounded emoji tile that leads a task or app row:
/// `34-46px;border-radius:9-16px;background:#EFEBE3 | #DCEDE5`.
class DsEmojiTile extends StatelessWidget {
  const DsEmojiTile({
    super.key,
    required this.emoji,
    this.size = 34,
    this.radius = AppRadius.sm,
    this.background = AppColors.fill,
    this.fontSize,
    this.opacity = 1,
  });

  final String emoji;
  final double size;
  final double radius;
  final Color background;
  final double? fontSize;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Text(
          emoji,
          style: TextStyle(fontSize: fontSize ?? size * 0.5, height: 1.15),
        ),
      ),
    );
  }
}

/// The 6-7px presence dot next to a child's status line.
class DsStatusDot extends StatelessWidget {
  const DsStatusDot({
    super.key,
    required this.online,
    this.size = 6,
    this.color,
  });

  const DsStatusDot.tinted({super.key, required this.color, this.size = 7})
    : online = false;

  final bool online;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? (online ? AppColors.success : AppColors.chevron),
        shape: BoxShape.circle,
      ),
    );
  }
}
