import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/utils/widgets/ds/ds_tab_bar.dart';

/// Android draws its navigation bar - back, home and recents, or the gesture
/// handle - inside the bottom inset. The tab bar used to pad that inset like
/// an iPhone home indicator, `inset - 8`, so on a 3-button phone the labels
/// sat 8dp under the system buttons.
void main() {
  Future<Rect> tabsLabel(
    WidgetTester tester, {
    required TargetPlatform platform,
    required double inset,
    double right = 0,
    Size size = const Size(412, 915),
  }) async {
    debugDefaultTargetPlatformOverride = platform;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    tester.view.viewPadding = FakeViewPadding(bottom: inset, right: right);
    tester.view.padding = FakeViewPadding(bottom: inset, right: right);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          extendBody: true,
          body: const SizedBox.expand(),
          bottomNavigationBar: DsTabBar(
            currentIndex: 0,
            onTap: (_) {},
            items: [
              for (final label in ['Today', 'Tasks', 'Limits', 'Family'])
                DsTabItem(
                  label: label,
                  builder: (color) => Icon(Icons.circle, color: color),
                ),
            ],
          ),
        ),
      ),
    );
    final rect = tester.getRect(find.text('Family'));
    debugDefaultTargetPlatformOverride = null;
    return rect;
  }

  testWidgets('labels sit above the 3-button navigation bar', (tester) async {
    final label = await tabsLabel(
      tester,
      platform: TargetPlatform.android,
      inset: 48,
    );
    expect(label.bottom, lessThanOrEqualTo(915 - 48 - 8));
  });

  testWidgets('labels sit above the gesture handle', (tester) async {
    final label = await tabsLabel(
      tester,
      platform: TargetPlatform.android,
      inset: 24,
    );
    expect(label.bottom, lessThanOrEqualTo(915 - 24 - 8));
  });

  testWidgets('in landscape the tabs step in from a side navigation bar', (
    tester,
  ) async {
    await tabsLabel(
      tester,
      platform: TargetPlatform.android,
      inset: 0,
      right: 48,
      size: const Size(915, 412),
    );
    // The whole tap target, not just the centred label, clears the buttons.
    final tab = find.ancestor(
      of: find.text('Family'),
      matching: find.byType(GestureDetector),
    );
    expect(tester.getRect(tab.first).right, lessThanOrEqualTo(915 - 48));
  });

  testWidgets('an iPhone keeps the artboard 26 under the labels', (
    tester,
  ) async {
    final label = await tabsLabel(
      tester,
      platform: TargetPlatform.iOS,
      inset: 34,
    );
    expect(915 - label.bottom, 26);
  });

  testWidgets('the bar only grows on Android', (tester) async {
    Future<double> extra(TargetPlatform platform, double inset) async {
      debugDefaultTargetPlatformOverride = platform;
      late double value;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(viewPadding: EdgeInsets.only(bottom: inset)),
          child: Builder(
            builder: (context) {
              value = DsTabBar.extraHeight(context);
              return const SizedBox();
            },
          ),
        ),
      );
      debugDefaultTargetPlatformOverride = null;
      return value;
    }

    expect(await extra(TargetPlatform.iOS, 34), 0);
    expect(await extra(TargetPlatform.iOS, 0), 0);
    expect(await extra(TargetPlatform.android, 0), 0);
    expect(await extra(TargetPlatform.android, 48), 30);
  });
}
