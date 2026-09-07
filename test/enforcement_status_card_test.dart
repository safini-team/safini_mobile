import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/parent/presentation/widgets/apps/enforcement_status_card.dart';

/// The parent's only view of whether protection is actually running. Saying
/// "App limits are running" when the child's phone stopped reporting is the
/// worst thing this widget can do, so every state is pinned to its own copy.
class _StatusAdapter implements HttpClientAdapter {
  _StatusAdapter(this.status);

  String? status;
  int code = 200;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    if (code != 200) {
      return ResponseBody.fromString('{"detail":"nope"}', code, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      });
    }
    return ResponseBody.fromString(
      jsonEncode({'status': status}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<void> pumpCard(WidgetTester tester, String childId) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: EnforcementStatusCard(childId: childId)),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  late _StatusAdapter adapter;

  setUp(() {
    adapter = _StatusAdapter('active');
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
      ..httpClientAdapter = adapter;
    if (getIt.isRegistered<Dio>()) getIt.unregister<Dio>();
    getIt.registerSingleton<Dio>(dio);
  });

  tearDown(() => GetIt.I.reset());

  testWidgets('each protection state gets its own sentence', (tester) async {
    for (final entry in {
      'active': 'App limits are running',
      'attention_required': 'App limits need attention',
      'offline': 'offline or has stopped reporting',
      'not_configured': 'Set up app limits',
    }.entries) {
      adapter.status = entry.key;
      await pumpCard(tester, 'child-${entry.key}');
      expect(
        find.textContaining(entry.value),
        findsOneWidget,
        reason: 'status ${entry.key} must not be reported as anything else',
      );
    }
  });

  testWidgets('only a healthy device gets the reassuring icon', (tester) async {
    adapter.status = 'active';
    await pumpCard(tester, 'child-1');
    expect(find.byIcon(Icons.verified_user_outlined), findsOneWidget);

    adapter.status = 'offline';
    await pumpCard(tester, 'child-2');
    expect(find.byIcon(Icons.verified_user_outlined), findsNothing);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });

  testWidgets('a failed check says so instead of claiming everything is fine',
      (tester) async {
    adapter.code = 500;
    await pumpCard(tester, 'child-1');
    expect(find.textContaining('Could not check protection'), findsOneWidget);
  });

  testWidgets('nothing is shown until the first answer arrives', (tester) async {
    final completer = Completer<void>();
    final slow = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
      ..httpClientAdapter = _BlockingAdapter(completer.future);
    if (getIt.isRegistered<Dio>()) getIt.unregister<Dio>();
    getIt.registerSingleton<Dio>(slow);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        locale: const Locale('en'),
        home: const Scaffold(body: EnforcementStatusCard(childId: 'child-1')),
      ),
    );
    await tester.pump();
    expect(find.byType(ListTile), findsNothing);
    completer.complete();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(ListTile), findsOneWidget);
  });

  testWidgets('switching child re-reads that child, not the previous one',
      (tester) async {
    adapter.status = 'active';
    await pumpCard(tester, 'child-1');
    final before = adapter.calls;
    await pumpCard(tester, 'child-2');
    expect(adapter.calls, greaterThan(before));
  });
}

class _BlockingAdapter implements HttpClientAdapter {
  _BlockingAdapter(this.gate);
  final Future<void> gate;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await gate;
    return ResponseBody.fromString(
      jsonEncode({'status': 'active'}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
