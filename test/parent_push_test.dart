import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/notifications/parent_push_service.dart';
import 'package:safini/core/notifications/push_deep_links.dart';

/// Records what the app actually put on the wire, without a network.
class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  int failures = 0;
  Completer<void>? holdPut;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (options.method == 'PUT' && holdPut != null) await holdPut!.future;
    if (failures > 0) {
      failures--;
      throw DioException(requestOptions: options);
    }
    return ResponseBody.fromString(
      jsonEncode({'registered': true}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakeMessaging implements FirebaseMessaging {
  _FakeMessaging(this.token);

  String? token;
  bool deleted = false;
  int permissionRequests = 0;
  final StreamController<String> refreshes =
      StreamController<String>.broadcast();

  @override
  Future<String?> getToken({
    String? vapidKey,
    String? serviceWorkerScriptPath,
  }) async => token;

  @override
  Future<void> deleteToken() async {
    deleted = true;
    token = null;
  }

  @override
  Stream<String> get onTokenRefresh => refreshes.stream;

  @override
  Future<RemoteMessage?> getInitialMessage() async => null;

  @override
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
    bool providesAppNotificationSettings = false,
  }) async {
    permissionRequests++;
    return const NotificationSettings(
      alert: AppleNotificationSetting.enabled,
      announcement: AppleNotificationSetting.disabled,
      authorizationStatus: AuthorizationStatus.authorized,
      badge: AppleNotificationSetting.enabled,
      carPlay: AppleNotificationSetting.disabled,
      lockScreen: AppleNotificationSetting.enabled,
      notificationCenter: AppleNotificationSetting.enabled,
      showPreviews: AppleShowPreviewSetting.always,
      timeSensitive: AppleNotificationSetting.disabled,
      criticalAlert: AppleNotificationSetting.disabled,
      sound: AppleNotificationSetting.enabled,
      providesAppNotificationSettings: AppleNotificationSetting.disabled,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The refresh listener awaits a full request, so one microtask is not enough.
Future<void> _settle(bool Function() done) async {
  for (var attempt = 0; attempt < 100 && !done(); attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

RemoteMessage _alert(String childId) => RemoteMessage(
  data: {
    'type': 'protection_alert',
    'kind': 'attention_required',
    'child_id': childId,
    'deep_link': 'safini://children/$childId/protection',
  },
);

void main() {
  group('deep link parsing', () {
    test('accepts only the protection link shape', () {
      expect(
        PushDeepLinks.parseChildId(
          Uri.parse('safini://children/abc/protection'),
        ),
        'abc',
      );
      for (final bad in [
        'safini://children/abc',
        'safini://children/abc/limits',
        'safini://kids/abc/protection',
        'https://children/abc/protection',
        'safini://children//protection',
      ]) {
        expect(PushDeepLinks.parseChildId(Uri.parse(bad)), isNull, reason: bad);
      }
    });

    test('holds the child id until something consumes it', () {
      final links = PushDeepLinks();
      expect(links.hasPending, isFalse);
      links.open('child-1');
      expect(links.hasPending, isTrue);
      expect(links.takeChildId(), 'child-1');
      expect(links.takeChildId(), isNull);
    });

    test('notifies a screen that is already open', () async {
      final links = PushDeepLinks();
      final seen = <String>[];
      final subscription = links.stream.listen(seen.add);
      links.open('child-2');
      await Future<void>.delayed(Duration.zero);
      expect(seen, ['child-2']);
      await subscription.cancel();
      await links.dispose();
    });
  });

  group('parent push service', () {
    late _RecordingAdapter adapter;
    late Dio dio;
    late PushDeepLinks links;

    setUp(() {
      adapter = _RecordingAdapter();
      dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
        ..httpClientAdapter = adapter;
      links = PushDeepLinks();
    });

    test('registers the current token, then every refreshed one', () async {
      final messaging = _FakeMessaging('token-1');
      final service = ParentPushService(
        dio,
        messaging,
        links,
        openedMessages: const Stream<RemoteMessage>.empty(),
      );

      await service.start();
      expect(adapter.requests.single.path, '/v1/me/push-devices');
      expect(adapter.requests.single.method, 'PUT');
      final body = adapter.requests.single.data as Map<String, dynamic>;
      expect(body['token'], 'token-1');
      expect(body['platform'], anyOf('android', 'ios'));
      expect(body['locale'], isNotEmpty);

      messaging.refreshes.add('token-2');
      await _settle(() => adapter.requests.length == 2);
      expect(adapter.requests.length, 2);
      expect(
        (adapter.requests.last.data as Map<String, dynamic>)['token'],
        'token-2',
      );
      await service.dispose();
    });

    test('a second start does not register twice', () async {
      final service = ParentPushService(
        dio,
        _FakeMessaging('token-1'),
        links,
        openedMessages: const Stream<RemoteMessage>.empty(),
      );
      await service.start();
      await service.start();
      expect(adapter.requests.length, 1);
      await service.dispose();
    });

    test(
      'sign-out revokes the token on the server and on the device',
      () async {
        final messaging = _FakeMessaging('token-1');
        final service = ParentPushService(
          dio,
          messaging,
          links,
          openedMessages: const Stream<RemoteMessage>.empty(),
        );
        await service.start();
        await service.revoke();

        final delete = adapter.requests.last;
        expect(delete.method, 'DELETE');
        expect(delete.path, '/v1/me/push-devices');
        expect((delete.data as Map<String, dynamic>)['token'], 'token-1');
        expect(messaging.deleted, isTrue);
        expect(service.registeredToken, isNull);
        await service.dispose();
      },
    );

    test('registration can retry after an offline first launch', () async {
      adapter.failures = 1;
      final service = ParentPushService(
        dio,
        _FakeMessaging('token-1'),
        links,
        openedMessages: const Stream<RemoteMessage>.empty(),
      );
      await service.start();
      await service.start();
      expect(service.registeredToken, 'token-1');
      await service.dispose();
    });

    test(
      'a new parent can register after sign-out in the same process',
      () async {
        final messaging = _FakeMessaging('old-parent');
        final service = ParentPushService(
          dio,
          messaging,
          links,
          openedMessages: const Stream<RemoteMessage>.empty(),
        );
        await service.start();
        await service.revoke();
        messaging.token = 'new-parent';
        await service.start();
        expect(service.registeredToken, 'new-parent');
        expect((adapter.requests.last.data as Map)['token'], 'new-parent');
        await service.dispose();
      },
    );

    test(
      'sign-out waits for registration and removes refresh listeners',
      () async {
        adapter.holdPut = Completer<void>();
        final messaging = _FakeMessaging('token-1');
        final service = ParentPushService(
          dio,
          messaging,
          links,
          openedMessages: const Stream<RemoteMessage>.empty(),
        );
        final starting = service.start();
        await _settle(() => adapter.requests.isNotEmpty);
        final stopping = service.revoke();
        adapter.holdPut!.complete();
        await Future.wait([starting, stopping]);
        final count = adapter.requests.length;
        messaging.refreshes.add('after-signout');
        await Future<void>.delayed(const Duration(milliseconds: 30));
        expect(service.registeredToken, isNull);
        expect(adapter.requests.last.method, 'DELETE');
        expect(adapter.requests.length, count);
        await service.dispose();
      },
    );

    test('a tapped alert routes to the child it names', () {
      final service = ParentPushService(
        dio,
        _FakeMessaging('token-1'),
        links,
        openedMessages: const Stream<RemoteMessage>.empty(),
      );
      service.handleMessage(_alert('child-9'));
      expect(links.takeChildId(), 'child-9');
    });

    test('anything that is not a protection alert is ignored', () {
      final service = ParentPushService(
        dio,
        _FakeMessaging('token-1'),
        links,
        openedMessages: const Stream<RemoteMessage>.empty(),
      );
      service.handleMessage(const RemoteMessage(data: {'type': 'marketing'}));
      service.handleMessage(
        const RemoteMessage(
          data: {'type': 'protection_alert', 'deep_link': 'https://evil.test'},
        ),
      );
      expect(links.hasPending, isFalse);
    });
  });
}
