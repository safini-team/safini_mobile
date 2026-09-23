import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_cubit.dart';
import 'package:safini/features/prizes/prize.dart';
import 'package:safini/features/prizes/prize_asks_cubit.dart';
import 'package:safini/features/prizes/prize_idea.dart';

import 'app_blocking_test.dart' show ProfileFake;

const _lego = {
  'id': 'prize-lego',
  'child_id': 'child',
  'title': 'Lego set',
  'emoji': '🧱',
  'note': null,
  'coin_cost': 800,
  'template_key': 'lego-set',
  'pending_request_id': null,
};

/// A fake API: the store, one prize, and whatever asks and wishes it is sent.
class FakePrizeServer {
  final List<RequestOptions> requests = [];
  int balance = 1000;
  bool failNextAsk = false;

  Dio dio() {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          final path = options.path;
          if (path.endsWith('/store')) {
            return handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'balance': balance,
                  'app_time_offers': [],
                  'avatar_items': [],
                },
              ),
            );
          }
          if (path.endsWith('/child/prizes')) {
            return handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'balance': balance,
                  'prizes': [_lego],
                  'requests': [
                    {
                      'id': 'wish-old',
                      'child_id': 'child',
                      'kind': 'wish',
                      'title': 'Kite',
                      'coin_cost': 90,
                      'status': 'pending',
                    },
                    {
                      'id': 'wish-done',
                      'child_id': 'child',
                      'kind': 'wish',
                      'title': 'Drone',
                      'coin_cost': 900,
                      'status': 'declined',
                    },
                  ],
                },
              ),
            );
          }
          if (path.endsWith('/prizes/prize-lego/requests')) {
            if (failNextAsk) {
              failNextAsk = false;
              return handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 409,
                    data: {
                      'detail': 'The price changed. Refresh before asking.',
                    },
                  ),
                ),
              );
            }
            balance -= 800;
            return handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'balance_after': balance,
                  'request': {
                    'id': 'ask-1',
                    'child_id': 'child',
                    'kind': 'buy',
                    'prize_id': 'prize-lego',
                    'title': 'Lego set',
                    'coin_cost': 800,
                    'status': 'pending',
                  },
                },
              ),
            );
          }
          if (path.endsWith('/wishes')) {
            final body = options.data as Map;
            return handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'balance_after': balance,
                  'request': {
                    'id': 'wish-new',
                    'child_id': 'child',
                    'kind': 'wish',
                    'title': body['title'],
                    'coin_cost': body['coin_cost'],
                    'status': 'pending',
                  },
                },
              ),
            );
          }
          if (path == '/v1/prize-requests') {
            return handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'requests': [
                    {
                      'id': 'ask-1',
                      'child_id': 'child',
                      'kind': 'buy',
                      'title': 'Lego set',
                      'coin_cost': 800,
                      'status': 'pending',
                      'child_nickname': 'Ali',
                    },
                    {
                      'id': 'wish-old',
                      'child_id': 'child',
                      'kind': 'wish',
                      'title': 'Kite',
                      'coin_cost': 90,
                      'status': 'pending',
                      'child_nickname': 'Ali',
                    },
                  ],
                },
              ),
            );
          }
          return handler.resolve(Response(requestOptions: options, data: {}));
        },
      ),
    );
    return dio;
  }
}

