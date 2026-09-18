import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:safini/features/models/domain/models/task_voice.dart';

/// Phone recorder. AAC-LC → `.m4a` / `audio/mp4`, which the API allowlists.
///
/// The [AudioRecorder] is created on first use so a parent who never taps
/// Record does not open the plugin, and widget tests that inject a fake never
/// construct one at all.
class RecordTaskVoiceCapture implements TaskVoiceCapture {
  AudioRecorder? _recorder;

  AudioRecorder get _active => _recorder ??= AudioRecorder();

  @override
  Future<bool> hasMicPermission() => _active.hasPermission();

  @override
  Future<void> startRecording(String path) {
    return _active.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
        numChannels: 1,
      ),
      path: path,
    );
  }

  @override
  Future<String?> stopRecording() => _active.stop();

  @override
  Future<void> dispose() async {
    final recorder = _recorder;
    _recorder = null;
    if (recorder == null) return;
    if (await recorder.isRecording()) {
      await recorder.stop();
    }
    await recorder.dispose();
  }
}

/// Signed-URL and local-file playback. Created on first play so a child who
/// never taps Play does not open the plugin.
class AudioplayersVoicePlayback implements TaskVoicePlayback {
  AudioPlayer? _player;

  AudioPlayer get _active => _player ??= AudioPlayer();

  @override
  Stream<bool> get playing =>
      _active.onPlayerStateChanged.map((state) => state == PlayerState.playing);

  @override
  Future<void> playFile(String path) => _active.play(DeviceFileSource(path));

  @override
  Future<void> playUrl(String url) => _active.play(UrlSource(url));

  @override
  Future<void> pause() => _active.pause();

  @override
  Future<void> stop() => _active.stop();

  @override
  Future<void> dispose() async {
    final player = _player;
    _player = null;
    if (player == null) return;
    await player.dispose();
  }
}
