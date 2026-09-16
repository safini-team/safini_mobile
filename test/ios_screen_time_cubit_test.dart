import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/features/child/data/services/screen_time_service.dart';
import 'package:safini/features/child/presentation/cubit/ios_screen_time_cubit.dart';

class Native extends ScreenTimeService {
  @override
  bool get isSupported => true;
  int installations = 0;
  ScreenTimeMember? member;
  final List<ScreenTimeMember> authorizeCalls = [];

  /// When set, `.child` authorization throws a `ScreenTimeException` with this
  /// code, the way Apple rejects a device that is not in a Family Sharing group.
  String? childAuthFailure;
  Map<String, dynamic> status = {
    'authorization': 'approved',
    'child_id': 'child',
    'selected_applications': 1,
    'selected_categories': 0,
    'shield_active': false,
    'monitoring_active': true,
    'mapped_slugs': ['roblox'],
    'policy_loaded': true,
    'all_mapped': true,
    'private_token': 'never-upload',
  };
  @override
  Future<Map<String, dynamic>> releaseStatus() async => status;
  @override
  Future<Map<String, dynamic>> configurePolicy(
    Map<String, dynamic> policy,
  ) async {
    installations++;
    return status;
  }

  @override
  Future<ScreenTimeAuthStatus> requestAuthorization({
    ScreenTimeMember member = ScreenTimeMember.individual,
  }) async {
    this.member = member;
    authorizeCalls.add(member);
    if (member == ScreenTimeMember.child && childAuthFailure != null) {
      throw ScreenTimeException(childAuthFailure!, 'rejected');
    }
    return ScreenTimeAuthStatus.approved;
  }
}

void main() {
  late Dio dio;
  late Native native;
  late IosScreenTimeCubit cubit;
  late List<RequestOptions> requests;
  setUp(() {
    native = Native();
    requests = [];
    dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          requests.add(request);
          handler.resolve(
            Response(
              requestOptions: request,
              data: request.method == 'GET'
                  ? {
                      'child_id': 'child',
                      'apps': [
                        {'app_slug': 'roblox', 'display_name': 'Roblox'},
                      ],
                    }
                  : {},
            ),
          );
        },
      ),
    );
    cubit = IosScreenTimeCubit(native, dio);
  });
  tearDown(() => cubit.close());
  test(
    'only operational fields reach the database; mapped IDs and tokens stay local',
    () async {
      await cubit.start('child');
      expect(cubit.state.ready, isTrue);
      expect(cubit.canPurchase('child', 'roblox'), isTrue);
      expect(cubit.canPurchase('different-child', 'roblox'), isFalse);
      final body = requests.last.data as Map;
      expect(body.keys.toSet(), {
        'platform',
        'authorization',
        'selected_applications',
        'selected_categories',
        'shield_active',
        'monitoring_active',
      });
      expect(native.installations, 1);
    },
  );
  test('offline refresh keeps cached protection and exposes retry', () async {
    await cubit.start('child');
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (r, h) => h.reject(DioException(requestOptions: r)),
      ),
    );
    await cubit.refresh();
    expect(cubit.state.ready, isTrue);
    expect(cubit.state.syncFailed, isTrue);
    expect(native.installations, 1);
  });
  test(
    'authorization without a configured policy cannot bypass setup',
    () async {
      native.status = {
        ...native.status,
        'policy_loaded': false,
        'all_mapped': false,
      };
      await cubit.start('child');
      expect(cubit.state.ready, isFalse);
    },
  );
  test(
    'authorization explicitly requires Apple child/parent approval',
    () async {
      await cubit.start('child');
      await cubit.authorize();
      expect(native.member, ScreenTimeMember.child);
    },
  );
  test(
    'a device outside Family Sharing falls back to individual authorization',
    () async {
      native.childAuthFailure = 'invalid_account';
      await cubit.start('child');
      await cubit.authorize();
      expect(native.authorizeCalls, [
        ScreenTimeMember.child,
        ScreenTimeMember.individual,
      ]);
      expect(cubit.state.errorCode, isNull);
    },
  );
  test('a non-account authorization failure is surfaced, not retried', () async {
    native.childAuthFailure = 'restricted';
    await cubit.start('child');
    await cubit.authorize();
    expect(native.authorizeCalls, [ScreenTimeMember.child]);
    expect(cubit.state.errorCode, 'restricted');
  });
  test(
    'late policy response after sign-out cannot reinstall the old child policy',
    () async {
      final pending = Completer<void>();
      dio.interceptors.clear();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (r, h) async {
            await pending.future;
            h.resolve(
              Response(
                requestOptions: r,
                data: {'child_id': 'child', 'apps': []},
              ),
            );
          },
        ),
      );
      final started = cubit.start('child');
      await Future<void>.delayed(Duration.zero);
      cubit.endSession();
      pending.complete();
      await started;
      expect(native.installations, 0);
      expect(cubit.state.ready, isFalse);
    },
  );
  test(
    'a policy bound to a different child cannot enable purchases offline',
    () async {
      native.status = {...native.status, 'child_id': 'other-child'};
      dio.interceptors.clear();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (r, h) => h.reject(DioException(requestOptions: r)),
        ),
      );
      await cubit.start('child');
      expect(cubit.state.ready, isFalse);
      expect(cubit.canPurchase('child', 'roblox'), isFalse);
    },
  );
  test(
    'exhausted global cap prevents spending coins on unusable minutes',
    () async {
      native.status = {...native.status, 'global_blocked': true};
      await cubit.start('child');
      expect(cubit.canPurchase('child', 'roblox'), isFalse);
    },
  );
}
