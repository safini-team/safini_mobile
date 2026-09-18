import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/child/presentation/widgets/task_voice_player.dart';
import 'package:safini/features/models/data/task_voice_media.dart';
import 'package:safini/features/models/domain/models/task_voice.dart';

/// Record → recording (60s countdown) → preview for a parent voice note.
class TaskVoiceRecorderPanel extends StatefulWidget {
  const TaskVoiceRecorderPanel({
    super.key,
    this.existingUrl,
    this.existingDurationMs,
    this.capture,
    this.playback,
    this.onBusy,
    required this.onChanged,
  });

  final String? existingUrl;
  final int? existingDurationMs;
  final TaskVoiceCapture? capture;
  final TaskVoicePlayback? playback;
  final ValueChanged<bool>? onBusy;
  final ValueChanged<TaskVoiceSave> onChanged;

  @override
  State<TaskVoiceRecorderPanel> createState() => _TaskVoiceRecorderPanelState();
}

enum _Phase { idle, denied, recording, preview }

class _TaskVoiceRecorderPanelState extends State<TaskVoiceRecorderPanel> {
  static const _minDurationMs = 400;
  static const _tick = Duration(milliseconds: 200);

  TaskVoiceCapture? _ownedCapture;
  Timer? _ticker;

  _Phase _phase = _Phase.idle;
  String? _localPath;
  int _elapsedMs = 0;
  int _durationMs = 0;
  bool _hadExisting = false;
  bool _starting = false;

  TaskVoiceCapture get _capture =>
      widget.capture ?? (_ownedCapture ??= RecordTaskVoiceCapture());

