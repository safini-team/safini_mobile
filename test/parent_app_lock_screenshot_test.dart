import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/network/auth_token_provider.dart';
import 'package:safini/core/network/authenticated_http_client.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds_toast.dart';
import 'package:safini/features/common/auth/data/auth_apple_sign_in_service.dart';
import 'package:safini/features/common/auth/data/auth_email_sign_in_service.dart';
import 'package:safini/features/common/auth/data/auth_google_sign_in_service.dart';
import 'package:safini/features/common/auth/data/user_me_service.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_state.dart';
import 'package:safini/features/parent/data/datasources/local/parent_app_lock_store.dart';
import 'package:safini/features/parent/domain/parent_pin_hasher.dart';
import 'package:safini/features/parent/presentation/cubit/app_lock/parent_app_lock_cubit.dart';
import 'package:safini/features/parent/presentation/screens/app_lock/parent_app_lock_settings_screen.dart';
import 'package:safini/features/parent/presentation/widgets/app_lock/parent_app_lock_host.dart';

/// Widget-test captures of the parent PIN gate and settings. Written to
/// `artifacts/` (and the cloud-agent screenshots folder when present). These
/// are not device shots: Linux has no iOS simulator here.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadScreenshotFonts);

  testWidgets('write parent app-lock screenshots', (tester) async {
    tester.view
      ..physicalSize = const Size(402, 874) * 2
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final store = MemoryParentAppLockStore();
    final lock = ParentAppLockCubit(
      store: store,
      hasher: const ParentPinHasher(),
    );
    addTearDown(lock.close);
    final auth = _SeededAuth()..seed('parent');
    addTearDown(auth.close);

    await store.write(const ParentPinHasher().hash('2580'));
    await tester.pumpWidget(
      _app(
        auth: auth,
        lock: lock,
        home: const ParentAppLockHost(
          child: Scaffold(body: Center(child: Text('Today'))),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await _save(tester, 'parent-app-lock-gate');

    await tester.tap(find.byKey(const ValueKey('app-lock-digit-0')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('app-lock-digit-0')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('app-lock-digit-0')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('app-lock-digit-0')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await _save(tester, 'parent-app-lock-gate-wrong-pin');

    final settingsStore = MemoryParentAppLockStore();
    final settingsLock = ParentAppLockCubit(
      store: settingsStore,
      hasher: const ParentPinHasher(),
    );
    addTearDown(settingsLock.close);
    await settingsLock.load();

    await tester.pumpWidget(
      _app(
        auth: auth,
        lock: settingsLock,
        home: const ParentAppLockSettingsScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await _save(tester, 'parent-app-lock-settings');

    await tester.tap(find.byKey(const ValueKey('app-lock-toggle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await _save(tester, 'parent-app-lock-settings-create');

    await _enterPin(tester, '2580');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await _save(tester, 'parent-app-lock-settings-confirm');

    await _enterPin(tester, '2580');
    await tester.pump();
    DsToast.dismiss();
    await tester.pump(const Duration(seconds: 3));
    await _save(tester, 'parent-app-lock-settings-on');

    await tester.tap(find.text('Change PIN'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await _save(tester, 'parent-app-lock-settings-change');
  }, timeout: const Timeout(Duration(seconds: 60)));
}

Future<void> _enterPin(WidgetTester tester, String pin) async {
  for (final digit in pin.split('')) {
    await tester.tap(find.byKey(ValueKey('app-lock-digit-$digit')));
    await tester.pump();
  }
}

class _FakeTokens implements AuthTokenProvider {
  @override
  bool hasSession = true;

  @override
  String? currentAccessToken;

  @override
  Future<String?> getAccessToken() async => currentAccessToken;

  @override
  Future<String?> refreshAfterUnauthorized(String? rejectedAccessToken) async =>
      currentAccessToken;
}

class _SeededAuth extends AuthSessionCubit {
  _SeededAuth()
    : super(
        AuthGoogleSignInService(),
        AuthAppleSignInService(),
        AuthEmailSignInService(),
        UserMeService(AuthenticatedHttpClient(_FakeTokens())),
        _FakeTokens(),
      );

  void seed(String? accountType) {
    emit(
      AuthSessionState(
        status: AuthSessionStatus.authenticated,
        userId: 'user-1',
        accountType: accountType,
      ),
    );
  }
}

const _screenshotText = TextStyle(
  fontFamily: 'NotoSans',
  fontFamilyFallback: ['NotoColorEmoji'],
);

Future<void> _loadScreenshotFonts() async {
  Future<ByteData> bytes(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      return ByteData(0);
    }
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

Widget _app({
  required AuthSessionCubit auth,
  required ParentAppLockCubit lock,
  required Widget home,
}) {
  return RepaintBoundary(
    child: MultiBlocProvider(
      providers: [
        BlocProvider.value(value: auth),
        BlocProvider.value(value: lock),
      ],
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
        home: home,
      ),
    ),
  );
}

Future<void> _save(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byType(RepaintBoundary).first,
    );
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
      } catch (_) {
        // The cloud-agent folder is optional on CI.
      }
    }
  });
}
