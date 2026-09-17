import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/models/domain/controllers/task_controller.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_task_repository.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/review_sheet.dart';

/// The review sheet framed the proof photo at a fixed 170 high with `cover`.
/// A phone camera shoots portrait, so the parent saw a strip across the middle
/// of the photo and could not tell whether the bed was made.
void main() {
  // 3x4 and 4x3 pixel PNGs: only the shape matters here.
  final portrait = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAMAAAAECAIAAADETxJQAAAAEElEQVR4nGNwaDgAQQx4WQBi'
    'NxIBylPvXQAAAABJRU5ErkJggg==',
  );
  final landscape = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAQAAAADCAIAAAA7ljmRAAAAEElEQVR4nGNwaDgARww4OQBZ'
    'NhIB0175YwAAAABJRU5ErkJggg==',
  );

  Future<Size> photoFrame(
    WidgetTester tester,
    List<int> bytes,
    String url,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 874);
    addTearDown(tester.view.reset);

    final cubit = ParentTasksCubit(_NoRepository(), _NoFamily(), _NoTasks());
    addTearDown(cubit.close);
    final task = ParentTaskInstanceModel(
      id: 't1',
      status: 'pending_approval',
      title: 'Make the bed',
      rewardCoins: 10,
      proofMode: 'text_image',
      submissionImageUrl: url,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  showReviewSheet(context, cubit: cubit, task: task),
              child: const Text('review'),
            ),
          ),
        ),
      ),
    );

    // Decoding needs real async, so load the photo into the cache first and
    // the sheet's Image.network finds it there.
    debugNetworkImageHttpClientProvider = () => _PhotoServer(bytes);
    await tester.runAsync(
      () =>
          precacheImage(NetworkImage(url), tester.element(find.text('review'))),
    );
    debugNetworkImageHttpClientProvider = null;

    await tester.tap(find.text('review'));
    await tester.pumpAndSettle();
    return tester.getSize(find.byType(Image));
  }

  testWidgets('a portrait photo is shown whole, not a 170 strip', (
    tester,
  ) async {
    final frame = await photoFrame(tester, portrait, 'https://p/portrait.png');
    // 3:4 across the sheet wants 477; the frame stops at half the screen, its
    // 1px border inside that, and the photo is letterboxed, never cropped.
    expect(frame.height, 874 * 0.5 - 2);
    expect(tester.widget<Image>(find.byType(Image)).fit, BoxFit.contain);
  });

  testWidgets('a landscape photo gets a frame of its own shape', (
    tester,
  ) async {
    final frame = await photoFrame(tester, landscape, 'https://p/land.png');
    expect(frame.height, closeTo(frame.width * 3 / 4, 0.01));
  });
}

class _NoRepository extends Fake implements IParentTaskRepository {}

class _NoFamily extends Fake implements ParentFamilyCubit {}

class _NoTasks extends Fake implements TaskController {}

class _PhotoServer extends Fake implements HttpClient {
  _PhotoServer(this.bytes);

  final List<int> bytes;

  @override
  bool autoUncompress = false;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _Request(bytes);
}

class _Request extends Fake implements HttpClientRequest {
  _Request(this.bytes);

  final List<int> bytes;

  @override
  Future<HttpClientResponse> close() async => _Response(bytes);
}

class _Response extends Fake implements HttpClientResponse {
  _Response(this.bytes);

  final List<int> bytes;

  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => bytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream<List<int>>.value(bytes).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
}
