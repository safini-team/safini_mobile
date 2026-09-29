import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/core/utils/widgets/ds/ds_avatar.dart';
import 'package:safini/features/models/domain/controllers/family_controller.dart';
import 'package:safini/features/models/domain/controllers/task_controller.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_task_repository.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/done_task_sheet.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/review_sheet.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/task_timeline.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A review opens on the list row, which often has no `submitted_at`. The
/// sheet fetches the task so the parent can see when the child sent it, and
/// Ask to redo waits for an optional note before it sends.
void main() {
  final sent = DateTime.utc(2026, 9, 27, 13, 40);
  final decided = DateTime.utc(2026, 9, 27, 14, 5);

  ParentTaskInstanceModel pending({DateTime? submittedAt}) =>
      ParentTaskInstanceModel(
        id: 'bed',
        status: 'pending_approval',
        title: 'Make the bed',
        childId: 'amir',
        rewardCoins: 10,
        proofMode: 'text',
        submissionNote: 'Done',
        submittedAt: submittedAt,
      );

  Future<_Repo> pumpReview(
    WidgetTester tester,
    ParentTaskInstanceModel detail,
  ) async {
    SharedPreferences.setMockInitialValues({
      'parent_family_cache': jsonEncode({
        'id': 'family',
        'children': [
          {'id': 'amir', 'nickname': 'Amir', 'coins_balance': 0},
        ],
      }),
    });
    final prefs = await SharedPreferences.getInstance();
    final family = ParentFamilyCubit(_NoFamily(), prefs);
    final repo = _Repo(detail);
    final cubit = ParentTasksCubit(repo, family, _NoTasks());
    addTearDown(() async {
      await cubit.close();
      await family.close();
    });
    await tester.runAsync(() => cubit.loadTasks(childId: 'amir'));

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
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showReviewSheet(
                context,
                cubit: cubit,
                task: pending(),
                childName: 'Amir',
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return repo;
  }

  testWidgets('a review shows when the child sent it', (tester) async {
    await pumpReview(tester, pending(submittedAt: sent.toLocal()));

    final timeline = tester.widget<TaskTimeline>(find.byType(TaskTimeline));
    expect(timeline.events.single.title, 'Sent for approval');
    expect(timeline.events.single.when, isNotEmpty);
  });

  testWidgets('ask to redo can carry a note, and cancel does not send', (
    tester,
  ) async {
    final repo = await pumpReview(tester, pending(submittedAt: sent.toLocal()));

    await tester.tap(find.text('Ask to redo'));
    await tester.pumpAndSettle();
    expect(repo.reviews, 0);
    expect(find.text('What should they fix? Optional.'), findsOneWidget);
    expect(find.textContaining('Approve'), findsNothing);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Approve'), findsOneWidget);
    expect(repo.reviews, 0);

    await tester.tap(find.text('Ask to redo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Corners are still up');
    await tester.ensureVisible(find.text('Ask to redo'));
    await tester.tap(find.text('Ask to redo'));
    await tester.pumpAndSettle();

    expect(repo.reviews, 1);
    expect(repo.decision, 'rejected');
    expect(repo.note, 'Corners are still up');
  });

  testWidgets('a done task shows who sent it and which parent decided', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final family = ParentFamilyCubit(_NoFamily(), prefs);
    final detail = ParentTaskInstanceModel(
      id: 'bed',
      status: 'rejected',
      title: 'Make the bed',
      childId: 'amir',
      rewardCoins: 10,
      submittedAt: sent.toLocal(),
      reviewedAt: decided.toLocal(),
      reviewedByParent: const ReviewedByParentModel(
        userId: 'parent-1',
        displayName: 'Alex Smith',
        avatarUrl: 'https://cdn.example/alex.jpg',
      ),
    );
    final repo = _Repo(detail);
    final cubit = ParentTasksCubit(repo, family, _NoTasks());
    addTearDown(() async {
      await cubit.close();
      await family.close();
    });

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
        home: BlocProvider.value(
          value: cubit,
          child: Scaffold(
            body: DoneTaskSheet(task: pending(), childName: 'Amir'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final timeline = tester.widget<TaskTimeline>(find.byType(TaskTimeline));
    expect(timeline.events, hasLength(2));
    expect(timeline.events.first.title, 'Sent for approval');
    expect(timeline.events.last.title, 'Asked to redo by Alex Smith');
    expect(timeline.events.last.reviewerName, 'Alex Smith');
    expect(
      timeline.events.last.reviewerAvatarUrl,
      'https://cdn.example/alex.jpg',
    );
    final avatar = tester.widget<DsInitialAvatar>(find.byType(DsInitialAvatar));
    expect(avatar.name, 'Alex Smith');
    expect(avatar.imageUrl, 'https://cdn.example/alex.jpg');
    expect(
      tester.getTopLeft(find.text('Sent for approval')).dy,
      lessThan(tester.getTopLeft(find.text('Asked to redo by Alex Smith')).dy),
    );
  });

  testWidgets('a done task resolves the reviewer from the family by id', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'parent_family_cache': jsonEncode({
        'id': 'family',
        'parents': [
          {
            'user_id': 'parent-1',
            'display_name': 'Alex Smith',
            'avatar_url': 'https://cdn.example/alex.jpg',
          },
        ],
      }),
    });
    final prefs = await SharedPreferences.getInstance();
    final family = ParentFamilyCubit(_NoFamily(), prefs);
    final detail = ParentTaskInstanceModel(
      id: 'bed',
      status: 'approved',
      title: 'Make the bed',
      reviewedAt: decided.toLocal(),
      reviewedByUserId: 'parent-1',
    );
    final cubit = ParentTasksCubit(_Repo(detail), family, _NoTasks());
    addTearDown(() async {
      await cubit.close();
      await family.close();
    });

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
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ParentFamilyCubit>.value(value: family),
            BlocProvider<ParentTasksCubit>.value(value: cubit),
          ],
          child: Scaffold(body: DoneTaskSheet(task: detail)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final timeline = tester.widget<TaskTimeline>(find.byType(TaskTimeline));
    expect(timeline.events.single.title, 'Approved by Alex Smith');
    expect(
      timeline.events.single.reviewerAvatarUrl,
      'https://cdn.example/alex.jpg',
    );
  });
}

class _Repo extends Fake implements IParentTaskRepository {
  _Repo(this.detail);

  final ParentTaskInstanceModel detail;
  String? decision;
  String? note;
  int reviews = 0;

  @override
  Future<Either<Failure, ParentTasksResponseModel>> fetchTasks(
    String childId,
  ) async => Right(
    ParentTasksResponseModel(
      tasks: [
        ParentTaskInstanceModel(
          id: detail.id,
          status: 'pending_approval',
          title: detail.title,
          childId: detail.childId,
          rewardCoins: detail.rewardCoins,
          proofMode: 'text',
        ),
      ],
    ),
  );

  @override
  Future<Either<Failure, ParentTaskInstanceModel>> fetchTask(
    String taskId,
  ) async => Right(detail);

  @override
  Future<Either<Failure, void>> reviewTask(
    String taskId, {
    required String decision,
    String? note,
  }) async {
    reviews += 1;
    this.decision = decision;
    this.note = note;
    return const Right(null);
  }
}

class _NoFamily extends Fake implements FamilyController {}

class _NoTasks extends Fake implements TaskController {}
