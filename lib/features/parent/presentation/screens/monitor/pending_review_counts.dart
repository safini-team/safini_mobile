import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/prizes/prize.dart';

/// How many items wait on the parent for [childId]: submitted tasks plus
/// open prize asks and wishes. Tasks with no `childId` cannot be attributed
/// to another kid, so they are skipped here (Today already shows the selected
/// child's own queue in "Needs your review").
int pendingReviewCountForChild({
  required String childId,
  required Iterable<ParentTaskInstanceModel> tasks,
  required Iterable<PrizeRequest> asks,
}) {
  var count = 0;
  for (final task in tasks) {
    if (task.isPendingApproval && task.childId == childId) count++;
  }
  for (final ask in asks) {
    if (ask.isPending && ask.childId == childId) count++;
  }
  return count;
}

/// Chip total: every child's pending count except the one already on screen.
int otherChildrenPendingReviewCount({
  required String selectedChildId,
  required Map<String, int> pendingByChild,
}) {
  var total = 0;
  for (final entry in pendingByChild.entries) {
    if (entry.key == selectedChildId) continue;
    total += entry.value;
  }
  return total;
}
