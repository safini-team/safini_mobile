import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/child/domain/models/task_proof_upload.dart';
import 'package:safini/features/child/presentation/cubit/quest_model.dart';
import 'package:safini/features/child/presentation/widgets/dialogs/task_detail_dialog.dart';

/// The parent has been able to ask for photo proof since the first release.
/// The value on the wire is `text_image` - not `photo`, which is what F12
/// checked for, which is why the review panel never rendered once in
/// production. Everything here pins the real string.
QuestModel _quest({String? proofMode}) {
  return QuestModel(
    id: 't1',
    title: 'Make your bed',
    subtitle: '',
    icon: Icons.star,
    iconColor: const Color(0xFF2E6F8E),
    iconBackground: const Color(0xFFDFEAF0),
    coins: 20,
    proofMode: proofMode,
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

void main() {
  group('needsPhoto', () {
    test('reads the value the API actually sends', () {
      expect(_quest(proofMode: 'text_image').needsPhoto, isTrue);
      expect(_quest(proofMode: 'TEXT_IMAGE').needsPhoto, isTrue);
    });

    test('a text-only or unset task is not asked for one', () {
      expect(_quest(proofMode: 'text').needsPhoto, isFalse);
      expect(_quest(proofMode: 'none').needsPhoto, isFalse);
      expect(_quest().needsPhoto, isFalse);
    });
  });

  group('proofExtensionFor', () {
    test('takes what the bucket takes', () {
      expect(proofExtensionFor('/tmp/shot.jpg'), 'jpg');
      expect(proofExtensionFor('/tmp/shot.HEIC'), 'heic');
      expect(proofExtensionFor('/tmp/a.b.c/shot.png'), 'png');
    });

    test('refuses what it does not, before the round trip', () {
      // The API answers 422 for these; there is no reason to ask.
      expect(proofExtensionFor('/tmp/shot.gif'), isNull);
      expect(proofExtensionFor('/tmp/shot.mp4'), isNull);
      expect(proofExtensionFor('/tmp/shot'), isNull);
      expect(proofExtensionFor('/tmp/shot.'), isNull);
    });
  });

  group('proofContentType', () {
    test('is what Storage will serve the photo back as', () {
      // Storage keeps whatever the PUT declares, and the parent's review sheet
      // renders it - a wrong type here is a broken image on their screen.
      expect(proofContentType('png'), 'image/png');
      expect(proofContentType('heic'), 'image/heic');
      expect(proofContentType('webp'), 'image/webp');
      expect(proofContentType('jpg'), 'image/jpeg');
      expect(proofContentType('jpeg'), 'image/jpeg');
    });
  });

  group('TaskProofUpload.fromJson', () {
    test('reads the signed slot', () {
      final upload = TaskProofUpload.fromJson(const {
        'object_key': 'child/task/uuid.jpg',
        'upload_url': 'https://project.supabase.co/storage/v1/object/x?token=y',
        'expires_in_seconds': 900,
        'max_bytes': 10485760,
      });
      expect(upload.isUsable, isTrue);
      expect(upload.objectKey, 'child/task/uuid.jpg');
      expect(upload.maxBytes, 10485760);
    });

    test('a response missing either half is not usable', () {
      expect(
        TaskProofUpload.fromJson(const {'object_key': 'k'}).isUsable,
        isFalse,
      );
      expect(
        TaskProofUpload.fromJson(const {'upload_url': 'u'}).isUsable,
        isFalse,
      );
    });
  });

  group('the task sheet', () {
    testWidgets('asks for a photo when the parent asked for one', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          TaskDetailDialog(
            quest: _quest(proofMode: 'text_image'),
            onSubmit: (_, _) async => null,
            onUploadPhoto: (_) async => 'key',
          ),
        ),
      );
      await tester.pump();

      expect(find.text(S.current.addPhoto), findsOneWidget);
    });

    testWidgets('does not for a text-only task', (tester) async {
      await tester.pumpWidget(
        _host(
          TaskDetailDialog(
            quest: _quest(proofMode: 'text'),
            onSubmit: (_, _) async => null,
            onUploadPhoto: (_) async => 'key',
          ),
        ),
      );
      await tester.pump();

      expect(find.text(S.current.addPhoto), findsNothing);
      expect(find.text(S.current.holdToMarkDone), findsOneWidget);
    });

    testWidgets('does not ask a submitted task for anything', (tester) async {
      await tester.pumpWidget(
        _host(TaskDetailDialog(quest: _quest(proofMode: 'text_image'))),
      );
      await tester.pump();

      expect(find.text(S.current.addPhoto), findsNothing);
    });
  });
}
