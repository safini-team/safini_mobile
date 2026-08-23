import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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

/// Every English string the app can render, mapped back to its key. If one of
/// these turns up on screen while the app is in Russian or Uzbek, some call site
/// is still hardcoded.
late final Map<String, String> _englishToKey;
late final Map<String, Map<String, String>> _byLocale;

Map<String, String> _arb(String locale) {
  final raw = File(
    'lib/core/translation/l10n/intl_$locale.arb',
  ).readAsStringSync();
  return (jsonDecode(raw) as Map<String, dynamic>).map(
    (k, v) => MapEntry(k, v.toString()),
  )..removeWhere((k, _) => k.startsWith('@'));
}

/// Content the artboard's sample data supplies: task titles, kid names, app
/// names. These are user data, not chrome, and stay untranslated by design.
const Set<String> _sampleContent = {
  'Amir',
  'Layla',
  'Aisha Karimova',
  'Bekzod Karimov',
  'Nilufar',
  'Made the bed',
  'Maths homework, p. 41-42',
  'Tidy the room',
  'Clear the table',
  'Walk Rex',
  'Practise piano, 20 min',
  'Read 20 minutes',
  'Brush teeth, evening',
  'Roblox',
  'YouTube',
  'Telegram',
  'Spotify',
  'Duolingo',
  'Ice cream after school',
  'Pick the film on Friday',
  '30 extra minutes of Roblox',
  'Trip to the pool',
  'Safini',
  'Before dinner',
  'After dinner',
  'Sent 18:52',
  'Paid this morning',
  'Health · 21:00',
  'Every day',
  'Mon, Wed, Fri',
  'Weekdays',
  'Amir · 12 min ago',
  'Layla · 1 h ago',
  'Owner · aisha@icloud.com',
  'Parent · bekzod@gmail.com',
  'Invite sent 2 days ago',
};

Widget _host(Widget child, String locale) => MaterialApp(
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

/// Renders [child] in [locale] and fails on any string that is verbatim English
/// chrome with a different translation available.
Future<void> _expectNoEnglish(
  WidgetTester tester,
  WidgetBuilder builder, {
  required String locale,
  required String screen,
}) async {
  tester.view
    ..physicalSize = const Size(402, 874) * 3
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(_host(Builder(builder: builder), locale));
  await tester.pump(const Duration(milliseconds: 400));

  final leaks = <String>[];

  for (final element in find.byType(Text).evaluate()) {
    final text = (element.widget as Text).data;
    if (text == null || text.trim().isEmpty) continue;
    if (_sampleContent.contains(text)) continue;

    final key = _englishToKey[text];
    if (key == null) continue;

    final translated = _byLocale[locale]![key];
    if (translated == null || translated == text) continue;

    leaks.add('"$text" should be "$translated" ($key)');
  }

  expect(
    leaks,
    isEmpty,
    reason: '$screen leaks English in $locale:\n  ${leaks.join("\n  ")}',
  );
}

void main() {
  setUpAll(() {
    _byLocale = {
      for (final l in ['en', 'ru', 'uz']) l: _arb(l),
    };

    // Only plain strings can be matched verbatim; ICU templates render with
    // their placeholders filled and are covered by the catalogue tests.
    _englishToKey = {};
    _byLocale['en']!.forEach((key, value) {
      if (value.contains('{')) return;
      _englishToKey.putIfAbsent(value, () => key);
    });
  });

  for (final locale in ['ru', 'uz']) {
    group('$locale renders no English chrome', () {
      testWidgets('Parent Today', (tester) async {
        await _expectNoEnglish(
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
          screen: 'Parent Today',
        );
      });

      testWidgets('Parent Tasks', (tester) async {
        await _expectNoEnglish(
          tester,
          (context) => ParentTasksView(
            data: SampleData.parentTasks(S.of(context)),
            onSelectScope: (_) {},
            onSelectLane: (_) {},
            onOpenTask: (_) {},
            onNewTask: () {},
          ),
          locale: locale,
          screen: 'Parent Tasks',
        );
      });

      testWidgets('Parent Limits', (tester) async {
        await _expectNoEnglish(
          tester,
          (context) => ParentLimitsView(
            data: SampleData.parentLimits,
            onSelectKid: (_) {},
            onOpenApp: (_) {},
            onAddApp: () {},
          ),
          locale: locale,
          screen: 'Parent Limits',
        );
      });

      testWidgets('Parent Family', (tester) async {
        await _expectNoEnglish(
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
          screen: 'Parent Family',
        );
      });

      testWidgets('Kid Today', (tester) async {
        await _expectNoEnglish(
          tester,
          (context) => ChildTodayView(
            data: SampleData.kidToday(S.of(context)),
            onOpenStore: () {},
            onOpenTasks: () {},
            onOpenQuest: (_) {},
            onSendQuest: (_) {},
          ),
          locale: locale,
          screen: 'Kid Today',
        );
      });

      testWidgets('Kid Tasks', (tester) async {
        await _expectNoEnglish(
          tester,
          (context) => ChildTasksView(
            data: SampleData.kidTasks(S.of(context)),
            onSelectCategory: (_) {},
            onOpenTask: (_) {},
          ),
          locale: locale,
          screen: 'Kid Tasks',
        );
      });

      testWidgets('Kid Store', (tester) async {
        await _expectNoEnglish(
          tester,
          (context) => ChildStoreView(
            data: SampleData.kidStore(S.of(context)),
            onSelectTab: (_) {},
            onOpenCard: (_) {},
          ),
          locale: locale,
          screen: 'Kid Store',
        );
      });

      testWidgets('Kid Me', (tester) async {
        await _expectNoEnglish(
          tester,
          (context) => ChildMeView(
            data: SampleData.kidMe(S.of(context)),
            onChangeAvatar: () {},
            onEditName: () {},
          ),
          locale: locale,
          screen: 'Kid Me',
        );
      });

      testWidgets('tab bars', (tester) async {
        await _expectNoEnglish(
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
          screen: 'parent tab bar',
        );
      });
    });
  }
}
