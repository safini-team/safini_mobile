import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/core/utils/request_id.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_cubit.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart';
import 'package:safini/features/common/profile/domain/models/profile_model.dart';

const _childId = 'child-1';

/// Answers the store GET, and holds every redeem POST open until released, so
/// a second tap really does land while the first is in flight.
class _SlowAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  final Completer<void> release = Completer<void>();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (options.method == 'POST') {
      await release.future;
      return _json({
        'balance_after': 850,
        'grant': {'id': 'grant-1', 'remaining_minutes': 20},
      });
    }
    return _json({
      'balance': 1000,
      'app_time_offers': [
        {
          'app_slug': 'roblox',
          'display_name': 'Roblox',
          'can_redeem': true,
          'is_enabled': true,
          'redeem_coin_cost': 150,
          'redeem_reward_minutes': 20,
          'minutes_remaining': 0,
        },
      ],
      'avatar_items': const [],
    });
  }

  ResponseBody _json(Map<String, dynamic> body) => ResponseBody.fromString(
    jsonEncode(body),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

class _FakeProfiles implements ProfileController {
  @override
  Future<Either<Failure, ProfileModel>> fetchMe() async => Right(
    ProfileModel(
      userId: 'user-1',
      email: 'kid@example.test',
      displayName: 'Ali',
      childId: _childId,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

Future<void> _settle(bool Function() done) async {
  for (var attempt = 0; attempt < 200 && !done(); attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

void main() {
  group('request ids', () {
    test('look like v4 uuids and do not repeat', () {
      final first = newRequestId();
      final second = newRequestId();
      expect(
        first,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
      expect(first, isNot(second));
    });
  });

  group('purchase guard', () {
    late _SlowAdapter adapter;
    late Dio dio;
    late CoinsCubit coins;
    late RewardStoreCubit cubit;

    setUp(() async {
      adapter = _SlowAdapter();
      dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
        ..httpClientAdapter = adapter;
      coins = CoinsCubit();
      cubit = RewardStoreCubit(coins, dio, _FakeProfiles());
      await _settle(() => cubit.state.appTimeItems.isNotEmpty);
    });

    tearDown(() async {
      if (!adapter.release.isCompleted) adapter.release.complete();
      await cubit.close();
      await coins.close();
    });

    test('a second tap while the first is in flight is ignored', () async {
      final id = cubit.state.appTimeItems.single.id;

      unawaited(cubit.purchaseAppTimeItem(id));
      await _settle(() => cubit.state.pendingPurchases.contains(id));
      expect(cubit.state.pendingPurchases, contains(id));

      unawaited(cubit.purchaseAppTimeItem(id));
      unawaited(cubit.purchaseAppTimeItem(id));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final posts = adapter.requests.where((r) => r.method == 'POST');
      expect(posts.length, 1, reason: 'only the first tap may reach the API');

      adapter.release.complete();
      await _settle(() => cubit.state.pendingPurchases.isEmpty);
      expect(cubit.state.pendingPurchases, isEmpty);
    });

    test('the purchase carries an idempotency key', () async {
      final id = cubit.state.appTimeItems.single.id;
      unawaited(cubit.purchaseAppTimeItem(id));
      await _settle(() => adapter.requests.any((r) => r.method == 'POST'));

      final post = adapter.requests.firstWhere((r) => r.method == 'POST');
      final body = post.data as Map<String, dynamic>;
      expect(body['app_slug'], id);
      expect(
        body['client_request_id'],
        matches(RegExp(r'^[0-9a-f-]{36}$')),
      );

      adapter.release.complete();
      await _settle(() => cubit.state.pendingPurchases.isEmpty);
    });

    test('a later tap is allowed once the first finished', () async {
      final id = cubit.state.appTimeItems.single.id;
      unawaited(cubit.purchaseAppTimeItem(id));
      await _settle(() => cubit.state.pendingPurchases.contains(id));
      adapter.release.complete();
      await _settle(() => cubit.state.pendingPurchases.isEmpty);

      await cubit.purchaseAppTimeItem(id);
      final posts = adapter.requests.where((r) => r.method == 'POST').toList();
      expect(posts.length, 2);
      expect(
        posts.first.data['client_request_id'],
        isNot(posts.last.data['client_request_id']),
        reason: 'a new attempt is a new purchase, not a replay',
      );
    });
  });
}