  @override
  void initState() {
    super.initState();
    final url = widget.existingUrl?.trim() ?? '';
    if (url.isNotEmpty) {
      _hadExisting = true;
      _phase = _Phase.preview;
      _durationMs = widget.existingDurationMs ?? 0;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ownedCapture?.dispose();
    super.dispose();
  }

  int get _remainingSeconds {
    final left = voiceMaxDurationMs - _elapsedMs;
    return ((left + 999) ~/ 1000).clamp(0, 60);
  }

  Future<void> _start() async {
    if (_starting || _phase == _Phase.recording) return;
    _starting = true;
    try {
      final allowed = await _capture.hasMicPermission();
      if (!mounted) return;
      if (!allowed) {
        setState(() => _phase = _Phase.denied);
        return;
      }

      final path =
          '${Directory.systemTemp.path}/safini-voice-${DateTime.now().millisecondsSinceEpoch}.$voiceRecordExtension';
      try {
        await _capture.startRecording(path);
      } catch (_) {
        if (!mounted) return;
        setState(() => _phase = _Phase.denied);
        return;
      }
      if (!mounted) return;

      _localPath = path;
      _elapsedMs = 0;
      widget.onBusy?.call(true);
      _ticker?.cancel();
      _ticker = Timer.periodic(_tick, (_) {
        if (!mounted || _phase != _Phase.recording) return;
        final elapsed = _elapsedMs + _tick.inMilliseconds;
        setState(() => _elapsedMs = elapsed.clamp(0, voiceMaxDurationMs));
        if (elapsed >= voiceMaxDurationMs) {
          _stop();
        }
      });
      setState(() => _phase = _Phase.recording);
    } finally {
      _starting = false;
    }
  }

  Future<void> _stop() async {
    if (_phase != _Phase.recording) return;
    // Leave recording immediately so a second Stop / the 60s timer cannot
    // run the same take twice.
    _phase = _Phase.preview;
    _ticker?.cancel();
    widget.onBusy?.call(false);
    final elapsed = _elapsedMs.clamp(1, voiceMaxDurationMs);
    String? stoppedPath;
    try {
      stoppedPath = await _capture.stopRecording();
    } catch (_) {
      stoppedPath = _localPath;
    }
    if (!mounted) return;

    if (elapsed < _minDurationMs) {
      _clearLocal();
      setState(() {
        _phase = _hadExisting ? _Phase.preview : _Phase.idle;
        _durationMs = _hadExisting ? (widget.existingDurationMs ?? 0) : 0;
        _localPath = null;
      });
      widget.onChanged(TaskVoiceSave.unchanged);
      return;
    }

    final path = (stoppedPath != null && stoppedPath.isNotEmpty)
        ? stoppedPath
        : _localPath!;
    setState(() {
      _phase = _Phase.preview;
      _localPath = path;
      _durationMs = elapsed;
      _elapsedMs = elapsed;
    });
    widget.onChanged(
      TaskVoiceSave.file(
        TaskVoiceDraft(filePath: path, durationMs: elapsed),
      ),
    );
  }

  void _remove() {
    _ticker?.cancel();
    _clearLocal();
    widget.onBusy?.call(false);
    setState(() {
      _phase = _Phase.idle;
      _durationMs = 0;
      _elapsedMs = 0;
      _localPath = null;
    });
    widget.onChanged(_hadExisting ? TaskVoiceSave.clear : TaskVoiceSave.unchanged);
  }

  Future<void> _rerecord() async {
    _clearLocal();
    await _start();
  }

  void _clearLocal() {
    final path = _localPath;
    _localPath = null;
    if (path == null) return;
    final file = File(path);
    if (file.existsSync()) {
      try {
        file.deleteSync();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _Phase.idle => _Idle(onRecord: _start),
      _Phase.denied => _Denied(onRetry: _start),
      _Phase.recording => _Recording(
        secondsLeft: _remainingSeconds,
        onStop: _stop,
      ),
      _Phase.preview => _Preview(
        url: _localPath == null ? widget.existingUrl : null,
        filePath: _localPath,
        durationMs: _durationMs,
        playback: widget.playback,
        onRerecord: _rerecord,
        onRemove: _remove,
      ),
    };
  }
}

class _Idle extends StatelessWidget {
  const _Idle({required this.onRecord});

  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Pressable.row(
      onTap: onRecord,
      child: DsSheetPanel(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            AppIcons.mic(color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                s.recordVoiceInstruction,
                style: AppText.rowTitleLg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Denied extends StatelessWidget {
  const _Denied({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DsSheetPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.micPermissionDenied,
            style: AppText.body.copyWith(color: AppColors.dangerDeep),
          ),
          const SizedBox(height: 10),
          Pressable(
            onTap: onRetry,
            child: Text(
              s.tryAgain,
              style: AppText.rowTitleLg.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Recording extends StatelessWidget {
  const _Recording({required this.secondsLeft, required this.onStop});

  final int secondsLeft;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DsSheetPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.danger,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.recordingVoice, style: AppText.rowTitleLg),
                const SizedBox(height: 2),
                Text(
                  s.voiceSecondsLeft(secondsLeft),
                  style: AppText.meta.copyWith(color: AppColors.dangerDeep).nums,
                ),
              ],
            ),
          ),
          Pressable(
            onTap: onStop,
            child: Text(
              s.stopRecording,
              style: AppText.rowTitleLg.copyWith(color: AppColors.dangerDeep),
            ),
          ),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.url,
    required this.filePath,
    required this.durationMs,
    required this.playback,
    required this.onRerecord,
    required this.onRemove,
  });

  final String? url;
  final String? filePath;
  final int durationMs;
  final TaskVoicePlayback? playback;
  final VoidCallback onRerecord;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TaskVoicePlayer(
          url: url,
          filePath: filePath,
          durationMs: durationMs,
          label: s.voiceInstructionLabel,
          playback: playback,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Pressable(
                onTap: onRerecord,
                child: Text(
                  s.rerecordVoice,
                  textAlign: TextAlign.center,
                  style: AppText.rowTitleLg.copyWith(color: AppColors.primary),
                ),
              ),
            ),
            Expanded(
              child: Pressable(
                onTap: onRemove,
                child: Text(
                  s.removeVoice,
                  textAlign: TextAlign.center,
                  style: AppText.rowTitleLg.copyWith(
                    color: AppColors.dangerDeep,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
