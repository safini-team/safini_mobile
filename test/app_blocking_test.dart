import 'package:dartz/dartz.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/child/data/services/app_block_service.dart';
import 'package:safini/features/child/data/services/child_app_rules_service.dart';
import 'package:safini/features/child/presentation/cubit/app_block_cubit.dart';
import 'package:safini/features/child/presentation/cubit/app_block_state.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart';
import 'package:safini/features/common/profile/domain/models/profile_model.dart';
import 'package:safini/features/models/domain/models/installed_app.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';

class NativeFake extends AppBlockService {
  bool usage = true;
  bool overlay = true;
  bool cached = false;
  bool failStart = false;
  bool running = true;
  int starts = 0;
  @override
  bool get isSupported => true;
  @override
  Future<bool> hasUsageAccess() async => usage;
  @override
  Future<bool> hasOverlayPermission() async => overlay;
  @override
  Future<bool> isConfigured(String id) async => true;
  @override
  Future<bool> isRunning() async => running;
  @override
  Future<bool> hasSnapshot() async => cached;
  @override
  Future<void> startService() async {
    starts++;
    if (failStart) throw StateError('offline');
  }

  @override
  Future<List<InstalledApp>> installedApps() async => [];
}

class RulesFake extends ChildAppRulesService {
  RulesFake() : super(Dio());
  @override
  Future<Either<Failure, Unit>> reportInstalledApps(
    String id,
    List<InstalledApp> apps,
  ) async => const Right(unit);
}

class ProfileFake implements ProfileController {
  @override
  Future<Either<Failure, ProfileModel>> fetchMe() async => Right(
    ProfileModel(
      userId: 'user',
      email: 'test@example.com',
      displayName: 'Test',
      childId: 'child',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class PurchaseNativeFake extends NativeFake {
  List<Object>? accepted;
  @override
  Future<Map<String, dynamic>> purchaseTime(
    String slug,
    int cost,
    int minutes,
  ) async {
    accepted = [slug, cost, minutes];
    return {
      'balance': 900,
      'apps': [
        {'app_slug': slug, 'remaining_minutes_today': 5},
      ],
    };
  }
}

Dio storeDio({required bool blocked, required List<String> methods}) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        methods.add(options.method);
        handler.resolve(
          Response(
            requestOptions: options,
            data: {
              'balance': 1000,
              'app_time_offers': [
                {
                  'app_slug': 'roblox',
                  'display_name': 'Roblox',
                  'is_enabled': true,
                  'is_blocked': blocked,
                  'redeem_coin_cost': 100,
                  'redeem_reward_minutes': 5,
                  'minutes_remaining': 3,
                },
              ],
              'avatar_items': [],
            },
          ),
        );
      },
    ),
  );
  return dio;
}

void main() {
  test(
    'shop preserves purchased minutes and disables manually blocked offers',
    () async {
      final coins = CoinsCubit();
      final cubit = RewardStoreCubit(
        coins,
        storeDio(blocked: true, methods: []),
        ProfileFake(),
      );
      await cubit.stream.firstWhere((state) => !state.isLoading);
      expect(cubit.state.appTimeItems.single.isEnabled, isFalse);
      expect(cubit.state.appTimeItems.single.remainingMinutes, 3);
      await cubit.close();
      await coins.close();
    },
  );
  test(
    'Android shop buys through native enforcement and applies authoritative balance',
    () async {
      final native = PurchaseNativeFake();
      getIt.registerSingleton<AppBlockService>(native);
      addTearDown(() => getIt.unregister<AppBlockService>());
      final methods = <String>[];
      final coins = CoinsCubit();
      final cubit = RewardStoreCubit(
        coins,
        storeDio(blocked: false, methods: methods),
        ProfileFake(),
      );
      await cubit.stream.firstWhere((state) => !state.isLoading);
      await cubit.purchaseAppTimeItem('roblox');
      expect(native.accepted, ['roblox', 100, 5]);
      expect(coins.state, 900);
      expect(cubit.state.appTimeItems.single.remainingMinutes, 5);
      expect(methods, ['GET']);
      await cubit.close();
      await coins.close();
    },
  );
  test(
    'manual block, unlimited and redemption flags round trip independently',
    () {
      final model = ChildAppUsageModel.fromJson({
        'app_slug': 'roblox',
        'display_name': 'Roblox',
        'is_blocked': true,
        'is_limited': false,
        'can_redeem': true,
        'daily_limit_minutes': 0,
      });
      expect(model.isBlocked, isTrue);
      expect(model.isLimited, isFalse);
      expect(model.canRedeem, isTrue);
      expect(
        model.copyWith(dailyLimitMinutes: 15).toRuleJson()['is_blocked'],
        isTrue,
      );
      expect(
        model.copyWith(isBlocked: false).toRuleJson()['is_blocked'],
        isFalse,
      );
    },
  );
  test('permission revocation on resume never remains active', () async {
    final native = NativeFake();
    final cubit = ChildAppBlockCubit(native, RulesFake(), ProfileFake());
    await cubit.start();
    expect(cubit.state.status, AppBlockStatus.active);
    native.usage = false;
    await cubit.onResumed();
    expect(cubit.state.status, AppBlockStatus.needsPermissions);
    expect(native.starts, 1);
    await cubit.close();
  });
  test(
    'first sync failure is visible; cached offline budgets remain usable',
    () async {
      final native = NativeFake()..failStart = true;
      final cubit = ChildAppBlockCubit(native, RulesFake(), ProfileFake());
      await cubit.start();
      expect(cubit.state.status, AppBlockStatus.error);
      native.cached = true;
      await cubit.onResumed();
      expect(cubit.state.status, AppBlockStatus.active);
      native.running = false;
      await cubit.onResumed();
      expect(cubit.state.status, AppBlockStatus.error);
      await cubit.close();
    },
  );
}
