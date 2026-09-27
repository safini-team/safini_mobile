import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/child_avatar_look.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/design_preview_data.dart';
import 'package:safini/features/parent/presentation/screens/family/parent_family_view.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart';
import 'package:safini/features/parent/presentation/screens/tasks/parent_tasks_view.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('en'),
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

void main() {
  const amir = ChildAvatarLook(
    faceEmoji: '😎',
    accessoryEmoji: '🦸',
    hasCustomFace: true,
  );

  testWidgets('DsKidFace draws the in-app face, never a network photo', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Scaffold(
          body: DsKidFace(
            name: 'Amir',
            color: Color(0xFF1A5C4A),
            avatar: amir,
            size: 38,
          ),
        ),
      ),
    );

    expect(find.text('😎'), findsOneWidget);
    expect(find.text('🦸'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(find.text('A'), findsNothing);
  });

  testWidgets('an unequipped child still gets the default smile', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Scaffold(
          body: DsKidFace(
            name: 'Amir',
            color: Color(0xFF1A5C4A),
            size: 38,
          ),
        ),
      ),
    );

    expect(find.text('😊'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('Everyone keeps the middot instead of a child face', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Scaffold(
          body: DsKidFace(
            name: 'Everyone',
            initial: '·',
            color: Color(0xFF64736D),
            size: 24,
          ),
        ),
      ),
    );

    expect(find.text('·'), findsOneWidget);
    expect(find.text('😊'), findsNothing);
  });

  testWidgets('the kid picker trigger shows the selected child face', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        Scaffold(
          body: DsKidPicker(
            selectedKey: 'amir',
            onSelect: (_) {},
            options: const [
              DsPickerOption(
                key: 'amir',
                label: 'Amir',
                color: Color(0xFF1A5C4A),
                avatar: amir,
              ),
              DsPickerOption(
                key: 'layla',
                label: 'Layla',
                color: Color(0xFF2E6F8E),
                avatar: ChildAvatarLook(
                  faceEmoji: '🥰',
                  accessoryEmoji: '🚀',
                  hasCustomFace: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('😎'), findsOneWidget);
    expect(find.byType(Image), findsNothing);

    await tester.tap(find.text('Amir'));
    await tester.pumpAndSettle();

    expect(find.text('😎'), findsWidgets);
    expect(find.text('🥰'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('parent Today, Tasks and Family render in-app faces', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(402, 874) * 2
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _host(
        ParentTodayView(
          data: SampleData.parentToday,
          onSelectKid: (_) {},
          onOpenSettings: () {},
          onOpenReview: (_) {},
          onApproveReview: (_) {},
          onOpenLimits: () {},
        ),
      ),
    );
    await tester.pump();
    expect(find.text('😎'), findsWidgets);
    expect(find.byType(DsChildAvatar), findsWidgets);
    expect(find.byType(Image), findsNothing);

    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) => ParentTasksView(
            data: SampleData.parentTasks(S.of(context)),
            onSelectScope: (_) {},
            onSelectLane: (_) {},
            onOpenTask: (_) {},
            onNewTask: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(DsChildAvatar), findsWidgets);
    expect(find.text('😎'), findsWidgets);
    expect(find.byType(Image), findsNothing);

    await tester.pumpWidget(
      _host(
        ParentFamilyView(
          data: SampleData.parentFamily,
          onOpenParent: (_) {},
          onInviteParent: () {},
          onOpenChild: (_) {},
          onAddChild: () {},
          onOpenSettings: () {},
        ),
      ),
    );
    await tester.pump();
    expect(find.text('😎'), findsOneWidget);
    expect(find.text('🥰'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('task create chips show each child face, not initials', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Scaffold(
          body: Wrap(
            spacing: 8,
            children: [
              DsKidChip(name: 'Everyone', showAvatar: false, selected: false),
              DsKidChip(
                name: 'Amir',
                color: Color(0xFF1A5C4A),
                avatar: amir,
                selected: true,
              ),
              DsKidChip(
                name: 'Layla',
                color: Color(0xFF2E6F8E),
                avatar: ChildAvatarLook(
                  faceEmoji: '🥰',
                  accessoryEmoji: '🚀',
                  hasCustomFace: true,
                ),
                selected: false,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('😎'), findsOneWidget);
    expect(find.text('🥰'), findsOneWidget);
    expect(find.text('A'), findsNothing);
    expect(find.text('L'), findsNothing);
    expect(find.byType(Image), findsNothing);
  });
}
