import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/version_gate/hard_update_gate.dart';
import 'package:safini/core/version_gate/version_gate_cubit.dart';
import 'package:safini/core/version_gate/version_gate_host.dart';
import 'package:safini/core/version_gate/version_policy.dart';
import 'package:safini/core/version_gate/version_policy_client.dart';
import 'package:safini/core/version_gate/version_policy_store.dart';
import 'package:safini/core/version_gate/version_update_launcher.dart';

void main() {
  late _FakeClient client;
  late VersionPolicyStore store;
  late VersionGateCubit cubit;
  late List<Uri> opened;

  setUp(() {
    client = _FakeClient();
    store = VersionPolicyStore(null);
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

  testWidgets('hard gate covers the app and cannot be popped', (tester) async {
    client.policy = _hardPolicy;
    await tester.pumpWidget(_app(cubit, child: const Text('Today')));
    await tester.pump();
    await tester.pump();

    expect(find.byType(HardUpdateGate), findsOneWidget);
    expect(find.text('Update required'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('version-gate-hard-update')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('version-gate-soft-dismiss')),
      findsNothing,
    );

    final popScope = tester.widget<PopScope>(find.byType(PopScope).first);
    expect(popScope.canPop, isFalse);

    await tester.tap(find.byKey(const ValueKey('version-gate-hard-update')));
    await tester.pump();
    await tester.pump();
    expect(opened, isNotEmpty);
  });

  testWidgets('soft banner dismisses and stays dismissed', (tester) async {
    client.policy = _softPolicy;
    await tester.pumpWidget(_app(cubit, child: const Text('Today')));
    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(const ValueKey('version-gate-soft-banner')),
      findsOneWidget,
    );
    expect(find.text('Update available'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('version-gate-soft-dismiss')));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('version-gate-soft-banner')),
      findsNothing,
    );
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('silent policy shows no gate UI', (tester) async {
    client.policy = const VersionPolicy(
      android: PlatformVersionPolicy(
        minSupported: '1.0.0',
        latestRecommended: '1.0.8',
        storeUrl: kPlayStoreListingUrl,
      ),
      ios: PlatformVersionPolicy(
        minSupported: '1.0.0',
        latestRecommended: '1.0.8',
        storeUrl: '',
      ),
    );
    await tester.pumpWidget(_app(cubit, child: const Text('Today')));
    await tester.pump();
    await tester.pump();

    expect(find.byType(HardUpdateGate), findsNothing);
    expect(
      find.byKey(const ValueKey('version-gate-soft-banner')),
      findsNothing,
    );
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('Russian gate copy stays localized with English remote copy', (
    tester,
  ) async {
    client.policy = VersionPolicy(
      android: _hardPolicy.android,
      ios: _hardPolicy.ios,
      message: const VersionPolicyMessage(
        hardTitle: 'Remote update required',
        hardBody: 'Remote English body',
      ),
    );
    await tester.pumpWidget(
      _app(cubit, child: const Text('Today'), locale: const Locale('ru')),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Нужно обновить'), findsOneWidget);
    expect(find.text('Remote update required'), findsNothing);
  });

  testWidgets('Russian soft banner ignores English remote copy', (
    tester,
  ) async {
    client.policy = VersionPolicy(
      android: _softPolicy.android,
      ios: _softPolicy.ios,
      message: const VersionPolicyMessage(
        softTitle: 'Remote update available',
        softBody: 'Remote English body',
      ),
    );
    await tester.pumpWidget(
      _app(cubit, child: const Text('Today'), locale: const Locale('ru')),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Доступно обновление'), findsOneWidget);
    expect(find.text('Remote update available'), findsNothing);
  });
}

const _hardPolicy = VersionPolicy(
  android: PlatformVersionPolicy(
    minSupported: '9.0.0',
    latestRecommended: '9.0.0',
    storeUrl: kPlayStoreListingUrl,
  ),
  ios: PlatformVersionPolicy(
    minSupported: '9.0.0',
    latestRecommended: '9.0.0',
    storeUrl: '',
  ),
);

const _softPolicy = VersionPolicy(
  android: PlatformVersionPolicy(
    minSupported: '1.0.0',
    latestRecommended: '9.0.0',
    storeUrl: kPlayStoreListingUrl,
  ),
  ios: PlatformVersionPolicy(
    minSupported: '1.0.0',
    latestRecommended: '9.0.0',
    storeUrl: '',
  ),
);

class _FakeClient extends VersionPolicyClient {
  _FakeClient() : super(Dio());
  VersionPolicy? policy;
  @override
  Future<VersionPolicy?> fetch() async => policy;
}

Widget _app(
  VersionGateCubit cubit, {
  required Widget child,
  Locale locale = const Locale('en'),
}) {
  return BlocProvider.value(
    value: cubit,
    child: MaterialApp(
      theme: AppTheme.light,
      locale: locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: VersionGateHost(
        child: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}
