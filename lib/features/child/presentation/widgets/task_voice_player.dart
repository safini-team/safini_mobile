import 'dart:async';

import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/models/data/task_voice_media.dart';
import 'package:safini/features/models/domain/models/task_voice.dart';

/// Play/pause for a parent's voice instruction. Autoplay is off.
class TaskVoicePlayer extends StatefulWidget {
  const TaskVoicePlayer({
    super.key,
    this.url,
    this.filePath,
    this.durationMs,
    this.label,
    this.playback,
  });

  /// Signed playback URL from the API.
  final String? url;

  /// Local preview of a take that has not been uploaded yet.
  final String? filePath;

  final int? durationMs;
  final String? label;
  final TaskVoicePlayback? playback;

  @override
  State<TaskVoicePlayer> createState() => _TaskVoicePlayerState();
}

class _TaskVoicePlayerState extends State<TaskVoicePlayer> {
  TaskVoicePlayback? _owned;
  StreamSubscription<bool>? _playingSub;
  bool _playing = false;
  String? _error;

  TaskVoicePlayback get _playback =>
      widget.playback ?? (_owned ??= AudioplayersVoicePlayback());

  bool get _hasSource {
    final url = widget.url?.trim() ?? '';
    final path = widget.filePath?.trim() ?? '';
    return url.isNotEmpty || path.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _playingSub = _playback.playing.listen((playing) {
      if (mounted) setState(() => _playing = playing);
    });
  }

  @override
  void dispose() {
    _playingSub?.cancel();
    _owned?.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (!_hasSource) return;
    setState(() => _error = null);
    try {
      if (_playing) {
        await _playback.pause();
        return;
      }
      final path = widget.filePath?.trim() ?? '';
      if (path.isNotEmpty) {
        await _playback.playFile(path);
      } else {
        await _playback.playUrl(widget.url!.trim());
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _playing = false;
        _error = S.of(context).voicePlaybackFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final duration = widget.durationMs ?? 0;

    return DsSheetPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DsOverlineText(widget.label ?? s.parentVoiceInstruction),
          const SizedBox(height: 10),
          Row(
            children: [
              Pressable(
                onTap: _toggle,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryTint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _playing ? s.pauseVoice : s.playVoice,
                      style: AppText.rowTitleLg,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                formatVoiceClock(duration),
                style: AppText.meta.copyWith(fontWeight: FontWeight.w600).nums,
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: AppText.metaSm.copyWith(color: AppColors.dangerDeep),
            ),
          ],
        ],
      ),
    );
  }
}