void main() {
  group('prize ideas', () {
    test('ten ideas, unique keys, big items priced like big items', () {
      expect(PrizeIdea.values, hasLength(10));
      expect(PrizeIdea.values.map((i) => i.key).toSet(), hasLength(10));
      expect(PrizeIdea.iceCream.coins, lessThan(PrizeIdea.book.coins));
      expect(PrizeIdea.bike.coins, greaterThanOrEqualTo(2000));
      expect(PrizeIdea.pet.coins, greaterThanOrEqualTo(2000));
    });

    test('an idea already in the store is not offered again', () {
      final left = PrizeIdea.notIn(['lego-set', null, 'pet']);
      expect(left, isNot(contains(PrizeIdea.lego)));
      expect(left, isNot(contains(PrizeIdea.pet)));
      expect(left, hasLength(8));
    });

    test('the price step grows with the price and round-trips', () {
      expect(nextPrizePrice(40), 50);
      expect(nextPrizePrice(200), 250);
      expect(nextPrizePrice(1000), 1100);
      expect(previousPrizePrice(1000), 950);
      expect(previousPrizePrice(250), 200);
      expect(previousPrizePrice(10), 10);
      expect(nextPrizePrice(100000), 100000);
    });
  });

  group('child store', () {
    test('asking holds the price and marks the prize waiting', () async {
      final server = FakePrizeServer();
      final coins = CoinsCubit();
      final cubit = RewardStoreCubit(coins, server.dio(), ProfileFake());
      await cubit.stream.firstWhere((state) => !state.isLoading);

      expect(cubit.state.prizes.single.title, 'Lego set');
      // Only open wishes show; a declined one is history, not a tile.
      expect(cubit.state.openWishes.map((w) => w.id), ['wish-old']);

      await cubit.askForPrize('prize-lego', notice: 'asked');
      expect(coins.state, 200);
      expect(cubit.state.prizes.single.isWaiting, isTrue);
      expect(cubit.state.notice, 'asked');

      // Tapping a waiting prize again sends nothing.
      final sent = server.requests.length;
      await cubit.askForPrize('prize-lego', notice: 'asked');
      expect(server.requests.length, sent);

      final ask = server.requests.firstWhere(
        (r) => r.path.endsWith('/requests'),
      );
      expect((ask.data as Map)['expected_coin_cost'], 800);
      expect((ask.data as Map)['client_request_id'], isNotEmpty);
      await cubit.close();
      await coins.close();
    });

    test('too few coins asks nothing and says how many are missing', () async {
      final server = FakePrizeServer()..balance = 300;
      final coins = CoinsCubit();
      final cubit = RewardStoreCubit(coins, server.dio(), ProfileFake());
      await cubit.stream.firstWhere((state) => !state.isLoading);
      await cubit.askForPrize('prize-lego', notice: 'asked');
      expect(cubit.state.missingCoins, 500);
      expect(server.requests.where((r) => r.method == 'POST'), isEmpty);
      await cubit.close();
      await coins.close();
    });

    test('a refused ask shows the server reason and keeps the coins', () async {
      final server = FakePrizeServer()..failNextAsk = true;
      final coins = CoinsCubit();
      final cubit = RewardStoreCubit(coins, server.dio(), ProfileFake());
      await cubit.stream.firstWhere((state) => !state.isLoading);
      await cubit.askForPrize('prize-lego', notice: 'asked');
      expect(
        cubit.state.purchaseError,
        'The price changed. Refresh before asking.',
      );
      expect(coins.state, 1000);
      expect(cubit.state.prizes.single.isWaiting, isFalse);
      await cubit.close();
      await coins.close();
    });

    test('a wish shows up as waiting straight away', () async {
      final server = FakePrizeServer();
      final coins = CoinsCubit();
      final cubit = RewardStoreCubit(coins, server.dio(), ProfileFake());
      await cubit.stream.firstWhere((state) => !state.isLoading);
      final sent = await cubit.sendWish(
        title: 'Football',
        coinCost: 300,
        emoji: '⚽',
        notice: 'wished',
      );
      expect(sent, isTrue);
      expect(cubit.state.openWishes.first.title, 'Football');
      expect(cubit.state.openWishes, hasLength(2));
      expect(coins.state, 1000, reason: 'nothing is held for a wish');
      await cubit.close();
      await coins.close();
    });
  });

  group('parent answers', () {
    test('an answered ask leaves the list, a wish carries its price', () async {
      final server = FakePrizeServer();
      final cubit = PrizeAsksCubit(PrizeApi(server.dio()));
      await cubit.load();
      expect(cubit.state.map((a) => a.childNickname), ['Ali', 'Ali']);

      final wish = cubit.state.firstWhere((a) => a.isWish);
      expect(await cubit.answer(wish, approve: true, coinCost: 120), isNull);
      final approve = server.requests.last;
      expect(approve.path, '/v1/prize-requests/wish-old/approve');
      expect(approve.data, {'coin_cost': 120});

      final ask = cubit.state.single;
      expect(await cubit.answer(ask, approve: false), isNull);
      expect(server.requests.last.path, '/v1/prize-requests/ask-1/decline');
      expect(cubit.state, isEmpty);
      await cubit.close();
    });
  });
}
