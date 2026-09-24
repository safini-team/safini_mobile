import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/notifications/foreground_notifications.dart';
import 'package:safini/core/notifications/push_deep_links.dart';
import 'package:safini/core/notifications/push_event.dart';
import 'package:safini/core/notifications/push_service.dart';

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
  int presentationOptionCalls = 0;
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
  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = false,
    bool badge = false,
    bool sound = false,
  }) async {
    if (alert && badge && sound) presentationOptionCalls++;
  }

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

/// Stands in for the Android method channel and records what would be posted.
class _RecordingForeground extends ForegroundNotifications {
  _RecordingForeground() : super();

  final List<RemoteMessage> shown = [];

  @override
  Future<void> show(RemoteMessage message) async => shown.add(message);
}

/// The refresh listener awaits a full request, so one microtask is not enough.
Future<void> _settle(bool Function() done) async {
  for (var attempt = 0; attempt < 100 && !done(); attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

const _child = '4c3d73d7-b950-47ee-bc20-5a237d37f4a0';
const _task = '9f3f7985-70a5-4e4c-a5dc-f3d0a3d88111';

RemoteMessage _push(Map<String, String> data, {String id = 'msg-1'}) =>
    RemoteMessage(
      messageId: id,
      data: data,
      notification: const RemoteNotification(
        title: 'Title',
        body: 'Body',
        android: AndroidNotification(channelId: 'safini_tasks', tag: 'task:1'),
      ),
    );

RemoteMessage _alert(String childId) => RemoteMessage(
  data: {
    'type': 'protection_alert',
    'kind': 'attention_required',
    'child_id': childId,
    'deep_link': 'safini://children/$childId/protection',
  },
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

    test('a target waits for the screen it is meant for', () {
      final links = PushDeepLinks();
      expect(links.hasPending, isFalse);
      links.open(const PushTarget(PushDestination.parentTasks, taskId: 't'));
      expect(links.take(PushDestination.parentLimits), isNull);
      expect(
        links.hasPending,
        isTrue,
        reason: 'another screen must not eat it',
      );
      expect(
        links.take(PushDestination.parentTasks),
        const PushTarget(PushDestination.parentTasks, taskId: 't'),
      );
      expect(links.take(PushDestination.parentTasks), isNull);
      links.open(const PushTarget(PushDestination.childToday));
      links.clear();
      expect(links.hasPending, isFalse);
    });

    test('notifies a shell that is already open', () async {
      final links = PushDeepLinks();
      final seen = <PushTarget>[];
      final subscription = links.stream.listen(seen.add);
      links.open(const PushTarget(PushDestination.childTasks));
      await Future<void>.delayed(Duration.zero);
      expect(seen, [const PushTarget(PushDestination.childTasks)]);
      await subscription.cancel();
      await links.dispose();
    });
  });

  group('push payloads', () {
    test('every kind the API sends opens the screen it is about', () {
      final expected = {
        'task_submitted': const PushTarget(
          PushDestination.parentTasks,
          childId: _child,
          taskId: _task,
        ),
        'app_limit_reached': const PushTarget(
          PushDestination.parentLimits,
          childId: _child,
        ),
        'screen_time_reached': const PushTarget(
          PushDestination.parentLimits,
          childId: _child,
        ),
        'weekly_digest': const PushTarget(
          PushDestination.parentToday,
          childId: _child,
        ),
        'child_connected': const PushTarget(
          PushDestination.parentFamily,
          childId: _child,
        ),
        'parent_joined': const PushTarget(
          PushDestination.parentFamily,
          childId: _child,
        ),
        'task_approved': const PushTarget(PushDestination.childToday),
        'streak_reminder': const PushTarget(PushDestination.childToday),
        'task_rejected': const PushTarget(
          PushDestination.childTasks,
          taskId: _task,
        ),
        'tasks_assigned': const PushTarget(
          PushDestination.childTasks,
          taskId: _task,
        ),
        'prize_requested': const PushTarget(
          PushDestination.parentToday,
          childId: _child,
        ),
        'wish_requested': const PushTarget(
          PushDestination.parentToday,
          childId: _child,
        ),
        'prize_added': const PushTarget(PushDestination.childStore),
        'prize_given': const PushTarget(PushDestination.childStore),
        'prize_declined': const PushTarget(PushDestination.childStore),
      };
      // The set of types is the API's KINDS plus protection alerts.
      expect(PushType.values.map((t) => t.wire).toSet(), {
        ...expected.keys,
        'protection_alert',
      });
      for (final entry in expected.entries) {
        final event = PushEvent.fromData({
          'type': entry.key,
          'notification_id': 'n-1',
          'child_id': _child,
          'task_id': _task,
        });
        expect(event?.target, entry.value, reason: entry.key);
      }
    });

    test('parent and child destinations never mix', () {
      for (final type in PushType.values) {
        final target = PushEvent(type).target.destination;
        final forParent = switch (type) {
          PushType.taskApproved ||
          PushType.taskRejected ||
          PushType.tasksAssigned ||
          PushType.streakReminder ||
          PushType.prizeAdded ||
          PushType.prizeGiven ||
          PushType.prizeDeclined => false,
          _ => true,
        };
        expect(target.isParent, forParent, reason: type.wire);
      }
    });

    test('unknown types and hostile ids go nowhere', () {
      expect(PushEvent.fromData({'type': 'marketing'}), isNull);
      expect(PushEvent.fromData({}), isNull);
      final event = PushEvent.fromData({
        'type': 'task_rejected',
        'task_id': '../../settings',
        'child_id': 'x' * 200,
      });
      expect(event?.taskId, isNull);
      expect(event?.childId, isNull);
      expect(
        PushEvent.fromData({
          'type': 'protection_alert',
          'deep_link': 'https://evil.test',
        }),
        isNull,
      );
    });

    test('a protection alert still routes by its link', () {
      expect(
        PushEvent.fromData(_alert('child-9').data)?.target,
        const PushTarget(PushDestination.parentLimits, childId: 'child-9'),
      );
    });
  });

  group('push service', () {
    late _RecordingAdapter adapter;
    late Dio dio;
    late PushDeepLinks links;
    late _RecordingForeground foreground;
    late StreamController<RemoteMessage> foregroundMessages;

    PushService service(_FakeMessaging messaging, {bool isIOS = false}) =>
        PushService(
          dio,
          messaging,
          links,
          openedMessages: const Stream<RemoteMessage>.empty(),
          foregroundMessages: foregroundMessages.stream,
          foreground: foreground,
          isIOS: isIOS,
        );

    setUp(() {
      adapter = _RecordingAdapter();
      dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
        ..httpClientAdapter = adapter;
      links = PushDeepLinks();
      foreground = _RecordingForeground();
      foregroundMessages = StreamController<RemoteMessage>.broadcast();
    });

    test('registers the current token, then every refreshed one', () async {
      final messaging = _FakeMessaging('token-1');
      final push = service(messaging);

      await push.start(locale: 'uz');
      expect(adapter.requests.single.path, '/v1/me/push-devices');
      expect(adapter.requests.single.method, 'PUT');
      final body = adapter.requests.single.data as Map<String, dynamic>;
      expect(body['token'], 'token-1');
      expect(body['platform'], 'android');
      expect(body['locale'], 'uz');

      messaging.refreshes.add('token-2');
      await _settle(() => adapter.requests.length == 2);
      expect(adapter.requests.length, 2);
      expect(
        (adapter.requests.last.data as Map<String, dynamic>)['token'],
        'token-2',
      );
      await push.dispose();
    });

    test(
      'a language change re-registers, the same language does not',
      () async {
        final push = service(_FakeMessaging('token-1'));
        await push.start(locale: 'ru');
        await push.start(locale: 'ru');
        expect(adapter.requests.length, 1);
        await push.start(locale: 'en');
        expect(adapter.requests.length, 2);
        expect((adapter.requests.last.data as Map)['locale'], 'en');
        await push.updateLocale('en');
        expect(adapter.requests.length, 2);
        await push.dispose();
      },
    );

    test('iOS registers as ios and shows pushes while open', () async {
      final messaging = _FakeMessaging('apns-backed');
      final push = service(messaging, isIOS: true);
      await push.start(locale: 'ru');
      expect((adapter.requests.single.data as Map)['platform'], 'ios');
      expect(messaging.presentationOptionCalls, 1);
      await push.dispose();
    });

    test('a push with the app open is shown and told to the screens', () async {
      final push = service(_FakeMessaging('token-1'));
      final events = <PushEvent>[];
      final subscription = push.events.listen(events.add);
      await push.start(locale: 'en');

      foregroundMessages.add(
        _push({'type': 'task_submitted', 'child_id': _child, 'task_id': _task}),
      );
      foregroundMessages.add(_push({'type': 'marketing'}, id: 'msg-2'));
      await _settle(() => events.isNotEmpty);

      expect(foreground.shown.map((m) => m.messageId), ['msg-1']);
      expect(events.single.type, PushType.taskSubmitted);
      expect(events.single.taskId, _task);
      expect(links.hasPending, isFalse, reason: 'arriving is not tapping');
      await subscription.cancel();
      await push.dispose();
    });

    test('a second start does not register twice', () async {
      final push = service(_FakeMessaging('token-1'));
      await push.start();
      await push.start();
      expect(adapter.requests.length, 1);
      await push.dispose();
    });

    test(
      'sign-out revokes the token on the server and on the device',
      () async {
        final messaging = _FakeMessaging('token-1');
        final push = service(messaging);
        await push.start();
        links.open(const PushTarget(PushDestination.parentTasks));
        await push.revoke();

        final delete = adapter.requests.last;
        expect(delete.method, 'DELETE');
        expect(delete.path, '/v1/me/push-devices');
        expect((delete.data as Map<String, dynamic>)['token'], 'token-1');
        expect(messaging.deleted, isTrue);
        expect(push.registeredToken, isNull);
        expect(links.hasPending, isFalse);
        await push.dispose();
      },
    );

    test('registration can retry after an offline first launch', () async {
      adapter.failures = 1;
      final push = service(_FakeMessaging('token-1'));
      await push.start();
      await push.start();
      expect(push.registeredToken, 'token-1');
      await push.dispose();
    });

    test(
      'a child can register after a parent signs out in the same process',
      () async {
        final messaging = _FakeMessaging('parent-phone');
        final push = service(messaging);
        await push.start(locale: 'ru');
        await push.revoke();
        messaging.token = 'child-phone';
        await push.start(locale: 'uz');
        expect(push.registeredToken, 'child-phone');
        expect((adapter.requests.last.data as Map)['token'], 'child-phone');
        expect((adapter.requests.last.data as Map)['locale'], 'uz');
        await push.dispose();
      },
    );

    test(
      'sign-out waits for registration and removes every listener',
      () async {
        adapter.holdPut = Completer<void>();
        final messaging = _FakeMessaging('token-1');
        final push = service(messaging);
        final events = <PushEvent>[];
        push.events.listen(events.add);
        final starting = push.start();
        await _settle(() => adapter.requests.isNotEmpty);
        final stopping = push.revoke();
        adapter.holdPut!.complete();
        await Future.wait([starting, stopping]);
        final count = adapter.requests.length;
        messaging.refreshes.add('after-signout');
        foregroundMessages.add(_push({'type': 'task_approved'}));
        await Future<void>.delayed(const Duration(milliseconds: 30));
        expect(push.registeredToken, isNull);
        expect(adapter.requests.last.method, 'DELETE');
        expect(adapter.requests.length, count);
        expect(events, isEmpty);
        expect(foreground.shown, isEmpty);
        await push.dispose();
      },
    );

    test('a tapped push parks where it goes', () {
      final push = service(_FakeMessaging('token-1'));
      push.handleMessage(_alert('child-9'));
      expect(links.take(PushDestination.parentLimits)?.childId, 'child-9');
      push.handleMessage(_push({'type': 'task_rejected', 'task_id': _task}));
      expect(links.take(PushDestination.childTasks)?.taskId, _task);
    });

    test('anything that is not a Safini push is ignored', () {
      final push = service(_FakeMessaging('token-1'));
      push.handleMessage(const RemoteMessage(data: {'type': 'marketing'}));
      push.handleMessage(
        const RemoteMessage(
          data: {'type': 'protection_alert', 'deep_link': 'https://evil.test'},
        ),
      );
      expect(links.hasPending, isFalse);
    });
  });

  group('foreground notifications on Android', () {
    const channel = MethodChannel('test/notifications');
    final calls = <MethodCall>[];

    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return call.method == 'enabled' ? false : null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('posts on the push channel and tag, with the message id', () async {
      const notifications = ForegroundNotifications(channel, true);
      await notifications.show(_push({'type': 'task_submitted'}));
      expect(calls.single.method, 'show');
      expect(calls.single.arguments, {
        'messageId': 'msg-1',
        'title': 'Title',
        'body': 'Body',
        'channelId': 'safini_tasks',
        'tag': 'task:1',
      });
      expect(await notifications.enabled(), isFalse);
    });

    test('does nothing on iOS or for a data-only message', () async {
      await const ForegroundNotifications(
        channel,
        false,
      ).show(_push({'type': 'task_submitted'}));
      await const ForegroundNotifications(
        channel,
        true,
      ).show(const RemoteMessage(messageId: 'm', data: {'type': 'x'}));
      expect(calls, isEmpty);
    });
  });
}
