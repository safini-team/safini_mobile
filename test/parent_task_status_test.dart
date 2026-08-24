import 'package:flutter_test/flutter_test.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';

/// The approve queue is driven entirely by string matching on `status`, and
/// the parser accepts a long list of key aliases per field. Both are places
/// where a backend rename lands as an empty screen rather than an error, so
/// they are pinned here.

ParentTaskInstanceModel _task(String status, {String id = 't1'}) =>
    ParentTaskInstanceModel(id: id, status: status, title: 'Made the bed');

void main() {
  group('isPendingApproval', () {
    for (final status in [
      'pending',
      'pending_approval',
      'awaiting_approval',
      'submitted',
    ]) {
      test('"$status" lands in the review queue', () {
        final task = _task(status);
        expect(task.isPendingApproval, isTrue);
        expect(task.isCompleted, isFalse);
      });
    }

    test('matching ignores case', () {
      expect(_task('SUBMITTED').isPendingApproval, isTrue);
      expect(_task('Pending_Approval').isPendingApproval, isTrue);
    });
  });

  group('isCompleted', () {
    for (final status in ['completed', 'done', 'approved']) {
      test('"$status" is finished', () {
        final task = _task(status);
        expect(task.isCompleted, isTrue);
        expect(task.isPendingApproval, isFalse);
      });
    }

    test('a finished task is locked against edits', () {
      // The backend answers 409 on an edit to an approved task, so the sheet
      // has to hide the controls rather than let the request go out.
      expect(_task('approved').isEditable, isFalse);
      expect(_task('active').isEditable, isTrue);
    });
  });

  test('an unrecognised status counts as active, not lost', () {
    // Anything the two predicates do not claim falls through to the active
    // bucket. That is the safe default: it shows up on screen either way.
    final task = _task('in_progress');
    expect(task.isPendingApproval, isFalse);
    expect(task.isCompleted, isFalse);
  });

  group('ParentTasksLoaded partitions every task exactly once', () {
    final tasks = [
      _task('submitted', id: 'a'),
      _task('pending', id: 'b'),
      _task('active', id: 'c'),
      _task('in_progress', id: 'd'),
      _task('approved', id: 'e'),
      _task('done', id: 'f'),
    ];
    final state = ParentTasksLoaded(
      childId: 'c1',
      childName: 'Amir',
      tasks: tasks,
    );

    test('splits into review / active / finished', () {
      expect(state.pendingApproval.map((t) => t.id), ['a', 'b']);
      expect(state.activeTasks.map((t) => t.id), ['c', 'd']);
      expect(state.completedTasks.map((t) => t.id), ['e', 'f']);
    });

    test('loses nothing and double-counts nothing', () {
      final grouped = [
        ...state.pendingApproval,
        ...state.activeTasks,
        ...state.completedTasks,
      ].map((t) => t.id).toList();

      expect(grouped.length, tasks.length);
      expect(grouped.toSet().length, tasks.length);
    });
  });

  group('fromJson accepts the aliases the API actually sends', () {
    test('reads the id from any of the three spellings', () {
      expect(ParentTaskInstanceModel.fromJson({'id': 'x'}).id, 'x');
      expect(ParentTaskInstanceModel.fromJson({'instance_id': 'y'}).id, 'y');
      expect(
        ParentTaskInstanceModel.fromJson({'task_instance_id': 'z'}).id,
        'z',
      );
    });

    test('reads the coin reward from snake, camel and legacy keys', () {
      int coins(Map<String, dynamic> json) =>
          ParentTaskInstanceModel.fromJson(json).rewardCoins ?? -1;

      expect(coins({'coin_reward': 10}), 10);
      expect(coins({'reward_coins': 11}), 11);
      expect(coins({'rewardCoins': 12}), 12);
      expect(coins({'coins_reward': 13}), 13);
      expect(coins({'coins': 14}), 14);
      expect(coins({'points': 15}), 15);
    });

    test('the first matching alias wins', () {
      final task = ParentTaskInstanceModel.fromJson({
        'coin_reward': 10,
        'points': 99,
      });
      expect(task.rewardCoins, 10);
    });

    test('displayTitle falls back to the id when there is no title', () {
      // Better a row labelled with an opaque id than a blank one - a blank
      // row reads as a rendering bug.
      final untitled = ParentTaskInstanceModel.fromJson({'id': 'inst-42'});
      expect(untitled.displayTitle, 'inst-42');

      final blank = ParentTaskInstanceModel.fromJson({
        'id': 'inst-42',
        'title': '   ',
      });
      expect(blank.displayTitle, 'inst-42');
    });

    test('the emoji comes out of metadata, blanks ignored', () {
      expect(
        ParentTaskInstanceModel.fromJson({
          'id': 't',
          'metadata': {'emoji': '🧹'},
        }).emoji,
        '🧹',
      );
      expect(
        ParentTaskInstanceModel.fromJson({
          'id': 't',
          'metadata': {'emoji': '  '},
        }).emoji,
        isNull,
      );
      expect(ParentTaskInstanceModel.fromJson({'id': 't'}).emoji, isNull);
    });
  });

  group('ParentTasksResponseModel', () {
    test('reads the list under any of its three keys', () {
      for (final key in ['tasks', 'today_instances', 'todayInstances']) {
        final parsed = ParentTasksResponseModel.fromJson({
          key: [
            {'id': 'a', 'status': 'active'},
          ],
        });
        expect(parsed.tasks.single.id, 'a', reason: 'key $key');
      }
    });

    test('an absent or malformed list is empty, not a throw', () {
      expect(ParentTasksResponseModel.fromJson({}).tasks, isEmpty);
      expect(
        ParentTasksResponseModel.fromJson({'tasks': 'nope'}).tasks,
        isEmpty,
      );
    });
  });
}
