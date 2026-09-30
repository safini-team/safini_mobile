import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safini/core/utils/constants/api_const.dart';
import 'package:safini/core/version_gate/app_version.dart';
import 'package:safini/core/version_gate/version_gate_cubit.dart';
import 'package:safini/core/version_gate/version_gate_tier.dart';
import 'package:safini/core/version_gate/version_policy.dart';
import 'package:safini/core/version_gate/version_policy_client.dart';
import 'package:safini/core/version_gate/version_policy_store.dart';
import 'package:safini/core/version_gate/version_update_launcher.dart';

void main() {
  test('policy endpoint matches safini-api GET /v1/system/version-policy', () {
    expect(ApiConst.versionPolicy, '/v1/system/version-policy');
  });

  group('compareAppVersions', () {
    test('orders major.minor.patch', () {
      expect(compareAppVersions('1.0.8', '1.0.9'), lessThan(0));
      expect(compareAppVersions('1.1.0', '1.0.9'), greaterThan(0));
      expect(compareAppVersions('2.0.0', '1.9.9'), greaterThan(0));
      expect(compareAppVersions('1.0.8', '1.0.8'), 0);
    });

    test('treats missing segments as zero and ignores build metadata', () {
      expect(compareAppVersions('1.4', '1.4.0'), 0);
      expect(compareAppVersions('1', '1.0.0'), 0);
      expect(compareAppVersions('1.0.8+12', '1.0.8'), 0);
      expect(compareAppVersions('1.0.8+12', '1.0.9'), lessThan(0));
    });

    test('pre-release is below the same numbers without a suffix', () {
      expect(compareAppVersions('1.4.0-beta', '1.4.0'), lessThan(0));
      expect(compareAppVersions('1.4.0', '1.4.0-beta'), greaterThan(0));
      expect(compareAppVersions('1.4.0-beta', '1.4.0-beta'), 0);
    });

    test('unparseable input is null so callers can fail open', () {
      expect(compareAppVersions('nope', '1.0.0'), isNull);
      expect(compareAppVersions('1.0.0', ''), isNull);
      expect(AppVersion.tryParse(''), isNull);
      expect(AppVersion.tryParse('1.2.3.4.5'), isNull);
    });
  });

  group('selectVersionGateTier', () {
    test('hard below min, soft below recommended, silent at or above', () {
      expect(
        selectVersionGateTier(
          installed: '1.0.7',
          minSupported: '1.0.8',
          latestRecommended: '1.1.0',
        ),
        VersionGateTier.hard,
      );
      expect(
        selectVersionGateTier(
          installed: '1.0.8',
          minSupported: '1.0.8',
          latestRecommended: '1.1.0',
        ),
        VersionGateTier.soft,
      );
      expect(
        selectVersionGateTier(
          installed: '1.0.9',
          minSupported: '1.0.8',
          latestRecommended: '1.1.0',
        ),
        VersionGateTier.soft,
      );
      expect(
        selectVersionGateTier(
          installed: '1.1.0',
          minSupported: '1.0.8',
          latestRecommended: '1.1.0',
        ),
        VersionGateTier.silent,
      );
      expect(
        selectVersionGateTier(
          installed: '1.2.0',
          minSupported: '1.0.8',
          latestRecommended: '1.1.0',
        ),
        VersionGateTier.silent,
      );
    });

    test('bad versions fail open to silent', () {
      expect(
        selectVersionGateTier(
          installed: 'built-from-source',
          minSupported: '1.0.0',
          latestRecommended: '1.1.0',
        ),
        VersionGateTier.silent,
      );
    });
  });

  group('VersionPolicy.tryParse', () {
    test('reads the SAF-203 contract', () {
      final policy = VersionPolicy.tryParse({
        'android': {
          'min_supported': '1.0.0',
          'latest_recommended': '1.0.8',
          'store_url': kPlayStoreListingUrl,
        },
        'ios': {
          'min_supported': '1.0.0',
          'latest_recommended': '1.0.8',
          'store_url': 'https://apps.apple.com/app/id123',
        },
        'message': {
          'hard_title': 'Update required',
          'hard_body': 'Please update',
          'soft_title': 'Update available',
          'soft_body': 'A newer version is ready.',
        },
      });
      expect(policy, isNotNull);
      expect(policy!.android.minSupported, '1.0.0');
      expect(policy.ios.storeUrl, 'https://apps.apple.com/app/id123');
      expect(policy.message!.softTitle, 'Update available');
      expect(
        VersionPolicy.tryParse(policy.toJson())!.android.latestRecommended,
        '1.0.8',
      );
    });

    test('rejects a missing platform or unparseable version', () {
      expect(VersionPolicy.tryParse({'android': {}}), isNull);
      expect(
        VersionPolicy.tryParse({
          'android': {
            'min_supported': 'nope',
            'latest_recommended': '1.0.0',
            'store_url': '',
          },
          'ios': {
            'min_supported': '1.0.0',
            'latest_recommended': '1.0.0',
            'store_url': '',
          },
        }),
        isNull,
      );
    });
  });

  test('iOS store URL stays on the Safini App Store listing', () {
    const ios = PlatformVersionPolicy(
      minSupported: '1.0.0',
      latestRecommended: '1.1.0',
      storeUrl: 'https://apps.apple.com/app/id0000000000',
    );
    expect(ios.effectiveStoreUrl(isIos: true), kAppStoreListingUrl);
    expect(
      const PlatformVersionPolicy(
        minSupported: '1.0.0',
        latestRecommended: '1.1.0',
        storeUrl: kPlayStoreListingUrl,
      ).effectiveStoreUrl(isIos: true),
      kAppStoreListingUrl,
    );
    expect(
      const PlatformVersionPolicy(
        minSupported: '1.0.0',
        latestRecommended: '1.1.0',
        storeUrl: 'https://apps.apple.com/us/app/safini/id6761075183',
      ).effectiveStoreUrl(isIos: true),
      'https://apps.apple.com/us/app/safini/id6761075183',
    );
    expect(
      VersionPolicy.forced(
        VersionGateForce.hard,
      ).ios.effectiveStoreUrl(isIos: true),
      kAppStoreListingUrl,
    );
  });

  group('VersionGateCubit', () {
    late _FakeClient client;
    late VersionPolicyStore store;
    late List<Uri> opened;
    late VersionGateCubit cubit;

    const current = VersionPolicy(
      android: PlatformVersionPolicy(
        minSupported: '1.0.0',
        latestRecommended: '1.0.8',
        storeUrl: kPlayStoreListingUrl,
      ),
      ios: PlatformVersionPolicy(
        minSupported: '1.0.0',
        latestRecommended: '1.0.8',
        storeUrl: 'https://apps.apple.com/app/id123',
      ),
    );

    const hard = VersionPolicy(
      android: PlatformVersionPolicy(
        minSupported: '2.0.0',
        latestRecommended: '2.0.0',
        storeUrl: kPlayStoreListingUrl,
      ),
      ios: PlatformVersionPolicy(
        minSupported: '2.0.0',
        latestRecommended: '2.0.0',
        storeUrl: 'https://apps.apple.com/us/app/safini/id6761075183',
      ),
    );

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      client = _FakeClient();
      store = VersionPolicyStore(prefs);
      opened = [];
      cubit = VersionGateCubit(
        client: client,
        store: store,
        launcher: VersionUpdateLauncher(
          startImmediate: () async => false,
          startFlexible: () async => false,
          openUrl: (uri) async {
            opened.add(uri);
            return true;
          },
        ),
        installedVersion: () async => '1.0.8',
        isIos: () => false,
      );
    });

    tearDown(() => cubit.close());

    test('silent when installed meets recommended', () async {
      client.policy = current;
      await cubit.refresh();
      expect(cubit.state.tier, VersionGateTier.silent);
      expect(cubit.state.blocksApp, isFalse);
      expect(cubit.state.showSoftBanner, isFalse);
    });

    test('soft banner until dismissed for that recommended version', () async {
      client.policy = const VersionPolicy(
        android: PlatformVersionPolicy(
          minSupported: '1.0.0',
          latestRecommended: '1.1.0',
          storeUrl: kPlayStoreListingUrl,
        ),
        ios: PlatformVersionPolicy(
          minSupported: '1.0.0',
          latestRecommended: '1.1.0',
          storeUrl: '',
        ),
      );
      await cubit.refresh();
      expect(cubit.state.tier, VersionGateTier.soft);
      expect(cubit.state.showSoftBanner, isTrue);

      await cubit.dismissSoft();
      expect(cubit.state.showSoftBanner, isFalse);

      await cubit.refresh();
      expect(cubit.state.showSoftBanner, isFalse);

      client.policy = const VersionPolicy(
        android: PlatformVersionPolicy(
          minSupported: '1.0.0',
          latestRecommended: '1.2.0',
          storeUrl: kPlayStoreListingUrl,
        ),
        ios: PlatformVersionPolicy(
          minSupported: '1.0.0',
          latestRecommended: '1.2.0',
          storeUrl: '',
        ),
      );
      await cubit.refresh();
      expect(cubit.state.showSoftBanner, isTrue);
    });

    test(
      'hard only after a successful fetch, never because fetch failed',
      () async {
        client.policy = hard;
        await cubit.refresh();
        expect(cubit.state.blocksApp, isTrue);
        expect(store.readPolicy(), isNotNull);

        client.policy = null;
        await cubit.refresh();
        expect(cubit.state.blocksApp, isFalse);
        expect(cubit.state.tier, VersionGateTier.soft);
        expect(cubit.state.fromCache, isTrue);
      },
    );

    test(
      'fails open to silent when there is no cache and fetch fails',
      () async {
        client.policy = null;
        await cubit.refresh();
        expect(cubit.state.tier, VersionGateTier.silent);
        expect(cubit.state.blocksApp, isFalse);
      },
    );

    test('opens the Play listing after a failed in-app update', () async {
      client.policy = hard;
      await cubit.refresh();
      await cubit.openStore();
      expect(opened, [Uri.parse(kPlayStoreListingUrl)]);
    });

    test('iOS uses the policy store URL', () async {
      await cubit.close();
      cubit = VersionGateCubit(
        client: client,
        store: store,
        launcher: VersionUpdateLauncher(
          startImmediate: () async => false,
          startFlexible: () async => false,
          openUrl: (uri) async {
            opened.add(uri);
            return true;
          },
        ),
        installedVersion: () async => '1.0.8',
        isIos: () => true,
      );
      client.policy = hard;
      await cubit.refresh();
      await cubit.openStore();
      expect(opened, [
        Uri.parse('https://apps.apple.com/us/app/safini/id6761075183'),
      ]);
    });

    test('unknown installed version never triggers a hard gate', () async {
      await cubit.close();
      cubit = VersionGateCubit(
        client: client,
        store: store,
        launcher: VersionUpdateLauncher(
          startImmediate: () async => false,
          startFlexible: () async => false,
          openUrl: (_) async => true,
        ),
        installedVersion: () async => '',
        isIos: () => false,
      );
      client.policy = hard;
      await cubit.refresh();
      expect(cubit.state.tier, VersionGateTier.silent);
      expect(cubit.state.blocksApp, isFalse);
    });
  });
}

class _FakeClient extends VersionPolicyClient {
  _FakeClient() : super(Dio());

  VersionPolicy? policy;

  @override
  Future<VersionPolicy?> fetch() async => policy;
}
