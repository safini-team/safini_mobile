import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/design_preview_data.dart';
import 'package:safini/features/child/presentation/screens/home/child_today_view.dart';
import 'package:safini/features/child/presentation/screens/profile/child_me_view.dart';
import 'package:safini/features/child/presentation/screens/store/child_store_view.dart';
import 'package:safini/features/child/presentation/screens/tasks/child_tasks_view.dart';
import 'package:safini/features/parent/presentation/screens/apps/parent_limits_view.dart';
import 'package:safini/features/parent/presentation/screens/family/parent_family_view.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart';
import 'package:safini/features/parent/presentation/screens/tasks/parent_tasks_view.dart';

const List<String> _locales = ['en', 'ru', 'uz'];

/// The narrowest and widest phones we support. The artboard is drawn at 402pt;
/// the iPhone SE at 320pt is where longer Russian and Uzbek copy actually bites.
const List<({String name, Size size})> _devices = [
  (name: 'iPhone SE', size: Size(320, 568)),
  (name: 'artboard', size: Size(402, 874)),
];

Widget _host(Widget child, String locale) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    locale: Locale(locale),
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: child,
  );
}

/// Pumps [child] and fails if Flutter reported any layout error - which is how
/// a RenderFlex overflow surfaces.
Future<void> _pumpClean(
  WidgetTester tester,
  WidgetBuilder builder, {
  required String locale,
  required ({String name, Size size}) device,
  required String label,
}) async {
  tester.view
    ..physicalSize = device.size * 3
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final errors = <FlutterErrorDetails>[];
  final previous = FlutterError.onError;
  FlutterError.onError = errors.add;

  try {
    await tester.pumpWidget(_host(Builder(builder: builder), locale));
    await tester.pump(const Duration(milliseconds: 400));
  } finally {
    FlutterError.onError = previous;
  }

  expect(
    errors.map((e) => e.exceptionAsString()).toList(),
    isEmpty,
    reason: '$label overflows in $locale on ${device.name}',
  );
}

/// Every visible label must fit on the lines it was given.
void _expectNoClippedText(WidgetTester tester, String reason) {
  final clipped = <String>[];

  for (final element in find.byType(Text).evaluate()) {
    final render = element.renderObject;
    if (render is! RenderParagraph) continue;
    if (!render.didExceedMaxLines) continue;
    clipped.add((element.widget as Text).data ?? '');
  }

  expect(clipped, isEmpty, reason: '$reason clipped: ${clipped.join(", ")}');
}

