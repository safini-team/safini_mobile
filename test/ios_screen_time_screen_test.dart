import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/child/data/services/screen_time_service.dart';
import 'package:safini/features/child/presentation/cubit/ios_screen_time_cubit.dart';
import 'package:safini/features/child/presentation/screens/screen_time/ios_screen_time_screen.dart';

void main() {
  for (final locale in ['en', 'ru', 'uz']) {
    testWidgets(
      'Screen Time setup fits a small screen with large $locale text',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final cubit = IosScreenTimeCubit(const ScreenTimeService(), Dio());
        getIt.registerSingleton<IosScreenTimeCubit>(cubit);
        addTearDown(() async {
          await getIt.reset();
          await cubit.close();
        });
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(locale),
            supportedLocales: S.delegate.supportedLocales,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            ),
            home: const IosScreenTimeScreen(),
          ),
        );
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(IosScreenTimeScreen));
        expect(find.text(S.of(context).iosScreenTimeFamily), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text(S.of(context).iosScreenTimePrivacy),
          180,
        );
        expect(find.text(S.of(context).iosScreenTimePrivacy), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
