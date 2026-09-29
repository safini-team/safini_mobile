import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/proof_photo_viewer.dart';

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

    final photo = url.isEmpty
        ? placeholder(emptyLabel)
        : _OpenablePhoto(
            url: url,
            failed: placeholder(failedLabel ?? emptyLabel),
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
      child: loading ? const SizedBox(height: 170) : photo,
    );
  }
}

/// A loaded proof opens full size. A URL that fails stays a placeholder, with
/// nothing to tap.
class _OpenablePhoto extends StatefulWidget {
  const _OpenablePhoto({required this.url, required this.failed});

  final String url;
  final Widget failed;

  @override
  State<_OpenablePhoto> createState() => _OpenablePhotoState();
}

class _OpenablePhotoState extends State<_OpenablePhoto> {
  bool _failed = false;

  @override
  void didUpdateWidget(_OpenablePhoto old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) _failed = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return widget.failed;

    return Semantics(
      button: true,
      label: S.of(context).viewPhoto,
      child: Pressable(
        onTap: () => showProofPhoto(context, url: widget.url),
        scale: 0.985,
        child: Stack(
          children: [
            Image.network(
              widget.url,
              fit: BoxFit.contain,
              width: double.infinity,
              // The URL expires in five minutes. A sheet left open past that
              // shows a placeholder, not a broken image.
              errorBuilder: (context, _, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_failed) setState(() => _failed = true);
                });
                return widget.failed;
              },
            ),
            const Positioned(
              right: 10,
              bottom: 10,
              child: IgnorePointer(child: _ExpandMark()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandMark extends StatelessWidget {
  const _ExpandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.45),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.open_in_full_rounded,
        size: 14,
        color: AppColors.surface,
      ),
    );
  }
}
