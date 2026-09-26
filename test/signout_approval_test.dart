import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/notifications/push_event.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_monitor_screen.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart';
import 'package:safini/features/signout/kid_signout_sheet.dart';
import 'package:safini/features/signout/signout_asks_cubit.dart';
import 'package:safini/features/signout/signout_request.dart';

/// SAF-191: a child could sign out, and so switch app limits off, with one
/// tap. Now the phone asks a parent, who approves in their app or reads out
/// the code from their push.
SignoutRequest _request(String status, {int attemptsLeft = 5}) =>
    SignoutRequest(
      id: 'r1',
      childId: 'aziz',
      status: status,
      attemptsLeft: attemptsLeft,
    );

class _Api extends Fake implements SignoutApi {
  _Api({this.answers = const []});

  final List<String> answers;
  int reads = 0;
  final codes = <String>[];

  @override
  Future<SignoutRequest?> ask(String childId) async => _request('pending');

  @override
  Future<SignoutRequest> read(String childId, String requestId) async {
    final status = reads < answers.length ? answers[reads] : 'pending';
    reads++;
    return _request(status);
  }

  @override
  Future<SignoutRequest> verify(
    String childId,
    String requestId,
    String code,
  ) async {
    codes.add(code);
    if (code == '0427') return _request('approved');
    throw const WrongSignoutCode(attemptsLeft: 4, status: 'pending');
  }
}

Future<bool?> _run(WidgetTester tester, _Api api) async {
  bool? result;
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      locale: const Locale('en'),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async => result = await askParentToSignOut(
              context,
              api: api,
              childId: 'aziz',
              poll: const Duration(milliseconds: 100),
            ),
            child: const Text('log out'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('log out'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  return result;
}

void main() {
  group('the child', () {
    testWidgets('waits until a parent approves, then may sign out', (
      tester,
    ) async {
      final api = _Api(answers: ['pending', 'approved']);
      await _run(tester, api);
      expect(find.text('Ask a parent to sign out'), findsOneWidget);
      expect(find.textContaining('Waiting for an answer'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 120));
      expect(find.text('Ask a parent to sign out'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pumpAndSettle();
      expect(find.text('Ask a parent to sign out'), findsNothing);
      expect(api.reads, 2);
    });

    testWidgets('a parent saying no keeps the child signed in', (tester) async {
      await _run(tester, _Api(answers: ['denied']));
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pumpAndSettle();
      expect(find.textContaining('said no'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Ask a parent to sign out'), findsNothing);
    });

    testWidgets('a wrong code says so, the right one lets them out', (
      tester,
    ) async {
      final api = _Api();
      await _run(tester, api);
      await tester.enterText(find.byType(EditableText), '1234');
      await tester.pump();
      await tester.pump();
      expect(find.textContaining('4 tries left'), findsOneWidget);
      await tester.enterText(find.byType(EditableText), '0427');
      await tester.pump();
      await tester.pumpAndSettle();
      expect(api.codes, ['1234', '0427']);
      expect(find.text('Ask a parent to sign out'), findsNothing);
    });

    test('no child profile behind the account means nothing to ask', () async {
      // 403: the profile was removed or moved to another phone.
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
        ..httpClientAdapter = _Status(403);
      expect(await SignoutApi(dio).ask('aziz'), isNull);
      dio.httpClientAdapter = _Status(503);
      // Anything else must not read as "free to go".
      expect(SignoutApi(dio).ask('aziz'), throwsA(isA<DioException>()));
    });
  });

  group('the parent', () {
    test('the push opens Today on that child', () {
      final event = PushEvent.fromData({
        'type': 'signout_requested',
        'child_id': 'aziz',
        'signout_id': 'r1',
      });
      expect(
        event?.target,
        const PushTarget(PushDestination.parentToday, childId: 'aziz'),
      );
    });

    testWidgets('Today lists the ask with its code and both answers', (
      tester,
    ) async {
      late List<TodayReview> reviews;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [S.delegate],
          supportedLocales: S.delegate.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              reviews = signoutReviews(S.of(context), const [
                SignoutRequest(
                  id: 'r1',
                  childId: 'aziz',
                  status: 'pending',
                  code: '0427',
                  childNickname: 'Aziz',
                ),
              ]);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(reviews.single.kind, TodayReviewKind.signout);
      expect(reviews.single.title, 'Aziz wants to sign out');
      expect(reviews.single.meta, contains('0427'));
    });

    test(
      'an ask another parent already answered just leaves the list',
      () async {
        final api = _AnsweringApi(conflict: true);
        final cubit = SignoutAsksCubit(api);
        await cubit.load();
        expect(cubit.state, hasLength(1));
        api.open = false;
        expect(await cubit.answer(cubit.state.single, approve: true), isNull);
        expect(cubit.state, isEmpty);
      },
    );
  });
}

class _AnsweringApi extends Fake implements SignoutApi {
  _AnsweringApi({this.conflict = false});

  final bool conflict;
  bool open = true;

  @override
  Future<List<SignoutRequest>> pending() async =>
      open ? [_request('pending')] : const [];

  @override
  Future<SignoutRequest> answer(
    SignoutRequest request, {
    required bool approve,
  }) async {
    if (conflict) {
      throw DioException(
        requestOptions: RequestOptions(path: '/'),
        response: Response(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 409,
          data: {'detail': 'This sign-out request is no longer open.'},
        ),
      );
    }
    return _request(approve ? 'approved' : 'denied');
  }
}

class _Status implements HttpClientAdapter {
  _Status(this.code);

  final int code;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    '{"detail":"nope"}',
    code,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}
