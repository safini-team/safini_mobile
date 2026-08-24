import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/child/presentation/cubit/quest_model.dart';

/// The child's task sheet from the artboard: icon, title, coins, the detail
/// copy, an optional note for the parent, then press-and-hold to send.
///
/// When the parent asked for photo proof the sheet asks for the photo and
/// refuses to send without it. The parent has been able to tick "Needs photo
/// proof" since the first release; the child was never asked, so the toggle
/// did nothing at all.
///
/// Still named `TaskDetailDialog` because every caller uses `.show()`; it is a
/// bottom sheet now, not a dialog.
class TaskDetailDialog extends StatefulWidget {
  const TaskDetailDialog({
    super.key,
    required this.quest,
    this.onSubmit,
    this.onUploadPhoto,
    this.imagePicker,
  });

  final QuestModel quest;

  /// Submit flow for an open task. Returns null on success, else the message.
  final Future<String?> Function(String? note, String? imageObjectKey)?
  onSubmit;

  /// Uploads the photo and returns its storage object key, or null if it did
  /// not land. Called as soon as the child takes the picture, so a failure
  /// surfaces while they are still writing the note.
  final Future<String?> Function(String filePath)? onUploadPhoto;

  /// Injected in tests; the real one talks to the camera.
  final ImagePicker? imagePicker;

  static Future<void> show(
    BuildContext context,
    QuestModel quest, {
    Future<String?> Function(String? note, String? imageObjectKey)? onSubmit,
    Future<String?> Function(String filePath)? onUploadPhoto,
    ImagePicker? imagePicker,
  }) {
    return showDsSheet<void>(
      context: context,
      builder: (_) => TaskDetailDialog(
        quest: quest,
        onSubmit: onSubmit,
        onUploadPhoto: onUploadPhoto,
        imagePicker: imagePicker,
      ),
    );
  }

  @override
  State<TaskDetailDialog> createState() => _TaskDetailDialogState();
}

class _TaskDetailDialogState extends State<TaskDetailDialog> {
  final _note = TextEditingController();
  bool _submitting = false;
  String? _error;

  /// Local file, shown back to the child. Kept alongside [_photoObjectKey] so
  /// a failed upload can clear the key without losing the preview.
  String? _photoPath;
  String? _photoObjectKey;
  bool _uploading = false;

  bool get _needsPhoto =>
      widget.quest.needsPhoto && widget.onUploadPhoto != null;

  bool get _hasPhoto => _photoObjectKey != null;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    if (_uploading || _submitting) return;

    final picker = widget.imagePicker ?? ImagePicker();
    final XFile? shot;
    try {
      shot = await picker.pickImage(
        source: ImageSource.camera,
        // The bucket refuses anything over 10 MB, and a modern phone camera
        // clears that on its own. This keeps a slow connection honest.
        maxWidth: 1600,
        imageQuality: 85,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = S.of(context).photoUploadFailed);
      return;
    }
    if (shot == null || !mounted) return;

    setState(() {
      _photoPath = shot!.path;
      _photoObjectKey = null;
      _uploading = true;
      _error = null;
    });

    final objectKey = await widget.onUploadPhoto!(shot.path);
    if (!mounted) return;

    setState(() {
      _uploading = false;
      _photoObjectKey = objectKey;
      if (objectKey == null) {
        _photoPath = null;
        _error = S.of(context).photoUploadFailed;
      }
    });
  }

  Future<void> _submit() async {
    if (_submitting || _uploading) return;

    if (_needsPhoto && !_hasPhoto) {
      setState(() => _error = S.of(context).photoRequired);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final text = _note.text.trim();
    final error = await widget.onSubmit!(
      text.isEmpty ? null : text,
      _photoObjectKey,
    );
    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _submitting = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final quest = widget.quest;
    final subtitle = quest.localizedSubtitle(s);
    final canSubmit = widget.onSubmit != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DsEmojiTile(
              emoji: quest.emoji ?? '⭐',
              size: 52,
              radius: AppRadius.icon,
              background: AppColors.primaryTint,
              fontSize: 26,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    quest.title,
                    style: AppText.title4.copyWith(height: 1.18),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppText.meta.copyWith(fontSize: 14)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            DsPill.coins(
              label: '+${quest.coins}',
              height: 28,
              fontSize: 14.5,
              horizontalPadding: 12,
            ),
          ],
        ),
        if (quest.reviewNote != null && quest.reviewNote!.isNotEmpty) ...[
          const SizedBox(height: 18),
          DsSheetPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DsOverlineText(s.noteFromParent),
                const SizedBox(height: 7),
                Text(
                  quest.reviewNote!,
                  style: AppText.body.copyWith(
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (canSubmit && _needsPhoto) ...[
          const SizedBox(height: 16),
          _PhotoPanel(
            path: _photoPath,
            uploading: _uploading,
            onTap: _takePhoto,
          ),
        ],
        if (canSubmit) ...[
          const SizedBox(height: 16),
          DsSheetPanel(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DsOverlineText(s.noteForParent),
                const SizedBox(height: 7),
                TextField(
                  controller: _note,
                  maxLines: 2,
                  minLines: 2,
                  cursorColor: AppColors.primary,
                  style: AppText.body.copyWith(
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    filled: false,
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: s.reviewNoteHint,
                    hintStyle: AppText.body.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: AppText.metaSm.copyWith(color: AppColors.dangerDeep),
            ),
          ],
          const SizedBox(height: 20),
          if (_submitting)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ),
            )
          else
            DsHoldButton(
              label: s.holdToMarkDone,
              holdingLabel: s.keepHolding,
              radius: AppRadius.panel,
              padding: const EdgeInsets.all(18),
              fontSize: 17,
              onComplete: _submit,
            ),
        ] else ...[
          const SizedBox(height: 20),
          DsSheetPanel(
            padding: const EdgeInsets.all(16),
            child: Text(
              quest.isSubmitted ? s.waitingForParentCheck : s.paidOutNice,
              textAlign: TextAlign.center,
              style: AppText.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// The capture tile: an empty dashed panel until there is a photo, then the
/// shot itself with a retake affordance over it.
class _PhotoPanel extends StatelessWidget {
  const _PhotoPanel({
    required this.path,
    required this.uploading,
    required this.onTap,
  });

  final String? path;
  final bool uploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Pressable.row(
      onTap: uploading ? null : onTap,
      child: Container(
        height: 170,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.fill,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: const Color(0x2417151C)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (path != null)
              Image.file(File(path!), fit: BoxFit.cover)
            else
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcons.camera(),
                  const SizedBox(height: 8),
                  Text(
                    s.addPhoto,
                    style: AppText.metaSm.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            if (uploading)
              Container(
                color: const Color(0x66FFFFFF),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              )
            else if (path != null)
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: DsPill.muted(
                    label: s.retakePhoto,
                    height: 28,
                    fontSize: 13,
                    horizontalPadding: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
