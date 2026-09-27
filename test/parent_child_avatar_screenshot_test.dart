import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/child_avatar_look.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/design_preview_data.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';
import 'package:safini/features/parent/presentation/screens/family/parent_family_view.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart';
import 'package:safini/features/parent/presentation/screens/tasks/parent_tasks_view.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/task_sheet.dart';

/// Widget-test captures of the parent surfaces that now show in-app child
/// faces. Written to `artifacts/` (and the cloud-agent screenshots folder when
/// present). These are not device shots: Linux has no iOS simulator here.
void main() {
  setUpAll(_loadScreenshotFonts);

  testWidgets('write parent child-avatar screenshots', (tester) async {
    tester.view
      ..physicalSize = const Size(402, 874) * 2
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await _capture(
      tester,
      filename: 'parent-child-switcher',
      child: ParentTodayView(
        data: SampleData.parentToday,
        onSelectKid: (_) {},
        onOpenSettings: () {},
        onOpenReview: (_) {},
        onApproveReview: (_) {},
        onOpenLimits: () {},
      ),
    );

    await _capture(
      tester,
      filename: 'parent-family-children',
      child: ParentFamilyView(
        data: SampleData.parentFamily,
        onOpenParent: (_) {},
        onInviteParent: () {},
        onOpenChild: (_) {},
        onAddChild: () {},
        onOpenSettings: () {},
      ),
    );

    await _capture(
      tester,
      filename: 'parent-tasks',
      child: Builder(
        builder: (context) => ParentTasksView(
          data: SampleData.parentTasks(S.of(context)),
          onSelectScope: (_) {},
          onSelectLane: (_) {},
          onOpenTask: (_) {},
          onNewTask: () {},
        ),
      ),
    );

    await _capturePickerMenu(tester);
    await _captureTaskCreate(tester);
  });
}

Future<void> _capturePickerMenu(WidgetTester tester) async {
  await tester.pumpWidget(
    _app(
      Scaffold(
        backgroundColor: const Color(0xFFF7F5F0),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Align(
            alignment: Alignment.topLeft,
            child: DsKidPicker(
              selectedKey: 'amir',
              onSelect: (_) {},
              options: const [
                DsPickerOption(
                  key: 'amir',
                  label: 'Amir',
                  color: Color(0xFF1A5C4A),
                  avatar: ChildAvatarLook(
                    faceEmoji: '😎',
                    accessoryEmoji: '🦸',
                    hasCustomFace: true,
                  ),
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
      ),
    ),
  );
  await tester.pump();
  await tester.tap(find.text('Amir'));
  await tester.pumpAndSettle();
  await _save(tester, 'parent-child-switcher-menu');
}

Future<void> _captureTaskCreate(WidgetTester tester) async {
  final family = _Family();
  final tasks = _Tasks();
  await tester.pumpWidget(
    _app(
      MultiBlocProvider(
        providers: [
          BlocProvider<ParentFamilyCubit>.value(value: family),
          BlocProvider<ParentTasksCubit>.value(value: tasks),
        ],
        child: const Scaffold(
          backgroundColor: Color(0xFFF7F5F0),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: TaskSheet(childId: 'amir'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await _save(tester, 'parent-task-create');
}

Future<void> _capture(
  WidgetTester tester, {
  required String filename,
  required Widget child,
}) async {
  await tester.pumpWidget(_app(child));
  await tester.pump(const Duration(milliseconds: 400));
  await _save(tester, filename);
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
}

Widget _app(Widget child) {
  return RepaintBoundary(
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
      builder: (context, appChild) => DefaultTextStyle.merge(
        style: _screenshotText,
        child: appChild ?? const SizedBox.shrink(),
      ),
      home: child,
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

class _Family extends Fake implements ParentFamilyCubit {
  @override
  ParentFamilyState get state => ParentFamilyState.initial(
    family: FamilyModel.fromJson({
      'id': 'family',
      'children': [
        {
          'id': 'amir',
          'nickname': 'Amir',
          'avatar_state': {
            'emojis': {'face': '😎'},
            'equipped': {'outfit': 'cosmic-cape'},
          },
        },
        {
          'id': 'layla',
          'nickname': 'Layla',
          'avatar_state': {
            'emojis': {'face': '🥰'},
            'equipped': {'outfit': 'rocket-pack'},
          },
        },
      ],
    }),
  );

  @override
  Stream<ParentFamilyState> get stream => const Stream.empty();
}

class _Tasks extends Fake implements ParentTasksCubit {
  @override
  ParentTasksState get state =>
      const ParentTasksLoaded(childId: 'amir', childName: 'Amir', tasks: []);

  @override
  Stream<ParentTasksState> get stream => const Stream.empty();
}
