import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_motion.dart';
import 'package:safini/core/utils/child_avatar_look.dart';
import 'package:safini/core/utils/qa_ids.dart';
import 'package:safini/core/utils/widgets/ds/app_icons.dart';
import 'package:safini/core/utils/widgets/ds/ds_avatar.dart';
import 'package:safini/core/utils/widgets/ds/pressable.dart';

/// One circle in [DsKidStories].
class DsStoryKid {
  const DsStoryKid({
    required this.id,
    required this.name,
    required this.color,
    this.avatar,
    this.hasNews = false,
  });

  final String id;
  final String name;
  final Color color;
  final ChildAvatarLook? avatar;

  /// A small dot: something on this child waits for the parent (reviews,
  /// asks, Fini items).
  final bool hasNews;
}

/// The child selector on Today, Tasks, Limits and Fini (SAF-269): a row of
/// round faces like Instagram stories, "Everyone" first and a dashed "Add"
/// last. The selected circle gets a pine ring.
///
/// Board "1 · Fini tab": 52px circles 18px apart, the ring is a 3px gap in
/// the page colour then 2.5px of `primary`, a 13px/600 label under each.
///
/// [selectedId] null is Everyone. An id that is not in [kids] falls back to
/// Everyone, so a child removed elsewhere never leaves nothing selected.
class DsKidStories extends StatelessWidget {
  const DsKidStories({
    super.key,
    required this.kids,
    required this.selectedId,
    required this.onSelect,
    required this.everyoneLabel,
    required this.addLabel,
    this.onAdd,
    this.everyoneHasNews = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final List<DsStoryKid> kids;
  final String? selectedId;

  /// Null for Everyone.
  final ValueChanged<String?> onSelect;
  final String everyoneLabel;
  final String addLabel;

  /// Hidden when null, e.g. for a parent who cannot add children.
  final VoidCallback? onAdd;
  final bool everyoneHasNews;
  final EdgeInsetsGeometry padding;

  static const double circle = 52;

  @override
  Widget build(BuildContext context) {
    final selected = kids.any((kid) => kid.id == selectedId)
        ? selectedId
        : null;
    return SizedBox(
      height: circle + 8 + 6 + 18,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        clipBehavior: Clip.none,
        children: [
          _Story(
            key: const ValueKey('kid-story-everyone'),
            semanticsId: QaIds.kidEveryone,
            label: everyoneLabel,
            selected: selected == null,
            hasNews: everyoneHasNews,
            onTap: () => onSelect(null),
            face: const _EveryoneFace(),
          ),
          for (final kid in kids)
            _Story(
              key: ValueKey('kid-story-${kid.id}'),
              label: kid.name,
              selected: kid.id == selected,
              hasNews: kid.hasNews,
              onTap: () => onSelect(kid.id),
              face: DsKidFace(
                name: kid.name,
                avatar: kid.avatar,
                color: kid.color,
                size: circle,
                fontSize: 20,
              ),
            ),
          if (onAdd != null)
            _Story(
              key: const ValueKey('kid-story-add'),
              label: addLabel,
              selected: false,
              onTap: onAdd!,
              labelColor: AppColors.textSecondary,
              isButton: true,
              face: const _AddFace(),
            ),
        ],
      ),
    );
  }
}

class _Story extends StatelessWidget {
  const _Story({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.face,
    this.hasNews = false,
    this.labelColor = AppColors.ink,
    this.isButton = false,
    this.semanticsId,
  });

  final String label;
  final bool selected;
  final bool hasNews;
  final VoidCallback onTap;
  final Widget face;
  final Color labelColor;
  final bool isButton;
  final String? semanticsId;

  static const double _ringGap = 3;
  static const double _ringWidth = 2.5;

  @override
  Widget build(BuildContext context) {
    const outer = DsKidStories.circle + 2 * (_ringGap + _ringWidth);
    return Semantics(
      identifier: semanticsId,
      container: true,
      button: true,
      // A tab-like choice, read as "Amir, selected" by VoiceOver/TalkBack.
      selected: isButton ? null : selected,
      inMutuallyExclusiveGroup: !isButton,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        scale: 0.94,
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          // At least 64 wide (the 44pt target), wider for a long label such
          // as a bold "Everyone".
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: outer + 4,
              maxWidth: 120,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: outer,
                  height: outer,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: AppMotion.tint,
                        curve: AppMotion.ease,
                        width: outer,
                        height: outer,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: _ringWidth,
                          ),
                        ),
                      ),
                      face,
                      if (hasNews)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            key: const ValueKey('kid-story-dot'),
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.bgParent,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    letterSpacing: -0.08,
                    color: labelColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Everyone: the family as two overlapping heads on the pine tint.
class _EveryoneFace extends StatelessWidget {
  const _EveryoneFace();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DsKidStories.circle,
      height: DsKidStories.circle,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.primaryTint,
        shape: BoxShape.circle,
      ),
      child: AppIcons.tabFamily(size: 26, color: AppColors.primary),
    );
  }
}

/// `border: 1.5px dashed #B5C2BC` with a plus.
class _AddFace extends StatelessWidget {
  const _AddFace();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: DsKidStories.circle,
      height: DsKidStories.circle,
      child: CustomPaint(
        painter: const _DashedCirclePainter(),
        child: Center(
          child: AppIcons.plus(size: 20, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 1.5;
    final paint = Paint()
      ..color = AppColors.chevron
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    const dashes = 22;
    const sweep = 2 * 3.141592653589793 / dashes;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(rect, i * sweep, sweep * 0.55, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => false;
}
