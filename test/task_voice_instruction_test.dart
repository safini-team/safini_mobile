import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/child/presentation/cubit/quest_model.dart';
import 'package:safini/features/child/presentation/widgets/dialogs/task_detail_dialog.dart';
import 'package:safini/features/models/data/dto/task_dto.dart';
import 'package:safini/features/models/data/repositories/task_repository_impl.dart';
import 'package:safini/features/models/domain/models/task_voice.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';

QuestModel _quest({
  String? proofMode,
  String subtitle = '',
  String? voiceUrl,
  int? voiceDurationMs,
}) {
  return QuestModel(
    id: 't1',
    title: 'Make your bed',
    subtitle: subtitle,
    icon: Icons.star,
    iconColor: const Color(0xFF2E6F8E),
    iconBackground: const Color(0xFFDFEAF0),
    coins: 20,
    proofMode: proofMode,
    voiceInstructionUrl: voiceUrl,
    voiceInstructionDurationMs: voiceDurationMs,
  );
}

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('en'),
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

class _FakePlayback implements TaskVoicePlayback {
  final _playing = StreamController<bool>.broadcast();
  var playCount = 0;

  @override
  Stream<bool> get playing => _playing.stream;

  @override
  Future<void> playFile(String path) async {
    playCount += 1;
    _playing.add(true);
  }

  @override
  Future<void> playUrl(String url) async {
    playCount += 1;
    _playing.add(true);
  }

  @override
  Future<void> pause() async => _playing.add(false);

  @override
  Future<void> stop() async => _playing.add(false);

  @override
  Future<void> dispose() async => _playing.close();
}

