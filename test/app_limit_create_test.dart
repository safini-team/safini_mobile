import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/screens/apps/parent_limits_view.dart';
import 'package:safini/features/parent/presentation/widgets/apps/app_limit_sheet.dart';

class _AppsCubit extends Fake implements ParentAppsCubit {
  Map<String, Object?>? added;

  @override
  Future<String?> addApp({
    required String slug,
    required String name,
    required int dailyLimitMinutes,
    required int redeemCoinCost,
    required int redeemRewardMinutes,
    bool isBlocked = false,
    bool isLimited = true,
    bool canRedeem = true,
  }) async {
    added = {
      'slug': slug,
      'name': name,
      'limit': dailyLimitMinutes,
      'cost': redeemCoinCost,
      'reward': redeemRewardMinutes,
      'blocked': isBlocked,
      'limited': isLimited,
      'redeem': canRedeem,
    };
    return null;
  }
}

void main() {
  testWidgets('new installed app is saved only from the configuration sheet', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(402, 1000) * 3
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final cubit = _AppsCubit();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showAppLimitSheet(
                context,
                cubit: cubit,
                childName: 'Amir',
                isNew: true,
                app: const LimitsApp(
                  slug: 'com.example.video',
                  name: 'Video',
                  emoji: '📺',
                  usedMinutes: 0,
                  limitMinutes: 60,
                  isLimited: true,
                  canRedeem: true,
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(cubit.added, isNull);

    await tester.tap(find.text('Save for Amir'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    expect(cubit.added, {
      'slug': 'com.example.video',
      'name': 'Video',
      'limit': 60,
      'cost': 100,
      'reward': 30,
      'blocked': false,
      'limited': true,
      'redeem': true,
    });
  });
}
