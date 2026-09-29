import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/version_gate/hard_update_gate.dart';
import 'package:safini/core/version_gate/version_gate_cubit.dart';
import 'package:safini/core/version_gate/version_gate_host.dart';
import 'package:safini/core/version_gate/version_policy.dart';
import 'package:safini/core/version_gate/version_policy_client.dart';
import 'package:safini/core/version_gate/version_policy_store.dart';
import 'package:safini/core/version_gate/version_update_launcher.dart';

/// Widget-test captures of the hard gate and soft banner. Device shots from
/// the local simulators are attached on the PR as well.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadScreenshotFonts);

  testWidgets('write version-gate screenshots', (tester) async {
    tester.view
      ..physicalSize = const Size(402, 874) * 2
      ..devicePixelRatio = 2
      ..padding = const FakeViewPadding(top: 54, bottom: 34);
    addTearDown(tester.view.reset);

    final hardKey = GlobalKey();
    final hard = _cubit(_hardPolicy);
    addTearDown(hard.close);
    await tester.pumpWidget(_app(hard, boundaryKey: hardKey));
    await tester.pumpAndSettle();
    expect(find.byType(HardUpdateGate), findsOneWidget);
    await _save(tester, 'version-gate-hard', hardKey);

    final softKey = GlobalKey();
    final soft = _cubit(_softPolicy);
    addTearDown(soft.close);
    await tester.pumpWidget(_app(soft, boundaryKey: softKey));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('version-gate-soft-banner')),
      findsOneWidget,
    );
    await _save(tester, 'version-gate-soft', softKey);
  }, timeout: const Timeout(Duration(seconds: 60)));
}

VersionGateCubit _cubit(VersionPolicy policy) {
  final client = _FakeClient()..policy = policy;
  return VersionGateCubit(
    client: client,
    store: VersionPolicyStore(null),
    launcher: VersionUpdateLauncher(
      startImmediate: () async => false,
      startFlexible: () async => false,
      openUrl: (_) async => true,
    ),
    installedVersion: () async => '1.0.8',
    isIos: () => false,
  );
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

const _screenshotText = TextStyle(
  fontFamily: 'NotoSans',
  fontFamilyFallback: ['NotoColorEmoji'],
);

Widget _app(VersionGateCubit cubit, {required GlobalKey boundaryKey}) {
  return RepaintBoundary(
    key: boundaryKey,
    child: BlocProvider.value(
      value: cubit,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light.copyWith(
          textTheme: AppTheme.light.textTheme.apply(fontFamily: 'NotoSans'),
        ),
        locale: const Locale('en'),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        builder: (context, child) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(disableAnimations: true),
            child: DefaultTextStyle.merge(
              style: _screenshotText,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
        home: VersionGateHost(
          child: Scaffold(
            backgroundColor: AppColors.bgParent,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 160, 20, 0),
                child: Text('Today', style: AppText.largeTitle),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _loadScreenshotFonts() async {
  Future<ByteData> bytes(String path) async {
    final file = File(path);
    if (!file.existsSync()) return ByteData(0);
    final data = await file.readAsBytes();
    return ByteData.view(Uint8List.fromList(data).buffer);
  }

  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    var any = false;
    for (final path in paths) {
      if (!File(path).existsSync()) continue;
      loader.addFont(bytes(path));
      any = true;
    }
    if (any) await loader.load();
  }

  await load('NotoSans', [
    '/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf',
    '/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf',
    '/Library/Fonts/Arial.ttf',
    '/System/Library/Fonts/Supplemental/Arial.ttf',
  ]);
  await load('NotoColorEmoji', [
    '/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf',
  ]);
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '';
  await load('MaterialIcons', [
    if (flutterRoot.isNotEmpty)
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    '/home/ubuntu/sdk/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

Future<void> _save(
  WidgetTester tester,
  String name,
  GlobalKey boundaryKey,
) async {
  await tester.runAsync(() async {
    final boundary =
        boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = data!.buffer.asUint8List();
    for (final dir in [
      Directory('artifacts'),
      Directory('docs/pr-screenshots'),
      Directory('/opt/cursor/artifacts/screenshots'),
    ]) {
      try {
        await dir.create(recursive: true);
        await File('${dir.path}/$name.png').writeAsBytes(bytes);
      } catch (_) {}
    }
  });
}
