import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/utils/widgets/ds/ds_kid_picker.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/presentation/screens/monitor/pending_review_counts.dart';
import 'package:safini/features/prizes/prize.dart';

ParentTaskInstanceModel _task({
  required String id,
  required String childId,
  String status = 'submitted',
}) => ParentTaskInstanceModel(id: id, status: status, childId: childId);

PrizeRequest _ask({
  required String id,
  required String childId,
  PrizeRequestStatus status = PrizeRequestStatus.pending,
}) => PrizeRequest(
  id: id,
  childId: childId,
  kind: PrizeRequestKind.buy,
  status: status,
  title: 'Lego',
  coinCost: 10,
);

void main() {
  group('pendingReviewCountForChild', () {
    test('counts submitted tasks and pending asks for that child only', () {
      final tasks = [
        _task(id: 't1', childId: 'amir'),
        _task(id: 't2', childId: 'amir'),
        _task(id: 't3', childId: 'layla'),
        _task(id: 't4', childId: 'amir', status: 'active'),
      ];
      final asks = [
        _ask(id: 'p1', childId: 'amir'),
        _ask(id: 'p2', childId: 'layla'),
        _ask(id: 'p3', childId: 'amir', status: PrizeRequestStatus.approved),
      ];

      expect(
        pendingReviewCountForChild(childId: 'amir', tasks: tasks, asks: asks),
        3,
      );
      expect(
        pendingReviewCountForChild(childId: 'layla', tasks: tasks, asks: asks),
        2,
      );
    });

    test('is 0 when that child has nothing waiting', () {
      expect(
        pendingReviewCountForChild(
          childId: 'zilola',
          tasks: [_task(id: 't1', childId: 'amir')],
          asks: [_ask(id: 'p1', childId: 'layla')],
        ),
        0,
      );
    });
  });

  group('otherChildrenPendingReviewCount', () {
    test('excludes the selected child', () {
      expect(
        otherChildrenPendingReviewCount(
          selectedChildId: 'amir',
          pendingByChild: {'amir': 5, 'layla': 2, 'frka': 1},
        ),
        3,
      );
    });

    test('is 0 when only the selected child has pending items', () {
      expect(
        otherChildrenPendingReviewCount(
          selectedChildId: 'amir',
          pendingByChild: {'amir': 4, 'layla': 0},
        ),
        0,
      );
    });
  });

  group('attentionBadgeLabel', () {
    test('hides at 0', () {
      expect(attentionBadgeLabel(0), isNull);
      expect(attentionBadgeLabel(-1), isNull);
    });

    test('caps at 9+', () {
      expect(attentionBadgeLabel(9), '9');
      expect(attentionBadgeLabel(10), '9+');
      expect(attentionBadgeLabel(99), '9+');
    });

    test('prints the count from 1 through 9', () {
      expect(attentionBadgeLabel(1), '1');
      expect(attentionBadgeLabel(8), '8');
    });
  });
}
