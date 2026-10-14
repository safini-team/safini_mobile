import 'dart:convert';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/profile_cubit.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart';
import 'package:safini/features/common/profile/domain/models/profile_model.dart';

const _childId = 'child-1';

class _Adapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (options.method == 'POST') return _json({'balance_after': 10});
    if (options.method == 'PATCH') return _json({});
    if (options.path.endsWith('/home')) {
      return _json({
        'child': {
          'level': 2,
          'avatar_state': {'character_id': 'char_02'},
        },
      });
    }
    return _json({
      'balance': 60,
      'app_time_offers': const [],
      'avatar_items': [
        {
          'item_key': 'char_11',
          'name': 'Astronaut',
          'slot': 'character',
          'coin_cost': 50,
          'is_owned': false,
        },
        {
          'item_key': 'char_13',
          'name': 'Scientist',
          'slot': 'character',
          'coin_cost': 50,
          'is_owned': true,
        },
        {
          'item_key': 'cosmic-cape',
          'slot': 'outfit',
          'coin_cost': 120,
          'is_owned': false,
        },
      ],
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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _settle(bool Function() done) async {
  for (var attempt = 0; attempt < 200 && !done(); attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

void main() {
  late _Adapter adapter;
  late CoinsCubit coins;
  late AvatarCubit cubit;

  setUp(() async {
    adapter = _Adapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
      ..httpClientAdapter = adapter;
    coins = CoinsCubit();
    cubit = AvatarCubit(coins, dio, _FakeProfiles());
    await _settle(() => cubit.state.characterId != null);
  });

  tearDown(() async {
    await cubit.close();
    await coins.close();
  });

  test('only unbought store characters are locked', () {
    expect(cubit.state.characterPrices, {'char_11': 50});
    expect(cubit.state.avatarItems.map((i) => i.id), ['cosmic-cape']);
  });

  test('a locked character cannot be put on without buying it', () async {
    await cubit.selectCharacter('char_11');
    expect(cubit.state.characterId, 'char_02');
    expect(adapter.requests.where((r) => r.method == 'PATCH'), isEmpty);
  });

  test('buying a character pays, unlocks and wears it', () async {
    final error = await cubit.buyCharacter('char_11');

    expect(error, isNull);
    expect(coins.state, 10);
    expect(cubit.state.characterPrices, isEmpty);
    expect(cubit.state.characterId, 'char_11');
    final post = adapter.requests.singleWhere((r) => r.method == 'POST');
    expect(post.data, {'item_key': 'char_11'});
    final patch = adapter.requests.singleWhere((r) => r.method == 'PATCH');
    expect(patch.data['avatar_state']['character_id'], 'char_11');
  });

  test('free and owned characters are worn straight away', () async {
    await cubit.selectCharacter('char_13');
    expect(cubit.state.characterId, 'char_13');
  });
}
