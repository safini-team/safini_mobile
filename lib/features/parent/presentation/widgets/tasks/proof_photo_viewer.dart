import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_motion.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/pressable.dart';

/// The proof photo, edge to edge. Pinch to zoom, double-tap to zoom in on
/// that point and double-tap again to fit.
Future<void> showProofPhoto(BuildContext context, {required String url}) {
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: AppColors.ink,
      transitionDuration: AppMotion.scrim,
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, _) => FadeTransition(
        opacity: animation,
        child: ProofPhotoViewer(url: url),
      ),
    ),
  );
}

class ProofPhotoViewer extends StatefulWidget {
  const ProofPhotoViewer({super.key, required this.url});

  final String url;

  @override
  State<ProofPhotoViewer> createState() => _ProofPhotoViewerState();
}

class _ProofPhotoViewerState extends State<ProofPhotoViewer>
    with SingleTickerProviderStateMixin {
  final TransformationController _transform = TransformationController();
  late final AnimationController _zoom = AnimationController(
    vsync: this,
    duration: AppMotion.tint,
  );
  TapDownDetails? _doubleTap;
  Animation<Matrix4>? _zoomAnim;

  @override
  void initState() {
    super.initState();
    _zoom.addListener(() {
      final anim = _zoomAnim;
      if (anim != null) _transform.value = anim.value;
    });
  }

  @override
  void dispose() {
    _zoom.dispose();
    _transform.dispose();
    super.dispose();
  }

  void _toggleZoom() {
    final point = _doubleTap?.localPosition;
    if (point == null) return;
    final zoomed = _transform.value.getMaxScaleOnAxis() > 1.01;
    const scale = 2.5;
    final end = zoomed
        ? Matrix4.identity()
        : (Matrix4.identity()
            ..translateByDouble(
              -point.dx * (scale - 1),
              -point.dy * (scale - 1),
              0,
              1,
            )
            ..scaleByDouble(scale, scale, 1, 1));
    _zoomAnim = Matrix4Tween(
      begin: _transform.value,
      end: end,
    ).animate(CurvedAnimation(parent: _zoom, curve: AppMotion.spring));
    _zoom.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Material(
      color: AppColors.ink,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onDoubleTapDown: (details) => _doubleTap = details,
            onDoubleTap: _toggleZoom,
            child: InteractiveViewer(
              transformationController: _transform,
              minScale: 1,
              maxScale: 4,
              onInteractionStart: (_) => _zoom.stop(),
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height,
                child: Image.network(
                  widget.url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                    size: 36,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            right: 12,
            child: Semantics(
              button: true,
              label: s.close,
              child: Pressable(
                onTap: () => Navigator.of(context).pop(),
                scale: 0.92,
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppColors.surface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
