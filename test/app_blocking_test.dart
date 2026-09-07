import 'package:dartz/dartz.dart';
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

void main() {
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
