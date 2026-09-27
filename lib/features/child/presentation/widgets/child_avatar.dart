import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/utils/widgets/ds/ds_avatar.dart';

/// The child's avatar: their face sticker on a colour disc, the equipped
/// accessory in a white bubble at the corner, and optionally their level on a
/// small pill under the chin. Drawn at 88pt on Me and smaller on Today; every
/// part scales from [size].
class ChildAvatar extends StatelessWidget {
  const ChildAvatar({
    super.key,
    required this.faceEmoji,
    required this.color,
    this.accessoryEmoji,
    this.level,
    this.size = 88,
  });

  final String faceEmoji;
  final Color color;
  final String? accessoryEmoji;

  /// Shown as "★ 4" under the disc when set.
  final int? level;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DsChildAvatar(
              faceEmoji: faceEmoji,
              accessoryEmoji: accessoryEmoji,
              color: color,
              size: size,
              showAccessory: true,
              accessoryOnTop: level != null,
            ),
          ),
          if (level != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: -7,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x330C231C),
                        offset: Offset(0, 1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    '★ $level',
                    style: AppText.micro
                        .copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          color: AppColors.primary,
                        )
                        .nums,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
