import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/models/domain/models/installed_app.dart';
import 'package:safini/features/parent/data/services/parent_app_blocking_service.dart';
import 'package:safini/features/parent/presentation/cubit/parent_installed_apps_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_installed_apps_state.dart';

/// SAF-191: for a child on an iPhone, "Add an app limit" said the apps show up
/// once the child opens Safini. An iPhone never sends that list, so the parent
/// waited forever.
class _Service extends Fake implements ParentAppBlockingService {
  _Service({required this.ios, this.apps = const []});

  final bool ios;
  final List<InstalledApp> apps;
  int iosChecks = 0;

  @override
  Future<Either<Failure, InstalledAppsSnapshot>> fetchInstalledApps(
    String childId,
  ) async => Right(InstalledAppsSnapshot(apps: apps));

  @override
  Future<bool> isIosDevice(String childId) async {
    iosChecks++;
    return ios;
  }
}

void main() {
  test('an empty list on an iPhone is marked as iOS', () async {
    final cubit = ParentInstalledAppsCubit(_Service(ios: true));
    await cubit.load('laylo');
    final state = cubit.state as ParentInstalledAppsLoaded;
    expect(state.isEmpty, isTrue);
    expect(state.iosDevice, isTrue);
  });

  test('an Android child that has not synced yet is not', () async {
    final cubit = ParentInstalledAppsCubit(_Service(ios: false));
    await cubit.load('aziz');
    expect((cubit.state as ParentInstalledAppsLoaded).iosDevice, isFalse);
  });

  test('a synced list skips the iPhone check', () async {
    final service = _Service(
      ios: false,
      apps: const [
        InstalledApp(packageName: 'com.android.chrome', appName: 'Chrome'),
      ],
    );
    final cubit = ParentInstalledAppsCubit(service);
    await cubit.load('aziz');
    expect((cubit.state as ParentInstalledAppsLoaded).apps, hasLength(1));
    expect(service.iosChecks, 0);
  });
}