void main() {
  for (final locale in _locales) {
    for (final device in _devices) {
      group('$locale on ${device.name}', () {
        testWidgets('Parent Today lays out cleanly', (tester) async {
          await _pumpClean(
            tester,
            (context) => ParentTodayView(
              data: SampleData.parentToday,
              onSelectKid: (_) {},
              onOpenSettings: () {},
              onOpenReview: (_) {},
              onApproveReview: (_) {},
              onOpenLimits: () {},
            ),
            locale: locale,
            device: device,
            label: 'Parent Today',
          );
        });

        testWidgets('Parent Tasks lays out cleanly', (tester) async {
          await _pumpClean(
            tester,
            (context) => ParentTasksView(
              data: SampleData.parentTasks(S.of(context)),
              onSelectScope: (_) {},
              onSelectLane: (_) {},
              onOpenTask: (_) {},
              onNewTask: () {},
            ),
            locale: locale,
            device: device,
            label: 'Parent Tasks',
          );
        });

        testWidgets('Parent Limits lays out cleanly', (tester) async {
          await _pumpClean(
            tester,
            (context) => ParentLimitsView(
              data: SampleData.parentLimits,
              onSelectKid: (_) {},
              onOpenApp: (_) {},
              onAddApp: () {},
            ),
            locale: locale,
            device: device,
            label: 'Parent Limits',
          );
        });

        // The capped panel puts an uppercased label and the stepper on one
        // row. "ЕЖЕДНЕВНОЕ ЭКРАННОЕ ВРЕМЯ" next to a 92pt control on a 320pt
        // phone is the tightest line on the screen.
        testWidgets('Parent Limits with a cap lays out cleanly', (
          tester,
        ) async {
          await _pumpClean(
            tester,
            (context) => ParentLimitsView(
              data: SampleData.parentLimitsWithCap,
              onSelectKid: (_) {},
              onOpenApp: (_) {},
              onAddApp: () {},
              onSetCap: (_) {},
            ),
            locale: locale,
            device: device,
            label: 'Parent Limits with a cap',
          );
        });

        testWidgets('Parent Family lays out cleanly', (tester) async {
          await _pumpClean(
            tester,
            (context) => ParentFamilyView(
              data: SampleData.parentFamily,
              onOpenParent: (_) {},
              onInviteParent: () {},
              onOpenChild: (_) {},
              onAddChild: () {},
              onOpenSettings: () {},
            ),
            locale: locale,
            device: device,
            label: 'Parent Family',
          );
        });

        testWidgets('Kid Today lays out cleanly', (tester) async {
          await _pumpClean(
            tester,
            (context) => ChildTodayView(
              data: SampleData.kidToday(S.of(context)),
              onOpenStore: () {},
              onOpenTasks: () {},
              onOpenQuest: (_) {},
              onSendQuest: (_) {},
            ),
            locale: locale,
            device: device,
            label: 'Kid Today',
          );
        });

        testWidgets('Kid Tasks lays out cleanly', (tester) async {
          await _pumpClean(
            tester,
            (context) => ChildTasksView(
              data: SampleData.kidTasks(S.of(context)),
              onSelectCategory: (_) {},
              onOpenTask: (_) {},
            ),
            locale: locale,
            device: device,
            label: 'Kid Tasks',
          );
        });

        testWidgets('Kid Store lays out cleanly', (tester) async {
          await _pumpClean(
            tester,
            (context) => ChildStoreView(
              data: SampleData.kidStore(S.of(context)),
              onSelectTab: (_) {},
              onOpenCard: (_) {},
            ),
            locale: locale,
            device: device,
            label: 'Kid Store',
          );
        });

        testWidgets('Kid Me lays out cleanly', (tester) async {
          await _pumpClean(
            tester,
            (context) => ChildMeView(
              data: SampleData.kidMe(S.of(context)),
              onChangeAvatar: () {},
              onEditName: () {},
            ),
            locale: locale,
            device: device,
            label: 'Kid Me',
          );
        });

        testWidgets('parent tab labels stay on one line', (tester) async {
          await _pumpClean(
            tester,
            (context) {
              final s = S.of(context);
              return Scaffold(
                bottomNavigationBar: DsTabBar(
                  currentIndex: 0,
                  onTap: (_) {},
                  items: [
                    DsTabItem(
                      label: s.tabToday,
                      builder: (c) => AppIcons.tabHome(color: c),
                    ),
                    DsTabItem(
                      label: s.tabTasks,
                      builder: (c) => AppIcons.tabTasksParent(color: c),
                      badge: 2,
                    ),
                    DsTabItem(
                      label: s.tabLimits,
                      builder: (c) => AppIcons.tabLimits(color: c),
                    ),
                    DsTabItem(
                      label: s.tabFamily,
                      builder: (c) => AppIcons.tabFamily(color: c),
                    ),
                  ],
                ),
              );
            },
            locale: locale,
            device: device,
            label: 'parent tab bar',
          );

          _expectNoClippedText(tester, 'parent tab bar in $locale');
        });

        testWidgets('child tab labels stay on one line', (tester) async {
          await _pumpClean(
            tester,
            (context) {
              final s = S.of(context);
              return Scaffold(
                bottomNavigationBar: DsTabBar.child(
                  currentIndex: 0,
                  onTap: (_) {},
                  items: [
                    DsTabItem(
                      label: s.tabToday,
                      builder: (c) => AppIcons.tabHome(color: c),
                    ),
                    DsTabItem(
                      label: s.tabTasks,
                      builder: (c) => AppIcons.tabTasksChild(color: c),
                    ),
                    DsTabItem(
                      label: s.tabStore,
                      builder: (c) => AppIcons.tabStore(color: c),
                    ),
                    DsTabItem(
                      label: s.tabMe,
                      builder: (c) => AppIcons.tabMe(color: c),
                    ),
                  ],
                ),
              );
            },
            locale: locale,
            device: device,
            label: 'child tab bar',
          );

          _expectNoClippedText(tester, 'child tab bar in $locale');
        });
      });
    }
  }

  group('tab metrics follow the copy-pressure rule', () {
    test('label size shrinks for Russian and Uzbek', () {
      expect(DsTabBar.metricsFor('en').label, 10.5);
      expect(DsTabBar.metricsFor('ru').label, 10);
      expect(DsTabBar.metricsFor('uz').label, 9.5);
      expect(DsTabBar.metricsFor('en').icon, 25);
      expect(DsTabBar.metricsFor('uz').icon, 23);
    });
  });
}
