import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:safini/core/network/auth_token_provider.dart';
import 'package:safini/core/network/authenticated_http_client.dart';
import 'package:safini/core/network/dio_error_mapper.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/models/data/repositories/family_repository_impl.dart';
import 'package:safini/features/subscription/free_limit.dart';

const _childLimit = 'The free plan has one child. Safini Pro adds every child.';

http.Response _limited(String limit) => http.Response(
  jsonEncode({'detail': _childLimit}),
  402,
  headers: {'content-type': 'application/json', 'x-safini-limit': limit},
);

class _Tokens implements AuthTokenProvider {
  @override
  bool hasSession = true;

  @override
  String? currentAccessToken = 'token';

  @override
  Future<String?> getAccessToken() async => currentAccessToken;

  @override
  Future<String?> refreshAfterUnauthorized(String? rejectedAccessToken) async =>
      currentAccessToken;
}

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light,
  locale: const Locale('en'),
  localizationsDelegates: const [
    S.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: S.delegate.supportedLocales,
  home: child,
);

void main() {
  group('reading a limit', () {
    test('only a 402 with a known limit is one', () {
      expect(FreeLimit.fromResponse(402, 'parents'), FreeLimit.parents);
      expect(FreeLimit.fromResponse(402, 'children'), FreeLimit.children);
      expect(
        FreeLimit.fromResponse(402, 'controlled_apps'),
        FreeLimit.controlledApps,
      );
      expect(
        FreeLimit.fromResponse(402, 'recurring_tasks'),
        FreeLimit.recurringTasks,
      );
      expect(FreeLimit.fromResponse(402, null), isNull);
      expect(FreeLimit.fromResponse(409, 'children'), isNull);
    });

    test('a Dio 402 becomes a FreeLimitFailure', () {
      final options = RequestOptions(path: '/v1/children/c1/tasks');
      final failure = mapDioError(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 402,
            data: {'detail': 'The free plan repeats three tasks.'},
            headers: Headers.fromMap({
              'x-safini-limit': ['recurring_tasks'],
            }),
          ),
        ),
        'Unable to create task.',
      );

      expect(failure, isA<FreeLimitFailure>());
      expect((failure as FreeLimitFailure).limit, FreeLimit.recurringTasks);
    });
  });

  test(
    'adding a second child on the free plan fails quietly and alerts',
    () async {
      final alerts = <FreeLimit>[];
      final subscription = FreeLimitAlerts.instance.stream.listen(alerts.add);
      addTearDown(subscription.cancel);
      final repository = FamilyRepositoryImpl(
        AuthenticatedHttpClient(
          _Tokens(),
          client: MockClient((_) async => _limited('children')),
        ),
      );

      final result = await repository.createChild(nickname: 'Mira', age: 7);
      await Future<void>.delayed(Duration.zero);

      final failure = result.fold((failure) => failure, (_) => null);
      expect(failure, isA<FreeLimitFailure>());
      expect(alerts, [FreeLimit.children]);
    },
  );

  group('the sheet', () {
    Future<void> open(WidgetTester tester, {required bool canBuy}) async {
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showFreeLimitSheet(
                context,
                FreeLimit.controlledApps,
                canBuy: canBuy,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('on iPhone it leads to Safini Pro', (tester) async {
      await open(tester, canBuy: true);

      expect(find.text("That's the free plan's limit"), findsOneWidget);
      expect(find.textContaining('five apps per child'), findsOneWidget);
      expect(find.text('See Safini Pro'), findsOneWidget);
      expect(find.textContaining('coming to Android'), findsNothing);
    });

    testWidgets('on Android it says Pro is coming', (tester) async {
      await open(tester, canBuy: false);

      expect(find.text('See Safini Pro'), findsNothing);
      expect(
        find.text('Safini Pro is coming to Android soon.'),
        findsOneWidget,
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.textContaining('five apps per child'), findsNothing);
    });
  });
}
