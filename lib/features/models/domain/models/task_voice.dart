// Parent voice instructions on a task (SAF-172).
//
// The API never sees the bytes. It signs an upload slot, the device PUTs
// straight to Storage, then the parent attaches the object key. Task lists
// mint a short-lived signed playback URL.

/// 60 seconds, matching `MAX_DURATION_MS` on the API.
const int voiceMaxDurationMs = 60 * 1000;

/// 10 MB, matching `MAX_UPLOAD_BYTES` on the API. The server is the authority;
/// this is the preflight so a huge file never starts the round trip.
const int voiceDefaultMaxBytes = 10 * 1024 * 1024;

/// What `VoiceUploadUrlRequest.extension` accepts. Anything else is a 422.
const Set<String> voiceAllowedExtensions = {
  'm4a',
  'aac',
  'mp3',
  'wav',
  'webm',
  'ogg',
  'mp4',
  '3gp',
};

/// AAC-LC on a phone lands as `.m4a` with `audio/mp4`, which is on the API
/// allowlist. The recorder always uses this pair so we never 422 on MIME.
const String voiceRecordExtension = 'm4a';
const String voiceRecordMime = 'audio/mp4';

/// A short-lived slot in Supabase Storage, from
/// `POST /v1/children/{child_id}/task-voice/upload-url`.
class TaskVoiceUpload {
  /// Already carries its own `?token=`, so the PUT needs no Authorization
  /// header — and must not carry ours, which is for our API, not Supabase.
  final String uploadUrl;

  /// `{child_id}/{task_id}/{uuid}.{ext}`. The server re-derives ownership
  /// from this on attach, so a client cannot attach someone else's recording.
  final String objectKey;

  final int maxBytes;
  final int maxDurationMs;

  const TaskVoiceUpload({
    required this.uploadUrl,
    required this.objectKey,
    required this.maxBytes,
    required this.maxDurationMs,
  });

  factory TaskVoiceUpload.fromJson(Map<String, dynamic> json) {
    return TaskVoiceUpload(
      uploadUrl: (json['upload_url'] ?? '').toString(),
      objectKey: (json['object_key'] ?? '').toString(),
      maxBytes: json['max_bytes'] is num
          ? (json['max_bytes'] as num).toInt()
          : voiceDefaultMaxBytes,
      maxDurationMs: json['max_duration_ms'] is num
          ? (json['max_duration_ms'] as num).toInt()
          : voiceMaxDurationMs,
    );
  }

  bool get isUsable => uploadUrl.isNotEmpty && objectKey.isNotEmpty;
}

/// A local recording waiting to be attached after the task exists.
class TaskVoiceDraft {
  final String filePath;
  final int durationMs;
  final String mime;
  final String extension;

  const TaskVoiceDraft({
    required this.filePath,
    required this.durationMs,
    this.mime = voiceRecordMime,
    this.extension = voiceRecordExtension,
  });

  bool get isAttachable =>
      filePath.isNotEmpty &&
      durationMs >= 1 &&
      durationMs <= voiceMaxDurationMs &&
      voiceAllowedExtensions.contains(extension);
}

/// A task that was created but whose voice note did not attach yet. Save
/// retries the attach on exactly these instead of creating the task again.
typedef TaskVoiceTarget = ({String childId, String taskId});

/// What the parent decided about the voice note on Save.
///
/// [unchanged] is a no-op. [clear] DELETEs an existing note. [file] uploads
/// and POSTs, replacing whatever was there.
class TaskVoiceSave {
  final TaskVoiceDraft? attach;
  final bool remove;

  const TaskVoiceSave._({this.attach, this.remove = false});

  static const unchanged = TaskVoiceSave._();
  static const clear = TaskVoiceSave._(remove: true);

  factory TaskVoiceSave.file(TaskVoiceDraft draft) =>
      TaskVoiceSave._(attach: draft);

  bool get hasWork => remove || attach != null;
}

/// The MIME the API allowlists for [extension], or [voiceRecordMime] when we
/// do not recognise it — the recorder only ever produces m4a.
String voiceMimeFor(String extension) {
  switch (extension.toLowerCase().replaceAll('.', '')) {
    case 'm4a':
    case 'mp4':
      return 'audio/mp4';
    case 'aac':
      return 'audio/aac';
    case 'mp3':
      return 'audio/mpeg';
    case 'wav':
      return 'audio/wav';
    case 'webm':
      return 'audio/webm';
    case 'ogg':
      return 'audio/ogg';
    case '3gp':
      return 'audio/3gpp';
    default:
      return voiceRecordMime;
  }
}

/// Create/edit description: optional when a voice note is going with the
/// task, otherwise the title stands in so the child still has copy.
String? descriptionForTaskSave({
  required String title,
  required String details,
  required bool hasVoice,
}) {
  final text = details.trim();
  if (text.isNotEmpty) return text;
  if (hasVoice) return null;
  return title;
}

/// `m:ss` from a millisecond duration, capped at 60s.
String formatVoiceClock(int durationMs) {
  final totalSeconds = (durationMs / 1000).floor().clamp(0, 60);
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// Device microphone. Injected in tests so the sheet never opens the plugin.
abstract class TaskVoiceCapture {
  Future<bool> hasMicPermission();
  Future<void> startRecording(String path);
  Future<String?> stopRecording();
  Future<void> dispose();
}

/// Play/pause for a local file or a signed URL. Injected in tests.
abstract class TaskVoicePlayback {
  Stream<bool> get playing;
  Future<void> playFile(String path);
  Future<void> playUrl(String url);
  Future<void> pause();
  Future<void> stop();
  Future<void> dispose();
}
