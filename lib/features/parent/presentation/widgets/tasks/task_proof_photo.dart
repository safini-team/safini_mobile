import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';

/// The child's proof photo, shared by the review sheet and the Done history.
///
/// The whole photo, not a crop: a phone shot is portrait, and a fixed
/// 170-high `cover` frame showed a strip across its middle. The frame takes
/// the photo's own shape, up to half the screen, and anything taller is
/// letterboxed on the fill.
class TaskProofPhoto extends StatelessWidget {
  const TaskProofPhoto({
    super.key,
    required this.url,
    required this.emptyLabel,
    this.failedLabel,
    this.loading = false,
  });

  /// Signed URL, or empty when there is no photo to show.
  final String url;

  /// Shown when there is no photo, and when it fails to load unless
  /// [failedLabel] says otherwise.
  final String emptyLabel;
  final String? failedLabel;

  /// The URL is still being fetched: keep the frame, drop the label.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    Widget placeholder(String label) => SizedBox(
      height: 170,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcons.camera(),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppText.metaSm.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );

    return Container(
      constraints: BoxConstraints(
        minHeight: 170,
        maxHeight: MediaQuery.sizeOf(context).height * 0.5,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: const Color(0x240C231C),
          style: BorderStyle.solid,
        ),
      ),
      child: loading
          ? const SizedBox(height: 170)
          : url.isEmpty
          ? placeholder(emptyLabel)
          : Image.network(
              url,
              fit: BoxFit.contain,
              width: double.infinity,
              // The URL expires in five minutes. A sheet left open past that
              // shows a placeholder, not a broken image.
              errorBuilder: (context, _, _) =>
                  placeholder(failedLabel ?? emptyLabel),
            ),
    );
  }
}