void main() {
  group('descriptionForTaskSave', () {
    test('keeps typed details even when a voice note is attached', () {
      expect(
        descriptionForTaskSave(
          title: 'Clean your room',
          details: 'Under the bed too',
          hasVoice: true,
        ),
        'Under the bed too',
      );
    });

    test('omits the title stand-in when a voice note is attached', () {
      expect(
        descriptionForTaskSave(
          title: 'Clean your room',
          details: '  ',
          hasVoice: true,
        ),
        isNull,
      );
    });

    test('still sends the title when there is no voice note', () {
      expect(
        descriptionForTaskSave(
          title: 'Clean your room',
          details: '',
          hasVoice: false,
        ),
        'Clean your room',
      );
    });
  });

  group('formatVoiceClock', () {
    test('renders m:ss capped at a minute', () {
      expect(formatVoiceClock(0), '0:00');
      expect(formatVoiceClock(12500), '0:12');
      expect(formatVoiceClock(60000), '1:00');
      expect(formatVoiceClock(90000), '1:00');
    });
  });

  group('TaskVoiceUpload.fromJson', () {
    test('reads the signed slot', () {
      final upload = TaskVoiceUpload.fromJson(const {
        'object_key': 'child/task/uuid.m4a',
        'upload_url': 'https://project.supabase.co/storage/v1/object/x?token=y',
        'max_bytes': 10485760,
        'max_duration_ms': 60000,
      });
      expect(upload.isUsable, isTrue);
      expect(upload.objectKey, 'child/task/uuid.m4a');
      expect(upload.maxDurationMs, 60000);
    });

    test('a response missing either half is not usable', () {
      expect(
        TaskVoiceUpload.fromJson(const {'object_key': 'k'}).isUsable,
        isFalse,
      );
      expect(
        TaskVoiceUpload.fromJson(const {'upload_url': 'u'}).isUsable,
        isFalse,
      );
    });
  });

  group('voice fields on task JSON', () {
    test('TaskDto carries the signed url and duration', () {
      final task = TaskDto.fromJson(const {
        'id': 't1',
        'title': 'Clean your room',
        'coin_reward': 10,
        'xp_reward': 10,
        'voice_instruction_url': 'https://signed/voice.m4a',
        'voice_instruction_object_key': 'c/t/u.m4a',
        'voice_instruction_duration_ms': 12500,
        'voice_instruction_mime': 'audio/mp4',
      }).toDomain();

      expect(task.hasVoiceInstruction, isTrue);
      expect(task.voiceInstructionUrl, 'https://signed/voice.m4a');
      expect(task.voiceInstructionDurationMs, 12500);
    });

    test('ParentTaskInstanceModel reads the API names', () {
      final task = ParentTaskInstanceModel.fromJson(const {
        'id': 't1',
        'status': 'available',
        'title': 'Clean your room',
        'voice_instruction_url': 'https://signed/voice.m4a',
        'voice_instruction_object_key': 'c/t/u.m4a',
        'voice_instruction_duration_ms': 12500,
        'voice_instruction_mime': 'audio/mp4',
      });

      expect(task.hasVoiceInstruction, isTrue);
      expect(task.toTaskModel().voiceInstructionUrl, 'https://signed/voice.m4a');
      expect(task.toTaskModel().voiceInstructionDurationMs, 12500);
    });

    test('a task without a note has no player', () {
      final task = ParentTaskInstanceModel.fromJson(const {
        'id': 't1',
        'status': 'available',
        'title': 'Clean your room',
      });
      expect(task.hasVoiceInstruction, isFalse);
      expect(task.voiceInstructionUrl, isNull);
    });
  });

  group('child task detail', () {
    testWidgets('plays the voice note and keeps optional text below it', (
      tester,
    ) async {
      final playback = _FakePlayback();
      addTearDown(playback.dispose);

      await tester.pumpWidget(
        _host(
          TaskDetailDialog(
            quest: _quest(
              subtitle: 'Under the bed too',
              voiceUrl: 'https://signed/voice.m4a',
              voiceDurationMs: 12500,
            ),
            voicePlayback: playback,
          ),
        ),
      );
      await tester.pump();

      expect(find.text(S.current.parentVoiceInstruction.toUpperCase()), findsOneWidget);
      expect(find.text('0:12'), findsOneWidget);
      expect(find.text('Under the bed too'), findsOneWidget);
      expect(find.text(S.current.playVoice), findsOneWidget);
      expect(playback.playCount, 0);

      await tester.tap(find.text(S.current.playVoice));
      await tester.pump();
      expect(playback.playCount, 1);
    });

    testWidgets('without a voice note keeps the text-only sheet', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          TaskDetailDialog(
            quest: _quest(subtitle: 'Under the bed too'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text(S.current.parentVoiceInstruction.toUpperCase()), findsNothing);
      expect(find.text(S.current.playVoice), findsNothing);
      expect(find.text('Under the bed too'), findsOneWidget);
    });

    testWidgets('voice-only does not invent a text instruction', (tester) async {
      final playback = _FakePlayback();
      addTearDown(playback.dispose);

      await tester.pumpWidget(
        _host(
          TaskDetailDialog(
            quest: _quest(
              voiceUrl: 'https://signed/voice.m4a',
              voiceDurationMs: 12500,
            ),
            voicePlayback: playback,
          ),
        ),
      );
      await tester.pump();

      expect(find.text(S.current.parentVoiceInstruction.toUpperCase()), findsOneWidget);
      expect(find.textContaining('coin'), findsNothing);
      expect(find.text(S.current.playVoice), findsOneWidget);
    });
  });

  test('aac-lc is the mime/extension pair the API allowlists', () {
    expect(voiceMimeFor('m4a'), 'audio/mp4');
    expect(voiceRecordExtension, 'm4a');
    expect(voiceAllowedExtensions.contains('m4a'), isTrue);
  });

  group('TaskVoiceDraft', () {
    test('rejects a take that is empty, too long, or the wrong type', () {
      expect(
        const TaskVoiceDraft(filePath: '/tmp/a.m4a', durationMs: 0).isAttachable,
        isFalse,
      );
      expect(
        const TaskVoiceDraft(
          filePath: '/tmp/a.m4a',
          durationMs: 60001,
        ).isAttachable,
        isFalse,
      );
      expect(
        const TaskVoiceDraft(
          filePath: '/tmp/a.webm',
          durationMs: 1000,
          extension: 'webm',
        ).isAttachable,
        isTrue,
      );
      expect(
        const TaskVoiceDraft(
          filePath: '/tmp/a.gif',
          durationMs: 1000,
          extension: 'gif',
        ).isAttachable,
        isFalse,
      );
    });
  });

  group('voice upload wiring', () {
    test('signs a slot then PUTs bytes without our API bearer', () async {
      late RequestOptions apiRequest;
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            apiRequest = options;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'upload_url': 'https://storage.example/put?token=abc',
                  'object_key': 'child/task/uuid.m4a',
                  'max_bytes': 10485760,
                  'max_duration_ms': 60000,
                },
              ),
            );
          },
        ),
      );

      http.BaseRequest? put;
      final repo = TaskRepositoryImpl(
        dio,
        uploadClient: MockClient((request) async {
          put = request;
          return http.Response('', 200);
        }),
      );

      final slot = await repo.createVoiceUploadUrl(
        childId: 'child',
        taskId: 'task',
        extension: 'm4a',
      );
      final upload = slot.getOrElse(() => throw StateError('no slot'));
      expect(apiRequest.path, '/v1/children/child/task-voice/upload-url');
      expect(apiRequest.data, {'task_id': 'task', 'extension': 'm4a'});

      final result = await repo.uploadVoiceBytes(
        upload: upload,
        bytes: const [1, 2, 3],
        mime: 'audio/mp4',
      );
      expect(result.isRight(), isTrue);
      expect(put!.url.toString(), 'https://storage.example/put?token=abc');
      expect(put!.headers['content-type'], 'audio/mp4');
      expect(put!.headers.containsKey('authorization'), isFalse);
    });

    test('refuses a recording larger than the signed cap before the PUT', () async {
      var puts = 0;
      final repo = TaskRepositoryImpl(
        Dio(),
        uploadClient: MockClient((request) async {
          puts += 1;
          return http.Response('', 200);
        }),
      );

      final result = await repo.uploadVoiceBytes(
        upload: const TaskVoiceUpload(
          uploadUrl: 'https://storage.example/put?token=abc',
          objectKey: 'child/task/uuid.m4a',
          maxBytes: 4,
          maxDurationMs: 60000,
        ),
        bytes: const [1, 2, 3, 4, 5],
        mime: 'audio/mp4',
      );
      expect(result.isLeft(), isTrue);
      expect(puts, 0);
    });
  });
}
