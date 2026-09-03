import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_motion.dart';
import 'package:safini/core/theme/app_radius.dart';

/// `border-radius:30px 30px 0 0;padding:10px 0 34px;max-height:88%` with a
/// 38×5 grabber. Presents on `sheetUp 400ms cubic-bezier(.32,.72,0,1)` behind a
/// `rgba(23,21,28,.42)` scrim that fades in over 260ms.
Future<T?> showDsSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool dismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: dismissible,
    enableDrag: dismissible,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    elevation: 0,
    sheetAnimationStyle: AnimationStyle(
      curve: AppMotion.sheet,
      duration: AppMotion.sheetIn,
      reverseCurve: AppMotion.spring,
      reverseDuration: const Duration(milliseconds: 260),
    ),
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.88,
    ),
    builder: (context) => DsSheet(child: Builder(builder: builder)),
  );
}

class DsSheet extends StatelessWidget {
  const DsSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x590C231C),
            offset: Offset(0, -20),
            blurRadius: 50,
            spreadRadius: -20,
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 5,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: const Color(0x290C231C),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                22,
                14,
                22,
                34 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// The grey inset panel that groups fields inside a sheet:
/// `background:#F8F7FB;border-radius:18-20px`.
class DsSheetPanel extends StatelessWidget {
  const DsSheetPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = AppRadius.panel,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.fillAlt,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}
